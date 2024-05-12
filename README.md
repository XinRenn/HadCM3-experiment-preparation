*****************************************************************
Backup of the scripts I used for my new experiments preparation.

Scripts are not so clean, even a little bit messy, but they work.

Only used to modify the maritime continent area. For other areas in the world, need to do some easy edits on the scripts.


*****************************************************************
Usage: sh Make_test_exp.sh

Modify the heading info for the new exp

lata_ref and lona_ref are the lat and lon indice of the atmospheric ancillary data.


*****************************************************************
NCL scripts used in Make_test_exp.sh are all in scripts/

Only uploaded part of the data used in the scripts. 

*****************************************************************
Chapter3 所需试验的boundary files准备脚本。最好不要改动 Make_test_exp.sh 里面的boxes的参考格点，如果要改动的话，注意stream function related variable在不同islands上面的值是不同且需要保持一致的。因此也要改动ostart脚本里面相关的处理语句（这里面很容易犯错，所以要记得改动后进行多次check）。
对于atm ancillary的处理是直接交换boxes里面的数据，该处理相对简单。
对于oceanic restart，采用了三种处理办法，a,直接交换boxes数据（对于一些不容易导致crash的变量）；b，对于新添加的海洋格点，copy参考试验在该格点上的数据（用于一些两个试验在同区域数值相差不大的变量，主要是为了避免boxes的边缘数据有太大落差）；c,对于新添加的海洋格点，赋给它周边有效格点的平均值（用于一些容易导致crash的变量，且两个试验同区域数值相差较大的情况）。

新增陆地格点后，一些容易忽略的导致试验crash地方：
1. PLE在孟加拉湾处的初始值如果太大容易crash；
2. ostart file里面UV格点和SST相关格点要对准，尤其是UV在longitude的边缘有一段overlapping
3. PI试验要reconfigure oceanic P-E flux correction， mPWP试验则不需要（因为在UMUI上有关盐度correction的设置不同）
4. 新创建的bathymetry文件在longitude边缘也有一段overlapping
5. island的配置也很重要，需要手动修改文档添加island
