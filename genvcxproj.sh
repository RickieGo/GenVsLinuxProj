#!/bin/bash
# Here for latest: https://github.com/robotdad/vclinux
#
# This script generates a VC Linux project file that includes your source files from the directory specified.
# The project type is makefile and it is set to not copy sources since the assumption here is the files have
#  been mapped to a Windows drive.
#
# This leaves your source in a flat list.
# To organize your files as seen in your directory use genfilters.sh to generate an accompanying filter file.
#
# The assumption this script has is that your source code is on a Linux machine and that
#  this directory has been mapped to Windows so the code can be edited in Visual Studio.
#
# You can find out more about VC++ for Linux here: http://aka.ms/vslinux
# Usage:
# $1 is the directory of source code to create a project file for
# $2 is file name to create, should be projectname.vcxproj
# $3 is the root of your Windows fodler where these files will be mapped
# the meat of this is after the printheader/footer functions

function printheader(){
 echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<Project DefaultTargets=\"Build\" ToolsVersion=\"15.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">
  <ItemGroup Label=\"ProjectConfigurations\">
    <ProjectConfiguration Include=\"Debug|x64\">
      <Configuration>Debug</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
    <ProjectConfiguration Include=\"Release|x64\">
      <Configuration>Release</Configuration>
      <Platform>x64</Platform>
    </ProjectConfiguration>
  </ItemGroup>
  <PropertyGroup Label=\"Globals\">
    <ProjectGuid>{edb85987-7176-458a-9f9a-b1bb634641e5}</ProjectGuid>
    <Keyword>Linux</Keyword>
    <RootNamespace>ConsoleApplication1</RootNamespace>
    <MinimumVisualStudioVersion>15.0</MinimumVisualStudioVersion>
    <ApplicationType>Linux</ApplicationType>
    <ApplicationTypeRevision>1.0</ApplicationTypeRevision>
    <TargetLinuxPlatform>Generic</TargetLinuxPlatform>
    <LinuxProjectType>{D51BCBC9-82E9-4017-911E-C93873C4EA2B}</LinuxProjectType>
  </PropertyGroup>
  <Import Project=\"\$(VCTargetsPath)\Microsoft.Cpp.Default.props\" />
  <PropertyGroup Condition=\"'\$(Configuration)|\$(Platform)'=='Debug|x64'\" Label=\"Configuration\">
    <UseDebugLibraries>true</UseDebugLibraries>
  </PropertyGroup>
  <PropertyGroup Condition=\"'\$(Configuration)|\$(Platform)'=='Release|x64'\" Label=\"Configuration\">
    <UseDebugLibraries>false</UseDebugLibraries>
  </PropertyGroup>
  <Import Project=\"\$(VCTargetsPath)\Microsoft.Cpp.props\" />
  <ImportGroup Label=\"ExtensionSettings\" />
  <ImportGroup Label=\"Shared\" />
  <ImportGroup Label=\"PropertySheets\" />
  <PropertyGroup Label=\"UserMacros\" />"
}

function printfooter(){
    echo "  <ItemDefinitionGroup />
  <Import Project=\"\$(VCTargetsPath)\Microsoft.Cpp.targets\" />
  <ImportGroup Label=\"ExtensionTargets\" />
    </Project>"
}

# function listothers(){
#     echo "  <ItemGroup>"
#     for i in $(find . -not -path '*/\.*' -type f ! -iname "*.c" ! -iname "*.cpp" ! -iname "*.h" ! -iname "*.txt" ! -iname "*.o" ! -iname "*.vcxproj" ! -iname "*.filters" ! -path "$excludedir")
#     do
#         d=${i%/*}
#         d=${d//\//\\}
#         f=${i##*/}
#         printf "    <None Include=\"%s\\%s\" />\n" "$d" "$f"
#     done
#     echo "  </ItemGroup>"
# }

function addexcludecmd(){
    for i in ${excludedir[@]}
    do
        cmd=''${cmd}' ! -path "'${i}'*"'
    done
}

