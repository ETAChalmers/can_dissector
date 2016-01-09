local p_nmt = Proto.new("auml_nmt", "Auml Network management")

local f_nmt_type = ProtoField.uint8("auml_nmt.type", "NMT Type id", base.DEC)
local f_nmt_src = ProtoField.uint8("auml_nmt.src", "Source", base.DEC)
local f_nmt_dst = ProtoField.uint8("auml_nmt.dst", "Destination", base.DEC)

-- For time packets
local f_nmt_time = ProtoField.uint32("auml_nmt.time", "Timestamp", base.DEC)

local f_nmt_hwid = ProtoField.uint32("auml_nmt.hwid", "Hardware ID", base.HEX)
local f_nmt_num_modules = ProtoField.uint8("auml_nmt.num_modules", "Number of Modules", base.DEC)

p_nmt.fields = {
    f_nmt_type,
    f_nmt_src,
    f_nmt_dst,
    f_nmt_time,
    f_nmt_hwid
}

-- Fields to read
local f_can_id = Field.new("can.id")

function p_nmt.dissector(tvb,pinfo,root)
    local subt = root:add(p_nmt, tvb)

    local can_id = f_can_id().tvb

    local nmt_type = can_id:bitfield( 8, 8)
    local nmt_src  = can_id:bitfield(16, 8)
    local nmt_dst  = can_id:bitfield(24, 8)

    subt:add(f_nmt_src,  nmt_src)
    subt:add(f_nmt_dst,  nmt_dst)

    pinfo.cols.protocol = "NMT"

    if nmt_src == 0 then
        pinfo.cols.src = ""
    else
        pinfo.cols.src = string.format("node %d", nmt_src)
    end

    if nmt_dst == 0 then
        pinfo.cols.dst = ""
    else
        pinfo.cols.dst = string.format("node %d", nmt_dst)
    end

    if nmt_type == 0 then -- Time / watchdog reset
        local nmt_time = tvb(0,4):le_uint()
        subt:add(f_nmt_time, nmt_time)
        pinfo.cols.info = string.format("Time: %s UTC", os.date("!%Y-%m-%d %H:%M:%S", nmt_time))
    elseif nmt_type == 44 then -- Heartbeat, node is alive
        local nmt_hwid = tvb(0,4):le_uint()
        local nmt_num_modules = tvb(4,1):le_uint()
        subt:add(f_nmt_hwid, nmt_hwid)
        subt:add(f_nmt_num_modules, nmt_num_modules)
        pinfo.cols.info = string.format("Heartbeat hwid: %08x (%d modules)", nmt_hwid, nmt_num_modules)
    else
        pinfo.cols.info = string.format("Type: %d, Data: %s", nmt_type, tvb(0))
    end
end

DissectorTable.get("auml.cmd"):add(0x0,p_nmt)
