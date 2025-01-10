#' Plot cross section of lasfile
#'
#' This function plots a cross section and a map of the cross section over the
#' bounding polygon(s) of the las or lasCatalog colors are automatically
#' assigned to the point classification
#'
#' @param las can be las file or lasCatalog
#' @param p1 starting point of cross section(x and y). If missing, then
#'   automatically choose cross section location
#' @param p2 ending point of cross section (x and y). If missing, then
#'   automatically choose cross section location
#' @param transect_len, length of the transect. If not specified, the entire
#'   extent of the lasfile is used, which may result in a very long cross
#'   section.
#' @param width cross section transect width
#' @param title plot title
#'
#' @return
#' @export
#'
#' @examples
plot_cross <- function(las,
                       p1,
                       p2,
                       transect_len,
                       width = 4,
                       title = NULL
)
{

  if(any(c(missing(p1),missing(p2)))){
    if(class(las) == "LAS"){
      p1 <- c(min(las@data$X), mean(las@data$Y))
      p2 <- c(max(las@data$X), mean(las@data$Y))
    }else if(class(las) == "LAScatalog"){
      p1 <- c(min(las@data$Min.X), mean(las@data$Min.Y))
      p2 <- c(max(las@data$Max.X), mean(las@data$Max.Y))
    }
  }

  if(!missing(transect_len)){
    ctr <- c(mean(p1[1],p2[1]),mean(p1[2],p2[2]))
    slope <- (p2[2]-p1[2])/(p2[1]-p1[1])
    x_off <- sqrt((transect_len^2)/(1+slope^2))
    y_off <- slope*x_off
    p1 <- c(ctr[1]-x_off, ctr[2]-y_off)
    p2 <- c(ctr[1]+x_off, ctr[2]+y_off)
  }

  data_clip <- clip_transect(las, p1, p2, width)

  cols <- c("1" = "gray", "2" = "purple", "18" = "orange")

  p <- ggplot(data_clip@data %>% mutate(Classification = as.character(Classification)),
              aes(X,Z, color = Classification)) +
    geom_point(size = 0.5) +
    coord_equal() + theme_minimal() +
    scale_color_manual(values = cols) +
    theme(legend.position.inside = c(0.9,0.9))

  if(!is.null(title)){
    p <- p + ggtitle(title)
  }

  p
}