# function listtxt(){
#     echo "  <ItemGroup>"
#     cmd=find . -not -path '*/\.*' -type f -iname "*.txt"
#     for i in $(cmd)
#     do
#         d=${i%/*}
#         d=${d//\//\\}
#         f=${i##*/}
#         printf "    <Text Include=\"%s\\%s\" />\n" "$d" "$f"
#     done
#     echo "  </ItemGroup>"
# }

function listcompile(){
    echo "  <ItemGroup>"
    cmd='find . -not -path "*/\.*" -type f  -iname "*.c"'
    addexcludecmd
    for i in $(eval ${cmd})
    do
        d=${i%/*}
        d=${d//\//\\}
        f=${i##*/}
        printf "    <ClCompile Include=\"%s\\%s\" />\n" "$d" "$f"
    done
    cmd='find . -not -path "*/\.*" -type f -iname "*.cpp"'
    addexcludecmd
    for i in $(eval ${cmd})
    do
        d=${i%/*}
        d=${d//\//\\}
        f=${i##*/}
        printf "    <ClCompile Include=\"%s\\%s\" />\n" "$d" "$f"
    done
    echo "  </ItemGroup>"
}

function listinclude(){
    echo "  <ItemGroup>"
    cmd='find . -not -path "*/\.*" -type f -iname "*.h"'
    addexcludecmd
    for i in $(eval ${cmd})
    do
        d=${i%/*}
        d=${d//\//\\}
        f=${i##*/}
        printf "    <ClInclude Include=\"%s\\%s\" />\n" "$d" "$f"
    done
    echo "  </ItemGroup>"
}

