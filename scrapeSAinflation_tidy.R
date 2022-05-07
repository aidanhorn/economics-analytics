# Programmatically pull the latest CPI data from StatsSA's website.
# Aidan Horn (hrnaid001@myuct.ac.za)
# Southern Africa Labour and Development Research Unit (SALDRU), University of Cape Town
# Oct-Dec 2020

# setwd()
# myemail <- "your.email@gmail.com"

# This file can be run on your computer, using the raw URL: source("https://raw.githubusercontent.com/aidanhorn/tricks/master/scrapeSAinflation_tidy.R") , AFTER setting the working directory, as above.
# It will collect the latest inflation data from StatsSA's website, tidy it, then export it to an Excel file ("CPI.xlsx") and to a .csv file ("CPI.csv"), only if those files aren't up-to-date on your computer. You can thus run this script once a day, using the Task Scheduler, to always have the latest inflation data on your computer.

# Alternatively, you can just use the "CPI.csv" file that I keep updated on my Dropbox storage. Use the following code to import it as a tibble, into your R session:
# CPI <- read_csv("http://csv.cpi.aidanhorn.co.za")
# The latest inflation index (and base date) can then be integrated into your analyses programatically, if you desire to show numerical values with the most recent known level of prices. See an example at the bottom of this script.


# Currently loaded external packages
names(sessionInfo()$otherPkgs)
# List of required external packages
packages <- c(
        'RCurl',
        'rvest',
        'tidyverse',
        'lubridate',
        'readxl',
        'openxlsx'
    )
# Installs packages that need to be installed
new.packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
# Loads required packages into the library
invisible(lapply(packages, library, c=T))
# List of loaded external packages
names(sessionInfo()$otherPkgs)

# This is where StatsSA stores the CPI data file (as a .zip file)
partialfilename<-"http://www.statssa.gov.za/timeseriesdata/Excel/P0141%20-%20CPI(COICOP)%20from%20Jan%202008%20("

# String for the month that was 38 days ago.
CPImonth <- paste0(
        year(Sys.Date()-38),
        month(Sys.Date()-38) %>%
            sprintf("%02d", .)
    )
# Not much point to this script if the file already is there. This also prevents needless overwriting to cloud-synced files.
if (file.exists("CPI.xlsx")) { 
    existing_file <- read_xlsx("CPI.xlsx")
    maxmonth <- max(existing_file$date) %>%
            sub("-", "", .) %>%
            sub(" ", "", .) %>%     # just in case the format changes
            substr(1, 6)
    CPI.file.exists <- function () {
            stopifnot(maxmonth!=CPImonth)   # comment this out if you want to overwrite the files.
    }
} else CPI.file.exists <- function() {}
CPI.file.exists()

CPIfilename <- function () {
    paste0(
        partialfilename, 
        CPImonth,
        ").zip"
    )
}

# Is there a CPI file from the month that was 38 days ago? If not, redefine the {CPImonth} string to the previous month.
if ( url.exists(CPIfilename())) {} else {
    CPImonth <- paste0(
            year(Sys.Date()-68),
            month(Sys.Date()-68) %>%
                sprintf("%02d", .)
        )
    CPI.file.exists()
}

if ( url.exists(CPIfilename())) {} else {
    CPImonth <- paste0(
            year(Sys.Date()-98),
            month(Sys.Date()-98) %>%
                sprintf("%02d", .)
        )
    CPI.file.exists()
}

# If there is an error, please provide a Gmail address to send the error report to. This only works with Gmail.
if ( url.exists(CPIfilename())) {} else {
    library("mailR")
    send.mail(
        from = "sender@gmail.com",
        to = myemail,	# myemail is a character vector of Gmail addresses you want this error report to be sent to.
        subject = "StatsSA's CPI zip file name has changed",
        body = paste(
                "Hi there\n\nStatsSA no longer has its CPI file at",
                paste0(
                    partialfilename, 
                    CPImonth,
                    ").zip"
                ),
                " so the R script cannot pull the CPI data from their website.\n\nThanks,\nAn R bot"
            ),
        smtp = list(host.name = "aspmx.l.google.com", port = 25),
        authenticate = FALSE,
        send = TRUE
    )
    stop()
}


