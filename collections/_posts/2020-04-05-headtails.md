---
title: "Head/tail breaks in the <strong>classInt</strong> package"
tags:
  - r_bloggers
  - rstats
  - rspatial
  - classInt
  - r_package
header_type: "splash"
header_img: ./assets/img/blog/20200405_finalplot-1.webp
show_toc: true
mathjax: true
output:
  md_document:
    variant: gfm
    preserve_yaml: true
last_modified_at: 2026-10-07
excerpt: "Explore head/tail breaks classification with classInt and a spatial case study."
---

<blockquote class="blockquote">
  <p class="small font-italic">There are far more ordinary people (say, 80 percent) than extraordinary people (say, 20 percent), and this is often characterized by the 80/20 principle, based on the observation made by the Italian economist Vilfredo Pareto in 1906 that 80% of land in Italy was owned by 20% of the population. A histogram of the data values for these phenomena would reveal a right-skewed or heavy-tailed distribution. How to map the data with the heavy-tailed distribution?</p>
  <footer class="blockquote-footer text-right">Jiang (2013)</footer>
</blockquote>

## Abstract

This vignette discusses the implementation of the "Head/tail breaks" style
(Jiang (2013)) in the `classIntervals()` function from the **classInt** package.
A step-by-step example is presented to clarify the method. A case study using
`spData::afcon` is also included, making use of additional packages such as
**sf**.

