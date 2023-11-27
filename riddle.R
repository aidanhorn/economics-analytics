

packages <- c(  "lubridate",
                "readr"     )
suppressMessages(invisible(lapply(packages, library, c=TRUE)))

day <- day(Sys.Date())
riddles <- read_csv("https://raw.githubusercontent.com/crawsome/riddles/main/riddles.csv",
                    show_col_types = FALSE  )
i = 1
resp = "0"
while(resp!="3") {
    message("\n")
    message(riddles[day+i, 1])
    Sys.sleep(5)
    resp <- readline(prompt="\nType 1 for answer, 2 for next riddle, 3 to end.\n")
    if (resp=="1") {
        message(riddles[day+i, 2])
        Sys.sleep(10)
        yn <- readline(prompt="\nNext riddle? Type Y or N.")
        if (yn %in% c("Y", "y", "yes", "Yes", "YES")) i = i+1
        else if (yn %in% c("N", "n", "no", "No", "NO")) q()
    } else if (resp=="2") i = i+1
    else if (resp=="3") q()
}