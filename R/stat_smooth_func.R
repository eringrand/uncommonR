#' @title stat_smooth_func
#' @export
#' @description mostly taken from https://stackoverflow.com/questions/7549694/adding-regression-line-equation-and-r2-on-graph

#' @param mapping mapping
#' @param data data
#' @param geom geom
#' @param position pos
#' @param ... extra
#' @param method method
#' @param formula form
#' @param se se
#' @param n n
#' @param span span
#' @param fullrange full
#' @param level lev
#' @param method.args x
#' @param na.rm na.rm
#' @param show.legend y
#' @param inherit.aes z
#' @param xpos a
#' @param ypos b
#'
#' @examples
#' library(dplyr)
#' library(ggplot2)
#' iris %>%
#'   ggplot(aes(x = Sepal.Width, y = Petal.Width, color = Species)) +
#'   geom_point() +
#'   stat_smooth_func(geom = "text", method = "lm", parse = TRUE, hjust = 0) +
#'   facet_wrap(~Species)


stat_smooth_func <- function(mapping = NULL,
                             data = NULL,
                             geom = "smooth",
                             position = "identity",
                             ...,
                             method = "auto",
                             formula = y ~ x,
                             se = TRUE,
                             n = 80,
                             span = 0.75,
                             fullrange = FALSE,
                             level = 0.95,
                             method.args = list(),
                             na.rm = FALSE,
                             show.legend = NA,
                             inherit.aes = TRUE,
                             xpos = NULL,
                             ypos = NULL) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = StatSmoothFunc,
    geom = geom,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      method = method,
      formula = formula,
      se = se,
      n = n,
      fullrange = fullrange,
      level = level,
      na.rm = na.rm,
      method.args = method.args,
      span = span,
      xpos = xpos,
      ypos = ypos,
      ...
    )
  )
}


StatSmoothFunc <- ggplot2::ggproto(
  "StatSmooth", ggplot2::Stat,
  setup_params = function(data, params) {
    # Figure out what type of smoothing to do: loess for small datasets,
    # gam with a cubic regression basis for large data
    # This is based on the size of the _largest_ group.
    if (identical(params$method, "auto")) {
      max_group <- max(table(data$group))

      if (max_group < 1000) {
        params$method <- "loess"
      } else {
        params$method <- "gam"
        params$formula <- y ~ s(x, bs = "cs")
      }
    }
    if (identical(params$method, "gam")) {
      params$method <- mgcv::gam
    }

    params
  },

  compute_group = function(data, scales, method = "auto", formula = y ~ x,
                             se = TRUE, n = 80, span = 0.75, fullrange = FALSE,
                             xseq = NULL, level = 0.95, method.args = list(),
                             na.rm = FALSE, xpos = NULL, ypos = NULL) {
    if (length(unique(data$x)) < 2) {
      # Not enough data to perform fit
      return(data.frame())
    }

    if (is.null(data$weight)) data$weight <- 1

    if (is.null(xseq)) {
      if (is.integer(data$x)) {
        if (fullrange) {
          xseq <- scales$x$dimension()
        } else {
          xseq <- sort(unique(data$x))
        }
      } else {
        if (fullrange) {
          range <- scales$x$dimension()
        } else {
          range <- range(data$x, na.rm = TRUE)
        }
        xseq <- seq(range[1], range[2], length.out = n)
      }
    }
    # Special case span because it's the most commonly used model argument
    if (identical(method, "loess")) {
      method.args$span <- span
    }

    if (is.character(method)) method <- match.fun(method)

    base.args <- list(quote(formula), data = quote(data), weights = quote(weight))
    model <- do.call(method, c(base.args, method.args))

    m <- model

        eq <- substitute(
      italic(r)^2 ~ "=" ~ r2,
      list(r2 = format(summary(m)$r.squared, digits = 3))
    )
    func_string <- as.character(as.expression(eq))

    if (is.null(xpos)) xpos <- min(data$x) * 0.95
    if (is.null(ypos)) ypos <- max(data$y) * 0.95
    data.frame(x = xpos, y = ypos, label = func_string)
  },

  required_aes = c("x", "y")
)
