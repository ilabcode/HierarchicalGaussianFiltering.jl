using HierarchicalGaussianFiltering
using Documenter
using Literate

 #Remove old tutorial markdown files
 for filename in readdir("src/markdowns")
     rm("src/markdowns/" * filename)
 end
 #Generate new tutorial markdown files
 for filename in readdir("src/HGF_package")
     if endswith(filename, ".jl")
         Literate.markdown("./src/HGF_package/" * filename, "src/markdowns", documenter = true)
     end
 end

#Generate new tutorial markdown files
for filename in readdir("src/tutorials")
    if endswith(filename, ".jl")
        Literate.markdown("./src/tutorials/" * filename, "src/markdowns", documenter = true)
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
    pages =[ "Introduction to Hierarchical Gaussian Filtering" => "./markdowns/introduction.md",
        "Theory" => ["./theory/genmodel.md",
                            "./theory/node.md",
                            "./theory/vape.md",
                            "./theory/vope.md"],
            "Tutorials"=> ["classic binary" => "./markdowns/classic_binary.md", 
                        "classic continouous"=>"./markdowns/classic_usdchf.md"],

            "Using the package"=>["The HGF Nodes"=>"./markdowns/the_HGF_nodes.md",
                                "Building an HGF"=>"./markdowns/building_an_HGF.md",
                                "Updating the HGF"=>"./markdowns/updating_the_HGF.md",
                                "List Of Premade Agent Models"=>"./markdowns/premade_models.md",
                                "List Of Premade HGF's"=>"./markdowns/premade_HGF.md",
                                "Fitting an HGF-agent model to data"=> "./markdowns/fitting_hgf_models.md",
                                "Utility Functions"=>"./markdowns/utility_functions.md"],
            "List Of Functions"=>"./theory/list_of_functions.md"
            ]
)
deploydocs(;
    repo = "github.com/ilabcode/HierarchicalGaussianFiltering.jl",
    devbranch = "dev",
)




