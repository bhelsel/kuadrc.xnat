
# kuadrc.xnat

The goal of `kuadrc.xnat` is to ease the implementation of working with the 
XNAT API in R and offers ways to read in dicm file formats convert them to 
images that can be used on reports.

The original intent of this R package was to provide a way to connect to the 
XNAT API so that MRI .dicm images can be retrieved and converted to a .png format
for their inclusion of feedback reports for our Down syndrome Cohort at the
University of Kansas Alzheimer's Disease Research Center. This is part of an
automated workflow to pull together data from different data sources for the
feedback reports.

### Installation

You can install the development version of kuadrc.xnat by using the `devtools`
package:

``` r
devtools::install_github("bhelsel/kuadrc.xnat")
```

### Easing the XNAT API Validation

We have made the XNAT API Validation process simple through our `validate_credentials`
function which gets called each time a user makes a call to a XNAT API endpoint.
Upon the first use of any of the kuadrc.xnat functions, the `validate_credentials`
will prompt the user to add the server, alias, and secret to their "~/.Renviron"
file. The alias and secret can be added by entering your username and password
into the R console when prompted or logging into your XNAT server and manually
generating an alias token to retrieve the alias and secret to copy and paste
into the R console. This step must be completed before a successful API call
can be made to XNAT, but the user may choose to bypass the alias and secret
by entering in their username and password. 

### Main API Endpoint Functions

Currently, there are four primary functions to retrieve metadata with an
associated user's account. These functions include:

|Functions|XNAT Documentation|
|:---------:|:------------------:|
|`get_projects`| https://wiki.xnat.org/xnat-api/project-api|
|`get_subjects`| https://wiki.xnat.org/xnat-api/subject-api|
|`get_experiments`| https://wiki.xnat.org/xnat-api/experiment-api|
|`get_scans`| https://wiki.xnat.org/xnat-api/image-session-scans-api|

The `get_projects` function will return all projects authorized to the user. This 
function also has an argument `name` that will match and return the project ID.
This is useful when building the URL to extract the images. The URL is constructed
within each of these 4 functions using the `construct_url` function. By default, 
without adding any arguments, the `get_subjects` and `get_experiments` will return
all subjects and experiments, respectively, authorized to a user. This is useful 
when you are looking for an experiment number for the `get_scans` function which
is what is ultimately used to return images.

Here is some examples of the functions and what it might look like in an R Script:

```r

project_id <- get_projects(name = "down-syndrome-cohort")

list_of_subjects <- get_subjects(project = project_id)

experiment_id <- get_experiments(project = project_id, subject = list_of_subjects[1])

url_for_download <- get_scans(experiment = experiment_id)

```

Knowing the project and subject IDs (e.g., having them in a data set) can speed 
up the process of identifying the API endpoint for downloading the images. We
are in the proces of working on functions to retrieve, download, and convert the
images from .dicm to a usable format for reports and will eventually add parallel
processing so it can be completed concurrently for multiple subjects.

Please reach out to Brian Helsel <bhelsel@kumc.edu> to provide feedback or if you
have any questions. 







