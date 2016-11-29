# Irritatingly, California WARM notice data are made available only via pdf.
# This extracts the California WARN notices from the pdf of the CA EDD website, preps data, 
# and writes to csv 


library(tabulizer)
library(dplyr)

# Location of WARN notice pdf file. You'll need to update this as necessary.
location <- 'http://www.edd.ca.gov/jobs_and_training/warn/WARN-Report-for-7-1-2016-to-11-25-2016.pdf'

# Extract the table
out <- extract_tables(location)

# Combine extracted tables into one, excluding last page, which just has the totals
final <- do.call(rbind, out[-length(out)])

# table headers get extracted as rows with bad formatting. Dump them.
final <- as.data.frame(final[3:nrow(final), ])

# Column names
headers <- c('Notice.Date', 'Effective.Date', 'Received.Date', 'Company', 'City', 
             'No.of.Employees', 'Layoff/Closure')

# Apply custom column names
names(final) <- headers

# These dplyr steps are not strictly necessary for dumping to csv, but useful if further data 
# manipulation in R is required. 
final <- final %>%
    # Convert date columns to date objects
    mutate_each(funs(as.Date(., format='%m/%d/%Y')), Notice.Date, Effective.Date, Received.Date) %>%
    # Convert No.of.Employees to numeric
    mutate(No.of.Employees = as.numeric(levels(No.of.Employees)[No.of.Employees]))


# Write final table to disk
write.csv(final, file='CA_WARN.csv', row.names=FALSE)
