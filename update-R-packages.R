# 1. Prerequisite: Install cranlogs if you don't have it
if (!require("cranlogs", quietly = TRUE)) {
  message("Installing 'cranlogs' to fetch package popularity data...")
  install.packages("cranlogs")
  library(cranlogs)
}

# 2. Get the list of outdated packages
message("Checking for outdated packages...")
old_pkgs_matrix <- old.packages()

if (is.null(old_pkgs_matrix)) {
  message("Great news! All your packages are up to date.")
  
} else {
  # Convert to data frame
  df <- as.data.frame(old_pkgs_matrix, stringsAsFactors = FALSE)
  
  # 3. Define a function to categorize the update type
  get_update_type <- function(curr, new) {
    v_curr <- package_version(curr)
    v_new  <- package_version(new)
    
    if (v_new[1, 1] > v_curr[1, 1]) {
      return("MAJOR") # e.g. 1.5 -> 2.0
    } else if (v_new[1, 2] > v_curr[1, 2]) {
      return("Minor") # e.g. 1.5 -> 1.6
    } else {
      return("Patch") # e.g. 1.5.1 -> 1.5.2
    }
  }
  
  # Apply the function row by row
  df$Type <- mapply(get_update_type, df$Installed, df$ReposVer)
  
  # 4. Fetch Popularity Data (Last Month's Downloads)
  message(paste("Fetching download stats for", nrow(df), "packages..."))
  
  # Get daily downloads for last month
  downloads <- cranlogs::cran_downloads(packages = df$Package, when = "last-month")
  
  # Aggregate to total monthly downloads per package
  # (cran_downloads returns daily data, so we sum it up)
  pop_stats <- aggregate(count ~ package, data = downloads, sum)
  
  # Merge popularity back into the main dataframe
  df_final <- merge(df, pop_stats, by.x = "Package", by.y = "package", all.x = TRUE)
  
  # 5. Sort the Data
  # Priority: 
  # 1. Major updates first (Descending)
  # 2. Most popular packages second (Descending count)
  df_final <- df_final[order(df_final$Type, -df_final$count), ]
  
  # Cleanup columns for the final view
  final_view <- df_final[, c("Package", "Type", "Installed", "ReposVer", "count")]
  colnames(final_view)[5] <- "Downloads_30d" # Rename for clarity
  
  # 6. Display the High Priority Updates
  print(head(final_view, 15))

  # 7. Update the major updates
  major_packages <- final_view %>% filter(Type == "MAJOR") %>% pull(Package)
  install.packages(major_packages)
}