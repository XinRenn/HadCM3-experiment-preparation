# This script is used to make new test experiments semi-aumontically.
# Cautions:
# 1. if you wanna edit gridboxed at the edge of the map.Check ~/scripts/mod_atm_ancil_exchange_box.ncl for the SST grid part. I didn't consider the edge case.
# 2. check the ostart streamfunc related variables, if you change the grid, you need to make sure values on same land piece are the same.
# 3. if you change the box, change line122 - lin133 in ~/scripts/mod_ostart_exchange_box.ncl

exp_name=(xpwkb) 

### PI 2 mPWP
file_old_ancil=(preind_tenvo/)
file_mod_ancil=(pliocene_tenvj/Plio_)
file_old_ostart=(../work/chap3/restart/xpwku_test3_1.ostart.nc) #see exp diary
file_mod_ostart=(../work/chap3/restart/xpwkv_test3_3.ostart.nc)
file_old_bath=(PI_bath.nc)
file_mod_bath=(mPWP_bath.nc)
file_old_flux=(flux_correction.nc)
file_mod_flux=(xpwkv_test3_3.ostart.nc)

#### mPWP 2 PI
#file_mod_ancil=(preind_tenvo/)
#file_old_ancil=(pliocene_tenvj/Plio_)
#file_mod_ostart=(../work/chap3/restart/xpwku_test3_1.ostart.nc) #see exp diary
#file_old_ostart=(../work/chap3/restart/xpwkv_test3_3.ostart.nc)
#file_mod_bath=(preind_tenvo/tenvo_bath.nc)
#file_old_bath=(pliocene_tenvj/tenvj_bath.nc)
#file_mod_flux=(preind_tenvo/flux_correction.nc)
#file_old_flux=(pliocene_tenvj/tenvjo@dap00c1.nc)

## Whole MC boxes
#lata_ref='(/27,40,36,40,40,45/)'
#lona_ref='(/25,34,35,41,30,41/)'

lata_ref='(/27,40/)' #upper left and lower right
lona_ref='(/25,34/)'

#lata_ref='(/36,40,40,45/)' #lower and right MC boxes
#lona_ref='(/35,41,30,41/)'

###! Test points
#lata_ref='(/33,33/)' #upper left and lower right
#lona_ref='(/28,28/)'


mkdir ~/ancil/$exp_name
#############################################
## 1. modify Atmosphere ancillary files
#############################################
for atm_ancil in qrclim.slt.nc qrfrac.disturb.nc qrclim.smow.nc qrfrac.type.nc \
qrparm.mask.nc qrparm.orog.nc qrparm.pft.nc qrparm.soil.nc ;do
rm ~/ancil/${exp_name}/${exp_name}_${atm_ancil}
ncl 'file_path="~/ancil/"' 'file_old="'${file_old_ancil}${atm_ancil}'"' \
'file_mod="'${file_mod_ancil}${atm_ancil}'"' \
'new_file="'${exp_name}'/'${exp_name}'_'${atm_ancil}'"' \
'lata_ref='${lata_ref}'' 'lona_ref='${lona_ref}'' \
~/scripts/mod_atm_ancil_exchange_box.ncl 
done

# PI and mPWP have different smow missing value, so need different process
##!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!################
##use a different way if change from mPWP to PI
## atm_ancil=(qrclim.smow.nc)
## rm -i ~/ancil/${exp_name}/${exp_name}_${atm_ancil}
## ncl 'file_path="~/ancil/"' 'file_old="'${file_old_ancil}${atm_ancil}'"' \
## 'file_mod="'${file_mod_ancil}${atm_ancil}'"' \
## 'new_file="'${exp_name}'/'${exp_name}'_'${atm_ancil}'"' \
## 'lata_ref='${lata_ref}'' 'lona_ref='${lona_ref}'' \
## ~/scripts/mod_atm_ancil_exchange_box_smow.ncl 

## 1.1 check the new ancillary files
for i in $(ls ~/ancil/${exp_name}/${exp_name}_qr*.nc);do \
ncl 'filename="'$i'"' 'exp_name="'${exp_name}'"'  ~/scripts/draw_gridbox_ancil.ncl ;done

