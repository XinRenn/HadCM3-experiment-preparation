;; This is used to modify the old_osart file 
;; used to change an ocean grid to land grid
;; by overwriting the ocean grid with land grid value
;; This script will change the relavent vars in this restart file all together

;;---This is how to use it
;;ncl 'file_path="[file_path]"' 'file_name="[old_filename]"' 'new_file_name="[newfilename]"' mod_ostart_change_ocean_into_land.ncl
;;Dont forget the mark " for the string
;;example: 
;;ncl 'file_path="~/ancil/"' 'file_old="preind_tenvo/tenvoo@dau00c1.nc"' 'file_mod="pliocene_tenvj/tenvjo@dap00c1.nc"' \
;; 'new_file="xpwka/xpwka.ostart.nc"' ~/scripts/mod_ostart_exchange_box.ncl

;file_path = "~/ancil/xpwks/"
;file_name = "tenvoo@dau00c1.nc"
;new_file_name = "new.nc"

;;;The order is important, make sure put temp_dpth before ucurrBaro_dpth and TAUX_uo.
keys_var = (/"temp_dpth", "salinity_dpth", "ucurrBaro_dpth", "vcurrBaro_dpth", \
"streamFn_uo", "field612_uo",\
      "field613_uo", "field614_uo", "mixLyrDpth_uo", \
        "snowdepth_uo", "carryheatice_uo","OcIceHflux_uo", "carrySalt_uo", "iceconc_uo", "icedepth_uo", "TAUX_uo", \
                "TAUY_uo", "WME_uo", "SOL_uo", "HTNpenhtflxocn_uo", \
                    "PLE_uo", "outflow_uo", "snowfall_uo", "sublim_uo", \
                        "topmelt_uo", "botmelt_uo", "thckDiffCoeff_uo"/)
copy_var = (/"latitude","longitude","latitude_1","longitude_1","t","depth"/)
;;;---set the x point which are going to be changed from ocean to land

;lata_ref = (/27,  39, 36,  40, 40,  45/)
;lona_ref = (/26,  34, 35,  41, 30,  41/)
;lata_ref = (/27,  39/)
;lona_ref = (/26,  34/)
;read from input

;;;read old file
fileold = addfile(file_path+file_old,"r")
;;;read old file
filemod = addfile(file_path+file_mod,"r")
;;---create new file
fileout = addfile(file_path+new_file,"c")

;;this is the atm box scheme, use as reference
;;what we need is only the lat and lon
  file_atm = addfile("~/ancil/preind_tenvo/qrparm.mask.nc","r")
  lon_atm = file_atm->longitude
  lat_atm = file_atm->latitude

;;-get the value of the box for ostart value!
;; for sst grid and uv grid, the box schemes are different
  lat_box_value_s = new(dimsizes(lata_ref), typeof(lat_atm))
  lon_box_value_s = new(dimsizes(lata_ref), typeof(lat_atm))
  lat_box_value_u = new(dimsizes(lata_ref), typeof(lat_atm))
  lon_box_value_u = new(dimsizes(lata_ref), typeof(lat_atm))
  do boxnum = 0, dimsizes(lata_ref)/2-1
  lat_box_value_s(boxnum*2)   = lat_atm(lata_ref(boxnum*2))+0.625   ;left upper coner
  lon_box_value_s(boxnum*2)   = lon_atm(lona_ref(boxnum*2))-1.25    ;left upper coner
  lat_box_value_s(boxnum*2+1) = lat_atm(lata_ref(boxnum*2+1))-0.625 ; right lower coner
  lon_box_value_s(boxnum*2+1) = lon_atm(lona_ref(boxnum*2+1))+1.25  ; right lower coner
  lat_box_value_u(boxnum*2)   = lat_atm(lata_ref(boxnum*2))+1.25   ;left upper coner
  lon_box_value_u(boxnum*2)   = lon_atm(lona_ref(boxnum*2))-1.875    ;left upper coner
  lat_box_value_u(boxnum*2+1) = lat_atm(lata_ref(boxnum*2+1))-1.25 ; right lower coner
  lon_box_value_u(boxnum*2+1) = lon_atm(lona_ref(boxnum*2+1))+1.875  ; right lower coner
  end do

;;;copy other relevant variables
  do j = 0,dimsizes(copy_var)-1
    coor_tmp = fileold->$copy_var(j)$
    fileout->$copy_var(j)$ =coor_tmp
    delete([/coor_tmp/])
  end do

