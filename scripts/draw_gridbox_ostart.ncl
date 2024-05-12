;;this is used to draw the gridbox of the ostart file
;; update 1 May: there're some bugs need to be fixed. e.g. turned off region, there need to add more vars
;;---This is how to use it
; ncl 'file_name="[filepath+filename]"' 'exp_name="[exp]"' draw_gridbox_ostart.ncl
;; example:
;; ncl 'file_name="~/ancil/xpwks/xpwks.ostart.nc"' 'exp_name="xpwks_test1"' scripts/draw_gridbox_ostart.ncl

;;remember to change the file_name, exp_name, plot_path, keys_var, region

plot_path = "~/work/chap3/gridbox_plot/" ;"./"

keys_var = (/"temp_dpth", "salinity_dpth", "ucurrBaro_dpth", "vcurrBaro_dpth", \
"streamFn_uo", "field612_uo",\
      "field613_uo", "field614_uo", "mixLyrDpth_uo", \
        "snowdepth_uo", "carryheatice_uo","OcIceHflux_uo", "carrySalt_uo", "iceconc_uo", "icedepth_uo", "TAUX_uo", \
                "TAUY_uo", "WME_uo", "SOL_uo", "HTNpenhtflxocn_uo", \
                    "PLE_uo", "outflow_uo", "snowfall_uo", "sublim_uo", \
                        "topmelt_uo", "botmelt_uo", "thckDiffCoeff_uo","anomSaltFlux_uo"/)
region = "True" ;;;True or False
test_points = "True" ;;;add lines to the test grids?

;;-----set latlon box
  latt = 30.
  latb = -25.
  lonl = 90.
  lonr = 160.  ;;;;this is for larger map

;; read atm ancillary. make the change of ostart consist with atm
;; BE CAREFUL: 1st value is the Upper left corner, 2nd value is the lower right corner. KEEP the order!
lata_ref = (/27,  39, 36,  40, 40,  45/)
lona_ref = (/26,  34, 35,  41, 30,  41/)


;;this is the atm box scheme, use as reference
file_atm = addfile("~/ancil/preind_tenvo/qrparm.mask.nc","r")
lon_atm = file_atm->longitude
lat_atm = file_atm->latitude

;;-get the value of the box for ostart value!
;; for sst grid and uv grid, the box scheme is different
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
;---Read netCDF file
  filein   = addfile(file_name,"r")
;---draw resource
  res               = True                        ; plot mods desired
  ;res@gsnMaximize   = True                        ; maximize plot size
  res@gsnDraw       = False                       ; don"t draw yet
  res@gsnFrame      = False                       ; don"t advance frame
  res@cnFillOn      = True
  res@cnFillMode    = "RasterFill"                  ; Raster Mode
  res@cnLinesOn     = False              ; turn off contour lines
  res@cnLineLabelsOn= False              ; turn off line labels
  res@pmTickMarkDisplayMode = "Always"            ; nice tickmark labels
  res@gsnRightString = "lat lon indicator starts from 0"                        ; no right string
  res@gsnLeftString  = " "                        ; no right string
  res@gsnRightStringFontHeightF = 0.015
  pres                   = True
  pres@gsnCoordsAsLines  = True
  pmres                        =  True
  pmres@gsMarkerIndex = 1
  pmres@gsMarkerSizeF = 0.03
  pmres@gsLineColor      = "red"                     ; color of lines
  pmres@gsLineThicknessF = 5.0                       ; thickness of lines

  tres                      = True                ; text mods desired
  tres@txFontHeightF        = 0.015               ; make smaller

  ;;set the axis of the map the orginal gridbox indices
  res@tmXBMode            = "Explicit"
  res@tmXBLabelFontHeightF  = 0.01
  res@tmYLMode            = "Explicit"
  res@tmYLLabelFontHeightF  = 0.01

