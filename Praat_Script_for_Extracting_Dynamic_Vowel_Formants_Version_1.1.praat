###############################################################################################################
# Script name : Praat Script for Extracting Dynamic Vowel Formants.                                           #
# Extracts    : F1, F2, and F3 at 10 Equidistant Time Points (0% - 100%), mean F1-F3, mean f0, mean intensity #
# Author      : Anugil Velayudhan                                                                             #
# affiliation : University of York, United Kingdom.                                                           #
# Version     : 1.1                                                                                           #
# License     : MIT License                                                                                   #
# Copy right  : Copyright (c) 2025-2026 Anugil Velayudhan                                                     #
###############################################################################################################

############################## BASIC SETTINGS ##############################                                                                           

# Basic Form Settings

clearinfo

form Formant Analysis: Basic Settings

    choice Gender
        option Male
        option Female
 
    comment ---- Which vowel labels are used? ----
    
    text Vowel_labels a aa i ii u uu e ee o oo eh ai oi ei au

    comment ---- To Formant (burg) settings ----
    positive Time_step_(s) 0.0
    positive Maximum_number_of_formants 5
    positive Maximum_formant_males_(Hz) 5000
    positive Maximum_formant_females_(Hz) 5500
    positive Window_length_(s) 0.025
    positive Pre_emphasis_from_(Hz) 50

    comment ---- Additional settings ----
    integer Pitch_time_step 0
    positive Pitch_floor_(Hz) 75
    positive Pitch_ceiling_(Hz) 500
    positive Intensity_value_(dB) 100

    comment ---- Do you want to use Formant tracker? ----
    choice Use_formant_tracker
        option Yes
        option No
   
    comment ---- Who is the analyser? ----
    text Analysed_by AV
           
endform

if gender$ = "Male"
    timeStep = time_step
    maxNumFormants = maximum_number_of_formants
    maxFormantmale = maximum_formant_males 
    windowLength = window_length  
    preEmphasis = pre_emphasis_from
    pitchFloor = pitch_floor
    pitchCeiling = pitch_ceiling
    intensityValue = intensity_value
    analysedby$ = analysed_by$

elsif  gender$ = "Female" 

    timeStep = time_step
    maxNumFormants = maximum_number_of_formants
    maxFormantfemale = maximum_formant_females 
    windowLength = window_length  
    preEmphasis = pre_emphasis_from
    pitchFloor = pitch_floor
    pitchCeiling = pitch_ceiling
    intensityValue = intensity_value
    analysedby$ = analysed_by$

endif

if use_formant_tracker$ = "Yes"

    beginPause("Formant Tracker Settings")

        comment ("---- How many formant tracks do you want to use? ----")
        positive ("Number of Formant Tracks", 3)

        comment("Formant Reference Settings for Male")
        positive("male F1 reference (Hz)", 500)
        positive("male F2 reference (Hz)", 1485)
        positive("male F3 reference (Hz)", 2475)
        positive("male F4 reference (Hz)", 3465)
        positive("male F5 reference (Hz)", 4455)

        comment("Formant Reference Settings for Female")
        positive("female F1 reference (Hz)", 550)
        positive("female F2 reference (Hz)", 1650)
        positive("female F3 reference (Hz)", 2750)
        positive("female F4 reference (Hz)", 3850)
        positive("female F5 reference (Hz)", 4950)

    continue_procedure = endPause("Continue", 1)
 
    if continue_procedure = 1

        numFormantTracks = number_of_Formant_Tracks
        m_f1_ref = male_F1_reference
        m_f2_ref = male_F2_reference
        m_f3_ref = male_F3_reference
        m_f4_ref = male_F4_reference 
        m_f5_ref = male_F5_reference
        f_f1_ref = female_F1_reference
        f_f2_ref = female_F2_reference
        f_f3_ref = female_F3_reference
        f_f4_ref = female_F4_reference 
        f_f5_ref = female_F5_reference
    endif
endif
 
writeInfoLine ("Basic settings completed !")

############################## SELECT THE INPUT AND OUTPUT FOLDER ##############################                                                         

