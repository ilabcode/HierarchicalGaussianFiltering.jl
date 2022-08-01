using HGF
using Documenter
using Literate

#Generate tutorial markdown files
for filename in readdir("tutorials")
    Literate.markdown("tutorials/" * filename, "src/tutorial_markdowns", documenter = true)
end

# Set documenter metadata
DocMeta.setdocmeta!(HGF, :DocTestSetup, :(using HGF); recursive = true)

#Create documentation
makedocs(;
    modules = [HGF],
    authors = "Peter Thestrup Waade ptw@cas.au.dk, Jacopo Comoglio jacopo.comoglio@gmail.com, Christoph Mathys chmathys@cas.au.dk
                  and contributors",
    repo = "https://github.com/ilabcode/HGF.jl/blob/{commit}{path}#{line}",
    sitename = "HGF.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://ilabcode.github.io/HGF.jl",
        assets = String[],
    ),
    pages = ["Home" => "index.md"],
)

deploydocs(; repo = "github.com/ilabcode/HGF.jl", devbranch = "dev")