function listincludepath(){
    echo "  <PropertyGroup Condition=\"'\$(Configuration)|\$(Platform)'=='Debug|x64'\">"
    directories=""
    cmd='find . -not -path "*/\.*" -type d'
    addexcludecmd
    for i in $(eval ${cmd})
    do
        f=${i##./}
        f=${f//\//\\}
        directories="${directories}.\\$f\\;"
    done
    printf "  <IncludePath>%s</IncludePath>\n"  "$directories" 
    echo "  </PropertyGroup>"
}

function listadditionalinclude(){
    echo "  <ItemDefinitionGroup>"
    echo "  <ClCompile>"
    directories=""
    cmd='find . -not -path "*/\.*" -type d'
    addexcludecmd
    for i in $(eval ${cmd})
    do
        f=${i##./}
        f=${f//\//\\}
        directories="${directories}.\\$f\\;"
    done
    printf "  <AdditionalIncludeDirectories>%s</AdditionalIncludeDirectories>\n"  "$directories" 
    echo "  </ClCompile>"
    echo "  </ItemDefinitionGroup>"
}

function printfilterheader(){
    echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>
    <Project ToolsVersion=\"4.0\" xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">"
}

function printfilterfooter(){
    echo "</Project>"
}

function listfilters(){
    echo "  <ItemGroup>"
    cmd='find . -not -path "*/\.*" -type d'
    addexcludecmd
    for i in $(eval ${cmd})
    do
        f=${i##./}
        f=${f//\//\\}
        uuid="$(uuidgen)"
        printf "    <Filter Include=\"%s\">\n" "$f"
        printf "      <UniqueIdentifier>{%s}</UniqueIdentifier>\n" "$uuid"
        printf "    </Filter>\n"
    done
    echo "  </ItemGroup>"
}

function listfilterinclude(){
    echo "  <ItemGroup>"
    cmd='find . -not -path "*/\.*" -type f -iname "*.h"'
    addexcludecmd
    for i in $(eval ${cmd})
    do
        d=${i%/*}
        fd=${d##*/}
        fd=${d##*/}
        fp=${d##./}
        fp=${fp//\//\\}
        d=${d//\//\\}
        f=${i##*/}
        if [ $fd = "." ]
        then
            printf "    <ClInclude Include=\"%s\\%s\" />\n" "$d" "$f"
        else
            printf "    <ClInclude Include=\"%s\\%s\">\n" "$d" "$f"
            printf "      <Filter>%s</Filter>\n" "$fp"
            printf "    </ClInclude>\n"
        fi
    done
    echo "  </ItemGroup>"
}



function listfiltercompile(){
    echo "  <ItemGroup>"
    cmd='find . -not -path "*/\.*" -type f -iname "*.cpp"';
    addexcludecmd
    for i in $(eval ${cmd})
    do
        d=${i%/*}
        fd=${d##*/}
        fd=${d##*/}
        fp=${d##./}
        fp=${fp//\//\\}
        d=${d//\//\\}
        f=${i##*/}
        if [ $fd = "." ]
        then
            printf "    <ClCompile Include=\"%s\\%s\" />\n" "$d" "$f"
        else
            printf "    <ClCompile Include=\"%s\\%s\">\n" "$d" "$f"
            printf "      <Filter>%s</Filter>\n" "$fp"
            printf "    </ClCompile>\n" "$d" "$f"
        fi
    done
    cmd='find . -not -path "*/\.*" -type f -iname "*.c"';
    addexcludecmd
    for i in $(eval ${cmd})
    do
        d=${i%/*}
        fd=${d##*/}
        fd=${d##*/}
        fp=${d##./}
        fp=${fp//\//\\}
        d=${d//\//\\}
        f=${i##*/}
        if [ $fd = "." ]
        then
            printf "    <ClCompile Include=\"%s\\%s\" />\n" "$d" "$f"
        else
            printf "    <ClCompile Include=\"%s\\%s\">\n" "$d" "$f"
            printf "      <Filter>%s</Filter>\n" "$fp"
            printf "    </ClCompile>\n" "$d" "$f"
        fi
    done
    echo "  </ItemGroup>"
}


# function listfilterothers(){
#     echo "  <ItemGroup>"
#     for i in $(find . -not -path '*/\.*' -type f ! -iname "*.c" ! -iname "*.cpp" ! -iname "*.h" ! -iname "*.txt" ! -iname "*.o" ! -iname "*.vcxproj" ! -path "$excludedir")
#     do
#         d=${i%/*}
#         fd=${d##*/}
#         fp=${d##./}
#         fp=${fp//\//\\}
#         d=${d//\//\\}
#         f=${i##*/}
#         if [ $fd = "." ]
#         then
#             printf "    <None Include=\"%s\\%s\" />\n" "$d" "$f"
#         else
#             printf "    <None Include=\"%s\\%s\" >\n" "$d" "$f"
#             printf "      <Filter>%s</Filter>\n" "$fp"
#             printf "    </None>\n"
#         fi
#     done
#     echo "  </ItemGroup>"
# }

# function listfiltertxt(){
#     echo "  <ItemGroup>"
#     for i in $(find . -not -path '*/\.*' -type f -iname "*.txt")
#     do
#         d=${i%/*}
#         fd=${d##*/}
#         fp=${d##./}
#         fp=${fp//\//\\}
#         d=${d//\//\\}
#         f=${i##*/}
#         if [ $fd = "." ]
#         then
#             printf "    <Text Include=\"%s\\%s\" />\n" "$d" "$f"
#         else
#             printf "    <Text Include=\"%s\\%s\">\n" "$d" "$f"
#             printf "      <Filter>%s</Filter>\n" "$fp"
#             printf "    </Text>\n"
#         fi
#     done
#     echo "  </ItemGroup>"
# }
projname=''$2'.vcxproj'
projfiltername=''$2'.vcxproj.filters'

excludedir=("./BattleServer/" ".vs" ".vscode" ".svn")
cmd=""
rm -rf $projname
# rm -rf $projfiltername
cd $1 || exit 2;
touch $projname && test -w $projname || exit 2;
printheader > $projname
#listothers >> $2
#listtxt >> $2

listincludepath >> $projname

listcompile >> $projname
listinclude >> $projname

printfooter >> $projname

touch $projfiltername && test -w $projfiltername || exit 2;

printfilterheader > $projfiltername
listfilters >> $projfiltername
# listothers >> $projfiltername
# #listtxt >> $projfiltername
listfiltercompile >> $projfiltername
listfilterinclude >> $projfiltername
printfilterfooter >> $projfiltername

exit
