;;;;This is used to check if the SST grids matches the ucurr and taux grids
;;;Usage:
;;;ncl 'ostartfile="~/ancil/'${exp_name}'/'${exp_name}'.ostart.nc"' ~/scripts/check_UV_grid.ncl 

fileocean=addfile(ostartfile,"r")
sst=fileocean->temp_dpth(0,:,:,:)
sss=fileocean->salinity_dpth(0,:,:,:)
ucurr=fileocean->ucurrBaro_dpth(0,:,:,:)
taux=fileocean->TAUX_uo(0,:,:,:)
lats=fileocean->latitude
lons=fileocean->longitude
latu=fileocean->latitude_1
lonu=fileocean->longitude_1

grid_sst=where(.not.ismissing(sst),1,0)
grid_sss=where(.not.ismissing(sss),1,0)
grid_ucurr=where(.not.ismissing(ucurr),1,0)
grid_taux=where(.not.ismissing(taux),1,0)

grid_sssta = grid_sst-grid_sst 
copy_VarCoords(grid_sss, grid_sssta)

;;;trans grid from sst to ucurr and taux
grid_uv_from_sst = new((/dimsizes(ucurr(:,0,0)),dimsizes(ucurr(0,:,0)),dimsizes(ucurr(0,0,:))/),typeof(ucurr),ucurr@_FillValue) 
grid_uv_from_sst = 1
do de = 0,dimsizes(sst(:,0,0))-1
    ;;middle map
    do i = 1,dimsizes(lats)-2 ;there's no data in the first and last lat line
        do j =0,dimsizes(lons)-1
        if(grid_sss(de,i,j).eq.0) then
            ;;;deal with the overlapping lon value 
            if(j.eq.0) then
                grid_uv_from_sst(de,i-1:i,j) = 0 ;;;; the surrounding 4 points of S grid will be missing
                grid_uv_from_sst(de,i-1:i,dimsizes(lons)-3:dimsizes(lons)-2) = 0 ;;;the other side of the map will also be missing
                end if
            if(j.eq.1) then
                grid_uv_from_sst(de,i-1:i,j-1:j) = 0 ;;;; the surrounding 4 points of S grid will be missing
                grid_uv_from_sst(de,i-1:i,dimsizes(lons)-2:dimsizes(lons)-1) = 0 ;;;the other side of the map will also be missing 
                end if
            if(j.eq.2) then
                grid_uv_from_sst(de,i-1:i,j-1:j) = 0 ;;;; the surrounding 4 points of S grid will be missing
                grid_uv_from_sst(de,i-1:i,dimsizes(lons)-1) = 0 ;;;the other side of the map will also be missing 
                end if
            ;;;;deal with the non-overlapping value
            if(j.ge.3) then
                grid_uv_from_sst(de,i-1:i,j-1:j) = 0 ;;;; the surrounding 4 points of S grid will be missing
                end if
        end if
        end do
    end do
end do

grid_uv_from_sst(:,0,:) = 0 ;;;; the last lat line will be missing
grid_uv_from_sst(:,dimsizes(lats)-2,:) = 0 ;;;; the last lat line will be missing

grid_uva_cur = grid_ucurr-grid_uv_from_sst ;should be 0, if grid transfer is right
grid_uva_tau = grid_taux(0,:,:)-grid_uv_from_sst(0,:,:)

copy_VarCoords(grid_ucurr, grid_uv_from_sst)
copy_VarCoords(grid_ucurr, grid_uva_cur)
copy_VarCoords(grid_ucurr(0,:,:), grid_uva_tau)


if(sum(grid_sssta).ne.0) then
print(" SSS data not match SST data, sum of unmatched points is: "+sum(grid_sssta))
end if
if(sum(grid_uva_tau).ne.0) then 
print("SST derived grids and TAUX grids does not match, sum of unmatched points is: "+sum(grid_uva_tau))
end if 
if(sum(grid_uva_cur).ne.0) then
print("SST derived grids and ucurr does not match, sum of unmatched points is: "+sum(grid_uva_cur))
a1D      = ndtooned(grid_uva_cur)
dsizes_a = dimsizes(grid_uva_cur)
indices  = ind_resolve(ind(a1D.ne.0),dsizes_a)
print("check points ")
;print(indices)
end if

if(sum(grid_sssta).eq.0 .and. sum(grid_uva_tau).eq.0 .and. sum(grid_uva_cur).eq.0) then
print("Great!! Oceanic grids match!!!!")
print("Now proceed to the next step!")
end if