library(classInt)
library(tidyverse)
library(scales)

# Define a common theme for the plots.
background <- "#FEFDFD"

map_title <- "inter-tight"
map_regular <- "inter"

# sysfonts::font_add_google("Inter Tight", family = map_title)
# sysfonts::font_add_google("Inter", family = map_regular)
# showtext::showtext_opts(dpi = knitr::opts_chunk$get("dpi"))
# showtext::showtext_auto()

theme_set(
  theme_bw(paper = background, base_family = map_regular) +
    theme(
      rect = element_rect(fill = background),
      plot.title = element_text(family = map_title, face = "bold"),
      legend.title = element_text(family = map_title, face = "bold"),
      strip.text = element_text(family = map_title, face = "bold"),
      plot.margin = margin(10, 10, 10, 10)
    )
)

# 1. Characterization of heavy-tail distributions----
set.seed(1234)
# Pareto distribution a=1 b=1.161 n=1000
sample_par <- (1 - runif(1000))^(-1 / (log(5) / log(4)))

sample_par_df <- tibble(x = sample_par) |>
  arrange(desc(x)) |>
  mutate(
    prop = row_number() / n(),
    cumulative = cumsum(x) / sum(x)
  )

ggplot(sample_par_df, aes(prop, cumulative)) +
  geom_line() +
  geom_vline(xintercept = 0.2, linetype = "dashed") +
  geom_hline(yintercept = 0.8, linetype = "dashed") +
  scale_x_continuous(labels = label_percent()) +
  scale_y_continuous(labels = label_percent()) +
  labs(
    title = "The 80/20 principle",
    subtitle = "An illustration using a Pareto distribution",
    x = "Top proportion of observations",
    y = "Cumulative share of total"
  )

# Histogram
ggplot(sample_par_df, aes(x = x)) +
  geom_histogram(
    aes(y = after_stat(density)),
    bins = 100,
    fill = "grey50",
    color = NA
  ) +
  scale_x_continuous(labels = label_comma()) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = "A heavy-tailed distribution",
    subtitle = "Histogram of a simulated Pareto sample",
    x = "Value",
    y = "Density"
  )


var <- sample_par
thr <- 0.4
brks <- range(var, na.rm = TRUE)

iterations <- list()
summary_rows <- list()

for (i in seq_len(10)) {
  mu <- mean(var)
  head_values <- var[var > mu]
  prop <- length(head_values) / length(var)

  brks <- sort(c(brks, mu))

  iterations[[i]] <- tibble(
    iter = i,
    value = var,
    mu = mu,
    prop = prop
  )

  summary_rows[[i]] <- tibble(
    iter = i,
    mu = mu,
    prop = prop,
    n_var = length(var),
    n_head = length(head_values)
  )

  if (!(prop < thr && length(head_values) > 1)) {
    break
  }

  var <- head_values
}

iter_df <- bind_rows(iterations) |>
  mutate(iter = factor(iter, levels = unique(iter)))

sum_table <- bind_rows(summary_rows)

labels_df <- sum_table |>
  mutate(
    iter = factor(iter, levels = levels(iter_df$iter)),
    label = paste0(
      "Share of observations in the head:\n",
      label_percent(accuracy = 0.1)(prop)
    )
  )

iter_df |>
  ggplot(aes(x = value)) +
  geom_histogram(
    bins = 50,
    fill = "grey50",
    color = NA
  ) +
  geom_vline(
    data = labels_df,
    aes(xintercept = mu),
    linetype = "dashed",
    color = "red3"
  ) +
  geom_text(
    data = labels_df,
    aes(x = mu, y = Inf, label = label),
    inherit.aes = FALSE,
    position = position_nudge(x = 20),
    hjust = 0,
    vjust = 1.5,
    size = 3
  ) +
  facet_wrap(
    vars(iter),
    scales = "free_y",
    labeller = labeller(iter = ~ paste("Iteration", .x))
  ) +
  labs(
    title = "Head/tail breaks: step by step",
    subtitle = "Recursive partitioning at the arithmetic mean",
    x = "Value",
    y = "Count"
  )

# Summary table
sum_table |>
  mutate(
    mu = round(mu, 4),
    prop = paste0(round(100 * prop, 2), "%")
  ) |>
  knitr::kable(row.names = FALSE)

# Compare with classInt
ht_sample_par <- classIntervals(
  sample_par,
  style = "headtails"
)

all.equal(brks, ht_sample_par$brks)

# 3. Effect of the threshold ----

thresholds <- c(0, 0.2, 0.4, 1)

