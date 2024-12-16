
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
can be made to XNAT. 

By default, the functions in the `kuadrc.xnat` package look for an alias and
secret within the "~/.Renviron" file. However, the user may choose to bypass the
alias and secret by entering in their username and password. The alias and
secret can also be added as arguments to the functions. The recognized arguments
include `username` and `password` or `alias` and `secret`, but no arguments are
needed if the alias and secret are stored in the "~/.Renviron" file.

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
up the process of identifying the API endpoint for downloading the images. To
download the .dicm images from the XNAT server, there is a function called
`xnat_download`. The only required argument is `outdir` for the output directory
where the files should be stored. If no other arguments are passed, the
`kuadrc.xnat` will take the user through an interactive program in the R console
to verify credentials and select the project, subject, experiment, and scans to
download. The user can also provide `project`, `subject`, `experiment`, and
`scan` information to bypass the interactive elements of the `kuadrc.xnat`
package and initiate the download faster. The interactive elements may be
helpful for those who don't know certain elements for how the scans are
classified. Here is an example of the `xnat_download` function with prespecified
arguments:

``` r

xnat_download(
  username = "XXXXXXX",
  password = "XXXXXXX",
  project = "123456",
  subject = "100100",
  experiment = "01",
  scan = "2-Axial-Scan"
)

```

Additionally, the `kuadrc.xnat` package contains other functionality to convert
the .dicm images to the .nii.gz format using the `convert_to_nifti` function as
well as plot and save the images to a png format using the `plot_nifti` and
`save_nifti_image` functions. The `convert_to_nifti` function only requires a
`directory` argument to the location of the folder that includes the "scans"
folder. The `plot_nifti` and `save_nifti_image` functions includes a few
different arguments to adjust the plane of view (i.e., axial, sagittal, and
coronal), image brightness, the `index` or slice represented, and the parameters
sent to the graphics device like image type, width, height, and resolution.


Please reach out to Brian Helsel <bhelsel@kumc.edu> to provide feedback or if you
have any questions. 







