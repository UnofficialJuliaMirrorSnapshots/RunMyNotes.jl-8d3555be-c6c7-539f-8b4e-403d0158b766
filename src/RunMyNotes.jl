module RunMyNotes

export folder, package

using Literate, Conda

"""
    folder(in, [out])
Runs all files `*.jl` found in folder `in`, generating a Jupyter `.ipynb` notebook for each,
saved in the same folder or in `out` if provided.

Keywords: 
* `html=true` then converts this notebook to HTML too, using `jupyter nbconvert`.
* `throw=true` exits with an error if any errors were encountered .
* `all=true` runs everything, `all=false` will skip any `.jl` files which are older than their `.ipynb` versions.
* 'verbose=true` adds details about time & computer at the end.
* `credit=true` adds links.
"""
function folder(indir::String, outdir::String=indir;
        html::Bool=true, throw::Bool=true, all::Bool=true, credit::Bool=true, verbose::Bool=true)

    fulldir = normpath(expanduser(indir))
    fullout = normpath(expanduser(outdir))
    @assert isdir(fulldir) "can't find input folder $fulldir"
    @assert isdir(fullout) "can't find output folder $fullout"
    
    olddir = pwd() # should just fix run command instead

    pre = verbose ? appendinfo : identity
    post = credit ? appendcredit : identity

    list = filter(s->endswith(s,".jl"), readdir(fulldir))

    errs = []

    for name in list
        jlname = joinpath(fulldir, name)
        nbname = joinpath(fullout, name)[1:end-2] * "ipynb"
        
        if isfile(nbname) && mtime(nbname) > mtime(jlname)
            all || continue # all=false means skip files for which .jl hasn't changed
        end
        
        ran = true
        nb = ""
        try
            nb = Literate.notebook(jlname, fullout; credit=credit, preprocess=pre, postprocess=post)
        catch err
            @error "error in creating or running notebook from $jlname \n" err
            push!(errs, err)
            ran = false
        end

        if html && ran
            try
                cd(Conda.PYTHONDIR)
                run(`./jupyter nbconvert $nb`) # writes to same folder
            catch err
                @error "error in converting notebook $nb \n" err
                push!(errs, err)
            end
        end
    end
    
    cd(olddir)

    if throw && length(errs)>0
        error("encountered $(length(errs)) errors executing & converting notebooks, details printed above")
    end

    return length(errs)==0 # for @test
end


"""
    package(ModuleName)
This essentially runs `RunMyNotes.foler("~/.julia/dev/ModuleName/notes/")`.
Change keyword `sub="notes"` to select a different folder.
"""
function package(mod::Module, outdir=nothing; sub::String="notes", kw...)

    indir = joinpath(dirname(pathof(mod)), "..", sub) # pathof gives "...dev/src/RunMyNotes.jl"
    if outdir==nothing
        outdir = indir # these will get expanduser |> normpath
    end

    return folder(indir, outdir; kw...)
end

using Dates, InteractiveUtils

function infostring()
    io = IOBuffer();
    InteractiveUtils.versioninfo(io)
    s = String(take!(io))
    vinfo = join(split(s, "\n")[[1,4,5]],",") # Julia Version, OS, CPU
    return string(DateTime(now()), ",  ", vinfo)
end

appendinfo(str) = str * string("\n # ----- \n # *", infostring(), "* ") # not entirely happy with \n here

function appendcredit(dict::Dict)
    str = dict["cells"][end]["source"][end]
    rep = replace(str, "/fredrikekre/Literate.jl)" =>
        "/fredrikekre/Literate.jl), called by [RunMyNotes](http://github.com/mcabbott/RunMyNotes.jl)")
    dict["cells"][end]["source"][end] = rep
    return dict
end

end # module