breaks_df <- lapply(thresholds, function(thr) {
  ci <- classIntervals(
    sample_par,
    style = "headtails",
    thr = thr
  )

  tibble(
    threshold = paste0("thr = ", thr),
    value = sample_par,
    class = findInterval(
      sample_par,
      ci$brks,
      all.inside = TRUE
    ),
    n_classes = length(ci$brks) - 1
  ) |>
    group_by(threshold, n_classes, class) |>
    summarise(xmin = min(value), xmax = max(value), .groups = "drop_last") |>
    mutate(ymin = -0.05, ymax = 0) |>
    mutate(xmin = ifelse(row_number() == 1, xmin, lag(xmax))) |>
    ungroup()
}) |>
  bind_rows() |>
  mutate(
    threshold = factor(
      threshold,
      levels = paste0("thr = ", thresholds)
    )
  )

# Number of classes
breaks_df |>
  distinct(threshold, n_classes) |>
  knitr::kable(row.names = FALSE)

# Distribution of observations across classes
ggplot(breaks_df, aes(fill = factor(class))) +
  stat_ecdf(
    data = tibble(x = sample_par),
    aes(x = x),
    inherit.aes = FALSE,
    linetype = "dashed"
  ) +
  geom_vline(
    data = breaks_df,
    aes(xintercept = xmax, color = factor(class)),
    show.legend = FALSE
  ) +
  geom_rect(aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)) +
  stat_ecdf(
    data = tibble(x = sample_par),
    aes(x = x),
    inherit.aes = FALSE,
    geom = "point",
    size = 1,
    pad = FALSE
  ) +
  facet_wrap(~threshold, scales = "free_x") +
  scale_y_continuous(labels = label_percent()) +
  scale_fill_viridis_d(option = "cividis") +
  scale_color_viridis_d(option = "cividis") +
  labs(
    title = "The effect of the threshold",
    subtitle = "Head/tail breaks with different stopping thresholds",
    x = "Value",
    y = "Cumulative proportion",
    fill = "Class"
  )

library(spData)


data(afcon, package = "spData")

# Top10
knitr::kable(head(
  afcon[order(afcon$totcon, decreasing = TRUE), c("name", "totcon")],
  10
))

ggplot(afcon, aes(x = totcon)) +
  geom_histogram(bins = 30) +
  scale_x_continuous(labels = label_comma()) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = "Conflict distribution in Africa, 1966–1978",
    subtitle = "Number of conflicts by country",
    x = "Number of conflicts",
    y = "Number of countries",
    caption = "Data source: Anselin & O'Loughlin (1992)"
  )


ggplot(afcon, aes(x = totcon)) +
  geom_density() +
  scale_x_continuous(labels = label_comma()) +
  scale_y_continuous(labels = label_comma()) +
  labs(
    title = "A skewed distribution of conflicts",
    subtitle = "Estimated density of conflict counts, 1966–1978",
    x = "Number of conflicts",
    y = "Density",
    caption = "Data source: Anselin & O'Loughlin (1992)"
  )


afcon$headtails <- classify_intervals(afcon$totcon, style = "headtails")
afcon$headtails_br <- as.numeric(afcon$headtails)

# Record the number of classes to set the same

nclass <- length(levels(afcon$headtails))

# Same number of classes for "fisher"
afcon$fisher <- classify_intervals(afcon$totcon, style = "fisher", n = nclass)
afcon$fisher_br <- as.numeric(afcon$fisher)

afcon$quantile <- classify_intervals(
  afcon$totcon,
  style = "quantile",
  n = nclass
)
afcon$quantile_br <- as.numeric(afcon$quantile)

levels(afcon$headtails)
levels(afcon$fisher)
levels(afcon$quantile)


ht_breaks <- classIntervals(afcon$totcon, style = "headtails")$brks[seq_len(
  nclass
)]

fisher_breaks <- classIntervals(
  afcon$totcon,
  style = "fisher",
  n = nclass
)$brks[seq_len(nclass)]


q_breaks <- classIntervals(
  afcon$totcon,
  style = "quantile",
  n = nclass
)$brks[seq_len(nclass)]


