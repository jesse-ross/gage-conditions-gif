# gage conditions

This repo contains code used to create the recurring `U.S. River Conditions` animation series, an example of which can be seen [here](https://www.usgs.gov/media/videos/us-river-conditions-january-march-2022). The name of this repo is a bit of a misnomer because at present this code will produce a video file, not a gif. However, the code used to create a gif version is still available in `6_visualize/src/combine_animation_frames.R` > `combine_animation_frames_gif()`.

*Instructions generated by Lindsay Platt*

## Before you build

Note that before you can just build this as the code suggests, you will have to have the appropriate permissions, which we grant to internal users and close collaborators. This includes access to the AWS S3 bucket with historic daily streamflow output from the `national-flow-observations` pipeline and a Google Drive folder for intermediate data products.

Also, note that this repo was one of the first `scipiper` repos that we constructed and is not following all of the best practices that were learned later (*ahem* the over use of `force=TRUE` *ahem*). In the spirit of "if it's not broken, don't fix it" and prioritization of future projects rather than this known technical debt, we will just ignore such quirks here unless they disrupt our ability to create the animation from this repo.

## How to build this animation

The process to create this animation is almost entirely automated using the (now dormant) custom dependency management R package, [`scipiper`](https://github.com/USGS-R/scipiper). There is a bit of manual work required to create and then prepare the animation's event/text callouts. Otherwise, it is mostly running chunks of code. The entire process is outlined below (*steps that aren't code, but are human checks are italicized in parentheses*).

1. [Change the animation dates and prepare the new data](#change-the-animation-dates-and-prepare-the-new-data) (*notify Web Comms and GWSIP team that this process has begun*)
1. [Create a new blank animation to use for event callout inspiration](#create-a-new-blank-animation-to-use-for-event-callout-inspiration)
1. [Gather event callouts and add to the animation](#gather-event-callouts-and-add-to-the-animation) (*work with GWSIP collaborators & involve IIDD reviewers as necessary*)
1. [Tweak event callout timing and appearance](#tweak-event-callout-timing-and-appearance)
1. [Generate final video animation](#generate-final-video-animation) (*get it approved by IIDD reviewers during this step, after approval ask Web Comms to start the video description paragraph*)
1. [Run code for simple-to-produce outreach artifacts](#run-code-for-simple-to-produce-outreach-artifacts) (*ask Web Comms to upload the VisID thumbnail to Drupal, then submit Drupal video upload form with link to that thumbnail*)
1. [Restructure code and build a new Instagram version](#restructure-code-and-build-a-new-instagram-version) (*share this and other outreach artifacts with Web Comms so the release package can be ready*)

The outputs from following this full process should be the following files:

* `6_visualize/out/river_conditions_[month start]_[month end]_[year]_twitter.mp4`
* `6_visualize/out/river_conditions_[month start]_[month end]_[year]_visid.mp4`
* `6_visualize/out/river_conditions_[month start]_[month end]_[year]_facebook.mp4`
* `6_visualize/out/river_conditions_[month start]_[month end]_[year]_reddit.mp4`
* `6_visualize/out/river_conditions_[month start]_[month end]_[year]_carousel.png`
* `6_visualize/out/river_conditions_[month start]_[month end]_[year]_visid_thumbnail.png`
* `6_visualize/out/river_conditions_[month start]_[month end]_[year]_square_thumbnail.png`
* `6_visualize/out/river_conditions_[month start]_[month end]_[year]_insta.mp4`

### 1. Change the animation dates and prepare the new data

#### Update the dates

Open `viz_config.yml` and make sure that the following items are correct:

1. Start/end entries for `vizDates`, which refer to the dates that will be shown as animation frames and for which data will be pulled. 
1. Start/end entries for `wheelDates`, which refer to the start/end dates for the current water year and are used to construct the date wheel visual on the bottom left of the animation. These shouldn't need to change every quarter.
1. The text for `title_cfg > subtitle` shows the appropriate dates. There are two instances of this item in the file, one is commented out further down the page in the "Instagram version" of the animation `viz_config.yml` (we will cover how to use that later).

We typically build these quarterly and kickoff this step immediately after a quarter has ended. So, we start this step on ...

| Quarter | Date to kickoff pipeline |
|--|--|
| Quarter 1 (Oct 1 - Dec 31) | January 1st                                                                 |
| Quarter 2 (Jan 1 - Mar 31) | April 1st                                                                   |
| Quarter 3 (Apr 1 - Jun 30) | July 1st *(note that this timing can be tricky given the July 4th holiday)* |
| Quarter 4 (Jul 1 - Sep 30) | October 1st |

#### Run code to download the data

First, verify that you are logged into Google Drive (GD). If you don't do this step or it times out, it can error on the last step of any given data download which pushes the data to GD (wah wah). If the command gives you multiple account options, make sure you click the account that was given permission to this repo's GD folder.

```r
googledrive::drive_auth()
```

Next, actually download the data by running the following code, which kicks off the lengthy data processing steps. 

```r
source('helper_fxns_pipeline.R')
rebuild_gage_data()
```

Note that this will take multiple hours. I usually plan on kicking this off in the morning and then getting back to it right at the end of the day, or even the next day. It also prints a lot to the console.

### 2. Create a new blank animation to use for event callout inspiration

Unless you have already know what the callouts will be, you should generate a blank version of the animation to use and share with collaborators in order to generate event callouts. If you already have callouts, still do the configuration steps here but don't bother rebuilding the animation frames until after you've followed the instructions further down to incorporate callouts into the animation.

#### Configuration step: clear `6_visualize/tmp`

In the end, the animation is created by stitching together a bunch of individual PNG frames. The code is currently setup to use any file within the folder `6_visualize/tmp`. If you have previously built this animation, you will likely already have files in that location and need to clear (or rename) the folder to prevent old frames from appearing in your new visualization. If this folder doesn't exist for you, please create it and leave it empty for now.

**Troubleshooting:** Note that I included "or rename" as an option because sometimes you need to quickly rebuild the full animation but don't need to rebuild each animation frame. By renaming the folder, you can always go back later, put the name back to `6_visualize/tmp` and then build the animation using those previous frames. It's a nice workaround if you need it.

#### Configuration step: clear `callouts_cfg.yml`

The animation's event callouts are added via the `callouts_cfg.yml` file. This file has a very specific structure so that the code can grab the information it needs to add them to the animation. Details about how to construct this file are included later on.

Create an empty `callouts_cfg.yml` file. If there is already an existing `callouts_cfg.yml` file in your directory, rename or delete it. I like to save previous versions of this file until the next water year begins in order to make the full water year animation creation easier. So, I would rename using the appropriate water year and quarter identifiers, e.g. `callouts_cfg_wy21_q2.yml`, and then delete ones from previous water years at a later date. Once you've either renamed or deleted `callouts_cfg.yml` (or it never existed to begin with), run `file.create("callouts_cfg.yml")` to create the empty version. 

**Troubleshooting:** Note that the `callouts_cfg.yml` file must exist for the rest of the code to run, even if it is just empty.

#### Build all animation frames and then the first, blank animation

Now that you don't have any files in `6_visualize/tmp` or any content in `callouts_cfg.yml`, you can build the initial, blank version of the animation. 

The animation is chunked into four sections:

1. `intro` - the title slide that fades in and out
1. `timestep` - each day's data with the map, datewheel, and text callouts updating
1. `pause` - the last frame of the animation repeated for a certain amount of time
1. `final` - the final informational statement about GWSIP that fades in and out

To build the animation frames, we can use the helper function called `rebuild_frame_sections()`. You can turn on/off the different sections to build one or more types of animation frames. At this stage, we need to get an initial build for all of the frames. To do so, run the following:

```r
source('helper_fxns_pipeline.R')
rebuild_frame_sections(intro = TRUE, timestep = TRUE, pause = TRUE, final = TRUE)
```

To stitch the completed frames together into a single video animation, run the following but updated the `new_name` argument to follow this pattern: `river_conditions_[month start]_[month end]_[year]_draft.mp4`.

```r
source('helper_fxns_pipeline.R')
rebuild_video(new_name = 'river_conditions_apr_jun_2022_draft.mp4')
```

Now, you can go view the draft animation and then share with collaborators to get event callout input.

### 3. Gather event callouts and add to the animation

#### Populate the initial `callouts_cfg.yml`

Provide callouts in a table with three columns: `Start`, `End`, and `Label` (as shown below).

Start | End | Label
-- | -- | --
4/5/2022 | 4/21/2022 | Fronts bring high water to parts of the Eastern and Southern U.S.
4/23/2022 | 6/7/2022 | Rain and snowmelt bring flooding to the Upper Midwest
4/27/2022 | 5/6/2022 | A dry period for the Mid-Atlantic

Then, save the callouts table in an Excel file called `input_callouts.xlsx` and run the following code to generate the initial `callouts_cfg.yml` file.

```r
source('helper_fxns_pipeline.R')
generate_callout_cfg_from_xlsx()
```

#### Update the `callouts_cfg.yml`

The initial callouts from the table were inserted into a yml structure with the default settings for each callout as specified in `1_fetch/in/callout_template.mustache`. Now that those initial callouts are there, it is time to go update their settings before rebuilding the animation. You can do these somewhat in the order written below, but there is also some iteration that will need to occur.

* **Single or multi-line text.** Decide whether you want the text to appear on one line or multiple lines. By default the text will appear on one line. If you want to create multiple lines, you will need to add square brackets around the text string and then make each line a string separated by commas, e.g. `["This is line 1", "and this is line 2"]`.
* **Text justification.** Use `pos` to declare whether you want the text to appear left justified (`pos = 4`), right justified (`pos=2`), or centered (`pos=1` or `pos=3`).
* **Text location.** Adjust `x_loc` and `y_loc` to change where the text appears. The value of `pos` will matter here since pos changes whether your text is below (`pos=1`), left of (`pos=2`), above (`pos=3`), or right of (`pos=4`) the x and y location you specify. The x and y location values are the fraction corresponding to the full image, starting from the bottomleft. See `6_visualize/in/frame_grid_xy_callout_locations.png` for some helpful positions of x and y location values and where they appear on the animation frame.
* **Event type.** Each event callout is given a box indicating the event duration on the date wheel visual on the bottomleft of the frame. By default, events are given a blue color (`"#04507d"`) for `wheel_color`. Update the event to a red color (`"#ca0020"`) if the event describes a drought or dry event.

These are the only elements you need to change right now. We will iterate on the others later.

*You may be wondering what the `polygon` element under each callout is for ... don't worry about this and leave as the default. We will hopefully add information about those at a later date.*

#### Rebuild the frames and animation with the callouts

Using the initial callouts timing and placement added in the previous step, generate a new animation by updating the appropriate frames and then rebuild the video using the code below. We only need to rebuild the `timestep` and `pause` frames here because the `intro` and `final` frames don't feature any callouts (those should only need to be built once per version).

```r
source('helper_fxns_pipeline.R')
rebuild_frame_sections(timestep = TRUE, pause = TRUE)
rebuild_video()
```

**Troubleshooting:** Sometimes, I notice that the `pause` frames are not updating as they should. There are not many of them, so if this happens I delete the individual frames manually and then rebuild. To delete manually, find any frame in `6_visualize/tmp` prefixed with `frame_6000`.

### 4. Tweak event callout timing and appearance

This is usually where I spend the most hands-on time because it is where you iterate on how the callouts integrate with the animation. Usually, the first animation is not ready for publication because callouts may overlap each other visually or temporally, some may extend the full length of the animation which isn't very useful, and others may blip on and then off too quickly for a user to read. Below we detail the other attributes and methods that you can use to polish the final visualization.

#### Event timing

To understand how events overlap and what you may want to update about them, run this code to generate a plot showing all the events and when they appear in the animation. It uses the dates in `callouts_cfg.yml`, so if you update those and save that file, rerun this code to see the new plot.

```r
source('helper_fxns_pipeline.R')
generate_event_graph()
```

* **Event appearance on the datewheel.** The `event_dates` and `wheel_hierarchy` attributes determine how an event will appear on the datewheel in the bottomleft of the animation frame. The goal is for us to see all of the events in one view. You should mostly be adjusting `wheel_hierarchy` (which defaults to 1 but ranges from 0-3) to change which appear in front and short (`wheel_hierarchy=0`) or behind and tall (`wheel_hierarchy=3`). Sometimes, two events overlap by 1 day and you want them to be the same `wheel_hierarchy`. In this rare instance, I adjust the `event_dates` on one of them to be 1-2 days earlier or later for visual separation. While this is not ideal, it provides for the visual separation we need on the datewheel.
* **Event timing.** There are three attributes that deal with when a callout is visible - `text_dates`, `fade_in`, and `fade_out`. `text_dates` will match the `event_dates` by default. You can play with these dates and the number of frames it takes to `fade_in` and `fade_out` to adjust when the text appears on the map. Changing the `text_dates` is independent of the `event_dates` (which should be mostly left alone). Adjusting the dates we see the text is especially necessary for events that are super short (like flash floods) or super long (like extended drought) in duration.

#### Event text appearance

Use the following items in `callouts_cfg.yml` for each callout to adjust its appearance.

* **Text location, justification, and layout.** Described earlier so that you could get an initial view with callouts, these same elements (`label`, `pos`, `x_loc`, `y_loc`) are likely to be adjusted during your polishing iterations. 
* **Text size.** You can increase or decrease the text size from the default of `cex=6`, but we recommend not going smaller if possible.
* **Box behind text.** `add_box` is initially left blank which means that no box will be added behind the text. If your text is particularly diffcult to read given the data points behind it's location, you may want to add a grey box by changing to `add_box=TRUE`.

As you iterate through the text appearance, you may be interested in generating just a single frame that occurs during all or one of the events you are adjusting. Below is some code to generate the individual frame(s). After you run the code, head over to `6_visualize/tmp` in the Files window of RStudio and sort by `Modified`. 

```r
# Build a frame for the middle of each event
source('helper_fxns_pipeline.R')
rebuild_event_frames()
```

You may even have a specific frame or range of frames you want to build. Here's some code to do that:

```r
source('helper_fxns_pipeline.R')

# Build a specific subset of days
days <- c(20220607:20220617)
rebuild_timestep_frames(days)

rebuild_timestep_frames(20220530) # Build a single frame
```

### 5. Generate final video animation

Once you are satisfied with the timing and appearance of your callouts and the datewheel, it is time to prepare a version to share out. You may already think you have a version ready to go, but I like to rebuild everything one more time knowing that my `callout_cfgs.yml` has the final up-to-date information, especially if I've been individually building frames as I iterated through callout appearance/timing.

To rebuild the full animation now that your callouts are finalized, rebuild the frames and the video animation as we did earlier. Update the `new_name` argument to match this scheme, `6_visualize/out/river_conditions_[month start]_[month end]_[year]_prototype.mp4`.

```r
source("helper_fxns_pipeline.R")
rebuild_frame_sections(intro = T, timestep = T, pause = T, final = T)
rebuild_video(new_name = "6_visualize/out/river_conditions_apr_jun_2022_prototype.mp4")
```

**Troubleshooting:** Remember, you might need to manually delete any pause pngs prefixed `frame_6000` before your video shows the most-up-to-date pause frames.

Next, I share this new video with others to get feedback and approval from the various groups I need to (GWSIP collaborators, Vizlab lead, Data Science Chief, and IIDD Director). I incorporate edits using the iterative techniques employed earlier and then regenerate one more version but rename to `6_visualize/out/river_conditions_[month start]_[month end]_[year]_twitter.mp4`:

```r
source("helper_fxns_pipeline.R")
rebuild_frame_sections(intro = T, timestep = T, pause = T, final = T)
rebuild_video(new_name = "6_visualize/out/river_conditions_apr_jun_2022_twitter.mp4")
```

Now, I share the Twitter version with collaborators in Web Communications through an MS Sharepoint folder so that they may start pulling together social media content. They will also help develop the descriptive text that can accompany the visualization to meet accessibility needs. I have found that providing them with a tabular version of the final events we feature is useful. To create that, run this code:

```r
source("helper_fxns_outreach_media.R")
output_table <- generate_callout_table()
View(output_table)
```

### 6. Run code for simple-to-produce outreach artifacts

While the social media plan is being developed using `6_visualize/out/river_conditions_[month start]_[month end]_[year]_twitter.mp4`, you can go ahead and start building all of the other social media content. There are a few configurations you need to set in the following codechunk.

```r
# Update to the appropriate [month start]_[month end]_[year] so that 
# this can be used when naming all other outputs
version_info <- "river_conditions_apr_jun_2022" 

# Update to the date you want to use for any still frames
frame_to_use <- "6_visualize/tmp/frame_20220616_00.png" 

# Specify the time (in seconds) associated with the frame you want 
# to appear as the Reddit preview
frame_to_use_t <- 38
```

Now that you have set those configurations, you can generate all of the media content using the code chunk below (except for Instagram, which we will cover after). Once these are complete, add them to the MS Sharepoint folder.

```r
# Load necessary functions
source("helper_fxns_outreach_media.R")

generate_visid_video(version_info) # USGS VisID animation
generate_facebook_video(version_info) # USGS Facebook animation
generate_reddit_video(version_info, frame_to_use_t) # Reddit animation
generate_carousel_image(version_info, frame_to_use) # USGS Drupal carousel image
generate_visid_thumb_image(version_info, frame_to_use) # USGS VisID thumbnail
generate_square_thumb_image(version_info, frame_to_use) # Square thumbnail
```

### 7. Restructure code and build a new Instagram version

Creating an Instagram-optimized version is not as simple as the others because we need the whole video to be square and in a different layout, where the different elements may be bigger or smaller than they appear on the rectangular versions. As such, we actually have to edit some of the `viz_config.yml`, rebuild the video animation, and then run the code snippet to turn the video into a square. So, this should be done after all of your other products are complete AND you really truly have the final approval (the others should be done after approval, but are easy to re-generate should you need to; this one is more complex and so should be done as one of the final steps before publishing).

#### Edit `viz_config.yml`, maybe `callouts_cfg.yml`

To update the `viz_config.yml` for Instagram:

1. Comment out everything below the comment `# Comment this out when building the Instagram version` and above `# End of regular version specs`. 
1. Then, *uncomment* everything below the comment that says `# End of regular version specs`. 
1. Double check that the text under `title_config > subtitle` has the appropriate dates and update if needed. 
1. Save the `viz_config.yml` file. 

While not always necessary, you may find that you want to increase the text size of callouts as specified in `callouts_cfg.yml`, so that they can easily be read in this Instagram version. By default, all of the callouts start with `cex=6`, but you may have made changes during your tweaking. We have found that a `cex` between 6 and 8 works best for the Instagram version. Save the file following any changes. Adjusting the size may require additional adjusting of the position or layout. 

**Before you potentially change `callouts_cfg.yml` for Instagram:** If you do change the `callouts_cfg.yml`, you should plan to retain a copy of your pre-Instagram `callouts_cfg.yml` for the default Twitter version only for use in the future water year version. Name the copy appropriately prior to making any changes related to Instagram.

#### Rebuild the animation

Now that the specifications for frames are updated and ready for the Instagram version, you need to rebuild all of the frames. Follow these steps:

1. We need to start with a blank `tmp/` folder. Instead of clearing the contents in the existing folder, rename it from `tmp/` to `tmp_twitter/`. I like to retain all of the Twitter-sized frames for easy access should we need rebuild the videos again. When you build the Instagram ones in the next step, they will automatically get added into a new `tmp/` folder.
2. Use the code below to build the Instagram-sized frames and create the new video. No need to rename the video created here from `year_in_review.mp4` to something else since we will process it further in the next step (and that code expects it to be named `year_in_review.mp4`).

```r
source("helper_fxns_pipeline.R")
rebuild_frame_sections(intro = T, timestep = T, pause = T, final = T)
rebuild_video()
```

#### Run code to create the square, Instagram version

Now that all of the frames and the initial video have been updated using our larger text and position adjustments, we are ready to apply the code below and cut/paste/convert the video into the final square, Instagram version. 

Make sure you update the value of `version_info` in the code below using the same syntax as we did with earlier code to match the appropriate month boundaries and year for which this is being generated. After you run this code, you should see a file called `6_visualize/out/river_conditions_[month start]_[month end]_[year]_insta.mp4`.

```r
source("helper_fxns_outreach_media.R")
version_info <- "river_conditions_apr_jun_2022"
generate_insta_video(version_info)
```

## Disclaimer

This software is in the public domain because it contains materials that originally came from the U.S. Geological Survey, an agency of the United States Department of Interior. For more information, see the official USGS copyright policy at [http://www.usgs.gov/visual-id/credit_usgs.html#copyright](http://www.usgs.gov/visual-id/credit_usgs.html#copyright)

This information is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The information has not received final approval by the U.S. Geological Survey (USGS) and is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the information. Although this software program has been used by the USGS, no warranty, expressed or implied, is made by the USGS or the U.S. Government as to the accuracy and functioning of the program and related program material nor shall the fact of distribution constitute any such warranty, and no responsibility is assumed by the USGS in connection therewith.

This software is provided "AS IS."


[
  ![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)
](http://creativecommons.org/publicdomain/zero/1.0/)