latname = "latitude"
lonname = "longitude"

;;;;---get the box index
  lat = fileold->$latname$
  lon = fileold->$lonname$
  lat_u= fileold->latitude_1
  lon_u= fileold->longitude_1
  latx = new((/dimsizes(lata_ref)/),"integer")
  lonx = new((/dimsizes(lata_ref)/),"integer")
  latu = new((/dimsizes(lata_ref)/),"integer")
  lonu = new((/dimsizes(lata_ref)/),"integer")
  ;if(dimsizes(lat).eq.143) then  ;;this is uv grid, use another process way.
  ;do i = 0,dimsizes(lat_box_value_s)-1
  ;latx(i) = ind(lat.eq.lat_box_value_u(i))
  ;lonx(i) = ind(lon.eq.lon_box_value_u(i))
  ;end do
  ;else
  do i = 0,dimsizes(lat_box_value_s)-1
  latx(i) = ind(lat.eq.lat_box_value_s(i))
  lonx(i) = ind(lon.eq.lon_box_value_s(i))
  latu(i) = ind(lat_u.eq.lat_box_value_u(i))
  lonu(i) = ind(lon_u.eq.lon_box_value_u(i))
  end do
  ;end if

  print("latu :")
  print(latu)
  print("lonu :")
  print(lonu)
