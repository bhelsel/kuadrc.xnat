#' @title save_nifti_image
#' @description Saves images after plotting with the `plot_nifti` function. This is
#'     convenience function to loop through all the .nii images in folder to plot and save
#'     the images as `image_type`.
#' @param path The location of a nifti file or folder as created with the `convert_to_nifti` function.
#' @param image_type The type of image to include as the extension, Default: 'png'
#' @param width Plot width in inches or other units passed to `...`, Default: 8.5
#' @param height Plot height in inches or other units passed to `...`, Default: 11
#' @param dpi Plot resolution, Default: 300
#' @param plane The plane to be displayed, Default: c("axial", "sagittal", "coronal")
#' @param save_file_as An option to change the file to a name other than what was downloaded from xnat
#' @param ... Other arguments passed on to the `plot_nifti` function
#' @return OUTPUT_DESCRIPTION
#' @details Saves images after plotting with the `plot_nifti` function. This is
#'     convenience function to loop through all the .nii images in folder to plot and save
#'     the images as `image_type`. It uses the same folder structure as retrieved from
#'     the `xnat_download` function.
#' @seealso
#'  \code{\link[ggplot2]{ggsave}}
#' @rdname save_nifti_image
#' @export
#' @importFrom ggplot2 ggsave

# Can eventually make this an S3 generic to handle the nifti data format
save_nifti_image <- function(
  path = NULL,
  image_type = "png",
  width = 8.5,
  height = 11,
  dpi = 300,
  plane = c("", "axial", "sagittal", "coronal"),
  save_file_as = NULL,
  ...
) {
  plane <- match.arg(plane, c("", "axial", "sagittal", "coronal"))

  if (grepl("nii.gz$", path)) {
    if (grepl("nifti", path)) {
      files <- path
    }
  } else if (dir.exists(path)) {
    files <- list.files(
      path,
      recursive = TRUE,
      full.names = TRUE,
      pattern = "nii.gz$"
    )
  }

  directory <- strsplit(x = files[1], "/nifti")[[1]][1]
  if (!dir.exists(file.path(directory, "images"))) {
    dir.create(file.path(directory, "images"))
  }
  image_files <- gsub("nifti", "images", gsub("nii.gz$", image_type, files))

  for (i in 1:length(image_files)) {
    if (plane == "") {
      plane <- guess_view(files)[i]
    }
    if (!dir.exists(dirname(image_files[i]))) {
      dir.create(dirname(image_files[i]))
    }
    data <- read_nifti(files[i])
    p <- plot_nifti(data, plane = plane, ...)
    if(!is.null(save_file_as)){
      save_file_as <- file.path(dirname(image_files[1]), save_file_as)
    }
      
    ggplot2::ggsave(
      filename = ifelse(!is.null(save_file_as), save_file_as, image_files[i]),
      plot = p,
      width = width,
      height = height,
      dpi = dpi
    )
  }
}
