using HierarchicalGaussianFiltering
using Documenter
using Literate

#Remove old tutorial markdown files
for filename in readdir("src/generated_markdowns")
    rm("src/generated_markdowns/" * filename)
end
#Generate new tutorial markdown files
for filename in readdir("src/Julia_src_files")
    if endswith(filename, ".jl")
        Literate.markdown(
            "./src/Julia_src_files/" * filename,
            "src/generated_markdowns",
            documenter = true,
        )
    end
end

#Generate new tutorial markdown files
for filename in readdir("src/tutorials")
    if endswith(filename, ".jl")
        Literate.markdown(
            "./src/tutorials/" * filename,
            "src/generated_markdowns",
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
        "Introduction to Hierarchical Gaussian Filtering" => "./generated_markdowns/introduction.md",
        "Theory" => [
            "./theory/genmodel.md",
            "./theory/node.md",
            "./theory/vape.md",
            "./theory/vope.md",
        ],
        "Tutorials" => [
            "classic binary" => "./generated_markdowns/classic_binary.md",
            "classic continouous" => "./generated_markdowns/classic_usdchf.md",
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
        "List Of Functions" => "./theory/list_of_functions.md",
    ],
)
deploydocs(;
    repo = "github.com/ilabcode/HierarchicalGaussianFiltering.jl",
    devbranch = "main",
    push_preview = false,
)
