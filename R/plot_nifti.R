#' @title plot_nifti
#' @description Uses ggplot2 to produce a plot containing the .nii image and center of mass
#' @param nifti_data Data set from a .nii file read in by the `read_nifti` function
#' @param plane The plane to be displayed, Default: c("axial", "sagittal", "coronal")
#' @param index The slice to be displayed, Default: NULL
#' @param n_gray Number of grayscale colors to display, Default: 64
#' @param adjust_brightness Manually adjust brightness by multiplying by this factor, Default: 1
#' @return A ggplot object of the brain image and its center
#' @details Uses ggplot2 to produce a plot containing the .nii image and center of mass
#' @seealso 
#'  \code{\link[oro.nifti]{cal_min-methods}}, \code{\link[oro.nifti]{cal_max-methods}}
#'  \code{\link[ggplot2]{coord_fixed}}, \code{\link[ggplot2]{element}}
#' @rdname plot_nifti
#' @export 
#' @importFrom ggplot2 ggplot aes geom_tile scale_fill_gradientn coord_fixed theme element_rect element_blank
#' @importFrom oro.nifti cal.min cal.max
#' @importFrom grDevices gray

plot_nifti <- function(nifti_data, plane = c("axial", "sagittal", "coronal"), 
                       index = NULL, n_gray = 64, adjust_brightness = 1){

  plane <- match.arg(plane, c("axial", "sagittal", "coronal"))
  
  # Sagittal (X-axis slices); Coronal (Y-axis slices); Axial (Z-axis slices)
  
  # Start code from oro.nifti:::image.nifti function
  switch(plane[1], axial = {
    aspect <- nifti_data@pixdim[3]/nifti_data@pixdim[2]
  }, coronal = {
    nifti_data@.Data <- aperm(nifti_data, c(1, 3, 2))
    aspect <- nifti_data@pixdim[4]/nifti_data@pixdim[2]
  }, sagittal = {
    nifti_data@.Data <- aperm(nifti_data, c(2, 3, 1))
    aspect <- nifti_data@pixdim[4]/nifti_data@pixdim[3]
  }, stop(paste("Orthogonal plane", plane[1], "is not valid.")))
  # End code from oro.nifti:::image.nifti function
  
  if(is.null(index)){
    index <- which.max(apply(nifti_data, 3, sum))
    message(
      sprintf("This slice is %i of %i.", index, dim(nifti_data)[3]),
      "\nYou can change the slice manually using the index argument within the plot_nifti function."
    )
  } else if(is.numeric(index)){
    index <- as.integer(index)
    message(sprintf("This slice is %i of %i.", index, dim(nifti_data)[3]))
  }

  zlim <- c(oro.nifti::cal.min(nifti_data), oro.nifti::cal.max(nifti_data))

  breaks <- c(zlim[1], seq(min(zlim), max(zlim), length = n_gray - 1), zlim[2])
  
  colors <- grDevices::gray(seq(from = 0, to = 1, length = n_gray))
  
  plot_data <- expand.grid(x = 1:nrow(nifti_data), y = 1:ncol(nifti_data))
  
  plot_data$intensity <- as.vector(nifti_data[, , index])
  
  p <- 
    ggplot2::ggplot(plot_data, ggplot2::aes(x = x, y = y, fill = intensity*adjust_brightness)) +
    ggplot2::geom_tile() +
    ggplot2::scale_fill_gradientn(colors = colors, breaks = breaks, limits = range(breaks)) +
    ggplot2::coord_fixed(ratio = aspect) +
    ggplot2::theme(legend.position = "none",
                   panel.background = ggplot2::element_rect(fill = "black"),
                   axis.title = ggplot2::element_blank(),
                   axis.text = ggplot2::element_blank(),
                   axis.ticks = ggplot2::element_blank(),
                   panel.grid.major = ggplot2::element_blank(),
                   panel.grid.minor = ggplot2::element_blank())
  return(p)
}




