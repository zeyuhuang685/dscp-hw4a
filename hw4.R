rm(list = ls())

library(FITSio)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 2) {
  cat("usage: Rscript hw4.R <template spectrum> <data directory>\n")
  quit(status = 1)
}

template_file <- args[1]
data_dir <- args[2]

cB58 <- readFrameFromFITS(template_file)

y <- cB58$FLUX
m <- length(y)

spec_files <- list.files(data_dir, pattern = "\\.fits$", full.names = FALSE)

if (length(spec_files) == 0) {
  cat("No .fits files found in", data_dir, "\n")
  quit(status = 1)
}

# spec_files <- head(spec_files, 10)

out <- data.frame(
  distance = rep(NA_real_, length(spec_files)),
  spectrumID = spec_files,
  i = rep(NA_integer_, length(spec_files)),
  stringsAsFactors = FALSE
)

for (f_idx in seq_along(spec_files)) {
  fname <- spec_files[f_idx]
  fpath <- file.path(data_dir, fname)

  df <- readFrameFromFITS(fpath)

  xall <- df$flux
  maskall <- df$and_mask

  n <- length(xall)
  max_i <- n - m + 1

  if (max_i < 1) {
    out$distance[f_idx] <- Inf
    out$i[f_idx] <- NA_integer_
    next
  }

  best_r <- -Inf
  best_i <- NA_integer_

  for (i in 1:max_i) {
    x <- xall[i:(i + m - 1)]
    mask <- maskall[i:(i + m - 1)]

    ok <- (mask == 0) & is.finite(x) & is.finite(y)

    if (sum(ok) < 0.8 * m) next

    r <- suppressWarnings(cor(y[ok], x[ok]))

    if (is.finite(r) && r > best_r) {
      best_r <- r
      best_i <- i
    }
  }

  if (is.finite(best_r)) {
    out$distance[f_idx] <- 1 - best_r
    out$i[f_idx] <- best_i
  } else {
    out$distance[f_idx] <- Inf
    out$i[f_idx] <- NA_integer_
  }
}

out <- out[order(out$distance), ]

out_file <- paste0(basename(normalizePath(data_dir)), ".csv")

write.table(
  out,
  file = out_file,
  sep = ",",
  row.names = FALSE,
  col.names = FALSE,
  quote = FALSE
)