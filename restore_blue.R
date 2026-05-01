css <- readLines("www/styles.css")
# Replace any remnants of red rgba to blue
css <- gsub("rgba\\(255,0,60,", "rgba(0,174,239,", css)
css <- gsub("rgba\\(255,26,26,", "rgba(0,174,239,", css)
css <- gsub("rgba\\(255,64,64,", "rgba(0,255,170,", css)
css <- gsub("rgba\\(255,0,85,", "rgba(176,0,255,", css)
css <- gsub("rgba\\(255,85,0,", "rgba(0,238,255,", css)
css <- gsub("rgba\\(204,0,0,", "rgba(176,0,255,", css)
css <- gsub("rgba\\(255,32,32,", "rgba(0,238,255,", css)
css <- gsub("rgba\\(13,0,0,", "rgba(5,5,5,", css)
writeLines(css, "www/styles.css")

gl <- readLines("global.R")
gl <- gsub("#080808", "#050505", gl, fixed=TRUE)
gl <- gsub("#110000", "#111111", gl, fixed=TRUE)
gl <- gsub("#0a0000", "#0a0a0a", gl, fixed=TRUE)
gl <- gsub("#66000040", "#00aeff40", gl, fixed=TRUE)
gl <- gsub("#ff003c15", "#00aeff15", gl, fixed=TRUE)
gl <- gsub("#ff1a1a15", "#00aeff15", gl, fixed=TRUE)
gl <- gsub("#cc0000", "#b000ff", gl, fixed=TRUE)
writeLines(gl, "global.R")

sr <- readLines("server.R")
sr <- gsub("bg = \"#080808\"", "bg = \"#050505\"", sr, fixed=TRUE)

# Fix scatter_plot
sr <- gsub("geom_point(color = \"#ff003c\"", "geom_point(color = \"#00aeff\"", sr, fixed=TRUE)
sr <- gsub("geom_smooth(method = \"lm\", color = \"#ff5500\", fill = \"#ff550014\"", "geom_smooth(method = \"lm\", color = \"#00eeff\", fill = \"#00eeff14\"", sr, fixed=TRUE)
sr <- gsub("geom_smooth(method = \"lm\", color = \"#ff2020\", fill = \"#ff404020\"", "geom_smooth(method = \"lm\", color = \"#00eeff\", fill = \"#00eeff14\"", sr, fixed=TRUE)

# Fix actual_vs_pred
sr <- gsub("geom_point(color = \"#ffea00\"", "geom_point(color = \"#00ffaa\"", sr, fixed=TRUE)
sr <- gsub("geom_abline(slope = 1, intercept = 0, color = \"#ff003c\"", "geom_abline(slope = 1, intercept = 0, color = \"#00aeff\"", sr, fixed=TRUE)

# Fix residual_plot
sr <- gsub("geom_hline(yintercept = 0, color = \"#ff003c\"", "geom_hline(yintercept = 0, color = \"#00aeff\"", sr, fixed=TRUE)
sr <- gsub("geom_point(color = \"#ff0055\"", "geom_point(color = \"#b000ff\"", sr, fixed=TRUE)
sr <- gsub("geom_smooth(method = \"loess\", color = \"#ff5500\"", "geom_smooth(method = \"loess\", color = \"#00eeff\"", sr, fixed=TRUE)

# Fix residual_hist
sr <- gsub("geom_histogram(fill = \"#ff003c\", color = \"#050505\"", "geom_histogram(fill = \"#00aeff\", color = \"#050505\"", sr, fixed=TRUE)
sr <- gsub("geom_density(aes(y = after_stat(count)), color = \"#ff5500\"", "geom_density(aes(y = after_stat(count)), color = \"#00eeff\"", sr, fixed=TRUE)

# Fix coef_importance_plot
sr <- gsub("scale_fill_gradient(low = \"#ff003c\", high = \"#ffea00\")", "scale_fill_gradient(low = \"#00aeff\", high = \"#00eeff\")", sr, fixed=TRUE)

# Fix qq_plot
sr <- gsub("geom_point(color = \"#ff5500\"", "geom_point(color = \"#00eeff\"", sr, fixed=TRUE)
sr <- gsub("geom_abline(slope = sd(res), intercept = mean(res), color = \"#ff003c\"", "geom_abline(slope = sd(res), intercept = mean(res), color = \"#00aeff\"", sr, fixed=TRUE)

# Fix health_score
sr <- gsub("color <- if(score >= 80) \"#ffea00\" else if(score >= 60) \"#ff8c00\" else \"#ff003c\"", "color <- if(score >= 80) \"#00ffaa\" else if(score >= 60) \"#00eeff\" else \"#00aeff\"", sr, fixed=TRUE)

# Fix summary text colors
sr <- gsub("color:#ffea00", "color:#00ffaa", sr, fixed=TRUE)
sr <- gsub("color:#ff8c00", "color:#00eeff", sr, fixed=TRUE)
sr <- gsub("color:#ff003c", "color:#00aeff", sr, fixed=TRUE)

writeLines(sr, "server.R")
