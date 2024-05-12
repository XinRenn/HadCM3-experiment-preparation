;; This is used to modify the old_osart file 
;; process flux separately because PI and mPWP use diff flux correction

;;---This is how to use it
;;ncl 'file_path="[file_path]"' 'file_name="[old_filename]"' 'new_file_name="[newfilename]"' mod_ostart_change_ocean_into_land.ncl
;;Dont forget the mark " for the string
;;example: 
;;ncl 'file_path="~/ancil/"' 'file_old="xpwka/old_flux_correction.nc"' 'file_mod="xpwka/for_xpwka_fluxcorrection.nc"'  'new_file="xpwka/xancil_fluxcorr_new.nc"' ~/scripts/mod_ostart_exchange_box_fluxcorr.ncl

;file_path = "~/ancil/xpwks/"
;file_name = "tenvoo@dau00c1.nc"
;new_file_name = "new.nc"

keys_var = (/"anomSaltFlux_uo"/)
;;;---set the x point which are going to be changed from ocean to land

;lata_ref = (/27,  39, 36,  40, 40,  45/)
;lona_ref = (/26,  34, 35,  41, 30,  41/)
;;;read old file

fileold = addfile(file_path+file_old,"r")
filemod = addfile(file_path+file_mod,"r")
fileout = addfile(file_path+new_file,"c")


;;this is the atm box scheme, use as reference
file_atm = addfile("~/ancil/preind_tenvo/qrparm.mask.nc","r")
lon_atm = file_atm->longitude
lat_atm = file_atm->latitude

;;-get the value of the box for ostart value!
;; for sst grid and uv grid, the box scheme is different
lat_box_value_s = new(dimsizes(lata_ref), typeof(lat_atm))
lon_box_value_s = new(dimsizes(lata_ref), typeof(lat_atm))
do boxnum = 0, dimsizes(lata_ref)/2-1
lat_box_value_s(boxnum*2)   = lat_atm(lata_ref(boxnum*2))+0.625   ;left upper coner
lon_box_value_s(boxnum*2)   = lon_atm(lona_ref(boxnum*2))-1.25    ;left upper coner
lat_box_value_s(boxnum*2+1) = lat_atm(lata_ref(boxnum*2+1))-0.625 ; right lower coner
lon_box_value_s(boxnum*2+1) = lon_atm(lona_ref(boxnum*2+1))+1.25  ; right lower coner
end do
latx = new((/dimsizes(lata_ref)/),"integer")
lonx = new((/dimsizes(lata_ref)/),"integer")

v=0
  ;read data including lat and lon
  varold = fileold->$keys_var(v)$
  varmod = filemod->PLE_uo
  var = varold
  latname = varold!2
  lonname = varold!3
  lat = fileold->$latname$
  lon = fileold->$lonname$

  do i = 0,dimsizes(lat_box_value_s)-1
  latx(i) = ind(lat.eq.lat_box_value_s(i))
  lonx(i) = ind(lon.eq.lon_box_value_s(i))
  end do

  ;;;---exchange the data
  do boxnum = 0, dimsizes(lata_ref)/2-1
    var(:,:,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1)) = where(ismissing(varmod(0,0,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1))),varold@missing_value,varold@valid_min)
  end do 
   copy_VarCoords(varold, var)
  ;;;---write the new var to the new file
  fileout->$keys_var(v)$ = var