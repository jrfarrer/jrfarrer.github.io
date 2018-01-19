# ---------------------------------------------
# Filename:     Sync Canvas Files
# Author:       Jordan Farrer
# Date Created: 2018-01-16
# ---------------------------------------------

# ---------------------------------------------
# Modify these paths
# ---------------------------------------------
sync_canvas_dir <- '/Users/jordanfarrer/Dropbox/Projects/sync_canvas'
file_dir <- '/Users/jordanfarrer/Dropbox/Wharton/Spring 2018/'

# ---------------------------------------------
#
# !!
# DO NOT CHANGE ANYTHING BELOW
# !!
#
# ---------------------------------------------

# ---------------------------------------------
# Sets the Canvas API path
# Access the API token in .Renviron
# ---------------------------------------------
canvas_api <- 'https://canvas.instructure.com/api/v1/'
access_token <- Sys.getenv("CANVAS_TOKEN")

# ---------------------------------------------
# Loads the two required packages
# ---------------------------------------------
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(tidyverse))

# ---------------------------------------------
# Load the course list to synced and 
# add the prefix to each of the course IDs
# ---------------------------------------------
courses <- 
  read_csv(file.path(sync_canvas_dir, "course_list.csv")) %>%
  mutate(course_id = paste0("25000000", course_id))

# ---------------------------------------------
# Function that builds the folder structure
# for each course
# ---------------------------------------------
folder_structure <- function(course_name, course_id) {
  folder_url <- paste0(canvas_api, 'courses/', course_id, '/folders?access_token=', access_token, '&per_page=100000')
  
  course_folders <-
    fromJSON(folder_url) %>% 
    as_tibble() %>%
    arrange(id) %>%
    mutate(
        folder_id = as.character(id)
      , folder_path = str_replace(full_name, 'course files', '')
    ) %>%
    select(folder_id, folder_path)
  
  walk(pull(course_folders, folder_path), function(x) {
    dir.create(file.path(file_dir, course_name, x), showWarnings = FALSE, recursive = TRUE)  
  })
    
  return(course_folders)
}

# ---------------------------------------------
# Function that gets information about each
# file for each course: file_id, file_name,
# file_size, and the file_url for downloading
# ---------------------------------------------
get_files_in_folder <- function(course_name, folder_id, folder_path) {
  folder_files_url <- paste0(canvas_api, 'folders/', folder_id, '/files?access_token=', access_token, '&per_page=100000')
  folder_files <- fromJSON(folder_files_url) %>% as_tibble()
  
  if(nrow(folder_files) != 0) {
    folder_files %>%
      mutate(file_id = as.character(id)) %>%
      select(file_id, file_name = display_name, size, file_url = url)
  } else{
    folder_files
  }
}

# ---------------------------------------------
# Function that downloads each file if it
# (1) does not exist or (2) exists but is a
# different file size
# ---------------------------------------------
download_file <- function(course_name, folder_path, file_name, file_url, size) {
  full_file_path <- file.path(file_dir, course_name, folder_path, file_name)
  
  # Download if file does not exist or if the file size is not the same
  if(!(file.exists(full_file_path) && file.size(full_file_path) == size)) {
    download.file(file_url, destfile = full_file_path, method = 'auto', quiet = TRUE)
    return(TRUE)
  } else{
    return(FALSE)
  }
}

# ---------------------------------------------
# Uses each function to gather the folder
# structure, the files to download, and 
# then performs the downloading
# Returns a data frame where each row represents
# each file in Canvas files
# ---------------------------------------------
download_log <- 
  courses %>%
  mutate(folder_structure = map2(course_name, course_id, folder_structure)) %>%
  unnest() %>%
  mutate(files_in_folder = pmap(list(course_name, folder_id, folder_path), get_files_in_folder)) %>%
  unnest() %>%
  mutate(downloaded = pmap_lgl(list(course_name, folder_path, file_name, file_url, size), download_file))

# ---------------------------------------------
#
# All code below relates only to logging
#
# ---------------------------------------------

# ---------------------------------------------
# Find only the files that were were downloaded
# ---------------------------------------------
files_downloaded <-
  download_log %>%
  filter(downloaded) %>%
  mutate(run_time = Sys.time()) %>%
  select(run_time, course_name, folder_path, file_name)

# ---------------------------------------------
# If no files downloaded, created a data frame
# skeleton that includes the run_time
# ---------------------------------------------
if(nrow(files_downloaded) == 0) {
  files_downloaded <- tribble(
    ~run_time, ~course_name, ~folder_path, ~file_name
    , Sys.time(), "", "", ""
  )
}

# ---------------------------------------------
# Get the current download log, if one does
# not yet exist, create the structure for
# one
# ---------------------------------------------
if (file.exists(file.path(sync_canvas_dir, "sync_canvas_log.csv"))) {
  current_log <- read_csv(file.path(sync_canvas_dir, "sync_canvas_log.csv"))
} else {
  current_log <- tribble(~run_time, ~course_name, ~folder_path, ~file_name)
}

# ---------------------------------------------
# Put the most recently downloaded files on
# top of previously downloaded ones and 
# export the log
# ---------------------------------------------
bind_rows(
  files_downloaded
  , current_log
) %>%
write_csv(file.path(sync_canvas_dir, "sync_canvas_log.csv"))