tibble(
  id_breaks = "Head/tails",
  b = ht_breaks,
  group = as.factor(seq_along(ht_breaks))
) |>
  bind_rows(
    tibble(
      id_breaks = "Fisher",
      b = fisher_breaks,
      group = as.factor(seq_along(fisher_breaks))
    )
  ) |>
  bind_rows(
    tibble(
      id_breaks = "Quantile",
      b = q_breaks,
      group = as.factor(seq_along(q_breaks))
    )
  ) |> 
  mutate(id_breaks = fct_inorder(id_breaks)) |>
  # Prepare rects
  group_by(id_breaks) |>
  mutate(xmin = if_else(group == 1, 0,b),
         xmax = if_else(group == nclass, max(afcon$totcon) + 500 ,lead(b)),
         ymin = 0,
         ymax = 1.1
         ) |> 
  ggplot() +
  stat_ecdf(
    data = afcon,
    aes(x = totcon),
    geom = "point",
    size = 1,
    pad = FALSE
  ) +
  geom_rect(aes(xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax, fill = group)) +
  guides(color = guide_legend()) +
  facet_wrap(vars(id_breaks), ncol = 1) +
  scale_fill_viridis_d(option = "cividis", alpha = 0.5) +
  scale_y_continuous(labels = label_percent(), breaks = seq(0,1,0.25)) +
  scale_x_continuous(labels = label_comma()) +
  guides(fill = guide_legend(override.aes = list(alpha = 1))) +
  labs(
    title = "Comparing classification methods",
    subtitle = "Head/tail breaks, Fisher–Jenks and quantiles",
    x = "Number of conflicts",
    y = "Cumulative proportion",
    fill = "Class"
  )

afcon$data <- scales::rescale(afcon$totcon, to = c(0.5, 4.5)) |> round()

afcon |>
  as_tibble() |>
  pivot_longer(
    cols = c(data, headtails_br, fisher_br, quantile_br),
    names_to = "class_name",
    values_to = "class"
  ) |>
  mutate(
    class_name = case_when(
      class_name %in% c("data", "original") ~ "Original values (rescaled)",
      class_name == "headtails_br" ~ "Head/tail breaks",
      class_name == "fisher_br" ~ "Fisher–Jenks",
      TRUE ~ "Quantiles"
    )
  ) |>
  mutate(class_name = fct_inorder(class_name)) |>
  ggplot() +
  geom_density(
    aes(x = class, color = class_name, linetype = class_name),
    key_glyph = draw_key_path,
    trim = TRUE,
    adjust = .75,
    linewidth = 0.8
  ) +
  scale_y_continuous(labels = label_comma()) +
  scale_color_viridis_d() +
  scale_linetype_manual(values = c("solid", "dashed", "dashed", "dashed")) +
  labs(
    title = "How classification methods distribute observations",
    subtitle = "Smoothed distributions of class indices",
    x = "Rescaled value / Class index",
    y = "Estimated density",
    color = "Classification method",
    linetype = "Classification method"
  )

library(giscoR)
library(sf)

africa <- gisco_get_countries(
  resolution = 60,
  region = "Africa",
  epsg = 3857
) |>
  st_transform("ESRI:102024")

africa_focus <- st_linestring(rbind(
  c(-20, 40),
  c(60, 40),
  c(60, -40),
  c(-20, -40),
  c(-20, 40)
)) |>
  st_segmentize(5) |>
  st_cast("POLYGON") |>
  st_sfc(crs = 4326) |>
  st_transform(st_crs(africa)) |>
  st_bbox()


afcon_sf <- st_as_sf(afcon, crs = 4326, coords = c("x", "y")) |>
  st_transform(st_crs(africa)) |>
  arrange(desc(totcon))


afcon_sf |>
  mutate(original = rescale(totcon, to = c(1, 5))) |>
  pivot_longer(
    cols = c(original, headtails_br, fisher_br, quantile_br),
    names_to = "class_name",
    values_to = "class"
  ) |>
  mutate(
    class_name = case_when(
      class_name %in% c("data", "original") ~ "Original values (rescaled)",
      class_name == "headtails_br" ~ "Head/tail breaks",
      class_name == "fisher_br" ~ "Fisher–Jenks",
      TRUE ~ "Quantiles"
    )
  ) |>
  mutate(class_name = fct_inorder(class_name)) |>
  arrange(desc(totcon)) |>
  ggplot() +
  geom_sf(data = africa, color = "grey50", fill = "grey50") +
  geom_sf(aes(size = class, color = class)) +
  facet_wrap(~class_name) +
  coord_sf(
    xlim = c(africa_focus[c("xmin", "xmax")]),
    ylim = c(africa_focus[c("ymin", "ymax")]),
    expand = FALSE
  ) +
  guides(
    color = guide_legend(reverse = TRUE),
    size = guide_legend(reverse = TRUE)
  ) +
  scale_color_viridis_c(
    option = "inferno",
    direction = -1,
    alpha = 0.75,
    breaks = seq(1, 5, 1)
  ) +
  theme(
    panel.grid = element_blank(),
    axis.line = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  ) +
  labs(
    title = "Classification methods compared on a map",
    subtitle = "Symbol sizes represent original values or assigned classes",
    color = "Class index",
    size = "Class index"
  )