**Historical example:** The mapping examples use **cartography**, which is now
in maintenance mode. Its maintainers recommend [**mapsf**](https://riatelab.github.io/mapsf/)
for new work. The original code and outputs are preserved and have not been
revalidated against current package versions.
{: .alert .alert-info .p-3 .mx-2 .mb-3 }

## Introduction

**Head/tail breaks** is a classification scheme introduced by Jiang (2013) for
revealing hierarchies in data with many small values and a few large ones.
The related **ht-index** measures the depth of this hierarchy, rather than
being another name for the classification method.

The distributions considered here are strongly right-skewed, with a minority
of large values in the head and a majority of small values in the tail. This
imbalance can be expressed as _"far more small things than large things"_.

Power-law and lognormal distributions are examples of heavy-tailed
distributions. The head/tail breaks literature also considers exponential
distributions under its broader description of this imbalance. Nature,
society and finance (Vasicek (2002)) provide examples of rare and extreme
events. Taleb (2008) discusses the impact of unexpected extreme events,
offering another reason to pay attention to low-frequency observations.

```r
library(classInt)

# 1. Characterization of heavy-tail distributions----
set.seed(1234)
# Pareto distribution a=1 b=1.161 n=1000
sample_par <- 1 / (1 - runif(1000))^(1 / 1.161)
opar <- par(no.readonly = TRUE)
par(mar = c(2, 4, 3, 1), cex = 0.8)
plot(
  sort(sample_par, decreasing = TRUE),
  type = "l",
  ylab = "F(x)",
  xlab = "",
  main = "80/20 principle"
)
abline(
  h = quantile(sample_par, .8),
  lty = 2,
  col = "red3"
)
abline(
  v = 0.2 * length(sample_par),
  lty = 2,
  col = "darkblue"
)
legend(
  "topleft",
  legend = c("F(x): p80", "x: Top 20%"),
  col = c("red3", "darkblue"),
  lty = 2,
  cex = 0.8
)

hist(
  sample_par,
  n = 100,
  xlab = "",
  main = "Histogram",
  col = "grey50",
  border = NA,
  probability = TRUE
)
par(opar)
```

![Ranked-value plot of a Pareto sample. Values fall steeply and then flatten, with reference lines marking the top 20 percent and the 80th percentile.](https://dieghernan.github.io/assets/img/blog/20200405_charheavytail-1.webp)![Histogram of a Pareto sample. Most values are small, with a long tail of rare large values.](https://dieghernan.github.io/assets/img/blog/20200405_charheavytail-2.webp)

## Breaking method

The method itself consists of a four-step process performed recursively until a
stopping condition is satisfied. Given a vector of values $$v = (a_1, a_2,
..., a_n) $$, the process can be described as follows:

1. Compute the arithmetic mean, $$\mu = \frac{1}{n}\sum_{i=1}^{n} a_i$$.
2. Break $$v$$ into the $$tail$$ and the $$head$$:
   $$tail = \{ a_x \in v | a_x \lt \mu \} $$
$$head = \{ a_x \in v | a_x \gt \mu \} $$.
3. Check whether the proportion of observations in the head is at most the
   chosen threshold:
   $$\frac{|head|}{|v|} \le threshold  $$
4. If step 3 is `TRUE` and the head contains at least two observations, replace
   $$v$$ with $$head$$ and repeat. Otherwise, stop.

Only values strictly above the mean enter the next iteration. Values equal to
the mean are not part of the head. Stopping does not require an exact 50/50
split.

A threshold of 40% provides a practical stopping rule. It is not a statistical
test for whether a distribution is heavy-tailed.

The final breaks are the vector of consecutive $$\mu$$:

$$ breaks = (\mu_1, \mu_2, \mu_3, ..., \mu_n ) $$

## Step-by-step example

We reproduce here the pseudo-code[^1] as per Jiang (2019):

```
Recursive function Head/tail Breaks:
 Rank the input data from the largest to the smallest
 Break the data into the head and the tail around the mean;
 // the head for those above the mean
 // the tail for those below the mean
 While (head <= 40%):
 Head/tail Breaks (head);
End Function
```

The following **R** example uses `prop < thr`, whereas the pseudocode above
uses `head <= 40%`. At exactly 40%, the R loop stops and the pseudocode
continues. This distinction does not affect the example below.

```r
opar <- par(no.readonly = TRUE)
par(mar = c(2, 2, 3, 1), cex = 0.8)
var <- sample_par
thr <- .4
brks <- c(min(var), max(var)) # Initialise with min and max

sum_table <- data.frame(
  iter = 0,
  mu = NA,
  prop = NA,
  n_var = NA,
  n_head = NA
)
# Pars for chart
limchart <- brks
# Iteration
for (i in 1:10) {
  mu <- mean(var)
  brks <- sort(c(brks, mu))
  head <- var[var > mu]
  prop <- length(head) / length(var)
  stopit <- prop < thr & length(head) > 1
  sum_table <- rbind(
    sum_table,
    c(i, mu, prop, length(var), length(head))
  )
  hist(
    var,
    main = paste0("Iter ", i),
    breaks = 50,
    col = "grey50",
    border = NA,
    xlab = "",
    xlim = limchart
  )
  abline(v = mu, col = "red3", lty = 2)
  ylabel <- max(hist(var, breaks = 50, plot = FALSE)$counts)
  labelplot <- paste0("PropHead: ", round(prop * 100, 2), "%")
  text(
    x = mu,
    y = ylabel,
    labels = labelplot,
    cex = 0.8,
    pos = 4
  )
  legend(
    "right",
    legend = paste0("mu", i),
    col = c("red3"),
    lty = 2,
    cex = 0.8
  )
  if (isFALSE(stopit)) {
    break
  }
  var <- head
}
par(opar)
```

![Histogram at step 1 of head/tail classification of a Pareto sample. A vertical line marks the mean used to separate the head from the tail.](https://dieghernan.github.io/assets/img/blog/20200405_stepbystep-1.webp)![Histogram at step 2 of head/tail classification of a Pareto sample. A vertical line marks the mean used to separate the head from the tail. Only values above the previous mean remain.](https://dieghernan.github.io/assets/img/blog/20200405_stepbystep-2.webp)![Histogram at step 3 of head/tail classification of a Pareto sample. A vertical line marks the mean used to separate the head from the tail. Only values above the previous mean remain.](https://dieghernan.github.io/assets/img/blog/20200405_stepbystep-3.webp)![Histogram at step 4 of head/tail classification of a Pareto sample. A vertical line marks the mean used to separate the head from the tail. Only values above the previous mean remain.](https://dieghernan.github.io/assets/img/blog/20200405_stepbystep-4.webp)

The head proportion varies across iterations and reaches 50% in the fourth,
which stops the loop. It does not increase monotonically.

| iter |       mu | prop   | n_var | n_head |
| ---: | -------: | :----- | ----: | -----: |
|    1 |   5.6755 | 14.5%  |  1000 |    145 |
|    2 |  27.2369 | 21.38% |   145 |     31 |
|    3 |  85.1766 | 19.35% |    31 |      6 |
|    4 | 264.7126 | 50%    |     6 |      3 |

The break vector includes the original minimum and maximum, plus the means
computed during the iterations. Here the original data are `sample_par`, since
`var` is replaced by the head inside the loop.

## Implementation in the **classInt** package

The implementation in `classIntervals()` reproduces these results:

```r
ht_sample_par <- classIntervals(sample_par, style = "headtails")
brks == ht_sample_par$brks
```

```
## [1] TRUE TRUE TRUE TRUE TRUE TRUE
```

As stated in Jiang (2013), the number of breaks is determined by the data.
However, the `thr` parameter can help adjust the final number. A lower value
of `thr` can yield fewer breaks, while a larger `thr` can increase the number if
the underlying distribution follows the _"far more small things than large
things"_ principle.

```r
opar <- par(no.readonly = TRUE)
par(mar = c(2, 2, 2, 1), cex = 0.8)

pal1 <- c("wheat1", "wheat2", "red3")
# Minimum: single break
print(paste("number of breaks", length(classIntervals(sample_par, style = "headtails", thr = 0)$brks - 1)))
plot(
  classIntervals(sample_par, style = "headtails", thr = 0),
  pal = pal1,
  main = "thr = 0"
)

# Two breaks
print(paste("number of breaks", length(classIntervals(sample_par, style = "headtails", thr = 0.2)$brks - 1)))
plot(
  classIntervals(sample_par, style = "headtails", thr = 0.2),
  pal = pal1,
  main = "thr = 0.2"
)

# Default breaks: 0.4
print(paste("number of breaks", length(classIntervals(sample_par, style = "headtails")$brks - 1)))
plot(classIntervals(sample_par, style = "headtails"),
  pal = pal1,
  main = "thr = Default"
)

# Maximum breaks
print(paste("number of breaks", length(classIntervals(sample_par, style = "headtails", thr = 1)$brks - 1)))
plot(
  classIntervals(sample_par, style = "headtails", thr = 1),
  pal = pal1,
  main = "thr = 1"
)
par(opar)
```

![Cumulative distribution of a Pareto sample classified with a head/tail threshold of 0. Vertical lines and a colored strip indicate the resulting class intervals.](https://dieghernan.github.io/assets/img/blog/20200405_examplesimp-1.webp)![Cumulative distribution of a Pareto sample classified with a head/tail threshold of 0.2. Vertical lines and a colored strip indicate the resulting class intervals.](https://dieghernan.github.io/assets/img/blog/20200405_examplesimp-2.webp)![Cumulative distribution of a Pareto sample classified with a head/tail threshold of the default value. Vertical lines and a colored strip indicate the resulting class intervals.](https://dieghernan.github.io/assets/img/blog/20200405_examplesimp-3.webp)![Cumulative distribution of a Pareto sample classified with a head/tail threshold of 1. Vertical lines and a colored strip indicate the resulting class intervals.](https://dieghernan.github.io/assets/img/blog/20200405_examplesimp-4.webp)

For this example, even `thr = 0` retains the mean as an internal break.
The returned vector also contains the minimum and maximum, so this gives two
classes, not one.

## Case study

Jiang (2013) states that _\"the new classification scheme is more natural than
the natural breaks in finding the groupings or hierarchy for data with a
heavy-tailed distribution.\"_ (p. 482), referring to Jenks' natural breaks
method. In this case study, we compare `headtails` vs. `fisher`, which is the
alias for the Fisher-Jenks algorithm and is always preferred to the `jenks`
style (see `?classIntervals`). For this example, we will use the `afcon`
dataset from the **spData** package, plus some additional spatial information to
create the data visualization.

```r
library(spData)
data(afcon, package = "spData")
```

Let's have a look at the top 10 values and the distribution of the variable
`totcon` (index of total conflict 1966-78):

```r
# Top10
knitr::kable(head(afcon[order(afcon$totcon, decreasing = TRUE), c("name", "totcon")], 10))

opar <- par(no.readonly = TRUE)
par(mar = c(4, 4, 3, 1), cex = 0.8)
hist(afcon$totcon,
  n = 20,
  main = "Histogram",
  xlab = "totcon",
  col = "grey50",
  border = NA,
)
plot(
  density(afcon$totcon),
  main = "Distribution",
  xlab = "totcon",
)
par(opar)
```

![Histogram of total conflict counts in African countries from 1966 to 1978. Most countries have low counts, with a few much higher values.](https://dieghernan.github.io/assets/img/blog/20200405_summspdata-1.webp)![Density curve of total conflict counts in African countries from 1966 to 1978, with a peak at low counts and a long right tail.](https://dieghernan.github.io/assets/img/blog/20200405_summspdata-2.webp)

The values for Egypt (EG) and Sudan (SU) stand out from the rest. The histogram
shows a strongly right-skewed pattern with many small values and a few large
ones.

In addition to `headtails` and `fisher`, we use `quantile` to compare the
classification styles. Quantile breaks are based on ranks rather than the
size of the gaps between observations.

Applying the three aforementioned methods to break the data:

```r
brks_ht <- classIntervals(afcon$totcon, style = "headtails")
print(brks_ht)
# Same number of classes for "fisher"
nclass <- length(brks_ht$brks) - 1
brks_fisher <- classIntervals(afcon$totcon,
  style = "fisher",
  n = nclass
)
print(brks_fisher)

brks_quantile <- classIntervals(afcon$totcon,
  style = "quantile",
  n = nclass
)
print(brks_quantile)

pal1 <- c("wheat1", "wheat2", "red3")
opar <- par(no.readonly = TRUE)
par(mar = c(2, 2, 2, 1), cex = 0.8)
plot(brks_ht, pal = pal1, main = "headtails")
plot(brks_fisher, pal = pal1, main = "fisher")
plot(brks_quantile, pal = pal1, main = "quantile")
par(opar)
```

![Cumulative distribution of African conflict counts classified using head/tail breaks. Vertical lines and a colored strip identify the class intervals.](https://dieghernan.github.io/assets/img/blog/20200405_breaksample-1.webp)![Cumulative distribution of African conflict counts classified using Fisher breaks. Vertical lines and a colored strip identify the class intervals.](https://dieghernan.github.io/assets/img/blog/20200405_breaksample-2.webp)![Cumulative distribution of African conflict counts classified using quantile breaks. Vertical lines and a colored strip identify the class intervals.](https://dieghernan.github.io/assets/img/blog/20200405_breaksample-3.webp)

The top three classes of `headtails` contain five observations, whereas those
of `fisher` contain 13. In this example, `headtails` gives more detail at the
upper end of the distribution.

The next plot compares density estimates of the rescaled `totcon` values and
the class assignments from each method. The original values are rescaled to
`[1, nclass]` and shifted by -0.5 for the visual comparison.

```r
# Helper function to reescale values
help_reescale <- function(x, min = 1, max = 10) {
  r <- (x - min(x)) / (max(x) - min(x))
  r <- r * (max - min) + min
  return(r)
}
afcon$ecdf_class <- help_reescale(afcon$totcon,
  min = 1 - 0.5,
  max = nclass - 0.5
)
afcon$ht_breaks <- cut(afcon$totcon,
  brks_ht$brks,
  labels = FALSE,
  include.lowest = TRUE
)

afcon$fisher_breaks <- cut(afcon$totcon,
  brks_fisher$brks,
  labels = FALSE,
  include.lowest = TRUE
)

afcon$quantile_break <- cut(afcon$totcon,
  brks_quantile$brks,
  labels = FALSE,
  include.lowest = TRUE
)

opar <- par(no.readonly = TRUE)
par(mar = c(4, 4, 1, 1), cex = 0.8)
plot(
  density(afcon$ecdf_class),
  ylim = c(0, 0.8),
  lwd = 2,
  main = "",
  xlab = "class"
)
lines(density(afcon$ht_breaks), col = "darkblue", lty = 2)
lines(density(afcon$fisher_breaks), col = "limegreen", lty = 2)
lines(density(afcon$quantile_break),
  col = "red3",
  lty = 2
)
legend("topright",
  legend = c(
    "Continuous", "headtails",
    "fisher", "quantile"
  ),
  col = c("black", "darkblue", "limegreen", "red3"),
  lwd = c(2, 1, 1, 1),
  lty = c(1, 2, 2, 2),
  cex = 0.8
)
par(opar)
```

![Density curves comparing continuous African conflict counts with values classified using head/tail, Fisher and quantile breaks. The methods produce different distribution shapes.](https://dieghernan.github.io/assets/img/blog/20200405_benchmarkbreaks-1.webp)

In this example, the class assignments from `headtails` retain more of the
original imbalance. By contrast, `quantile` aims for similar numbers of
observations per class, regardless of the gaps between values.

We now compare the methods using proportional-symbol maps. Symbol size
represents `totcon`, while color distinguishes the classes.

The first map uses proportional symbols without class-based colors, providing
a reference for the three classified maps.

```r
library(sf)
library(giscoR)
library(cartography)

opar <- par(no.readonly = TRUE)

par(
  mfrow = c(2, 2),
  mar = c(1, 1, 1, 1),
  bg = "white"
)
africa <- gisco_get_countries(resolution = 60, region = "Africa", epsg = 3857)

afcon.sf <- st_as_sf(afcon, crs = 4326, coords = c("x", "y"))
afcon.sf <- st_transform(afcon.sf, st_crs(africa))
# afcon.sf <- st_join(africa[, "admin"], afcon.sf)
afcon.sf <- afcon.sf[order(afcon.sf$totcon), ]



# High granularity map
plot(st_geometry(africa), col = "grey80", border = NA)
propSymbolsLayer(
  afcon.sf,
  var = "totcon",
  inches = 0.2,
  col = adjustcolor("grey10", alpha.f = 0.5),
  border = NA
)
title(main = "High granularity map")

# Quantile

pal <- hcl.colors(5, palette = "inferno", alpha = 0.6)
plot(st_geometry(africa), col = "grey80", border = NA)
propSymbolsTypoLayer(
  afcon.sf,
  var = "totcon",
  inches = 0.2,
  col = pal,
  border = NA,
  legend.var.pos = "n",
  legend.var2.pos = "bottomleft",
  var2 = "quantile_break"
)
title(main = "Quantile")


# Fisher
plot(st_geometry(africa), col = "grey80", border = NA)
propSymbolsTypoLayer(
  afcon.sf,
  var = "totcon",
  inches = 0.2,
  col = pal,
  border = NA,
  legend.var.pos = "n",
  legend.var2.pos = "bottomleft",
  var2 = "fisher_breaks"
)
title(main = "Fisher")

# Head Tails
plot(st_geometry(africa), col = "grey80", border = NA)
propSymbolsTypoLayer(
  afcon.sf,
  var = "totcon",
  inches = 0.2,
  col = pal,
  border = NA,
  legend.var.pos = "n",
  legend.var2.pos = "bottomleft",
  var2 = "ht_breaks"
)
title(main = "Head Tails")
par(opar)
```

![Four proportional-symbol maps of African conflict counts comparing the unclassified data with quantile, Fisher and head/tail classifications. Circle size represents conflict counts and colors distinguish classes.](https://dieghernan.github.io/assets/img/blog/20200405_finalplot-1.webp)

Compared with the unclassified proportional-symbol map, `headtails` makes
the most extreme values easier to distinguish. The `quantile` style groups
observations by rank, while `fisher` provides an intermediate view in this
example.

It is also important to note that `headtails` and `fisher` reveal different
information that can be useful depending on the context. While `headtails`
highlights the outliers, it fails to provide good clustering on the tail, while
`fisher` seems to reflect these patterns better. This can be observed in the
values of Western Africa and the Niger River Basin, where `headtails` does not
highlight any special cluster of conflicts, while `fisher` suggests a
potential cluster consistent with the unclassified map. This can be
confirmed in the histogram generated previously, where a concentration of
`totcon` around 1,000 is visible.

## References

Jiang, Bin. 2013. \"Head/Tail Breaks: A New Classification Scheme for Data with a Heavy-Tailed Distribution.\" _The Professional Geographer_ 65 (3): 482–94. [DOI](https://doi.org/10.1080/00330124.2012.700499).

———. 2019. \"A Recursive Definition of Goodness of Space for Bridging the Concepts of Space and Place for Sustainability.\" _Sustainability_ 11 (15): 4091. [DOI](https://doi.org/10.3390/su11154091).

Jiang, Bin, Xintao Liu, and Tao Jia. 2013. \"Scaling of Geographic Space as a Universal Rule for Map Generalization.\" _Annals of the Association of American Geographers_ 103 (4): 844–55. [DOI](https://doi.org/10.1080/00045608.2013.765773).

Jiang, Bin, and Junjun Yin. 2013. \"Ht-Index for Quantifying the Fractal or Scaling Structure of Geographic Features.\" _Annals of the Association of American Geographers_ 104 (3): 530–40. [DOI](https://doi.org/10.1080/00045608.2013.834239).

Taleb, Nassim Nicholas. 2008. _The Black Swan: The Impact of the Highly Improbable._ 1st ed. London: Random House.

Vasicek, Oldrich. 2002. \"Loan Portfolio Value.\" _Risk_, December, 160–62.

[^1]: The method implemented in **classInt** corresponds to head/tail breaks
    1.0, as named in this article.
