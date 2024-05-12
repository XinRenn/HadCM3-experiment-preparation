;;---This script is used to modify the old atm ancillary file 
;; used to change an ocean grid to land grid
;; by adding the neighbour land grid value to the old ocean grid

;;---This is how to use it
;;ncl 'file_path="[file_path]"' 'file_name="[old_filename]"' 'new_file_name="[newfilename]"' mod_atm_ancil_change_ocean_into_land.ncl
;;Dont forget the mark'""' for the string
;;example: 
;;ncl 'file_path="~/ancil/"' 'file_old="preind_tenvo/qrclim.smow.nc"' \
;; 'file_mod="pliocene_tenvj/Plio_qrclim.smow.nc"' 'new_file="xpwka/xpwka_qrclim.smow.nc"' ~/scripts/mod_atm_ancil_exchange_box.ncl 


;;---change all in the folder
;; do it in the folder where you got the old files
;; for i in $(ls qr*.nc);do ncl 'file_path="~/ancil/"' \
;;  'file_old="preind_tenvo/'$i'"' 'file_mod="/pliocene_tenvj/Plio_'$i'"' \
;; 'new_file="xpwka/xpwka_'$i'"' ~/scripts/mod_atm_ancil_exchange_box.ncl ;done
;;

begin


;;;read old file
fileold = addfile(file_path+file_old,"r")
filemod = addfile(file_path+file_mod,"r")

;;---create new file
fileout = addfile(file_path+new_file,"c")

;;----draw box for the test area. indice are the two corners of the box
;lata_ref = (/27,  39, 36,  40, 40,  45/)
;lona_ref = (/26,  34, 35,  41, 30,  41/)
;read from input

latx = lata_ref
lonx = lona_ref

var_name_list=getfilevarnames(fileold)

do i=0,dimsizes(var_name_list)-1
  var_name=var_name_list(i)
  shape=filevardimsizes(fileold,var_name)
  varold = fileold->$var_name$ ;;read the variable
  varmod = filemod->$var_name$ ;;read the variable
  var = varold
if(dimsizes(shape).eq.4) then  ;;then you need to mod the data
  ;;;---exchange the data
  do boxnum = 0, dimsizes(lata_ref)/2-1
  var(:,:,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1)) = varmod(:,:,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1))
  end do
  end if
  copy_VarCoords(varold, var)
  ;;;---write the new var to the new file
  fileout->$var_name$ = var
  delete([/varold,varmod,var,shape/])
end do

end