;;;---exchange the data
do v = 0,dimsizes(keys_var)-1 ;change the first 27 vars used in making ostart

  ;read data including lat and lon
    varold = fileold->$keys_var(v)$
    varmod = filemod->$keys_var(v)$
    ;latname = varold!2
    ;lonname = varold!3
    var = varold

  ;;;---exchange the data
  ;;; for SST grid box data
    if(dimsizes(var(0,0,:,0)).eq.144) then

      ;;;;for streamfunction related vars
      ;;;; don't change the land value
      if(keys_var(v).eq."streamFn_uo".or.keys_var(v).eq."field612_uo".or.keys_var(v).eq."field613_uo".or.keys_var(v).eq."field614_uo") then
        do boxnum = 0, dimsizes(lata_ref)/2-1
        do i = latx(boxnum*2+1),latx(boxnum*2)
        do j = lonx(boxnum*2),lonx(boxnum*2+1)
         ;;;;island in PI but ocean in mPWP
        if(var(0,0,i,j).eq.0.and.varmod(0,0,i,j).ne.0) then
          ;;;;give value to the new ocean points
          if(avg(var(0,0,i-2:i+2,j-3:j+3)).ne.0) then
          var(0,0,i,j) = avg(var(0,0,i-2:i+2,j-3:j+3))
          else
          print("error: the surrounding points are all missing. You need to redo it.")
          end if
        end if
        ;;;;for the land in mPWP but ocean in PI
          ;;;box 1
          if(varold(0,0,latx(0),lonx(0)).eq.0.and.boxnum.eq.0) then   ;;;;if the box is the Northern MC box. var has been modified, so use varold here
            newilat = latx(0) - 6 ;;;locate the new land point
            newilon = lonx(1) - 7
            if(varmod(0,0,i,j).eq.0.or.varmod(0,0,i,j).eq.varmod(0,0,newilat,newilon)) then ;mainland or Japan land
              ;;;;give value to the new land points
              var(0,0,i,j) = varmod(0,0,i,j)
            end if
          else 
              newilat = latx(dimsizes(lata_ref)-1)    ;;;locate the Austria land point
              newilon = lonx(dimsizes(lata_ref)-1) - 20
            if(varmod(0,0,i,j).eq.varmod(0,0,newilat,newilon)) then ;Austria land
              ;;;;give value to the new land points
              var(0,0,i,j) = var(0,0,newilat,newilon)
            end if
          end if
        ;var(0,0,i,j) = where(var(0,0,i,j).eq.0,varmod(0,0,i,j),var(0,0,i,j))
        ;if(boxnum.ne.0) then
        ;    aust_land_old=varold(0,0,latx(boxnum*2-1),(lonx(boxnum*2)+lonx(boxnum*2-1))/2) ;;;this is a land box for Austria land. But need to be careful, the lon value is not the same as the SST grid
        ;    aust_land_mod=varmod(0,0,latx(boxnum*2-1),(lonx(boxnum*2)+lonx(boxnum*2-1))/2)
        ;    var(:,:,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1)) = where(var(:,:,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1)).eq.aust_land_mod,aust_land_old,var(:,:,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1)))
        ;end if
        end do
        end do 
        end do ;;end the streamfunction related vars
        var = where(ismissing(var),0,var)
      ;;;;for other vars
        else 
        do boxnum = 0, dimsizes(lata_ref)/2-1
          var(:,:,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1)) = varmod(:,:,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1))
          ;; get rid of the extreme values
          ;var = where(var.lt.var@valid_min,var@valid_min,var)
          ;var = where(var.gt.var@valid_max,var@valid_max,var)
          ;;；；； smooth the salinity data
          ;;do de = 0,dimsizes(var(0,:,0,0))-1
          ;;salavg = avg(sal_temp(0,de,:,:))
          ;;var(0,de,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1)) = where(ismissing(var(0,de,latx(boxnum*2):latx(boxnum*2+1),lonx(boxnum*2):lonx(boxnum*2+1))),var@missing_value,salavg)
          ;;end do
          ;delete(sal_temp)
        end do
      end if
    end if 

  ;;;use the modified SST data to decide land mask in depth when modify UV grid variables
  ;;;make sure put temp_dpth before ucurrBaro_dpth and TAUX_uo in keys_var array.
    if(keys_var(v).eq."temp_dpth") then
      Tgrid = var 
    end if

  ;;; for UV grid box data
  ;; the logic is to use modified SST to mask the UV data out
  if(keys_var(v).eq."ucurrBaro_dpth".or.keys_var(v).eq."vcurrBaro_dpth".or.keys_var(v).eq."TAUY_uo".or.keys_var(v).eq."TAUX_uo") then 
    ;;;;first fill the original missing value with values.
    ;;;; where SST grid is missing, the surrounding 4 UV grid will be missing;;;;for box missing in both exps, it will still be missing, so dont need to fill it.
    do boxnum = 0, dimsizes(lata_ref)/2-1
    do de = 0,dimsizes(var(0,:,0,0))-1 ;depth loop
    ;;;;for box missing in both exps, it will still be missing, so dont need to fill it.
    var(:,de,latu(boxnum*2+1):latu(boxnum*2),lonu(boxnum*2):lonu(boxnum*2+1)) = where(ismissing(var(:,de,latu(boxnum*2+1):latu(boxnum*2),lonu(boxnum*2):lonu(boxnum*2+1))).and.(.not.ismissing(varmod(:,de,latu(boxnum*2+1):latu(boxnum*2),lonu(boxnum*2):lonu(boxnum*2+1)))),varmod(:,de,latu(boxnum*2+1):latu(boxnum*2),lonu(boxnum*2):lonu(boxnum*2+1)),var(:,de,latu(boxnum*2+1):latu(boxnum*2),lonu(boxnum*2):lonu(boxnum*2+1)))
    do i = latx(boxnum*2+1)-3,latx(boxnum*2)+3 ;there's no data in the first and last lat line
        do j =lonx(boxnum*2)-4,lonx(boxnum*2+1)+4
        if(ismissing(Tgrid(0,de,i,j))) then
            ;;;deal with the overlapping lon value 
            ;;The following is not the case for the MC, so comment it out to save computation
            ;if(j.eq.0) then
            ;    var(:,de,i-1:i,j) = var@missing_value
            ;    var(:,de,i-1:i,dimsizes(lon)-3:dimsizes(lon)-2) = var@missing_value
            ;    end if
            ;if(j.eq.1) then
            ;    var(:,de,i-1:i,j-1:j) = var@missing_value
            ;    var(:,de,i-1:i,dimsizes(lon)-2:dimsizes(lon)-1) = var@missing_value
            ;    end if
            ;if(j.eq.2) then
            ;    var(:,de,i-1:i,j-1:j) = var@missing_value
            ;    var(:,de,i-1:i,dimsizes(lon)-1) = var@missing_value
            ;    end if
            ;;;;;deal with the non-overlapping value
            if(j.ge.3) then
                var(:,de,i-1:i,j-1:j) = var@missing_value
                end if
        end if
        end do ;end j loop
    end do ;end i loop
    end do ;end depth loop
    end do ;end box loop
  end if

  copy_VarCoords(varold, var)

;;;---write the new var to the new file
  fileout->$keys_var(v)$ = var
  delete([/varold,varmod,var/])
end do ;end var loop