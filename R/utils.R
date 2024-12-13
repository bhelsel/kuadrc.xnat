
# Try to guess view based on folder name
guess_view <- function(files){
  folders <- dirname(files)
  planes <- rep("", length(files))
  planes[grep("AX_|Axial", folders)] <- "axial"
  planes[grep("Sagittal", folders)] <- "sagittal"
  planes[grep("Coronal", folders)] <- "coronal"
  return(planes)
}

# A wrapper to oro.nifti::readNIfTI
read_nifti <- function(file){
  data <- oro.nifti::readNIfTI(file)
  return(data)
}


# A simple function to remove all the .dcm files after converted to .nii
remove_dcm_files <- function(directory){
  unlink(file.path(directory, "scans"), recursive = TRUE)
}

# A simple function to remove all the .nii files plots
remove_nii_files <- function(directory){
  unlink(file.path(directory, "nifti"), recursive = TRUE)
}



unzip_xnat_files <- function(outdir, zip_file){
  # Retrieve dcm files within the zip files
  fileList <- utils::unzip(zip_file, list = TRUE)$Name
  dcmScan <- fileList[grep(".*DICOM", fileList)]
  # Unzip only the dcm files
  dcmScanFiles <- utils::unzip(zip_file, exdir = outdir, files = dcmScan)
  # Copy the files to the top level scan directory
  new_loc <- gsub("resources/DICOM/files/", replacement = "", dcmScan)
  file.copy(from = file.path(outdir, dcmScan), to = file.path(outdir, new_loc))
  # Remove the old files and directories that are no longer needed
  file.remove(file.path(outdir, dcmScan))
  unlink(file.path(outdir, unique(gsub("DICOM/files", "", dirname(dcmScan)))), recursive = TRUE)
  # Remove the zip file
  file.remove(zip_file)
}