# The path to the dictionary containing .wav and .TextGrid files.
soundDictionary$ = chooseDirectory$ ("Select the folder where your dictionary files (.wav & .TextGrid) are stored")

# The output path for saving the results.
outputFolderPath$ = chooseDirectory$ ("Select the folder where you want to save the results")
outputFileName$ = "vowel_Formants.csv"
outputPath$ = outputFolderPath$ + "\" + outputFileName$
writeFileLine: "'outputPath$'", "file_Id,v_Phoneme,v_Start,v_End,v_Dur,syllable,syllable_Dur,word,word_Dur,pre_C,follow_C,F1_0,F1_10,F1_20,F1_30,F1_40,F1_50,F1_60,F1_70,F1_80,F1_90,F1_100,F2_0,F2_10,F2_20,F2_30,F2_40,F2_50,F2_60,F2_70,F2_80,F2_90,F2_100,F3_0,F3_10,F3_20,F3_30,F3_40,F3_50,F3_60,F3_70,F3_80,F3_90,F3_100,F1_mean,F2_mean,F3_mean,F0_mean,I_mean,Analyser"

# Ensure that the output directory exists.
createFolder: outputFolderPath$

# Display confirmation for paths.
writeInfoLine: "Dictionary Path: ", soundDictionary$
writeInfoLine: "Output File Path: ", outputPath$

# Create List of Files.
fileList = Create Strings as file list: "fileList", soundDictionary$ + "\*.wav"
numberOfFiles = Get number of strings
writeInfoLine: "File list has been successfully created!"

############################## LOOPING THROUGH FILES THEN TIER 1 ##############################                                                       


