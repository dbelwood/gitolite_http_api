module KeyHelper
	KEY_ROOT = File.join(File.expand_path(File.dirname(__FILE__)), "../../keys").to_s
	def get_key_data email
		data = (File.read("#{KEY_ROOT}/#{email}.pub")).split
		{:type => data[0], :blob => data[1], :email => data[2]}
	end
end