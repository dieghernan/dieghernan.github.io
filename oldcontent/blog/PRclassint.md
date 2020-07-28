---
layout: post
title: "Head/Tails method on classIntervals"
subtitle: "Draft Vignette"
tags: [R,vignette]
date: 2020-03-22
permalink: /headtailsvignette/
output: github_document
---

# Head/Tails breaks

As an introductory remark, this method corresponds to "Head/tail breaks" 
as per Jiang (2013). On Jiang (2019) this method is named 
as 1.0 given that a 2.0 algorithm with 
more relaxed conditions is presented.

Full R script [on this gist](https://gist.github.com/dieghernan/0f4593cd74f53b1dfe70cb4f62385cf7).
Rendered `reprex` [on this gist](https://gist.github.com/dieghernan/def704dd13bf4fe68ee7d33e4e717edf).

On my computer (PC Windows 10) the full script 
run on 25 secs, including several tests and plots.


## Index

- [Motivation](#motivation)
- [Breaking method](#breaking-method)
- [Step by step example](#step-by-step)
- [Standalone version](#standalone-version)
- [Testing](#testing)
- [Case study](#case-study)
- [References](#references)
- [Annex: Test result](#test-results)

## Motivation
[*Taken from of Jiang (2013)* - brief summary]

> *"This paper introduces a new classification scheme – head/tail breaks – in order to find groupings or
hierarchy for data with a heavy-tailed distribution. The heavy-tailed distributions are heavily right
skewed, with a minority of large values in the head and a majority of small values in the tail,
commonly characterized by a power law, a lognormal or an exponential function." (...)*

> *"(...)This new classification scheme partitions all of the data values around the mean into two parts and 
continues the process iteratively for the values (above the mean) in the head until the head part
 values are no longer heavy-tailed distributed. Thus, the number of classes and the class intervals are both 
naturally determined."(...)*

> *"The heavy-tailed distribution is commonly found in many societal and
natural phenomena, including geographical systems. Small events are far more common in geographic
spaces than large events (Jiang 2010), particularly in urban, architectural environments (Salingaros
and West 1999, Jiang 2009). For example, there are far more small cities than large ones (Zipf 1949);
far more short streets than long ones (Jiang 2009); far more small city blocks than large ones, and far
more low-density areas than high-density ones (Jiang and Liu 2011). This is the pattern that underlies
geographic spaces and which should be reflected in the map. "*


##### *[Back to Index](#index)*
## Breaking method

The method itself consists on a four-step process performed recursively until a stopping condition is satisfied:
1. Compute the `mean` of a range of values `values`.
2. Break `values` into the `tail` (as `values < mean`) and the `head` (as `values > mean`).
3. Assess it the proportion of `head` over `values` is lower or equal than a given threshold (i.e. `length(head)/length(values) <= thresold`)
4. If 3 is `TRUE`, repeat 1 to 3 until the condition is `FALSE` or no more partitions are possible (i.e. `length(head) < 2`). 

It is important to note that, at the beginning of a new iteration, `values` are replaced by `head`. 
The underlying hypothesis is to create partitions until the `head` and the `tail` are balanced in terms of distribution.
So the stopping criteria is satisfied when the last `head` and the last `tail` are evenly balanced. 

In terms of threshold, Jiang et al. (2013) set 40% as a good approximation, meaning that if the `head` 
contains more than 40% of the observations the distribution is not considered heavy-tailed.

The final breaks are the vector of `mean` values.


##### *[Back to Index](#index)*
## Step by step
Pseudo-code as per Jiang (2019):
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

A step-by-step example in **R** (for illustrative purposes):

```r
#1. Characterization of heavy-tail distributions----
set.seed(1234)
#Pareto distribution a=2 b=6 n=1000
sample_par <- 2 / (1 - runif(1000)) ^ (1 / 6)
```
![](https://i.imgur.com/pw6McvG.png)

```r
#2. Step by step example----
set.seed(1234)
sample_par <- 2 / (1 - runif(1000)) ^ (1 / 6)
var <- sample_par
thr <- 0.35 #Cherry-picked thresold  for the example

#Step1
mu0 <- mean(var)
#The breaks are the means of the head
breaks <- c(mu0)
n0 <- length(var)
head0 <- var[var > mu0]
prop0 <- length(head0) / n0
```

![](https://i.imgur.com/bLXniiu.png)

``` r
prop0 <= thr &
  n0 > 1 #Additional control to stop if no more breaks are possible
#> [1] TRUE


#The process is iterative through the head, i.e, now var <- head0
var <- head0

#Iter2
mu1 <- mean(var)
#Add the break
breaks <- c(breaks, mu1)
n1 <- length(var)
head1 <- var[var > mu1]
prop1 <- length(head1) / n1
```

![](https://i.imgur.com/wt9KwiL.png)

``` r
prop1 <= thr  & n1 > 1
#> [1] FALSE

# End given that condition is FALSE
```

| iter|    n| nhead|       mu|  prophead|   breaks|
|----:|----:|-----:|--------:|---------:|--------:|
|    1| 1000|   316| 2.422568| 0.3160000| 2.422568|
|    2|  316|   118| 2.971249| 0.3734177| 2.971249|


##### *[Back to Index](#index)*
## Standalone version

This is the function to be implemented. Comments are likely to be removed.

``` r
 
#3. Standalone function----
# Default thresold = 0.4 as per Jiang et al. (2013)


ht_index <- function(var, style = "headtails", ...) {
  if (style == "headtails") {
    # Contributed Diego Hernangomez
    dots <- list(...)
    thr <- ifelse(is.null(dots$thr),
                 .4,
                 dots$thr)
    
    thr <-  min(1,max(0, thr))
    head <- var
    breaks <- NULL #Init on null
    #Safe-check loop to set a maximum of iterations
    #Option to set a WHILE loop and set an additional par to stop the loop
    for (i in 1:100) {
      mu <- mean(head, na.rm = TRUE)
      breaks <- c(breaks, mu)
      ntot <- length(head)
      #Switch head
      head <- head[head > mu]
      prop <- length(head) / ntot
      keepiter <- prop <= thr & length(head) > 1
      print(paste0("prop:", prop, " nhead:", length(head)))
      if (isFALSE(keepiter)) {
        #Just for checking the execution
        # to remove on implementation
        print(paste("Breaks found: ", i, ", Intervals:", i+1))
        break
      }
    }
    #Add min and max to complete intervals
    breaks <- sort(unique(c(
      min(var, na.rm = TRUE),
      breaks,
      max(var, na.rm = TRUE)
    )))
    #Remove on implementation
    print(breaks)
    return(breaks)
  }
}


```

Some inline checks:
- Loop until `i == 100`. As per my tests, no more than 25 iterations has been observed. See also [Tests and stress](#tests-and-stress).
- `thr` is restricted to `[0,1]`.
- `thr` is passed via `...`.
- If `head` has only one value (or even 0, observed on one test) the loop stops, given that no more partitions are possible
- Another checks as `NA`, remove `class`, etc. are already implemented on `classIntervals`.

See some comparisons using `thr = .35` and `thr = .40`.

```r
plot(
  density(sample_par),
  lty = 3,
  axes = FALSE,
  ylab = "",
  xlab = "",
  main = "sample_par: breaks"
)
axis(2)
abline(v = ht_index(sample_par, thr = 0.35), col = "green")
#> [1] "prop:0.316 nhead:316"
#> [1] "prop:0.373417721518987 nhead:118"
#> [1] "Breaks found:  2 , Intervals: 3"
#> [1] 2.000114 2.422568 2.971249 6.716770
abline(
  v = ht_index(sample_par, thr = 0.4),
  col = "orange",
  lty = 3,
  lwd = 0.5
)
#> [1] "prop:0.316 nhead:316"
#> [1] "prop:0.373417721518987 nhead:118"
#> [1] "prop:0.355932203389831 nhead:42"
#> [1] "prop:0.285714285714286 nhead:12"
#> [1] "prop:0.333333333333333 nhead:4"
#> [1] "prop:0.25 nhead:1"
#> [1] "Breaks found:  6 , Intervals: 7"
#> [1] 2.000114 2.422568 2.971249 3.559716 4.227112 5.055604 6.181099 6.716770
legend(
  "right",
  legend = c("thresold .35", "thresold .4"),
  col = c("green", "orange"),
  lty = c(1, 3),
  cex = 0.8
)
```

![](https://i.imgur.com/hfl7ZwG.png)


##### *[Back to Index](#index)*
## Testing

Testing has been performed over the following distributions:
- Pareto
- Exponential (with extra 10 extreme values)
- Log-normal
- Weibull
- Normal (non heavy-tailed)
- Truncated Normal (left-tailed)
- Log-Cauchy, also known as super-heavy tail distribution.

With sample = 5,000,000 observations. Corner cases of the threshold (i.e. 0,1) has been already tested.

Performance is very good IMO, sampling not needed.

This is a summary, see [Annex](#test-results)
for full test-suit results.

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Title</th>
<th style="text-align: left;">nsample</th>
<th style="text-align: right;">thresold</th>
<th style="text-align: right;">nbreaks</th>
<th style="text-align: left;">time_secs</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Pareto Dist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.4000</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.419203042984009</td>
</tr>
<tr class="even">
<td style="text-align: left;">Pareto Dist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.335700988769531</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Pareto Dist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.396288871765137</td>
</tr>
<tr class="even">
<td style="text-align: left;">ExpDist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.4000</td>
<td style="text-align: right;">16</td>
<td style="text-align: left;">0.341656923294067</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ExpDist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.205184936523438</td>
</tr>
<tr class="even">
<td style="text-align: left;">ExpDist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.422024965286255</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogNorm</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.7500</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.368312835693359</td>
</tr>
<tr class="even">
<td style="text-align: left;">LogNorm</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.181805849075317</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogNorm</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.39214301109314</td>
</tr>
<tr class="even">
<td style="text-align: left;">Weibull</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.2500</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.352260112762451</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Weibull</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.215781927108765</td>
</tr>
<tr class="even">
<td style="text-align: left;">Weibull</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.413298845291138</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Normal</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.8000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.484923839569092</td>
</tr>
<tr class="even">
<td style="text-align: left;">Normal</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.248221158981323</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Normal</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.433116912841797</td>
</tr>
<tr class="even">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">0.6000</td>
<td style="text-align: right;">22</td>
<td style="text-align: left;">0.489871025085449</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.279742002487183</td>
</tr>
<tr class="even">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">22</td>
<td style="text-align: left;">0.645022869110107</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">200.0000</td>
<td style="text-align: right;">22</td>
<td style="text-align: left;">0.548133134841919</td>
</tr>
<tr class="even">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">-100.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.314825057983398</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogCauchy</td>
<td style="text-align: left;">4,990,828</td>
<td style="text-align: right;">0.7896</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">0.189254999160767</td>
</tr>
<tr class="even">
<td style="text-align: left;">LogCauchy</td>
<td style="text-align: left;">4,990,828</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.197987079620361</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogCauchy</td>
<td style="text-align: left;">4,990,828</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">0.249590158462524</td>
</tr>
</tbody>
</table>

##### *[Back to Index](#index)*
## Case study

In order to check the method with real data I
used the algorithm to create a choropleth map
of the European population, using the `cartography` package.

As expected by Jiang (2013), head/tails seems to emphasise better
extreme values of the distribution:
![](https://i.imgur.com/MbMLLSR.png)
![](https://i.imgur.com/2mtANJg.png)
![](https://i.imgur.com/0UQJcEm.png)


Full script of the Case study (including
benchmark with `classIntervals` styles):

``` r

# 5. Case study: Population----
library(cartography)
library(sf)
#> Warning: package 'sf' was built under R version 3.5.3
#> Linking to GEOS 3.6.1, GDAL 2.2.3, PROJ 4.9.3
library(classInt)
#> Warning: package 'classInt' was built under R version 3.5.3

nuts3 <- st_as_sf(nuts3.spdf)
nuts3 <- merge(nuts3, nuts3.df)

nrow(nuts3)
#> [1] 1448

nuts3$var <- nuts3$pop2008 / 1000 #Thousands

opar <- par(no.readonly = TRUE)
par(mar = c(3, 2.5, 2, 1))
plot(density(nuts3$var),
     main = "NUTS3 Pop2008 (thousands)",
     ylab = "",
     xlab = "")
```

![](https://i.imgur.com/q19Ao0C.png)

``` r


#benchmark
init <- Sys.time()
brks_ht <- ht_index(nuts3$var)
#> [1] "prop:0.31767955801105 nhead:460"
#> [1] "prop:0.267391304347826 nhead:123"
#> [1] "prop:0.252032520325203 nhead:31"
#> [1] "prop:0.32258064516129 nhead:10"
#> [1] "prop:0.3 nhead:3"
#> [1] "prop:0.333333333333333 nhead:1"
#> [1] "Breaks found:  6 , Intervals: 7"
#> [1]    15.4710   402.6459   862.5118  1638.0025  2979.9322  5084.1036  8035.3390
#> [8] 12573.8360
Sys.time() - init
#> Time difference of 0.0009970665 secs

init <- Sys.time()
brks_fisher <-
  classIntervals(nuts3$var, style = "fisher", n = 7)$brks
Sys.time() - init
#> Time difference of 0.0219841 secs

init <- Sys.time()
brks_kmeans <-
  classIntervals(nuts3$var, style = "kmeans", n = 7)$brks
Sys.time() - init
#> Time difference of 0.007397175 secs


cols <- c(carto.pal("harmo.pal", 7))



par(mar = c(0, 0, 0, 0))
choroLayer(
  nuts3,
  var = "var",
  breaks = brks_ht,
  legend.title.txt = "HT-index",
  col = cols,
  border = NA,
  legend.pos = "right"
)
```

![](https://i.imgur.com/MbMLLSR.png)

``` r

choroLayer(
  nuts3,
  var = "var",
  breaks = brks_fisher,
  legend.title.txt = "Fisher",
  col = cols,
  border = NA,
  legend.pos = "right"
)
```

![](https://i.imgur.com/2mtANJg.png)

``` r

choroLayer(
  nuts3,
  var = "var",
  breaks = brks_kmeans,
  legend.title.txt = "Kmeans",
  col = cols,
  border = NA,
  legend.pos = "right"
)
```

![](https://i.imgur.com/0UQJcEm.png)

``` r
par(opar)

```


##### *[Back to Index](#index)*
## References
- Jiang, B. (2013). "Head/tail breaks: A new classification scheme for data with a heavy-tailed distribution", *The Professional Geographer*, 65 (3), 482 – 494. https://arxiv.org/abs/1209.2801v1
- Jiang, B. Liu, X. and Jia, T. (2013). "Scaling of geographic space as a universal rule for map generalization", *Annals of the Association of American Geographers*, 103(4), 844 – 855. https://arxiv.org/abs/1102.1561v3
- Jiang, B. (2019). "A recursive definition of goodness of space for bridging the concepts of space and place for sustainability". *Sustainability*, 11(15), 4091. https://arxiv.org/abs/1909.01073v1


##### *[Back to Index](#index)*
## Test results

``` r


#4. Test and stress----
#Init table on default
testresults <- data.frame(
  Title = NA,
  nsample  = NA,
  thresold = NA,
  nbreaks = NA,
  time_secs = NA
)

benchmarkdist <-
  function(dist,
           thr = 0.4,
           title = "",
           plot = TRUE) {
    dist = c(na.omit(dist))
    init <- Sys.time()
    br <- ht_index(dist, thr = thr)
    a <- Sys.time() - init
    print(a)
    test <- data.frame(
      Title = title,
      nsample  = format(length(dist), scientific = FALSE, big.mark = ","),
      thresold = thr,
      nbreaks = length(br) - 1,
      time_secs = as.character(a)
    )
    testresults <- unique(rbind(testresults, test))
    
    if (plot) {
      plot(density(dist),
           col = "black",
           main = paste0(title, ", thr =", thr, ", nbreaks = ", length(br)-1))
      abline(v = br,
             col = "green",
             lty = 3)
    }
    return(testresults)
  }



#Scalability: 5 millions
set.seed(2389)

#Pareto distributions a=7 b=14
paretodist <- 7 / (1 - runif(5000000)) ^ (1 / 14)
#Exponential dist
expdist <- rexp(5000000)
#Lognorm
lognormdist <- rlnorm(5000000)
#Weibull
weibulldist <- rweibull(5000000, 1, scale = 5)
#Normal dist
normdist <- rnorm(5000000)
#Left-tailed distr
leftnorm <- rep(normdist[normdist < mean(normdist)], 2)
#LogCauchy "super-heavy tail"
logcauchdist <- exp(rcauchy(5000000, 2, 4))
#Remove Inf - this check is already implemented on classIntervals
logcauchdist <- logcauchdist[logcauchdist < Inf]

#Tests
testresults <- benchmarkdist(paretodist, title = "Pareto Dist")
#> [1] "prop:0.3543272 nhead:1771636"
#> [1] "prop:0.354200862931212 nhead:627515"
#> [1] "prop:0.354158864728333 nhead:222240"
#> [1] "prop:0.354063174946004 nhead:78687"
#> [1] "prop:0.35352726625745 nhead:27818"
#> [1] "prop:0.355345459774247 nhead:9885"
#> [1] "prop:0.355791603439555 nhead:3517"
#> [1] "prop:0.35371054876315 nhead:1244"
#> [1] "prop:0.343247588424437 nhead:427"
#> [1] "prop:0.346604215456674 nhead:148"
#> [1] "prop:0.371621621621622 nhead:55"
#> [1] "prop:0.327272727272727 nhead:18"
#> [1] "prop:0.388888888888889 nhead:7"
#> [1] "prop:0.142857142857143 nhead:1"
#> [1] "Breaks found:  14 , Intervals: 15"
#>  [1]  7.000000  7.538849  8.119161  8.743518  9.416418 10.143382 10.929898
#>  [8] 11.777121 12.679457 13.651872 14.734872 15.963453 17.311978 18.988971
#> [15] 20.211755 23.807530
#> Time difference of 0.419203 secs
```

![](https://i.imgur.com/Ys2BoO8.png)

``` r
testresults <-
  benchmarkdist(paretodist, 0, title = "Pareto Dist", plot = FALSE)
#> [1] "prop:0.3543272 nhead:1771636"
#> [1] "Breaks found:  1 , Intervals: 2"
#> [1]  7.000000  7.538849 23.807530
#> Time difference of 0.335701 secs
testresults <-
  benchmarkdist(paretodist, 1, title = "Pareto Dist", plot = FALSE)
#> [1] "prop:0.3543272 nhead:1771636"
#> [1] "prop:0.354200862931212 nhead:627515"
#> [1] "prop:0.354158864728333 nhead:222240"
#> [1] "prop:0.354063174946004 nhead:78687"
#> [1] "prop:0.35352726625745 nhead:27818"
#> [1] "prop:0.355345459774247 nhead:9885"
#> [1] "prop:0.355791603439555 nhead:3517"
#> [1] "prop:0.35371054876315 nhead:1244"
#> [1] "prop:0.343247588424437 nhead:427"
#> [1] "prop:0.346604215456674 nhead:148"
#> [1] "prop:0.371621621621622 nhead:55"
#> [1] "prop:0.327272727272727 nhead:18"
#> [1] "prop:0.388888888888889 nhead:7"
#> [1] "prop:0.142857142857143 nhead:1"
#> [1] "Breaks found:  14 , Intervals: 15"
#>  [1]  7.000000  7.538849  8.119161  8.743518  9.416418 10.143382 10.929898
#>  [8] 11.777121 12.679457 13.651872 14.734872 15.963453 17.311978 18.988971
#> [15] 20.211755 23.807530
#> Time difference of 0.3962889 secs

testresults <- benchmarkdist(expdist, title = "ExpDist")
#> [1] "prop:0.3677448 nhead:1838724"
#> [1] "prop:0.367977466982538 nhead:676609"
#> [1] "prop:0.368261433117207 nhead:249169"
#> [1] "prop:0.367794549081146 nhead:91643"
#> [1] "prop:0.367807688530493 nhead:33707"
#> [1] "prop:0.368706796807785 nhead:12428"
#> [1] "prop:0.36562600579337 nhead:4544"
#> [1] "prop:0.36949823943662 nhead:1679"
#> [1] "prop:0.363311494937463 nhead:610"
#> [1] "prop:0.360655737704918 nhead:220"
#> [1] "prop:0.354545454545455 nhead:78"
#> [1] "prop:0.397435897435897 nhead:31"
#> [1] "prop:0.387096774193548 nhead:12"
#> [1] "prop:0.333333333333333 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "Breaks found:  15 , Intervals: 16"
#>  [1] 4.534944e-07 9.990109e-01 1.998383e+00 2.996829e+00 3.993308e+00
#>  [6] 4.988082e+00 5.985162e+00 6.973514e+00 7.969093e+00 8.968558e+00
#> [11] 9.974569e+00 1.096586e+01 1.203901e+01 1.307891e+01 1.402431e+01
#> [16] 1.493760e+01 1.539196e+01
#> Time difference of 0.3416569 secs
```

![](https://i.imgur.com/SAUjOul.png)

``` r
testresults <-
  benchmarkdist(expdist, 0, title = "ExpDist", plot = FALSE)
#> [1] "prop:0.3677448 nhead:1838724"
#> [1] "Breaks found:  1 , Intervals: 2"
#> [1] 4.534944e-07 9.990109e-01 1.539196e+01
#> Time difference of 0.2051849 secs
testresults <-
  benchmarkdist(expdist, 1, title = "ExpDist", plot = FALSE)
#> [1] "prop:0.3677448 nhead:1838724"
#> [1] "prop:0.367977466982538 nhead:676609"
#> [1] "prop:0.368261433117207 nhead:249169"
#> [1] "prop:0.367794549081146 nhead:91643"
#> [1] "prop:0.367807688530493 nhead:33707"
#> [1] "prop:0.368706796807785 nhead:12428"
#> [1] "prop:0.36562600579337 nhead:4544"
#> [1] "prop:0.36949823943662 nhead:1679"
#> [1] "prop:0.363311494937463 nhead:610"
#> [1] "prop:0.360655737704918 nhead:220"
#> [1] "prop:0.354545454545455 nhead:78"
#> [1] "prop:0.397435897435897 nhead:31"
#> [1] "prop:0.387096774193548 nhead:12"
#> [1] "prop:0.333333333333333 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  16 , Intervals: 17"
#>  [1] 4.534944e-07 9.990109e-01 1.998383e+00 2.996829e+00 3.993308e+00
#>  [6] 4.988082e+00 5.985162e+00 6.973514e+00 7.969093e+00 8.968558e+00
#> [11] 9.974569e+00 1.096586e+01 1.203901e+01 1.307891e+01 1.402431e+01
#> [16] 1.493760e+01 1.536455e+01 1.539196e+01
#> Time difference of 0.422025 secs

testresults <- benchmarkdist(lognormdist, 0.75, title = "LogNorm")
#> [1] "prop:0.3087264 nhead:1543632"
#> [1] "prop:0.309735740124589 nhead:478118"
#> [1] "prop:0.315926193952121 nhead:151050"
#> [1] "prop:0.319311486262827 nhead:48232"
#> [1] "prop:0.323270857521977 nhead:15592"
#> [1] "prop:0.333760903027193 nhead:5204"
#> [1] "prop:0.329554189085319 nhead:1715"
#> [1] "prop:0.332361516034985 nhead:570"
#> [1] "prop:0.335087719298246 nhead:191"
#> [1] "prop:0.350785340314136 nhead:67"
#> [1] "prop:0.26865671641791 nhead:18"
#> [1] "prop:0.277777777777778 nhead:5"
#> [1] "prop:0.4 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  14 , Intervals: 15"
#>  [1] 5.960499e-03 1.648513e+00 3.693475e+00 6.541902e+00 1.037196e+01
#>  [6] 1.539770e+01 2.186603e+01 2.976225e+01 3.948552e+01 5.107634e+01
#> [11] 6.517331e+01 8.141691e+01 1.075394e+02 1.514656e+02 1.960593e+02
#> [16] 2.019891e+02
#> Time difference of 0.3683128 secs
```

![](https://i.imgur.com/XgzwEvK.png)

``` r
testresults <-
  benchmarkdist(lognormdist, 0, title = "LogNorm", plot = FALSE)
#> [1] "prop:0.3087264 nhead:1543632"
#> [1] "Breaks found:  1 , Intervals: 2"
#> [1] 5.960499e-03 1.648513e+00 2.019891e+02
#> Time difference of 0.1818058 secs
testresults <-
  benchmarkdist(lognormdist, 1, title = "LogNorm", plot = FALSE)
#> [1] "prop:0.3087264 nhead:1543632"
#> [1] "prop:0.309735740124589 nhead:478118"
#> [1] "prop:0.315926193952121 nhead:151050"
#> [1] "prop:0.319311486262827 nhead:48232"
#> [1] "prop:0.323270857521977 nhead:15592"
#> [1] "prop:0.333760903027193 nhead:5204"
#> [1] "prop:0.329554189085319 nhead:1715"
#> [1] "prop:0.332361516034985 nhead:570"
#> [1] "prop:0.335087719298246 nhead:191"
#> [1] "prop:0.350785340314136 nhead:67"
#> [1] "prop:0.26865671641791 nhead:18"
#> [1] "prop:0.277777777777778 nhead:5"
#> [1] "prop:0.4 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  14 , Intervals: 15"
#>  [1] 5.960499e-03 1.648513e+00 3.693475e+00 6.541902e+00 1.037196e+01
#>  [6] 1.539770e+01 2.186603e+01 2.976225e+01 3.948552e+01 5.107634e+01
#> [11] 6.517331e+01 8.141691e+01 1.075394e+02 1.514656e+02 1.960593e+02
#> [16] 2.019891e+02
#> Time difference of 0.392143 secs

testresults <- benchmarkdist(weibulldist, 0.25, title = "Weibull")
#> [1] "prop:0.3679468 nhead:1839734"
#> [1] "Breaks found:  1 , Intervals: 2"
#> [1] 2.735760e-07 5.001702e+00 7.673301e+01
#> Time difference of 0.3522601 secs
```

![](https://i.imgur.com/QYqb6oa.png)

``` r
testresults <-
  benchmarkdist(weibulldist, 0, title = "Weibull", plot = FALSE)
#> [1] "prop:0.3679468 nhead:1839734"
#> [1] "Breaks found:  1 , Intervals: 2"
#> [1] 2.735760e-07 5.001702e+00 7.673301e+01
#> Time difference of 0.2157819 secs
testresults <-
  benchmarkdist(weibulldist, 1, title = "Weibull", plot = FALSE)
#> [1] "prop:0.3679468 nhead:1839734"
#> [1] "prop:0.367591727934582 nhead:676271"
#> [1] "prop:0.367926467348149 nhead:248818"
#> [1] "prop:0.367995884542115 nhead:91564"
#> [1] "prop:0.367447905290289 nhead:33645"
#> [1] "prop:0.368108188438104 nhead:12385"
#> [1] "prop:0.373112636253533 nhead:4621"
#> [1] "prop:0.357714780350573 nhead:1653"
#> [1] "prop:0.372655777374471 nhead:616"
#> [1] "prop:0.375 nhead:231"
#> [1] "prop:0.350649350649351 nhead:81"
#> [1] "prop:0.37037037037037 nhead:30"
#> [1] "prop:0.366666666666667 nhead:11"
#> [1] "prop:0.363636363636364 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  16 , Intervals: 17"
#>  [1] 2.735760e-07 5.001702e+00 1.000405e+01 1.501010e+01 2.001468e+01
#>  [6] 2.501961e+01 3.004452e+01 3.504632e+01 3.991777e+01 4.495168e+01
#> [11] 4.986135e+01 5.441215e+01 5.900803e+01 6.358776e+01 6.870115e+01
#> [16] 7.444729e+01 7.666662e+01 7.673301e+01
#> Time difference of 0.4132988 secs

testresults <- benchmarkdist(normdist, 0.8, title = "Normal")
#> [1] "prop:0.5001914 nhead:2500957"
#> [1] "prop:0.425015304141575 nhead:1062945"
#> [1] "prop:0.404747188236456 nhead:430224"
#> [1] "prop:0.39417373275317 nhead:169583"
#> [1] "prop:0.390198309972108 nhead:66171"
#> [1] "prop:0.386498617219023 nhead:25575"
#> [1] "prop:0.380879765395894 nhead:9741"
#> [1] "prop:0.380043116723129 nhead:3702"
#> [1] "prop:0.388438681793625 nhead:1438"
#> [1] "prop:0.376216968011127 nhead:541"
#> [1] "prop:0.384473197781885 nhead:208"
#> [1] "prop:0.375 nhead:78"
#> [1] "prop:0.397435897435897 nhead:31"
#> [1] "prop:0.354838709677419 nhead:11"
#> [1] "prop:0.272727272727273 nhead:3"
#> [1] "prop:0.333333333333333 nhead:1"
#> [1] "Breaks found:  16 , Intervals: 17"
#>  [1] -4.9605354548 -0.0005467484  0.7967107507  1.3642943161  1.8241333245
#>  [6]  2.2189491694  2.5678495216  2.8821718784  3.1713279927  3.4411382573
#> [11]  3.6857094948  3.9189055988  4.1366848899  4.3482116520  4.5304538179
#> [16]  4.7010151808  4.9286029511  5.2074184961
#> Time difference of 0.4849238 secs
```

![](https://i.imgur.com/kAwfJkA.png)

``` r
testresults <-
  benchmarkdist(normdist, 0, title = "Normal", plot = FALSE)
#> [1] "prop:0.5001914 nhead:2500957"
#> [1] "Breaks found:  1 , Intervals: 2"
#> [1] -4.9605354548 -0.0005467484  5.2074184961
#> Time difference of 0.2482212 secs
testresults <-
  benchmarkdist(normdist, 1, title = "Normal", plot = FALSE)
#> [1] "prop:0.5001914 nhead:2500957"
#> [1] "prop:0.425015304141575 nhead:1062945"
#> [1] "prop:0.404747188236456 nhead:430224"
#> [1] "prop:0.39417373275317 nhead:169583"
#> [1] "prop:0.390198309972108 nhead:66171"
#> [1] "prop:0.386498617219023 nhead:25575"
#> [1] "prop:0.380879765395894 nhead:9741"
#> [1] "prop:0.380043116723129 nhead:3702"
#> [1] "prop:0.388438681793625 nhead:1438"
#> [1] "prop:0.376216968011127 nhead:541"
#> [1] "prop:0.384473197781885 nhead:208"
#> [1] "prop:0.375 nhead:78"
#> [1] "prop:0.397435897435897 nhead:31"
#> [1] "prop:0.354838709677419 nhead:11"
#> [1] "prop:0.272727272727273 nhead:3"
#> [1] "prop:0.333333333333333 nhead:1"
#> [1] "Breaks found:  16 , Intervals: 17"
#>  [1] -4.9605354548 -0.0005467484  0.7967107507  1.3642943161  1.8241333245
#>  [6]  2.2189491694  2.5678495216  2.8821718784  3.1713279927  3.4411382573
#> [11]  3.6857094948  3.9189055988  4.1366848899  4.3482116520  4.5304538179
#> [16]  4.7010151808  4.9286029511  5.2074184961
#> Time difference of 0.4331169 secs


testresults <-
  benchmarkdist(leftnorm, 0.6, title = "Left. Trunc. Normal")
#> [1] "prop:0.574960895030618 nhead:2873704"
#> [1] "prop:0.51244526228171 nhead:1472616"
#> [1] "prop:0.503100604638276 nhead:740874"
#> [1] "prop:0.501235027818495 nhead:371352"
#> [1] "prop:0.499935371291928 nhead:185652"
#> [1] "prop:0.499935362937108 nhead:92814"
#> [1] "prop:0.499730644083867 nhead:46382"
#> [1] "prop:0.500452761847268 nhead:23212"
#> [1] "prop:0.502240220575564 nhead:11658"
#> [1] "prop:0.490478641276377 nhead:5718"
#> [1] "prop:0.508219657222805 nhead:2906"
#> [1] "prop:0.487267721954577 nhead:1416"
#> [1] "prop:0.505649717514124 nhead:716"
#> [1] "prop:0.494413407821229 nhead:354"
#> [1] "prop:0.497175141242938 nhead:176"
#> [1] "prop:0.488636363636364 nhead:86"
#> [1] "prop:0.511627906976744 nhead:44"
#> [1] "prop:0.454545454545455 nhead:20"
#> [1] "prop:0.5 nhead:10"
#> [1] "prop:0.4 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0 nhead:0"
#> [1] "Breaks found:  22 , Intervals: 23"
#>  [1] -4.9605354548 -0.7984148615 -0.3786370780 -0.1871224722 -0.0935267116
#>  [6] -0.0470891909 -0.0238467336 -0.0121898326 -0.0063800214 -0.0034807516
#> [11] -0.0020189035 -0.0012697479 -0.0009096890 -0.0007229499 -0.0006345192
#> [16] -0.0005898488 -0.0005691473 -0.0005569817 -0.0005515657 -0.0005488630
#> [21] -0.0005479547 -0.0005477666 -0.0005476086
#> Time difference of 0.489871 secs
```

![](https://i.imgur.com/13ORPlT.png)

``` r
testresults <-
  benchmarkdist(leftnorm, 0, title = "Left. Trunc. Normal", plot = FALSE)
#> [1] "prop:0.574960895030618 nhead:2873704"
#> [1] "Breaks found:  1 , Intervals: 2"
#> [1] -4.9605354548 -0.7984148615 -0.0005476086
#> Time difference of 0.279742 secs
testresults <-
  benchmarkdist(leftnorm, 1, title = "Left. Trunc. Normal", plot = FALSE)
#> [1] "prop:0.574960895030618 nhead:2873704"
#> [1] "prop:0.51244526228171 nhead:1472616"
#> [1] "prop:0.503100604638276 nhead:740874"
#> [1] "prop:0.501235027818495 nhead:371352"
#> [1] "prop:0.499935371291928 nhead:185652"
#> [1] "prop:0.499935362937108 nhead:92814"
#> [1] "prop:0.499730644083867 nhead:46382"
#> [1] "prop:0.500452761847268 nhead:23212"
#> [1] "prop:0.502240220575564 nhead:11658"
#> [1] "prop:0.490478641276377 nhead:5718"
#> [1] "prop:0.508219657222805 nhead:2906"
#> [1] "prop:0.487267721954577 nhead:1416"
#> [1] "prop:0.505649717514124 nhead:716"
#> [1] "prop:0.494413407821229 nhead:354"
#> [1] "prop:0.497175141242938 nhead:176"
#> [1] "prop:0.488636363636364 nhead:86"
#> [1] "prop:0.511627906976744 nhead:44"
#> [1] "prop:0.454545454545455 nhead:20"
#> [1] "prop:0.5 nhead:10"
#> [1] "prop:0.4 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0 nhead:0"
#> [1] "Breaks found:  22 , Intervals: 23"
#>  [1] -4.9605354548 -0.7984148615 -0.3786370780 -0.1871224722 -0.0935267116
#>  [6] -0.0470891909 -0.0238467336 -0.0121898326 -0.0063800214 -0.0034807516
#> [11] -0.0020189035 -0.0012697479 -0.0009096890 -0.0007229499 -0.0006345192
#> [16] -0.0005898488 -0.0005691473 -0.0005569817 -0.0005515657 -0.0005488630
#> [21] -0.0005479547 -0.0005477666 -0.0005476086
#> Time difference of 0.6450229 secs

testresults <-
  benchmarkdist(leftnorm, 200, title = "Left. Trunc. Normal", plot = FALSE)
#> [1] "prop:0.574960895030618 nhead:2873704"
#> [1] "prop:0.51244526228171 nhead:1472616"
#> [1] "prop:0.503100604638276 nhead:740874"
#> [1] "prop:0.501235027818495 nhead:371352"
#> [1] "prop:0.499935371291928 nhead:185652"
#> [1] "prop:0.499935362937108 nhead:92814"
#> [1] "prop:0.499730644083867 nhead:46382"
#> [1] "prop:0.500452761847268 nhead:23212"
#> [1] "prop:0.502240220575564 nhead:11658"
#> [1] "prop:0.490478641276377 nhead:5718"
#> [1] "prop:0.508219657222805 nhead:2906"
#> [1] "prop:0.487267721954577 nhead:1416"
#> [1] "prop:0.505649717514124 nhead:716"
#> [1] "prop:0.494413407821229 nhead:354"
#> [1] "prop:0.497175141242938 nhead:176"
#> [1] "prop:0.488636363636364 nhead:86"
#> [1] "prop:0.511627906976744 nhead:44"
#> [1] "prop:0.454545454545455 nhead:20"
#> [1] "prop:0.5 nhead:10"
#> [1] "prop:0.4 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0 nhead:0"
#> [1] "Breaks found:  22 , Intervals: 23"
#>  [1] -4.9605354548 -0.7984148615 -0.3786370780 -0.1871224722 -0.0935267116
#>  [6] -0.0470891909 -0.0238467336 -0.0121898326 -0.0063800214 -0.0034807516
#> [11] -0.0020189035 -0.0012697479 -0.0009096890 -0.0007229499 -0.0006345192
#> [16] -0.0005898488 -0.0005691473 -0.0005569817 -0.0005515657 -0.0005488630
#> [21] -0.0005479547 -0.0005477666 -0.0005476086
#> Time difference of 0.5481331 secs

testresults <-
  benchmarkdist(leftnorm, -100, title = "Left. Trunc. Normal", plot = FALSE)
#> [1] "prop:0.574960895030618 nhead:2873704"
#> [1] "Breaks found:  1 , Intervals: 2"
#> [1] -4.9605354548 -0.7984148615 -0.0005476086
#> Time difference of 0.3148251 secs


testresults <-
  benchmarkdist(logcauchdist, 0.7896, title = "LogCauchy", plot = FALSE)
#> [1] "prop:3.16580735701571e-05 nhead:158"
#> [1] "prop:0.20253164556962 nhead:32"
#> [1] "prop:0.34375 nhead:11"
#> [1] "prop:0.363636363636364 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  6 , Intervals: 7"
#> [1]  0.000000e+00 3.600688e+302 1.137365e+307 5.236743e+307 9.915649e+307
#> [6] 1.411160e+308 1.637900e+308 1.725945e+308
#> Time difference of 0.189255 secs
testresults <-
  benchmarkdist(logcauchdist, 0, title = "LogCauchy", plot = FALSE)
#> [1] "prop:3.16580735701571e-05 nhead:158"
#> [1] "Breaks found:  1 , Intervals: 2"
#> [1]  0.000000e+00 3.600688e+302 1.725945e+308
#> Time difference of 0.1979871 secs
testresults <-
  benchmarkdist(logcauchdist, 1, title = "LogCauchy", plot = FALSE)
#> [1] "prop:3.16580735701571e-05 nhead:158"
#> [1] "prop:0.20253164556962 nhead:32"
#> [1] "prop:0.34375 nhead:11"
#> [1] "prop:0.363636363636364 nhead:4"
#> [1] "prop:0.5 nhead:2"
#> [1] "prop:0.5 nhead:1"
#> [1] "Breaks found:  6 , Intervals: 7"
#> [1]  0.000000e+00 3.600688e+302 1.137365e+307 5.236743e+307 9.915649e+307
#> [6] 1.411160e+308 1.637900e+308 1.725945e+308
#> Time difference of 0.2495902 secs

# On non skewed or left tails thresold should be stressed beyond 50%,
# otherwise just the first iter (i.e. min, mean, max) is returned.
par(opar)



knitr::kable(testresults[-1, ], format = "markdown", row.names = FALSE)
```

<table>
<thead>
<tr class="header">
<th style="text-align: left;">Title</th>
<th style="text-align: left;">nsample</th>
<th style="text-align: right;">thresold</th>
<th style="text-align: right;">nbreaks</th>
<th style="text-align: left;">time_secs</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td style="text-align: left;">Pareto Dist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.4000</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.419203042984009</td>
</tr>
<tr class="even">
<td style="text-align: left;">Pareto Dist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.335700988769531</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Pareto Dist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.396288871765137</td>
</tr>
<tr class="even">
<td style="text-align: left;">ExpDist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.4000</td>
<td style="text-align: right;">16</td>
<td style="text-align: left;">0.341656923294067</td>
</tr>
<tr class="odd">
<td style="text-align: left;">ExpDist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.205184936523438</td>
</tr>
<tr class="even">
<td style="text-align: left;">ExpDist</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.422024965286255</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogNorm</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.7500</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.368312835693359</td>
</tr>
<tr class="even">
<td style="text-align: left;">LogNorm</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.181805849075317</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogNorm</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">15</td>
<td style="text-align: left;">0.39214301109314</td>
</tr>
<tr class="even">
<td style="text-align: left;">Weibull</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.2500</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.352260112762451</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Weibull</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.215781927108765</td>
</tr>
<tr class="even">
<td style="text-align: left;">Weibull</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.413298845291138</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Normal</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.8000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.484923839569092</td>
</tr>
<tr class="even">
<td style="text-align: left;">Normal</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.248221158981323</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Normal</td>
<td style="text-align: left;">5,000,000</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">17</td>
<td style="text-align: left;">0.433116912841797</td>
</tr>
<tr class="even">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">0.6000</td>
<td style="text-align: right;">22</td>
<td style="text-align: left;">0.489871025085449</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.279742002487183</td>
</tr>
<tr class="even">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">22</td>
<td style="text-align: left;">0.645022869110107</td>
</tr>
<tr class="odd">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">200.0000</td>
<td style="text-align: right;">22</td>
<td style="text-align: left;">0.548133134841919</td>
</tr>
<tr class="even">
<td style="text-align: left;">Left. Trunc. Normal</td>
<td style="text-align: left;">4,998,086</td>
<td style="text-align: right;">-100.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.314825057983398</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogCauchy</td>
<td style="text-align: left;">4,990,828</td>
<td style="text-align: right;">0.7896</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">0.189254999160767</td>
</tr>
<tr class="even">
<td style="text-align: left;">LogCauchy</td>
<td style="text-align: left;">4,990,828</td>
<td style="text-align: right;">0.0000</td>
<td style="text-align: right;">2</td>
<td style="text-align: left;">0.197987079620361</td>
</tr>
<tr class="odd">
<td style="text-align: left;">LogCauchy</td>
<td style="text-align: left;">4,990,828</td>
<td style="text-align: right;">1.0000</td>
<td style="text-align: right;">7</td>
<td style="text-align: left;">0.249590158462524</td>
</tr>
</tbody>
</table>


##### *[Back to Index](#index)*