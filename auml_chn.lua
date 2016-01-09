local p_chn = Proto.new("auml_chn", "Auml Channel data")

local f_chn_id = ProtoField.uint8("auml_chn.id", "Channel ID", base.DEC)
local f_chn_src = ProtoField.uint8("auml_chn.src", "Source", base.DEC)
local f_chn_value = ProtoField.uint8("auml_chn.value", "Value", base.DEC)

p_chn.fields = {
    f_chn_id,
    f_chn_src,
    f_chn_value
}

-- Fields to read
local f_can_id = Field.new("can.id")

function p_chn.dissector(tvb,pinfo,root)
    local subt = root:add(p_chn, tvb)
    local chn_id = f_can_id().tvb:bitfield( 8,16)
    local chn_src = f_can_id().tvb:bitfield(24, 8)

    subt:add(f_chn_id,  chn_id)
    subt:add(f_chn_src, chn_src)
   
    -- FIXME: Handle more data fields than one
    if tvb:len() ~= 2 then return end
    local chn_value = tvb(0,2)
    subt:add(f_chn_value, chn_value)
    
    pinfo.cols.protocol = "CHN"
    pinfo.cols.src = string.format("node %d", chn_src)
    pinfo.cols.dst = string.format("chn %d", chn_id)
    pinfo.cols.info = string.format("Value: %d", chn_value:uint())
end

DissectorTable.get("auml.cmd"):add(0xa,p_chn)
