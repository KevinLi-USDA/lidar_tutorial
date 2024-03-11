#' Plot cross section transect
#'
#' @param a lasCatalog
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
plot_transect <- function(lasCatalog,
                          p1,
                          p2,
                          transect_len,
                          width = 4,
                          title = NULL
){

  if(class(lasCatalog)!="LASCATALOG"){
    stop("Must be lasCatalog",call. = FALSE)
  }

  if(any(c(missing(p1),missing(p2)))){
    if(class(lasCatalog) == "LAS"){
      p1 <- c(min(lasCatalog@data$X), mean(lasCatalog@data$Y))
      p2 <- c(max(lasCatalog@data$X), mean(lasCatalog@data$Y))
    }else if(class(lasCatalog) == "LAScatalog"){
      p1 <- c(min(lasCatalog@data$Min.X), mean(lasCatalog@data$Min.Y))
      p2 <- c(max(lasCatalog@data$Max.X), mean(lasCatalog@data$Max.Y))
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

  transectline <- matrix(c(p1, p2), byrow = TRUE, ncol = 2,
                         dimnames = list(c("p1", "p2"),c("x","y"))) %>%
    as_tibble() %>% sf::st_as_sf(coords = c("x","y")) %>%
    mutate(lineid = 1) %>% group_by(lineid) %>% summarize() %>%
    sf::st_cast("LINESTRING") %>% sf::st_set_crs(st_crs(lasCatalog))

  ggplot(lasCatalog$geometry) + geom_sf() + geom_sf(data = transectline) + theme_minimal()
}
