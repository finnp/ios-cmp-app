#!/bin/bash

versionToRelease=$1
podspecFileName="ConsentViewController.podspec"
spConsentManagerFileName="ConsentViewController/Classes/SPConsentManager.swift"
readmeFileName="README.md"

# Function to check if an array contains a value
containsElement () {
    local e match="$1"
    shift
    for e; do
        [[ "$e" == "$match" ]] && return 0
    done
    return 1
}

updatePodspec() {
    echo "Updating podspec"
    local version=$1
    sed -i '' "s/\(s.version = '\)\(.*\)\('\)/\1${version}\3/" "$podspecFileName"
}

updateVersionOnSPConsentManager() {
    echo "Updating SPConsentManager"
    local version=$1
    sed -i '' "s/\(let VERSION = \"\)\(.*\)\(\"\)/\1${version}\3/" "$spConsentManagerFileName"
}

updateReadme() {
    echo "Updating README"
    local version=$1
    sed -i '' "s/\(pod 'ConsentViewController', '\)\(.*\)\('\)/\1${version}\3/" "$readmeFileName"
    sed -i '' "s/\(.upToNextMinor(from: \"\)\(.*\)\(\")\)/\1${version}\3/" "$readmeFileName"
}

createTag() {
    echo "Creating tag"
    local version=$1
    git tag -a "$version" -m "'$version'"
    gitPush $dryRun "--tags"
}

podInstall() {
    cd Example
    pod install
    cd ..
}

gitPush() {
    local dryRun=$1
    local gitArgs=$2
    if [ $dryRun -eq 0 ]; then
        echo "git push $gitArgs"
    else
        git push "$gitArgs"
    fi
}

podTrunk() {
    local dryRun=$1
    if [ $dryRun -eq 0 ]; then
        echo "pod trunk push ConsentViewController.podspec --verbose"
    else
        pod trunk push ConsentViewController.podspec --verbose
    fi
}

release () {
    local version=$1
    local dryRun=$2

    echo "Releasing stuff..."
    updatePodspec $version
    updateVersionOnSPConsentManager $version
    updateReadme $version
    git add .
    git commit -m "'update version to $version'"
    podInstall
    git add .
    git commit -am "'run pod install with $version'"
    bash ./buildXCFrameworks.sh
    git add .
    git commit -m "'update XCFrameworksfor $version'"
    gitPush $dryRun
    # git checkout master
    # git merge develop
    createTag $version
    gitPush $dryRun
    podTrunk $dryRun
    git checkout develop
}


# Function to check if a string matches the SemVer pattern
isSemVer() {
    local semver_regex="^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$"
    [[ $1 =~ $semver_regex ]]
}

printUsage() {
    printf "Usage:\n"
    printf "\t./release x.y.z\n"
}

printHelp() {
    printf "Script used to release iOS/tvOS SDK.\n"
    printf "Execute it from a clean state 'develop' branch.\n"
    printf "Options:\n"
    printf "\t -h prints this message\n"
    printUsage
}

helpArg="-h"
dryRunArg="--dry"

dryRun = 1 # false

if containsElement $dryRunArg $@; then
    dryRun = 0 # true
    exit 0
fi

if containsElement $helpArg $@; then
    printHelp
    exit 0
fi

if [ -z $versionToRelease ]; then
    printf "Did you forget to pass the version as argument?\n"
    printUsage
    exit 1
fi

if isSemVer $versionToRelease; then
    release $versionToRelease $dryRun
    exit 0
else
    printf "$versionToRelease is not a valid SemVer.\n"
    exit 1
fi