using HierarchicalGaussianFiltering
using Documenter
using Literate

#Remove old tutorial markdown files
for filename in readdir("docs/src/generated_markdowns")
    rm("docs/src/generated_markdowns/" * filename)
end
rm("docs/src/index.md")
#Generate new markdown files from the documentation source files
for filename in readdir("docs/src/Julia_src_files")
    if endswith(filename, ".jl")

        #Place the index file in another folder than the rest of the documentation
        if startswith(filename, "index")
            Literate.markdown(
                "docs/src/Julia_src_files/" * filename,
                "docs/src",
                documenter = true,
            )
        else
            Literate.markdown(
                "docs/src/Julia_src_files/" * filename,
                "docs/src/generated_markdowns",
                documenter = true,
            )
        end
    end
end

#Generate new tutorial markdown files from the tutorials
for filename in readdir("docs/src/tutorials")
    if endswith(filename, ".jl")
        Literate.markdown(
            "docs/src/tutorials/" * filename,
            "docs/src/generated_markdowns",
            documenter = true,
        )
    end
end

#Set documenter metadata
DocMeta.setdocmeta!(
    HierarchicalGaussianFiltering,
    :DocTestSetup,
    :(using HierarchicalGaussianFiltering);
    recursive = true,
)

#Create documentation
makedocs(;
    modules = [HierarchicalGaussianFiltering],
    authors = "Peter Thestrup Waade ptw@cas.au.dk, Jacopo Comoglio jacopo.comoglio@gmail.com, Christoph Mathys chmathys@cas.au.dk
                  and contributors",
    repo = "https://github.com/ilabcode/HierarchicalGaussianFiltering.jl/blob/{commit}{path}#{line}",
    sitename = "HierarchicalGaussianFiltering.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://ilabcode.github.io/HierarchicalGaussianFiltering.jl",
        assets = String[],
    ),
    pages = [
        "Introduction to Hierarchical Gaussian Filtering" => "./index.md",
        "Theory" => [
            "./theory/genmodel.md",
            "./theory/node.md",
            "./theory/vape.md",
            "./theory/vope.md",
        ],
        "Using the package" => [
            "The HGF Nodes" => "./generated_markdowns/the_HGF_nodes.md",
            "Building an HGF" => "./generated_markdowns/building_an_HGF.md",
            "Updating the HGF" => "./generated_markdowns/updating_the_HGF.md",
            "List Of Premade Agent Models" => "./generated_markdowns/premade_models.md",
            "List Of Premade HGF's" => "./generated_markdowns/premade_HGF.md",
            "Fitting an HGF-agent model to data" => "./generated_markdowns/fitting_hgf_models.md",
            "Utility Functions" => "./generated_markdowns/utility_functions.md",
        ],
        "Tutorials" => [
            "classic binary" => "./generated_markdowns/classic_binary.md",
            "classic continouous" => "./generated_markdowns/classic_usdchf.md",
        ],
        "All Functions" => "./generated_markdowns/all_functions.md",
    ],
)
deploydocs(;
    repo = "github.com/ilabcode/HierarchicalGaussianFiltering.jl",
    devbranch = "main",
    push_preview = false,
)
