;;---This script is used to draw the gridbox of the ancillary data
;;---This is how to use it
; ncl 'filename=[filepath+filename]' draw_gridbox_ancil.ncl

;;---draw all in the folder
;; for i in $(ls ~/ancil/preind_tenvo/qr*.nc);do ncl 'filename="'$i'"' 'exp_name="preind"'  ~/scripts/draw_gridbox_ancil.ncl;done
;;

;exp_name = "PI"
plot_path = "~/work/chap3/gridbox_plot/"

region = "True" ;;;True or False
test_points = "True" ;;;add lines to the test grids?

;;-----set latlon box
  latb = 30.
  latt = -25.
  lonl = 90.
  lonr = 160.  ;;;;this is for larger map

;;----draw box for the test area. indice are the two corners of the box
latx1 = (/27,  39/)
lonx1 = (/26,  34/)
latx2 = (/36,  40/)
lonx2 = (/35,  41/)
latx3 = (/40,  45/)
lonx3 = (/30,  41/)


;---Read netCDF file
  filein   = addfile(filename,"r")

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

var_name_list=getfilevarnames(filein)
do i=0,dimsizes(var_name_list)-1
  var_name=var_name_list(i)
  shape=filevardimsizes(filein,var_name)
if(dimsizes(shape).eq.4) then
  vartmp = filein->$var_name$
  var = vartmp(0,0,:,:)
  latname = var!0
  lonname = var!1
  lat = filein->$latname$
  lon = filein->$lonname$
    ;;;there are longitude over 360 for ancillary input. it is overlapping with the 1st data. 
    ;;; still not sure if I should add the following line 
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
    var := var(latbind:lattind,lonlind:lonrind)
  end if

  res@tmYLValues          := lat ;;set the axis where it really is
  res@tmYLLabels          := lat
  res@tmYRLabels          := ispan(latbind, lattind,1)
  res@tmXBValues          := lon(:) ;; make it less dense
  res@tmXBLabels          := lon(:)

  ;set the names for pics
  plot_name = "gridbox_" +exp_name+"_atm_"+ var_name
  title = "gridbox_" +exp_name+"_" + var_name
  
  ;start to draw
  wks = gsn_open_wks("png",plot_path+plot_name)
  res@tiMainString  = title
  map = gsn_csm_contour(wks, var, res)

  ;;;;add the text to the as indicator for the box


  ;;;;add the text to the as indicator for the box
  if(test_points.ne."True") then
    lonmid=(lonrind-lonlind)/2
    latmid=(lattind-latbind)/2
    dut = gsn_add_text(wks,map,"lon: "+(lonlind+lonmid)+" lat:"+(latbind+latmid),lon(lonmid),lat(latmid-2),tres)
    dum = gsn_add_polymarker(wks, map, lon(lonmid), lat(latmid), pmres)
  else
    dum = new((/12/),"graphic")
    dum(0) =gsn_add_polyline(wks,map,(/lon(lonx1(0)-lonlind),lon(lonx1(0)-lonlind)/),(/lat(latx1(0)-latbind),lat(latx1(1)-latbind)/),pmres)
    dum(1) =gsn_add_polyline(wks,map,(/lon(lonx1(1)-lonlind),lon(lonx1(1)-lonlind)/),(/lat(latx1(0)-latbind),lat(latx1(1)-latbind)/),pmres)
    dum(2) =gsn_add_polyline(wks,map,(/lon(lonx1(0)-lonlind),lon(lonx1(1)-lonlind)/),(/lat(latx1(0)-latbind),lat(latx1(0)-latbind)/),pmres)
    dum(3) =gsn_add_polyline(wks,map,(/lon(lonx1(0)-lonlind),lon(lonx1(1)-lonlind)/),(/lat(latx1(1)-latbind),lat(latx1(1)-latbind)/),pmres)
    dum(4) =gsn_add_polyline(wks,map,(/lon(lonx2(0)-lonlind),lon(lonx2(0)-lonlind)/),(/lat(latx2(0)-latbind),lat(latx2(1)-latbind)/),pmres)
    dum(5) =gsn_add_polyline(wks,map,(/lon(lonx2(1)-lonlind),lon(lonx2(1)-lonlind)/),(/lat(latx2(0)-latbind),lat(latx2(1)-latbind)/),pmres)
    dum(6) =gsn_add_polyline(wks,map,(/lon(lonx2(0)-lonlind),lon(lonx2(1)-lonlind)/),(/lat(latx2(0)-latbind),lat(latx2(0)-latbind)/),pmres)
    dum(7) =gsn_add_polyline(wks,map,(/lon(lonx2(0)-lonlind),lon(lonx2(1)-lonlind)/),(/lat(latx2(1)-latbind),lat(latx2(1)-latbind)/),pmres)
    dum(8) =gsn_add_polyline(wks,map,(/lon(lonx3(0)-lonlind),lon(lonx3(0)-lonlind)/),(/lat(latx3(0)-latbind),lat(latx3(1)-latbind)/),pmres)
    dum(9) =gsn_add_polyline(wks,map,(/lon(lonx3(1)-lonlind),lon(lonx3(1)-lonlind)/),(/lat(latx3(0)-latbind),lat(latx3(1)-latbind)/),pmres)
    dum(10)=gsn_add_polyline(wks,map,(/lon(lonx3(0)-lonlind),lon(lonx3(1)-lonlind)/),(/lat(latx3(0)-latbind),lat(latx3(0)-latbind)/),pmres)
    dum(11)=gsn_add_polyline(wks,map,(/lon(lonx3(0)-lonlind),lon(lonx3(1)-lonlind)/),(/lat(latx3(1)-latbind),lat(latx3(1)-latbind)/),pmres)
    end if

  gsn_coordinates(wks,map,var,pres)

  ;clear the memory to start another loop
  clear(wks)
  delete([/vartmp,var,lat,lon/])
  system("rm "+" "+plot_path+plot_name+".000001.png")
  system("mv "+" "+plot_path+plot_name+".000002.png"+" "+plot_path+plot_name+".png")
end if
delete(shape)
end do