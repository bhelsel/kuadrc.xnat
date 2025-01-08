#' @title convert_to_nifti
#' @description Reads in .dcm files and converts them to .nii
#' @param directory The location of the scans folder as downloaded with the `xnat_download` function.
#' @return  A character value containing the location of the nifti files
#' @details Reads in .dcm files and converts them to .nii
#' @seealso 
#'  \code{\link[oro.dicom]{readDICOM}}, \code{\link[oro.dicom]{dicom2nifti}}
#'  \code{\link[oro.nifti]{writeNIfTI-methods}}
#' @rdname convert_to_nifti
#' @export 
#' @importFrom oro.dicom readDICOM dicom2nifti
#' @importFrom oro.nifti writeNIfTI

convert_to_nifti <- function(directory){

  niftidir <- file.path(directory, "nifti")
  
  files <- list.files(directory, recursive = TRUE, full.names = TRUE, pattern = "dcm$")
  
  directories <- basename(unique(dirname(files)))
  
  if(any(grepl("1-localizer", directories))){
    directories <- directories[-which(directories == "1-localizer")]  
  }
  
  scan_types <- gsub("[0-9]-", "", directories)
  
  for(d in 1:length(directories)){
    f <- file.path(directory, "scans", directories[d])
    cat(
      "\r", paste(rep(" ", 100), collapse = ""), 
      "\rConverting image from dicom to nifti: ", scan_types[d], " (", d, "/", length(directories), " complete)",
      sep = ""
      )
    dicomData <- oro.dicom::readDICOM(f)
    niftiData <- oro.dicom::dicom2nifti(dicomData) # Convert to nifti-like format
    idlab <- strsplit(basename(directory), "_")[[1]]
    slab <- gsub("[0-9]-", "", directories[d])
    if(!dir.exists(niftidir)) dir.create(file.path(directory, "nifti"))
    if(!dir.exists(file.path(niftidir, directories[d]))) dir.create(file.path(directory, "nifti", directories[d]))
    fn <- file.path(niftidir, directories[d], sprintf("%s_%s_%s_%s", idlab[1], idlab[2], idlab[3], slab))
    oro.nifti::writeNIfTI(niftiData, filename = fn)
  }
  return(invisible(niftidir))
}
