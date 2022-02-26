import win32com.client
from os import walk

def mergePresentations(inputFileNames, outputFileName):

    Application = win32com.client.Dispatch("PowerPoint.Application")
    outputPresentation = Application.Presentations.Add() 
    outputPresentation.SaveAs(outputFileName)

    for file in inputFileNames:    
        currentPresentation = Application.Presentations.Open(file)
        currentPresentation.Slides.Range(range(1, currentPresentation.Slides.Count+1)).copy()
        Application.Presentations(outputFileName).Windows(1).Activate()    
        outputPresentation.Application.CommandBars.ExecuteMso("PasteSourceFormatting")    
        currentPresentation.Close()

    outputPresentation.save()
    outputPresentation.close()
    Application.Quit()

# Example; let's say you have a folder of presentations that need to be merged 
#           to new file named "allSildesMerged.pptx" in the same folder

file_dir = input('파일경로를 입력해주세요.:')
path,_,files = next(walk(file_dir))
outputFileName = path + '\\' + 'allSildesMerged.pptx'
inputFiles = []

for file in files:
    inputFiles.append(path + '\\' + file)

mergePresentations(inputFiles, outputFileName)








