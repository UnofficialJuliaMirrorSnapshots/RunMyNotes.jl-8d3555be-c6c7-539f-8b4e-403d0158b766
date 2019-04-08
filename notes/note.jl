# ## Test note for RunMyNotes.jl
# This is a plain text `.jl` file formatted so that
# [Literate.jl](https://github.com/fredrikekre/Literate.jl) will understand it.

[i^2 for i=1:10]  # column
[i^2 for i=1:10]' # row

#-

using Plots
## notice that Plots is mentioned in /test/REQUIRE
plot(rand(20))

# Commented text becomes text (markdown) cells, `##` stays a comment,
# and `#-` divides two code cells to keep their output visible.
