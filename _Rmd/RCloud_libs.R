Toinstall = c('abind','antiword','ape', 'askpass', 'assertthat', 'AUC', 'backports', 'base64enc', 'bdvis', 
              'bindr', 'bindrcpp', 'BiocInstaller', 'bit', 'bit64', 'bitops', 'blob', 'bold', 'boot', 'brew',               'broom', 'Cairo', 'cairoDevice', 'callr', 'car', 'carData', 'cartogram', 'cartography', 
              'caTools', 'cellranger', 'chron', 'class', 'classInt', 'cli', 'clipr', 'clisymbols', 'clue',
              'cluster', 'codetools', 'colorspace', 'colourpicker', 'compare', 'countrycode', 'crayon',
              'crosstalk', 'crul', 'curl', 'data.table', 'DBI', 'dbplyr', 'DEoptimR', 'desc', 'DescTools',
              'devtools', 'dichromat', 'digest', 'doParallel', 'dotCall64', 'dplyr', 'e1071', 'ellipsis',
              'enc', 'evaluate', 'expm', 'extrafont', 'extrafontdb', 'fansi', 'farver', 'fields', 'fontcm',
              'forcats', 'foreach', 'foreign', 'formatR', 'futile.logger', 'futile.options', 'fuzzyjoin',
              'gdtools', 'generics', 'geoaxe', 'geojson', 'geojsonio', 'geonames', 'geosphere', 'gganimate',
              'ggmap', 'ggplot2', 'ggrepel', 'gh', 'git2r', 'glue', 'gplots', 'gridBase', 'gridExtra',
              'grImport2', 'gsubfn', 'gtable', 'gtools', 'haven', 'hexbin', 'highr', 'hms', 'htmltools',
              'htmlwidgets', 'httpcode', 'httr', 'igraph', 'ini', 'iterators', 'jpeg', 'jqr', 'jsonlite',
              'KernSmooth', 'knitr', 'labeling', 'laeken', 'lambda.r', 'later', 'lattice', 'latticeExtra',
              'lazyeval', 'LDPD', 'leaflet', 'leafletR', 'lme4', 'lmtest', 'lpSolve', 'lubridate', 'lwgeom',
              'magrittr', 'manipulate', 'manipulateWidget', 'mapdata', 'mapproj', 'maps', 'maptools',
              'mapview', 'markdown', 'MASS', 'Matrix', 'MatrixModels', 'memoise', 'mgcv', 'mime', 'miniUI',
              'minqa', 'misc3d', 'mnormt', 'modelr', 'munsell', 'mvtnorm', 'natserv', 'ndjson', 'nleqslv',
              'nlme', 'nloptr', 'NLP', 'nnet', 'numDeriv', 'oai', 'openssl', 'openxlsx', 'osmdata',
              'packcircles', 'pacman', 'pbkrtest', 'pdftools', 'pillar', 'pixmap', 'pkgbuild', 'pkgconfig',
              'pkgload', 'plogr', 'plot3D', 'plotly', 'plotrix', 'plyr', 'png', 'polyclip', 'praise',
              'prettymapr', 'prettyunits', 'prioritizr', 'pROC', 'processx', 'profvis', 'progress',
              'promises', 'proto', 'protolite', 'proxy', 'ps', 'psych', 'purrr', 'quantreg', 'R6', 'ranger',
              'RANN', 'raster', 'rasterVis', 'rattle', 'rattle.data', 'rcmdcheck', 'RColorBrewer', 'Rcpp',
              'RcppEigen', 'RCurl', 'readODS', 'readr', 'readtext', 'readxl', 'rematch', 'rematch2',
              'remotes', 'rentrez', 'reprex', 'reshape', 'reshape2', 'rgbif', 'rgdal', 'rgeos', 'rgl',
              'Rglpk', 'RgoogleMaps', 'RGraphics', 'RGtk2', 'rio', 'ritis', 'rlang', 'rmarkdown',
              'rnaturalearth','rnaturalearthdata', 'rnaturalearthhires', 'rncl', 'robustbase', 'ROCR',
              'rosm', 'rotl', 'rpart', 'rprojroot', 'rredlist', 'RSQLite', 'rstudioapi', 'rsvg', 'Rttf2pt1',
              'rvest', 'rworldmap', 'sampling', 'satellite', 'scales', 'selectr', 'sessioninfo', 'sf',
              'shiny', 'shinydashboard', 'shinyjs', 'showtext', 'showtextdb', 'slam', 'SnowballC',
              'solrium', 'sourcetools', 'sp', 'spam', 'sparkTable', 'SparseM', 'spData', 'sqldf',
              'StatMatch', 'streamR', 'stringdist', 'stringi', 'stringr', 'striprtf', 'styler', 'survey',
              'survival', 'svglite', 'sys', 'sysfonts', 'tabulizer', 'taxize', 'testthat', 'textreadr',
              'textshape', 'tibble', 'tidyr', 'tidyselect', 'tidyverse', 'tinytex', 'tm', 'tmap', 
              'tmaptools', 'treemap', 'triebeard', 'tweenr', 'units', 'urltools', 'usethis', 'utf8', 'uuid',
              'V8', 'vcd', 'VennDiagram', 'VIM', 'viridis', 'viridisLite', 'webshot', 'whisker', 'wicket',
              'WikidataR', 'WikipediR', 'wikitaxa', 'withr', 'wordcloud', 'worrms', 'WriteXLS', 'xfun',
              'xlsx', 'xlsxjars', 'XML', 'xml2', 'xopen', 'xtable', 'yaml', 'zip', 'zoo', 'base', 
              'compiler', 'datasets', 'graphics', 'grDevices', 'grid', 'methods', 'parallel', 'splines',
              'stats', 'stats4', 'tcltk', 'tools', 'utils', 'leaflet', 'leaflet.extras'
              )
Toinstall=sort(unique(Toinstall))

library(dplyr)
alreadyInst=as.data.frame(installed.packages(),stringsAsFactors = FALSE)
alPack=list(alreadyInst$Package) %>% unlist() %>% unique() %>% sort()
diff=subset(Toinstall,!Toinstall %in% alPack)
install.packages(diff,dependencies = TRUE)

