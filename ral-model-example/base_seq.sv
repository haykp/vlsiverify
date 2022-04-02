class base_seq extends uvm_sequence#(seq_item);
  seq_item req;
  `uvm_object_utils(base_seq)

  function new (string name = "base_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "Base seq: Inside Body", UVM_LOW);
    `uvm_do(req);
  endtask
endclass

class reg_seq extends uvm_sequence#(seq_item);
  // seq_item req;
  RegModel_SFR reg_model;
  uvm_status_e   status;
  uvm_reg_data_t read_data;
  `uvm_object_utils(reg_seq)

  function new (string name = "reg_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), "Reg seq: Inside Body", UVM_LOW);
    // Here we got the reg_model from config db. Well other option to pass this model from the top
    if(!uvm_config_db#(RegModel_SFR) :: get(uvm_root::get(), "", "reg_model", reg_model))
      `uvm_fatal(get_type_name(), "reg_model is not set at top level");
    // Now we just use read,write tasks to work with the reg_model and read, write the registers.
    // We specify the exact register from reg_model to which we want to write or read
    // After this all these information should be transferred to the driver, where the driver to toggle the interface pins of DUT to implements write/read
    // So we need to translate this high level commands to driver understandable langauge. For that reason we have the adaptor class, where we already 
    // wrote how the translation should happen.
    reg_model.mod_reg.control_reg.write(status, 32'h1234_1234);
    reg_model.mod_reg.control_reg.read(status, read_data);

    reg_model.mod_reg.intr_msk_reg.write(status, 32'h5555_5555);
    reg_model.mod_reg.intr_msk_reg.read(status, read_data);

    reg_model.mod_reg.debug_reg.write(status, 32'hAAAA_AAAA);
    reg_model.mod_reg.debug_reg.read(status, read_data);
  endtask
endclass