download.file(CPIfilename(), "CPI data.zip")
   unzip("CPI data.zip", paste0("Excel - CPI (COICOP) from January 2008 (", CPImonth, ").xlsx")) %>% # "Excel table from 2008.xls") %>%  # "Excel - CPI (COICOP) from Jan 2008.xls") %>%
   file.rename("CPI data.xlsx") # The file used to be an HTML file.

# HTMLtable <- read_html("CPI data.html") %>%
#   html_table()
XLSXtable <- read_xlsx("CPI data.xlsx")

# observe the duplicated rows:
XLSXtable %>%     # as_tibble(HTMLtable[[1]])
# XLStable %>%
    filter(
        duplicated(H03) | 
        duplicated(H03, fromLast=T)     # a hack to get both the duplicated rows
    ) %>% 
    select(3:7)

# tidying (mostly transposing)☺
# CPItable <- as_tibble(HTMLtable[[1]]) %>%
CPItable <- XLSXtable %>%
        select(-H01, -H02, -H14, -H17, -H18, -H25) %>%
        filter(!duplicated(H03, fromLast=T)) %>%
        mutate(
            H04=ifelse(!is.na(H05), H05, H04),
            H04=ifelse(
                    !is.na(H06), 
                    paste(
                        substr(H04, 1, nchar(H04)-1), # removes the "s" at the end of "deciles"
                        H06
                    ), 
                    H04
                ),
            H13=ifelse(H13=="Rural Areas", "Rural areas", H13),
            H13=ifelse(H13=="North-West", "North West", H13),
            H13=ifelse(H13=="Kwazulu-Natal", "KwaZulu-Natal", H13),
            H04=ifelse(H04=="Medical products", "Medical Products", H04),
            H04=ifelse(H04=="CPI for pensioners", "Pensioners", H04),
            H04=ifelse(H04=="Fuel", "Petrol", H04)
        ) %>%
        select(-H03, -H05, -H06) %>%
        pivot_longer(
            cols=-(1:2), 
            names_to=c("month", "year"), 
            names_prefix="MO", 
            names_sep=2, 
            values_to="index"
        ) %>%
        pivot_wider(
            names_from=H04,
            values_from=index
        ) %>%
        mutate(
            date=ymd(paste(year, month, "15", sep="-"))
        ) %>%
        rename(Region=H13) %>%
        relocate(date, .after=year) %>%
        arrange(Region!="Rural areas") %>%
        arrange(Region!="Total country") %>%
        arrange(Region!="All urban areas")


# Export data to Excel
wb <- createWorkbook()
addWorksheet(wb, sheetName="Inflation indicies")
writeData(wb, sheet="Inflation indicies", x=CPItable)
setColWidths(wb, sheet="Inflation indicies", cols=seq(1, 4), widths=c(15, 5, 5, 10))
freezePane(wb, sheet="Inflation indicies", firstActiveRow=2, firstActiveCol=5)
saveWorkbook(
    wb,
    file="CPI.xlsx",
    overwrite=T
)


# Export to .csv
write_csv(
    x=CPItable,
    path="CPI.csv",
    na=""
)

# The .csv file can now be pulled programmatically. For example:
CPI <- read_csv("http://csv.cpi.aidanhorn.co.za") %>%
        select(1:5) %>%
        filter(Region=="All urban areas")

# Headline CPI is the CPI for all urban areas, all items.
latest.CPI <- setNames(
        CPI$`All Items`[nrow(CPI)], 
        paste( 
            month.name[month(CPI$date[nrow(CPI)])], 
            year(CPI$date[nrow(CPI)]) 
        )
    )

