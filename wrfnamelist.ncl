;;==============================================================================
;; WRF namelist parser
;; Author: Shen Wenqiang
;; Email: wqshen91@gmail.com
;; Date: 2016/12/6
;;-----------------------------------------------------------------------------
;; Usage: test.ncl
;;    --------------------------------------------------------
;;   |   load "./wrfnamelist.ncl"                             |
;;   |   wrfnamelist('~/WRF/WRFV3/run/namelist.input')        |
;;   |   print("DX = "+domains@dx+" DY = "+domains@dy)        |
;;   |   print("Start Time: " +time_control@start_year+" "+\  |
;;   |                         time_control@start_month+" "+\ |
;;   |                         time_control@start_day+" "+\   |
;;   |                         time_control@start_hour)       |
;;    --------------------------------------------------------
;;==============================================================================

;------------------------------------------------------------
;; Initialize Global Variables, You can append more !
time_control = False
domains = False
dynamics = False
physics = False
fdda = False
bdy_control = False
grib2 = False
namelist_quilt = False
tc = False
;--------------------------------------------

function read(path: string)
begin
    data = asciiread(path, -1, "string")
    match_start = str_match_ind(data, "&")
    match_end = str_match_ind(data, "/")
    if (dimsizes(match_start) .ne. dimsizes(match_end)) .or. \
       (all(ismissing(match_start)) .or. all(ismissing(match_end))) then
        print("Error: The input seems not a correct WRF namelist files!")
        exit
    end if
    return [/data, match_start, match_end/]
end

function asserttype(str [*]: string)
begin
    dq = str_get_dq()
    if isStrSubset(str, "true") .or. isStrSubset(str, "false") then
        type = "logical"
    else if isStrSubset(str, dq).or. isStrSubset(str, "'") then
        type = "string"
    else if isStrSubset(str, ".") then
        type = "float"
    else if .not. ismissing(str_match_regex(str, "[0-9,]")) then
        type = "int"
    else
        print("Error: The type of value can't be confirmed")
        exit
    end if
    end if
    end if
    end if
    return type
end

function stringtological(value [*]: string)
begin
    out = new(dimsizes(value), logical)
    do i = 0, dimsizes(value)-1
    if isStrSubset(value(i), ".true.") then
        out(i) = True
    else if isStrSubset(value(i), ".false.") then
        out(i) = False
    end if
    end if
    end do
    return out
end

function attribution(seg)
local len, segvar, line
begin
    len = dimsizes(seg)-2
    segvar = True
    do j = 0, len-1
        line = str_strip(str_split(seg(len-j), "="))
        key = line(0)
        value := str_strip(str_split(line(1), ","))
        type = asserttype(line(1))
	if type .eq. "int" then
            value := toint(value)
        else if type .eq. "float" then
            value := tofloat(value)
        else if type .eq. "logical" then
            value := stringtological(value)
        else if type .eq. "string" then
	    value := str_split(value, str_get_dq())
	    print(value)
        end if
        end if
        end if
	end if
        segvar@$key$ = value
    end do
    return segvar
end

procedure delunusedvar()
begin
    if time_control .eq. False then
        delete(time_control)
    else if domains .eq. False  then
        delete(domains)
    else if physics .eq. False  then
        delete(physics)
    else if dynamics .eq. False  then
        delete(dynamics)
    else if fdda .eq. False  then
        delete(fdda)
    else if bdy_control .eq. False  then
        delete(bdy_control)
    else if grib2 .eq. False  then
        delete(grib2)
    else if namelist_quilt .eq. False  then
        delete(namelist_quilt)
    else if tc .eq. False  then
        delete(tc)
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
    end if
end

procedure decompose(data, s, e)
local i, seg, segname, segattr
begin
    do i = 0, dimsizes(s)-1
        seg := data(s(i):e(i))
        len = e(i)-s(i)-1
        segname = str_split(str_strip(seg(0)), "&")
        segattr = attribution(seg)
        if segname .eq. "time_control" then
            time_control = segattr
        else if segname .eq. "domains" then
            domains = segattr
        else if segname .eq. "physics"
            physics = segattr
        else if segname .eq. "dynamics"
            dynamics = segattr
        else if segname .eq. "fdda"
            fdda = segattr
        else if segname .eq. "bdy_control"
            bdy_control = segattr
        else if segname .eq. "grib2"
            grib2 = segattr
        else if segname .eq. "namelist_quilt"
            namelist_quilt = segattr
        else if segname .eq. "tc"
            tc = segattr
        end if
        end if
        end if
        end if
        end if
        end if
        end if
        end if
        end if
    end do
    delunusedvar()
end

procedure wrfnamelist(pathfile [1]: string)
local f
begin
    f = read(pathfile)
    decompose(f[0], f[1], f[2])
end
