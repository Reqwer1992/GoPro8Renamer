# Situation: when filming with GoPro if video is longer than 5:20 it is split into multiple files
# Problem: because of how files are named, sorting files names alphanumerically doesn't result in the file order that we want
# Solution: rename the files so that sorting would be fixed

# Example file names for one video: GH010789.MP4 , GH020789.MP4 , GH030789.MP4
# 1,2,3 - file part numbers
# 789 - file number

$ErrorActionPreference = "Stop"

$fileList = Get-ChildItem

# file list to check new file name uniqueness
$newFileList = New-Object 'system.collections.generic.dictionary[string,Object]'

# switch file part number and file number for each file name
foreach($file in $fileList)
{
  $fileName = $file.Name
  # we are only interested in files that are not renamed
  if(($fileName -like 'GH*') -AND ($fileName -like '*.MP4') -AND ($fileName.Length -eq 12))
  {
    $partNr = $fileName[3]
    $fileNr = $fileName[5]+$fileName[6]+$fileName[7]
    $newFileName = $fileNr + '-' + $partNr

    # ensuring that we haven't messed up somewhere and generated unique file names
    if($newFileList.ContainsKey($newFileName))
    {
      throw ("File name conflict for" + $newFileName + ": " + $newFileList[$newFileName].Name + ", " + $fileName)
    }
    $newFileList[$newFileName] = $file
  }
}

$finalFileList = New-Object 'system.collections.generic.dictionary[string,string]'

foreach($newFileName in $newFileList.Keys)
{
  # okey we have correct file number/part number, now we need to add date and file type
  $creationDate = $newFileList[$newFileName].CreationTime.ToString("dd.MM.yyyy")
  $finalFileName = $newFileName + ' ' + $creationDate + '.mp4'

  echo ($newFileList[$newFileName].Name + ' -> ' + $finalFileName)
  $finalFileList[$finalFileName] = $newFileList[$newFileName].Name
}

$answer = read-host "Do the rename? y/n "
if ($answer -eq 'y') {
  foreach($finalFileName in $finalFileList.Keys)
  {
    Rename-Item -Path $finalFileList[$finalFileName] -NewName $finalFileName
  }

  echo 'Rename done'
}


# TODO: promt to do the rename (y/n)
# TODO: do the rename