do v = 0,dimsizes(keys_var)-1 ;draw the first 27(28) vars used in making ostart
  ;read data including lat and lon
  vartmp = filein->$keys_var(v)$
  latname = vartmp!2
  lonname = vartmp!3
  lat = filein->$latname$
  lon = filein->$lonname$
    sizelat = dimsizes(lat)
    sizelon = dimsizes(lon)
    if(max(lon).gt.360) then 
        lon := lon(0:dimsizes(lon)-3)
    end if
    if(region.eq."True") then
      latbind = ind_nearest_coord(latb, lat, 0)
      lattind = ind_nearest_coord(latt, lat, 0)
      lonlind = ind_nearest_coord(lonl, lon, 0)
      lonrind = ind_nearest_coord(lonr, lon, 0)
      lat := lat(latbind:lattind)
      lon := lon(lonlind:lonrind)
      vartmp := vartmp(:,:,latbind:lattind,lonlind:lonrind)
      else 
      latbind = 0
      lonlind = 0
    end if
  
  ;do depth = 0,1 ;dimsizes(vartmp(0,:,0,0))-1
  depth = 0
  var = vartmp(0,depth,:,:)
  res@tmYLValues          := lat ;;set the axis where it really is
  res@tmYLLabels          := lat
  res@tmYRLabels          := ispan(latbind, lattind,1)
  res@tmXBValues          := lon(:) ;; make it less dense
  res@tmXBLabels          := lon(:)
  
  print("for var"+keys_var(v)+sizelat+" the missing value is :"+num(ismissing(var)))
  ;set the names for pics
  plot_name = "gridbox_"+exp_name+"_"+ keys_var(v)+"_"+depth
  title = exp_name+"_" + keys_var(v)+"lat:"+sizelat+" lon:"+sizelon
  
  ;start to draw
  wks = gsn_open_wks("png",plot_path+plot_name)
  res@tiMainString  = title
  map = gsn_csm_contour(wks, var, res)

  ;;;;add the text to the as indicator for the box
  if(test_points.ne."True") then
    lonmid=(lonrind-lonlind)/2
    latmid=(lattind-latbind)/2
    dut = gsn_add_text(wks,map,"lon: "+(lonlind+lonmid)+" lat:"+(latbind+latmid),lon(lonmid),lat(latmid-2),tres)
    dum = gsn_add_polymarker(wks, map, lon(lonmid), lat(latmid), pmres)
  else
    dum = new((/dimsizes(lata_ref)*2/),"graphic")
    
    if(sizelat.eq.143) then
      box_lat_value = lat_box_value_u
      box_lon_value = lon_box_value_u
      else
      box_lat_value = lat_box_value_s
      box_lon_value = lon_box_value_s
    end if
    
    lata_ref = (/27,  38, 37,  40, 41,  45/)
    lona_ref = (/26,  33, 36,  40, 31,  40/)

    do i = 0, dimsizes(lata_ref)/2-1  ; how many boxes we need
    dum(i*4)  = gsn_add_polyline(wks, map, (/box_lon_value(i*2),  box_lon_value(i*2+1)/), (/box_lat_value(i*2),  box_lat_value(i*2)/),   pmres)
    dum(i*4+1)= gsn_add_polyline(wks, map, (/box_lon_value(i*2),  box_lon_value(i*2+1)/), (/box_lat_value(i*2+1),box_lat_value(i*2+1)/), pmres)
    dum(i*4+2)= gsn_add_polyline(wks, map, (/box_lon_value(i*2),  box_lon_value(i*2)/),   (/box_lat_value(i*2),  box_lat_value(i*2+1)/), pmres)
    dum(i*4+3)= gsn_add_polyline(wks, map, (/box_lon_value(i*2+1),box_lon_value(i*2+1)/), (/box_lat_value(i*2),  box_lat_value(i*2+1)/), pmres)
    end do 
  end if

  gsn_coordinates(wks,map,var,pres)

  ;clear the memory to start another loop
  clear(wks)
  delete([/var/])
  system("rm "+" "+plot_path+plot_name+".000001.png")
  system("mv "+" "+plot_path+plot_name+".000002.png"+" "+plot_path+plot_name+".png")
  ;end do 
  delete([/vartmp,lat,lon/])
end do