# Loop through all files
for i from 1 to numberOfFiles
    selectObject: fileList
    soundName$ = Get string: i

    # Extract base name
    baseName$ = soundName$ - ".wav"
    writeInfoLine: "Processing: " + baseName$

    # Define paths and read files
    soundFile = Read from file: soundDictionary$ + "\" + baseName$ + ".wav"
    textGridFile = Read from file: soundDictionary$ + "\" + baseName$ + ".TextGrid"

    # Loop through intervals on the Phone tier (Note: Tier 1 is the Phone tier)
    numberOfPhone = Get number of intervals: 1   

    for j from 1 to numberOfPhone
        selectObject: textGridFile
        phone$ = Get label of interval: 1, j
        
        # Check if the label is in the vowel list
        if index(vowel_labels$, phone$) > 0

        # Get start and end times of the vowel
        phoneStartTime = Get start time of interval: 1, j
        phoneEndTime   = Get end time of interval: 1, j
        vowelDuration  = phoneEndTime - phoneStartTime

        # Define time points (0% to 100%)
        time_zero = phoneStartTime
        time_ten = phoneStartTime + 0.1 * (phoneEndTime - phoneStartTime)
        time_twenty = phoneStartTime + 0.2 * (phoneEndTime - phoneStartTime)
        time_thirty = phoneStartTime + 0.3 * (phoneEndTime - phoneStartTime)
        time_forty = phoneStartTime + 0.4 * (phoneEndTime - phoneStartTime)
        time_fifty = phoneStartTime + 0.5 * (phoneEndTime - phoneStartTime)
        time_sixty = phoneStartTime + 0.6 * (phoneEndTime - phoneStartTime)
        time_seventy = phoneStartTime + 0.7 * (phoneEndTime - phoneStartTime)
        time_eighty = phoneStartTime + 0.8 * (phoneEndTime - phoneStartTime)
        time_ninety = phoneStartTime + 0.9 * (phoneEndTime - phoneStartTime)
        time_hundred = phoneEndTime
                          
        # Debugging: Check if vowel is found
        writeInfoLine: "Vowel found: " + phone$ + " (" + string$(phoneStartTime) + " - " + string$(phoneEndTime) + ")"       

        # Create formant: analysis using the Burg method and Track method
        selectObject: soundFile

        if gender$ = "Male" 
            formantObject = To Formant (burg)... timeStep maxNumFormants maxFormantmale windowLength preEmphasis
        elsif gender$ = "Female" 
            formantObject = To Formant (burg)... timeStep maxNumFormants maxFormantfemale windowLength preEmphasis
        endif

        selectObject: formantObject
             
        if gender$ = "Male" and use_formant_tracker$ = "Yes" 
            formantObject = Track... numFormantTracks m_f1_ref m_f2_ref m_f3_ref m_f4_ref m_f5_ref 1 1 1

        elsif gender$ = "Female" and use_formant_tracker$ = "Yes" 
            formantObject = Track... numFormantTracks f_f1_ref f_f2_ref f_f3_ref f_f4_ref f_f5_ref 1 1 1
        endif
      
        # Extract Formants from time points (0% to 100%)
        selectObject: formantObject

        f1_zero  = Get value at time... 1 time_zero Hertz Linear
        f2_zero  = Get value at time... 2 time_zero Hertz Linear
        f3_zero  = Get value at time... 3 time_zero Hertz Linear

        f1_ten   = Get value at time... 1 time_ten Hertz Linear
        f2_ten   = Get value at time... 2 time_ten Hertz Linear
        f3_ten   = Get value at time... 3 time_ten Hertz Linear

        f1_twenty   = Get value at time... 1 time_twenty Hertz Linear
        f2_twenty   = Get value at time... 2 time_twenty Hertz Linear
        f3_twenty   = Get value at time... 3 time_twenty Hertz Linear

        f1_thirty = Get value at time... 1 time_thirty Hertz Linear
        f2_thirty = Get value at time... 2 time_thirty Hertz Linear
        f3_thirty = Get value at time... 3 time_thirty Hertz Linear

        f1_forty = Get value at time... 1 time_forty Hertz Linear
        f2_forty = Get value at time... 2 time_forty Hertz Linear
        f3_forty = Get value at time... 3 time_forty Hertz Linear

        f1_fifty  = Get value at time... 1 time_fifty Hertz Linear
        f2_fifty  = Get value at time... 2 time_fifty Hertz Linear
        f3_fifty  = Get value at time... 3 time_fifty Hertz Linear

        f1_sixty = Get value at time... 1 time_sixty Hertz Linear
        f2_sixty = Get value at time... 2 time_sixty Hertz Linear
        f3_sixty = Get value at time... 3 time_sixty Hertz Linear

        f1_seventy = Get value at time... 1 time_seventy Hertz Linear
        f2_seventy = Get value at time... 2 time_seventy Hertz Linear
        f3_seventy = Get value at time... 3 time_seventy Hertz Linear

        f1_eighty = Get value at time... 1 time_eighty Hertz Linear
        f2_eighty = Get value at time... 2 time_eighty Hertz Linear
        f3_eighty = Get value at time... 3 time_eighty Hertz Linear

        f1_ninety  = Get value at time... 1 time_ninety Hertz Linear
        f2_ninety  = Get value at time... 2 time_ninety Hertz Linear
        f3_ninety  = Get value at time... 3 time_ninety Hertz Linear

        f1_hundred   = Get value at time... 1 time_hundred Hertz Linear
        f2_hundred   = Get value at time... 2 time_hundred Hertz Linear
        f3_hundred   = Get value at time... 3 time_hundred Hertz Linear

        # Get mean formant values over the entire duration
        selectObject: formantObject

        f1_mean = Get mean... 1 phoneStartTime phoneEndTime Hertz
        f2_mean = Get mean... 2 phoneStartTime phoneEndTime Hertz
        f3_mean = Get mean... 3 phoneStartTime phoneEndTime Hertz

        # Get mean pitch
        selectObject: soundFile
        pitchObject = To Pitch... 0.0 pitchFloor pitchCeiling 
        pitch_mean = Get mean... phoneStartTime phoneEndTime Hertz

        # Get mean intensity
        selectObject: soundFile
        intensityObject = To Intensity... intensityValue 0 yes
        intensity_mean = Get mean... phoneStartTime phoneEndTime dB

        # Find preceding consonant
        selectObject: textGridFile
            if j > 1
                precedingConsonant$ = Get label of interval: 1, j - 1
                precedingConsonantStart = Get start time of interval: 1, j - 1
                precedingConsonantEnd = Get end time of interval: 1, j - 1
                precedingConsonantDuration = precedingConsonantEnd - precedingConsonantStart
            else
                precedingConsonant$ = "NA"
                precedingConsonantDuration = 0
            endif

         # Find following consonant
            if j < numberOfPhone
                followingConsonant$ = Get label of interval: 1, j + 1
                followingConsonantStart = Get start time of interval: 1, j + 1
                followingConsonantEnd = Get end time of interval: 1, j + 1
                followingConsonantDuration = followingConsonantEnd - followingConsonantStart
            else
                followingConsonant$ = "NA"
                followingConsonantDuration = 0
            endif

        # Get syllable details (Note: Tier 2 is the Syllable tier)
        intervalIndex = Get interval at time: 2, (phoneStartTime + phoneEndTime) / 2
            if intervalIndex > 0
                syllableLabel$ = Get label of interval: 2, intervalIndex
                syllableStart = Get start time of interval: 2, intervalIndex
                syllableEnd = Get end time of interval: 2, intervalIndex
                syllableDuration = syllableEnd - syllableStart
            else
                syllableLabel$ = "NA"
                syllableDuration = 0
            endif

        # Get word details (Note: Tier 3 is the Word tier)
        intervalIndex = Get interval at time: 3, (phoneStartTime + phoneEndTime) / 2
            if intervalIndex > 0
                wordLabel$ = Get label of interval: 3, intervalIndex
                wordStart = Get start time of interval: 3, intervalIndex
                wordEnd = Get end time of interval: 3, intervalIndex
                wordDuration = wordEnd - wordStart
            else
                wordLabel$ = "NA"
                wordDuration = 0
 
            endif

        # Save to CSV file
            appendFileLine: "'outputPath$'",
                ...baseName$, ",", 
                ...phone$, ",", 
                ...phoneStartTime, ",", 
                ...phoneEndTime, ",", 
                ...vowelDuration, ",",
                ...syllableLabel$, ",", 
                ...syllableDuration, ",",  
                ...wordLabel$, ",", 
                ...wordDuration, ",", 
                ...precedingConsonant$, ",", 
                ...followingConsonant$, ",", 
                ...f1_zero, ",", 
                ...f1_ten, ",", 
                ...f1_twenty, ",", 
                ...f1_thirty, ",", 
                ...f1_forty, ",", 
                ...f1_fifty, ",", 
                ...f1_sixty, ",", 
                ...f1_seventy, ",", 
                ...f1_eighty, ",", 
                ...f1_ninety, ",", 
                ...f1_hundred, ",",
                ...f2_zero, ",", 
                ...f2_ten, ",", 
                ...f2_twenty, ",", 
                ...f2_thirty, ",", 
                ...f2_forty, ",", 
                ...f2_fifty, ",", 
                ...f2_sixty, ",", 
                ...f2_seventy, ",", 
                ...f2_eighty, ",", 
                ...f2_ninety, ",", 
                ...f2_hundred, ",",
                ...f3_zero, ",", 
                ...f3_ten, ",", 
                ...f3_twenty, ",", 
                ...f3_thirty, ",", 
                ...f3_forty, ",", 
                ...f3_fifty, ",", 
                ...f3_sixty, ",", 
                ...f3_seventy, ",", 
                ...f3_eighty, ",", 
                ...f3_ninety, ",", 
                ...f3_hundred, ",",
                ...f1_mean, ",",
                ...f2_mean, ",",
                ...f3_mean, ",",
                ...pitch_mean, ",",
                ...intensity_mean, ",",
                ...analysedby$

            writeInfoLine: "Data saved for " + baseName$
            writeInfoLine: "Formant Extraction Completed!"
        endif  
    endfor  
endfor  

appendInfoLine: newline$, newline$, "Whoo-hoo! It didn't crash!"

############################## END OF THE SCRIPT ##############################                                                                        