eog ~/work/chap3/gridbox_plot/gridbox_${exp_name}_atm_canopyCond_snp_srf.png  
ls -lrt  ~/ancil/${exp_name}/*

echo Atmospheric ancillary files are ready
read -r -s -p $'Press enter to continue...'

#############################################
## 2. modify Ocean ancillary files
#############################################
rm -i ~/ancil/${exp_name}/${exp_name}.ostart.nc
#ncl 'file_path="~/ancil/"' 'file_old="'${file_old_ostart}'"' 'file_mod="'${file_mod_ostart}'"' \
#'new_file="'${exp_name}'/'${exp_name}'.ostart.nc"' \
#'lata_ref='${lata_ref}'' 'lona_ref='${lona_ref}'' \
#~/scripts/mod_ostart_exchange_box.ncl
ncl 'file_path="~/ancil/"' 'file_old="'${file_old_ostart}'"' 'file_mod="'${file_mod_ostart}'"' \
'new_file="'${exp_name}'/'${exp_name}'.ostart.nc"' \
'lata_ref='${lata_ref}'' 'lona_ref='${lona_ref}'' \
~/scripts/mod_ostart_exchange_box_N+S.ncl

## 2.1 check the ocean grids
ncl 'ostartfile="~/ancil/'${exp_name}'/'${exp_name}'.ostart.nc"' ~/scripts/check_UV_grid.ncl 
read -r -s -p $'Press enter to continue...'


## 2.2 check the new ancillary files
ncl 'file_name="~/ancil/'${exp_name}'/'${exp_name}'.ostart.nc"' \
'exp_name="'${exp_name}'"' ~/scripts/draw_gridbox_ostart.ncl
#mv ~/ancil/${exp_name}/${exp_name}.ostart.nc ~/ancil/${exp_name}/${exp_name}.ostart_xancil.nc
eog ~/work/chap3/gridbox_plot/gridbox_${exp_name}_botmelt_uo_0.png  


## 2.3 modify fluxcorrection file
rm -i ~/ancil/${exp_name}/${exp_name}_fluxcorr_xancil.nc
ncl 'file_path="~/ancil/"' 'file_old="'${file_old_flux}'"' \
'file_mod="'${file_mod_flux}'"'  \
'new_file="'${exp_name}'/'${exp_name}'_fluxcorr_xancil.nc"' \
'lata_ref='${lata_ref}'' 'lona_ref='${lona_ref}'' \
~/scripts/mod_ostart_exchange_box_fluxcorr.ncl
#check flux correction
ncview ~/ancil/${exp_name}/${exp_name}_fluxcorr_xancil.nc


## 2.4 prepare the bath file
rm -i ~/ancil/${exp_name}/${exp_name}_xancil_bath_old.nc
ncl 'file_path="~/ancil/"' 'file_old="'${file_old_bath}'"' \
'file_mod="'${file_mod_bath}'"' 'new_file="'${exp_name}'/'${exp_name}'_xancil_bath_old.nc"' \
'lata_ref='${lata_ref}'' 'lona_ref='${lona_ref}'' \
~/scripts/mod_ostart_bath_exchange_box.ncl

rm -i ~/ancil/${exp_name}/${exp_name}_xancil_bath_new.nc
ncl 'file_name="~/ancil/'${exp_name}'/'${exp_name}'_xancil_bath"' ~/scripts/mod_bath.ncl

ls -lrt  ~/ancil/${exp_name}/*

###store this script as a record
current_date=$(date +%Y-%m-%d)
cp ~/scripts/Make_test_exp.sh ~/ancil/${exp_name}/Make_test_exp_${current_date}.sh
echo cp this scripts into the exp folder


echo Atm ancillary files and ocean restart file is ready
echo Now you need to 
echo 0. ncview ${exp_name}.ostart.nc to check the streamfunc
echo 1. xancil get atm ancil: xancil -x -j ${exp_name}_xancil_atm.job
echo 2. mod isl.dat
echo 3. xancil get ocn ancil: xancil -x -j ${exp_name}_xancil_oce.job
echo 4. check if the ostart is alright with command:
echo ~/scripts/bath_islands_scr_new ${exp_name}.ostart check_${exp_name}_bath.nc check_${exp_name}_island.nc check_${exp_name}_island.ascii check_${exp_name}_nisles.ascii
echo and use the following to check is bath is correct. The tmp.nc should all be zero.
echo cdo -sub check_${exp_name}_bath.nc ${exp_name}_xancil_bath_old.nc tmp.nc
echo ncview tmp.nc
echo rm tmp.nc
echo useful commands: sed -i 's/[old_exp]/[new_exp]/g' ${exp_name}_xancil_atm.job
