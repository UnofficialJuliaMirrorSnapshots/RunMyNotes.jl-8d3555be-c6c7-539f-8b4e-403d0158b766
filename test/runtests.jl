using RunMyNotes
using Test

@test RunMyNotes.package(RunMyNotes) 

@test RunMyNotes.folder(joinpath(@__DIR__, "..", "notes")) # the same!
