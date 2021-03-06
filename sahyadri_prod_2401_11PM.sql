PGDMP     !                     y            sahyadri    12.4    13.0 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16426    sahyadri    DATABASE     \   CREATE DATABASE sahyadri WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF8';
    DROP DATABASE sahyadri;
                cloudsqlsuperuser    false            	            2615    16428 
   masterdata    SCHEMA        CREATE SCHEMA masterdata;
    DROP SCHEMA masterdata;
                sahyadri    false            �           0    0    SCHEMA public    ACL     �   REVOKE ALL ON SCHEMA public FROM cloudsqladmin;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO cloudsqlsuperuser;
GRANT ALL ON SCHEMA public TO PUBLIC;
                   cloudsqlsuperuser    false    4                        3079    16429 	   uuid-ossp 	   EXTENSION     C   CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA masterdata;
    DROP EXTENSION "uuid-ossp";
                   false    9            �           0    0    EXTENSION "uuid-ossp"    COMMENT     W   COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';
                        false    2            n           1255    17592   create_address(uuid, uuid, character varying, character varying, character varying, bigint, character varying, character varying, character varying, character varying, character varying, character varying, boolean, boolean, bigint, boolean, numeric, numeric, character varying)    FUNCTION     �
  CREATE FUNCTION masterdata.create_address(_store_id uuid, _customer_id uuid, _first_name character varying, _last_name character varying, _email character varying, _mobile bigint, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _is_billing boolean, _is_shipping boolean, _pincode bigint, _is_default boolean, _latitude numeric, _longitude numeric, _landmark character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __address_id UUID;
		__existing_address_id uuid;
        __is_default boolean;
	BEGIN

        if _customer_id is not null then

            if _is_default = 'true' THEN

                UPDATE masterdata.addresses SET is_default = 'false'
                where customer_id = _customer_id;
				
				select _is_default into __is_default;

            end if;
			
			if _is_default is null then
			
                __is_default = 'false';
			end if;
			
			select address_id into __existing_address_id from masterdata.addresses where customer_id = _customer_id and is_active = true;

            if __existing_address_id is null then 

                __is_default = 'true';
				
			end if;

            INSERT INTO masterdata.addresses(store_id, customer_id, first_name, last_name, email, mobile, line_1, line_2, street, city, state, country, pincode, is_billing, is_shipping, created_by, updated_by, is_default, latitude, longitude, landmark) 
                values (_store_id, _customer_id, _first_name, _last_name, _email, _mobile, _line_1, _line_2, _street, _city, _state, _country, _pincode, _is_billing , _is_shipping, _customer_id, _customer_id, __is_default, _latitude, _longitude, _landmark) 
                RETURNING address_id into __address_id;

        else 

            INSERT INTO masterdata.addresses(store_id, customer_id, first_name, last_name, email, mobile, line_1, line_2, street, city, state, country, pincode, is_billing, is_shipping, created_by, updated_by) 
                values (_store_id, _customer_id, _first_name, _last_name, _email, _mobile, _line_1, _line_2, _street, _city, _state, _country, _pincode, _is_billing , _is_shipping, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', '009d88ce-df5e-11e9-a5a4-533ffa965c3d') 
                RETURNING address_id into __address_id;

        end if;

    RETURN __address_id;                                                       -- Return the id to the caller
	  
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_address', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _customer_id);
			RETURN 'failure';
    END;
$$;
 �  DROP FUNCTION masterdata.create_address(_store_id uuid, _customer_id uuid, _first_name character varying, _last_name character varying, _email character varying, _mobile bigint, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _is_billing boolean, _is_shipping boolean, _pincode bigint, _is_default boolean, _latitude numeric, _longitude numeric, _landmark character varying);
    
   masterdata          sahyadri    false    9            L           1255    16441 2   create_delivery_option(character varying, boolean)    FUNCTION       CREATE FUNCTION masterdata.create_delivery_option(_delivery_option character varying, _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __delivery_option_id UUID;
	BEGIN

		IF _delivery_option not in (select delivery_option from masterdata.delivery_options) then

        INSERT INTO masterdata.delivery_options( delivery_option, is_active, created_by, updated_by) 
            values ( _delivery_option, _is_active, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', '009d88ce-df5e-11e9-a5a4-533ffa965c3d') 
            RETURNING delivery_option_id into __delivery_option_id;

        RETURN __delivery_option_id;       

        ELSE

            RETURN 'delivery_option_already_present'; 

        END IF;
	
	
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.delivery_option', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _delivery_option);
			RETURN 'failure';
	  
    END;
$$;
 i   DROP FUNCTION masterdata.create_delivery_option(_delivery_option character varying, _is_active boolean);
    
   masterdata          sahyadri    false    9                       1255    16442 �   create_delivery_point(character varying, bigint, bigint, character varying, character varying, character varying, character varying, character varying, character varying, bigint, bigint[])    FUNCTION     t  CREATE FUNCTION masterdata.create_delivery_point(_delivery_point_name character varying, _plant_code bigint, _dp_code bigint, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _pincode bigint, _serviceable_pincodes bigint[]) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __delivery_point_id UUID;
		__address_id UUID;
        __pincode bigint;
	BEGIN

        INSERT INTO masterdata.delivery_points( delivery_point_name, plant_code, dp_code, created_by, updated_by) 
            values ( _delivery_point_name, _plant_code, _dp_code, '009d88ce-df5e-11e9-a5a4-533ffa965c3d','009d88ce-df5e-11e9-a5a4-533ffa965c3d') 
            RETURNING delivery_point_id into __delivery_point_id;

        INSERT INTO masterdata.addresses( line_1, line_2, street, city, state, country, pincode, created_by, updated_by) 
                values ( _line_1, _line_2, _street, _city, _state, _country, _pincode, __delivery_point_id, __delivery_point_id) 
                RETURNING address_id into __address_id;

        FOREACH __pincode in array _serviceable_pincodes
        LOOP

            insert into masterdata.serviceable_pincodes (pincode, delivery_point_id, created_by, updated_by) 
					values (__pincode, __delivery_point_id,  
						    __delivery_point_id, __delivery_point_id) ;

        End LOOP;

        UPDATE masterdata.delivery_points
        SET address_id = __address_id
        WHERE delivery_point_id = __delivery_point_id;

    RETURN __delivery_point_id;             
	
	
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_delivery_point', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _delivery_point_name);
			RETURN 'failure';
	  
    END;
$$;
 N  DROP FUNCTION masterdata.create_delivery_point(_delivery_point_name character varying, _plant_code bigint, _dp_code bigint, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _pincode bigint, _serviceable_pincodes bigint[]);
    
   masterdata          sahyadri    false    9                       1255    16443 ,   create_frequency(character varying, boolean)    FUNCTION     �  CREATE FUNCTION masterdata.create_frequency(_frequency character varying, _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __frequency_id UUID;
	BEGIN

		IF _frequency not in (select frequency from masterdata.frequencies) then
		
			INSERT INTO masterdata.frequencies( frequency, is_active, created_by, updated_by) 
			values ( _frequency, _is_active, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', '009d88ce-df5e-11e9-a5a4-533ffa965c3d') 
			RETURNING frequency_id into __frequency_id;

    		RETURN __frequency_id;   			
			
		else

  			return 'frequency_already_present';
			
		end if;
	
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.frequencies', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _frequency);
			RETURN 'failure';
	  
    END;
$$;
 ]   DROP FUNCTION masterdata.create_frequency(_frequency character varying, _is_active boolean);
    
   masterdata          sahyadri    false    9            ?           1255    16444 e   create_get_customer(bigint, character varying, character varying, bigint, character varying, numeric)    FUNCTION     �  CREATE FUNCTION masterdata.create_get_customer(_store_id bigint, _first_name character varying, _last_name character varying, _magento_customer_id bigint, _email character varying, _mobile numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	    __customer_status boolean;
        __customer_id UUID;
	BEGIN

        if _magento_customer_id is not null then

            select cm.is_active into __customer_status from masterdata.customers cm where cm.magento_customer_id = _magento_customer_id;

            if __customer_status is null or not __customer_status then

                INSERT INTO masterdata.customers(store_id, magento_customer_id, first_name, last_name, email, mobile, is_active, created_by, updated_by) 
                    values (_store_id, _magento_customer_id, _first_name, _last_name, _email, _mobile, 'true', '009d88ce-df5e-11e9-a5a4-533ffa965c3d', '009d88ce-df5e-11e9-a5a4-533ffa965c3d') 
                    RETURNING customer_id into __customer_id;
                    
            else
                
                SELECT customer_id INTO __customer_id FROM masterdata.customers WHERE is_active = true and magento_customer_id = _magento_customer_id; 

            end if;

        else 

            INSERT INTO masterdata.customers(is_active, created_by, updated_by) 
                    values ('true', '009d88ce-df5e-11e9-a5a4-533ffa965c3d', '009d88ce-df5e-11e9-a5a4-533ffa965c3d') 
                    RETURNING customer_id into __customer_id;

        end if;

    RETURN __customer_id;                                                       -- Return the id to the caller
	  
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_teammate', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _magento_customer_id);
			RETURN 'failure';
    END;
$$;
 �   DROP FUNCTION masterdata.create_get_customer(_store_id bigint, _first_name character varying, _last_name character varying, _magento_customer_id bigint, _email character varying, _mobile numeric);
    
   masterdata          sahyadri    false    9            M           1255    17280    create_min_order_value(numeric)    FUNCTION     �  CREATE FUNCTION masterdata.create_min_order_value(_min_order_value numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __min_order_value_id UUID;
		__existing_min_order_value numeric;
	BEGIN
	
		SELECT count(*) into __existing_min_order_value from masterdata.min_order_value;

        if __existing_min_order_value is not null THEN

            DELETE from masterdata.min_order_value;
        
        end if;

        INSERT INTO masterdata.min_order_value(min_order_value) 
            values ( _min_order_value) 
            RETURNING min_order_value_id into __min_order_value_id;

    RETURN __min_order_value_id;             
	
	
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_min_order_value', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _min_order_value);
			RETURN 'failure';
	  
    END;
$$;
 K   DROP FUNCTION masterdata.create_min_order_value(_min_order_value numeric);
    
   masterdata          sahyadri    false    9            W           1255    17158 z   create_oms_user(character varying, character varying, bigint, character varying, character varying, uuid, uuid[], boolean)    FUNCTION     L  CREATE FUNCTION masterdata.create_oms_user(_first_name character varying, _last_name character varying, _mobile bigint, _email character varying, _password character varying, _role_id uuid, _store_id uuid[], _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __user_id UUID;
		__email character varying;
	BEGIN
		
		

		IF _email in (select email from masterdata.oms_users) then
		
			return 'email_already_present';
			
		else

            INSERT INTO masterdata.oms_users( first_name, last_name, mobile, email, password, role_id, store_id, is_active) 
                values ( _first_name, _last_name, _mobile, _email, _password, _role_id, _store_id, _is_active) 
                RETURNING user_id into __user_id;
                
            RETURN __user_id; 

		
		END IF;
		
	
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_oms_user', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _email);
			RETURN 'failure';
	  
    END;
$$;
 �   DROP FUNCTION masterdata.create_oms_user(_first_name character varying, _last_name character varying, _mobile bigint, _email character varying, _password character varying, _role_id uuid, _store_id uuid[], _is_active boolean);
    
   masterdata          sahyadri    false    9            S           1255    17149 o   create_order(uuid, uuid, uuid, uuid, character varying, uuid, character varying, uuid, uuid, character varying)    FUNCTION     )  CREATE FUNCTION masterdata.create_order(_cart_id uuid, _billing_address_id uuid, _shipping_address_id uuid, _channel_id uuid, _payment_method character varying, _time_slot_id uuid, _order_type character varying, _fulfilment_id uuid, _store_id uuid, _slot_date character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
     __cart_id uuid;
	 __customer_id uuid;
	 __cart_amount bigint;
     __first_name character varying;
	 __last_name character varying;
	 __email character varying;
     __mobile bigint;
     __app_order_no CHARACTER VARYING;
     __order_id uuid;
	 __status_id uuid;
	 __online_status_id uuid;
     __order_part_id uuid;
     __channel CHARACTER VARYING;
     __channel_id uuid;
	 __packaging_type_id uuid;
     __sub_total numeric;
     __delivery_charges numeric;
	 __payment_method CHARACTER VARYING;

	BEGIN

		select cart_id into __cart_id from masterdata.carts where cart_id = _cart_id and is_active = true;

		if __cart_id is not null then 

            SELECT customer_id, cart_amount, packaging_type_id, sub_total,delivery_charges into __customer_id , __cart_amount,__packaging_type_id, __sub_total, __delivery_charges from masterdata.carts where cart_id = __cart_id;

            if __customer_id is not null then

                -- select magento_customer_id into __magento_customer_id from masterdata.customers where customer_id = __customer_id;

                -- if __magento_customer_id is not null then
			
				
					select status_id into __status_id from masterdata.status where status_name = 'placed';
					select status_id into __online_status_id from masterdata.status where status_name = 'payment_failed';
					select channel, channel_id into __channel, __channel_id from masterdata.channels where channel_id = _channel_id;

                    select masterdata.generate_unique_app_order_number(__channel) into __app_order_no;

			        select first_name , last_name, email, mobile  into __first_name , __last_name , __email, __mobile from masterdata.addresses where address_id = _billing_address_id;		
					
					if _payment_method = 'ONLINE_PAYMENT' THEN

						INSERT INTO masterdata.orders (cart_id, customer_id, billing_address_id, shipping_address_id, channel_id, order_no, payment_method, total_amount, status_id, created_by, updated_by, status_history, time_slot_id, packaging_type_id, sub_total, delivery_charges, payment_status, store_id, slot_date)
						values (__cart_id, __customer_id, _billing_address_id, _shipping_address_id, __channel_id, __app_order_no, _payment_method, __cart_amount, __online_status_id, __customer_id, __customer_id, concat('placed','@',CURRENT_TIMESTAMP), _time_slot_id, __packaging_type_id, __sub_total, __delivery_charges, 'FAILURE', _store_id, _slot_date)
						RETURNING order_id into __order_id;
						
					else
					
						INSERT INTO masterdata.orders (cart_id, customer_id, billing_address_id, shipping_address_id, channel_id, order_no, payment_method, total_amount, status_id, created_by, updated_by, status_history, time_slot_id, packaging_type_id, sub_total, delivery_charges, payment_status, store_id, slot_date)
						values (__cart_id, __customer_id, _billing_address_id, _shipping_address_id, __channel_id, __app_order_no, _payment_method, __cart_amount, __status_id, __customer_id, __customer_id, concat('placed','@',CURRENT_TIMESTAMP), _time_slot_id, __packaging_type_id, __sub_total, __delivery_charges, 'SUCCESS', _store_id, _slot_date)
						RETURNING order_id into __order_id;
						
					end if;
					

                    INSERT INTO masterdata.order_parts (order_id, order_type, fulfilment_id, shipping_address_id, amount, created_by, updated_by)
                    values (__order_id, _order_type, _fulfilment_id, _shipping_address_id, __cart_amount, __customer_id, __customer_id )
                    RETURNING order_part_id into __order_part_id;

                    INSERT INTO masterdata.order_lines (cart_id, item_id, item_name, item_description, quantity, price, item_image_urls, item_category, item_shelf_life, total_price, user_subscription_id , created_by, updated_by,
													   				pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, row, rack, bin, ean, hsn, gst, item_status,
													   				category_id, category_name, sub_category_id, sub_category_name, mrp, final_selling_price)
                    SELECT cart_id, item_id, item_name, item_description, quantity, price, item_image_urls, item_category, item_shelf_life, total_price, user_subscription_id, created_by, updated_by,
																	pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, row, rack, bin, ean, hsn, gst, item_status,
																	category_id, category_name, sub_category_id, sub_category_name, mrp, final_selling_price
                    FROM masterdata.cart_lines
                    WHERE cart_id = __cart_id;

                    UPDATE masterdata.order_lines 
                    SET order_part_id = __order_part_id
                    WHERE cart_id = __cart_id;

                    DELETE from masterdata.cart_lines WHERE cart_id = __cart_id;

                    DELETE from masterdata.carts where cart_id = __cart_id;

                    UPDATE masterdata.time_slots
                    SET slot_current_orders = slot_current_orders + 1
                    WHERE time_slot_id = _time_slot_id;

                    RETURN concat(__order_id,',', __app_order_no,',',__cart_amount,',',__first_name,',', __last_name,',', __email,',', __mobile,',',__customer_id);

            end if;

        end if;
                
	  
        EXCEPTION WHEN others THEN
            insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_order', SQLSTATE, SQLERRM, _cart_id, _cart_id);
        RETURN 'failure';
    END;
$$;
   DROP FUNCTION masterdata.create_order(_cart_id uuid, _billing_address_id uuid, _shipping_address_id uuid, _channel_id uuid, _payment_method character varying, _time_slot_id uuid, _order_type character varying, _fulfilment_id uuid, _store_id uuid, _slot_date character varying);
    
   masterdata          sahyadri    false    9            ^           1255    17276 2   create_packaging_types(character varying, numeric)    FUNCTION     �  CREATE FUNCTION masterdata.create_packaging_types(_packaging_type character varying, _amount numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __packaging_type_id UUID;
	BEGIN

        INSERT INTO masterdata.packaging_types(packaging_type, amount) 
            values ( _packaging_type, _amount) 
            RETURNING packaging_type_id into __packaging_type_id;

    RETURN __packaging_type_id;             
	
	
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_packaging_types', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _packaging_type);
			RETURN 'failure';
	  
    END;
$$;
 e   DROP FUNCTION masterdata.create_packaging_types(_packaging_type character varying, _amount numeric);
    
   masterdata          sahyadri    false    9            I           1255    16447 '   create_role(character varying, boolean)    FUNCTION     �  CREATE FUNCTION masterdata.create_role(_role_name character varying, _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __role_id UUID;
	BEGIN
	
		IF _role_name not in (select role_name from masterdata.roles) then

			INSERT INTO masterdata.roles( role_name, is_active) 
				values ( _role_name, _is_active) 
				RETURNING role_id into __role_id;

			RETURN __role_id; 
			
		else
		
			return 'role_name_already_present';
			
		end if;
	
	
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_role', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _role_name);
			RETURN 'failure';
	  
    END;
$$;
 X   DROP FUNCTION masterdata.create_role(_role_name character varying, _is_active boolean);
    
   masterdata          sahyadri    false    9            @           1255    16448 �   create_store(character varying, bigint, bigint, bigint, boolean, boolean, character varying, character varying, character varying, character varying, character varying, character varying, bigint, boolean, bigint[], numeric[], character varying)    FUNCTION     ]	  CREATE FUNCTION masterdata.create_store(_store_name character varying, _plant_code bigint, _ds_code bigint, _phone_no bigint, _is_sfs_enabled boolean, _is_cc_enabled boolean, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _pincode bigint, _is_active boolean, _serviceable_pincodes bigint[], _lat_long numeric[], _zone character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __store_id UUID;
        __address_id UUID;
		__pincode bigint;
-- 		__arr numeric[] := _lat_long;
		__lat_long numeric[];
	BEGIN

		IF _store_name not in (select store_name from masterdata.stores) then
		
			INSERT INTO masterdata.stores( store_name, plant_code, ds_code, phone_no, is_sfs_enabled, is_cc_enabled, created_by, updated_by, is_active, zone) 
            values ( _store_name, _plant_code, _ds_code, _phone_no, _is_sfs_enabled, _is_cc_enabled,'009d88ce-df5e-11e9-a5a4-533ffa965c3d','009d88ce-df5e-11e9-a5a4-533ffa965c3d', _is_active, _zone) 
            RETURNING store_id into __store_id;

            INSERT INTO masterdata.addresses(store_id, line_1, line_2, street, city, state, country, pincode, created_by, updated_by) 
            values (__store_id, _line_1, _line_2, _street, _city, _state, _country, _pincode, __store_id, __store_id) 
            RETURNING address_id into __address_id;

            FOREACH __pincode in array _serviceable_pincodes
            LOOP

                insert into masterdata.serviceable_pincodes (pincode, store_id, created_by, updated_by, plant_code) 
                        values (__pincode, __store_id,  
                                __store_id, __store_id, _plant_code) ;

            End LOOP;
            
            FOREACH __lat_long slice 1 in array _lat_long
            LOOP
                insert into masterdata.serviceable_pincodes (lat_longs, store_id, created_by, updated_by, plant_code) 
                        values (__lat_long, __store_id,  
                                __store_id, __store_id, _plant_code) ;

            End LOOP;
                        

            UPDATE masterdata.stores
            SET address_id = __address_id
            WHERE store_id = __store_id;

            RETURN __store_id;  
			
		else

  			return 'store_already_present';
			
		end if;

    END;
$$;
 �  DROP FUNCTION masterdata.create_store(_store_name character varying, _plant_code bigint, _ds_code bigint, _phone_no bigint, _is_sfs_enabled boolean, _is_cc_enabled boolean, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _pincode bigint, _is_active boolean, _serviceable_pincodes bigint[], _lat_long numeric[], _zone character varying);
    
   masterdata          sahyadri    false    9            	           1255    16449 /   create_subscribed_users(uuid, uuid, uuid, uuid)    FUNCTION     L  CREATE FUNCTION masterdata.create_subscribed_users(_customer_id uuid, _subscription_id uuid, _delivery_option_id uuid, _frequency_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	    __subscribed_user_id uuid;

	BEGIN

        INSERT INTO masterdata.user_subscriptions( customer_id, subscription_id, delivery_option_id, frequency_id) 
        values ( _customer_id, _subscription_id, _delivery_option_id, _frequency_id) 
        RETURNING subscribed_user_id into __subscribed_user_id;
        
    	RETURN __subscribed_user_id;                 
	  
    END;
$$;
 �   DROP FUNCTION masterdata.create_subscribed_users(_customer_id uuid, _subscription_id uuid, _delivery_option_id uuid, _frequency_id uuid);
    
   masterdata          sahyadri    false    9            
           1255    16450 7   create_subscription(character varying, bigint, boolean)    FUNCTION     �  CREATE FUNCTION masterdata.create_subscription(_subscription_type character varying, _subscription_period bigint, _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __subscription_id UUID;
	BEGIN

             if _subscription_period in (Select subscription_period from masterdata.subscriptions where subscription_type = _subscription_type) THEN
                return 'subscription_already_present';

        else

            INSERT INTO masterdata.subscriptions( subscription_type, subscription_period, is_active, created_by, updated_by) 
                values ( _subscription_type, _subscription_period, _is_active, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', '009d88ce-df5e-11e9-a5a4-533ffa965c3d') 
                RETURNING subscription_id into __subscription_id;

            RETURN __subscription_id;  

        end if;            
	
	
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_subscription', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _subscription_type);
			RETURN 'failure';
	  
    END;
$$;
 �   DROP FUNCTION masterdata.create_subscription(_subscription_type character varying, _subscription_period bigint, _is_active boolean);
    
   masterdata          sahyadri    false    9                       1255    16451 6   create_update_cart(uuid, uuid, numeric, boolean, json)    FUNCTION     �O  CREATE FUNCTION masterdata.create_update_cart(_customer_id uuid, _cart_id uuid, _cart_amount numeric, _is_guest_cart boolean, _items json) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	 __customer_id uuid;
     __cart_id uuid;
	 __items_length integer;
     __item_counter integer;
	 __existing_item_id character varying;
	 __existing_total_price numeric;
	 __existing_delivery_charges numeric;
	 __delivery_charges numeric;
     __cart_amount numeric;
	 __existing_packaging_amount numeric;
	 __sub_total numeric;

	BEGIN

		select customer_id into __customer_id from masterdata.customers where customer_id = _customer_id and is_active = true;

		if __customer_id is not null and _cart_id is null then 
					
			-- 	create a cart
				
				select cart_id into __cart_id from masterdata.carts where customer_id = __customer_id and is_active = true;
				
				if __cart_id is null then

					INSERT INTO masterdata.carts (customer_id, cart_amount, sub_total, is_guest_cart, created_by, updated_by)
							values (__customer_id, _cart_amount, _cart_amount, _is_guest_cart, __customer_id, __customer_id)
							RETURNING cart_id into __cart_id; 

                    __items_length := json_array_length(_items);

					if __items_length is not null and __items_length > 0 then
									
						FOR __item_counter in  0..(__items_length -1)
						LOOP

							insert into masterdata.cart_lines (cart_id, item_id, item_name, item_description, price , quantity, item_image_urls, total_price, user_subscription_id,
					                                      created_by, updated_by, 
														pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, row, rack, bin,
															  ean, gst, hsn, item_status, category_id, category_name, sub_category_id, sub_category_name, mrp, final_selling_price, store_code) 
				            values (__cart_id,  
                            cast(_items -> __item_counter ->> 'item_id' as varchar),
							cast(_items -> __item_counter ->> 'name' as character varying),
                            cast(_items -> __item_counter ->> 'description' as character varying),
                            cast(_items -> __item_counter ->> 'price' as numeric),
                            cast(_items -> __item_counter ->> 'quantity' as integer),
                            cast(_items -> __item_counter ->> 'image_url' as character varying),
                            cast(_items -> __item_counter ->> 'total_price' as numeric),
                            cast(_items -> __item_counter ->> 'user_subscription_id' as uuid),
                            __customer_id, __customer_id,
							cast(_items -> __item_counter ->> 'pack_size' as character varying),
							cast(_items -> __item_counter ->> 'unit_of_measure' as character varying),
							cast(_items -> __item_counter ->> 'weight' as numeric),
							cast(_items -> __item_counter ->> 'brand' as character varying),
							cast(_items -> __item_counter ->> 'variants' as character varying),
							cast(_items -> __item_counter ->> 'inventory' as bigint),
							cast(_items -> __item_counter ->> 'special_price' as numeric),
							cast(_items -> __item_counter ->> 'short_description' as character varying),
							cast(_items -> __item_counter ->> 'sku' as character varying),
							cast(_items -> __item_counter ->> 'row' as character varying),						
							cast(_items -> __item_counter ->> 'rack' as character varying),						
							cast(_items -> __item_counter ->> 'bin' as character varying),
							cast(_items -> __item_counter ->> 'ean' as character varying),					
							cast(_items -> __item_counter ->> 'gst' as numeric),					
							cast(_items -> __item_counter ->> 'hsn' as bigint),					
							cast(_items -> __item_counter ->> 'item_status' as integer),					
							cast(_items -> __item_counter ->> 'category_id' as smallint),
							cast(_items -> __item_counter ->> 'category_name' as character varying),					
							cast(_items -> __item_counter ->> 'sub_category_id' as smallint),					
							cast(_items -> __item_counter ->> 'sub_category_name' as character varying),
							cast(_items -> __item_counter ->> 'mrp' as numeric),					
							cast(_items -> __item_counter ->> 'final_selling_price' as numeric),
							cast(_items -> __item_counter ->> 'store_id' as integer)
							);

						End LOOP;
									
					else
						return 'atleast_one_item_required_to_add_to_cart';
					end if;

                    SELECT amount into __delivery_charges from masterdata.delivery_charges
                        where _cart_amount BETWEEN min_cart_value AND max_cart_value;

                    if __delivery_charges is not null THEN
                        UPDATE masterdata.carts 
                        set cart_amount = cart_amount + __delivery_charges,
                            delivery_charges = __delivery_charges
                        where cart_id = __cart_id;
						
                    end if;

                    return __cart_id;
					
				else

                -- Just updating the cart
				
					__items_length := json_array_length(_items);

					if __items_length is not null and __items_length > 0 then
									
						FOR __item_counter in  0..(__items_length -1)
						LOOP
						
							SELECT item_id into __existing_item_id from masterdata.cart_lines where item_id = cast(_items -> __item_counter ->> 'item_id' as varchar) and cart_id = __cart_id;
							
							if __existing_item_id is not null then
								
								SELECT total_price into __existing_total_price from masterdata.cart_lines where item_id = __existing_item_id and cart_id = __cart_id;
								
								UPDATE masterdata.cart_lines
								SET quantity = cast(_items -> __item_counter ->> 'quantity' as integer),
									total_price = cast(_items -> __item_counter ->> 'total_price' as numeric)
								WHERE item_id = __existing_item_id and cart_id = __cart_id;
								
								UPDATE masterdata.carts
								SET cart_amount = cart_amount - __existing_total_price + cast(_items -> __item_counter ->> 'total_price' as numeric),
									sub_total = sub_total - __existing_total_price + cast(_items -> __item_counter ->> 'total_price' as numeric)
								WHERE cart_id = __cart_id;
								
							else
						
								insert into masterdata.cart_lines (cart_id, item_id, item_name, item_description, price , quantity, item_image_urls, total_price, user_subscription_id,
															  created_by, updated_by,
														pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, row, rack, bin,
															  ean, gst, hsn, item_status, category_id, category_name, sub_category_id, sub_category_name, mrp, final_selling_price, store_code) 
															  
								values (__cart_id,  
								cast(_items -> __item_counter ->> 'item_id' as varchar),
								cast(_items -> __item_counter ->> 'name' as character varying),
								cast(_items -> __item_counter ->> 'description' as character varying),
								cast(_items -> __item_counter ->> 'price' as numeric),
								cast(_items -> __item_counter ->> 'quantity' as integer),
								cast(_items -> __item_counter ->> 'image_url' as character varying),
								cast(_items -> __item_counter ->> 'total_price' as numeric),
								cast(_items -> __item_counter ->> 'user_subscription_id' as uuid),
								__customer_id, __customer_id,
								cast(_items -> __item_counter ->> 'pack_size' as character varying),
								cast(_items -> __item_counter ->> 'unit_of_measure' as character varying),
								cast(_items -> __item_counter ->> 'weight' as numeric),
								cast(_items -> __item_counter ->> 'brand' as character varying),
								cast(_items -> __item_counter ->> 'variants' as character varying),
								cast(_items -> __item_counter ->> 'inventory' as bigint),
								cast(_items -> __item_counter ->> 'special_price' as numeric),
								cast(_items -> __item_counter ->> 'short_description' as character varying),
								cast(_items -> __item_counter ->> 'sku' as character varying),
								cast(_items -> __item_counter ->> 'row' as character varying),						
								cast(_items -> __item_counter ->> 'rack' as character varying),						
								cast(_items -> __item_counter ->> 'bin' as character varying),
								cast(_items -> __item_counter ->> 'ean' as character varying),					
								cast(_items -> __item_counter ->> 'gst' as numeric),					
								cast(_items -> __item_counter ->> 'hsn' as bigint),					
								cast(_items -> __item_counter ->> 'item_status' as integer),				
								cast(_items -> __item_counter ->> 'category_id' as smallint),
								cast(_items -> __item_counter ->> 'category_name' as character varying),					
								cast(_items -> __item_counter ->> 'sub_category_id' as smallint),					
								cast(_items -> __item_counter ->> 'sub_category_name' as character varying),
								cast(_items -> __item_counter ->> 'mrp' as numeric),					
								cast(_items -> __item_counter ->> 'final_selling_price' as numeric),
								cast(_items -> __item_counter ->> 'store_id' as integer)
								);
								
								UPDATE masterdata.carts
								SET cart_amount = cart_amount  + cast(_items -> __item_counter ->> 'total_price' as numeric),
									sub_total = sub_total  + cast(_items -> __item_counter ->> 'total_price' as numeric)
									where cart_id = __cart_id;
								
							end if;							

						End LOOP;
									
					else
						return 'atleast_one_item_required_for_cart';
					end if;
--                     select c.delivery_charges, c.cart_amount,p.amount into __existing_delivery_charges, __cart_amount, __existing_packaging_amount from masterdata.carts c 
-- 					left join masterdata.packaging_types p on c.packaging_type_id = p.packaging_type_id where c.cart_id = __cart_id;

					select delivery_charges, cart_amount, sub_total into __existing_delivery_charges, __cart_amount, __sub_total from masterdata.carts
 					where cart_id = __cart_id;
					
 					select coalesce(p.amount,0.00) into __existing_packaging_amount from masterdata.packaging_types p 
 						join masterdata.carts c on p.packaging_type_id = c.packaging_type_id where c.cart_id = __cart_id;

-- 					if __existing_packaging_amount is null or __existing_packaging_amount = 0.00 then
-- 						UPDATE masterdata.carts 
-- 						set sub_total = __cart_amount - __existing_delivery_charges 
-- 						where cart_id = __cart_id;
-- 					else 
-- 						UPDATE masterdata.carts 
-- 						set sub_total = __cart_amount - (__existing_delivery_charges + __existing_packaging_amount)
-- 						where cart_id = __cart_id;
-- 					end if;

-- 					SELECT amount) into __delivery_charges from masterdata.delivery_charges
-- 						where __sub_total between min_cart_value AND max_cart_value;

					SELECT amount into __delivery_charges from masterdata.delivery_charges
                        where __sub_total BETWEEN min_cart_value AND max_cart_value;
						
						
					if __delivery_charges is not null THEN
                        UPDATE masterdata.carts 
                        set cart_amount = cart_amount - __existing_delivery_charges + __delivery_charges,
                            delivery_charges = __delivery_charges
                        where cart_id = __cart_id;
						
					else
						UPDATE masterdata.carts 
                        set cart_amount = cart_amount - __existing_delivery_charges,
                            delivery_charges = 0.00
                        where cart_id = __cart_id;
						

                    end if;

-- 						if __delivery_charges is not null and __existing_delivery_charges is not null THEN

-- 							UPDATE masterdata.carts 
-- 							set cart_amount = __cart_amount - __existing_delivery_charges + __delivery_charges,
-- 								delivery_charges = __delivery_charges
-- 							where cart_id = __cart_id;

-- 						elsif __delivery_charges is null and __existing_delivery_charges is not null then

-- 							UPDATE masterdata.carts 
-- 							set cart_amount = __cart_amount -__existing_delivery_charges,
-- 								delivery_charges = 0.00
-- 							where cart_id = __cart_id;

-- 						elsif __delivery_charges is not null and __existing_delivery_charges is null then

-- 							UPDATE masterdata.carts 
-- 							set cart_amount = __cart_amount +__delivery_charges,
-- 								delivery_charges = __delivery_charges
-- 							where cart_id = __cart_id;

-- 						end if;
				
                	return __cart_id;

				end if;

			
		else
            --Updating Guest Cart

            select cart_id into __cart_id from masterdata.carts where cart_id = _cart_id and is_active = true;

            if __cart_id is not null then

                __items_length := json_array_length(_items);

			    if __items_length is not null and __items_length > 0 then

--                     UPDATE masterdata.carts
--                         SET cart_amount = cart_amount + _cart_amount
--                         WHERE cart_id = __cart_id;
									
			        FOR __item_counter in  0..(__items_length -1)
				    LOOP

					    SELECT item_id into __existing_item_id from masterdata.cart_lines where item_id = cast(_items -> __item_counter ->> 'item_id' as varchar) and cart_id = __cart_id;
							
							if __existing_item_id is not null then
								
								SELECT total_price into __existing_total_price from masterdata.cart_lines where item_id = __existing_item_id and cart_id = __cart_id;
								
								UPDATE masterdata.cart_lines
								SET quantity = cast(_items -> __item_counter ->> 'quantity' as integer),
									total_price = cast(_items -> __item_counter ->> 'total_price' as numeric)
								WHERE item_id = __existing_item_id and cart_id = __cart_id;
								
								UPDATE masterdata.carts
								SET cart_amount = cart_amount - __existing_total_price + cast(_items -> __item_counter ->> 'total_price' as numeric),
									sub_total = sub_total - __existing_total_price + cast(_items -> __item_counter ->> 'total_price' as numeric)
								WHERE cart_id = __cart_id;
								
							else
						
								insert into masterdata.cart_lines (cart_id, item_id, item_name, item_description, price , quantity, item_image_urls, total_price, user_subscription_id,
															  created_by, updated_by,
														pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, row, rack, bin,
															  ean, gst, hsn, item_status, category_id, category_name, sub_category_id, sub_category_name, mrp, final_selling_price, store_code) 

								values (__cart_id,  
								cast(_items -> __item_counter ->> 'item_id' as varchar),
								cast(_items -> __item_counter ->> 'name' as character varying),
								cast(_items -> __item_counter ->> 'description' as character varying),
								cast(_items -> __item_counter ->> 'price' as numeric),
								cast(_items -> __item_counter ->> 'quantity' as integer),
								cast(_items -> __item_counter ->> 'image_url' as character varying),
								cast(_items -> __item_counter ->> 'total_price' as numeric),
								cast(_items -> __item_counter ->> 'user_subscription_id' as uuid),
								__customer_id, __customer_id,
								cast(_items -> __item_counter ->> 'pack_size' as character varying),
								cast(_items -> __item_counter ->> 'unit_of_measure' as character varying),
								cast(_items -> __item_counter ->> 'weight' as numeric),
								cast(_items -> __item_counter ->> 'brand' as character varying),
								cast(_items -> __item_counter ->> 'variants' as character varying),
								cast(_items -> __item_counter ->> 'inventory' as bigint),
								cast(_items -> __item_counter ->> 'special_price' as numeric),
								cast(_items -> __item_counter ->> 'short_description' as character varying),
								cast(_items -> __item_counter ->> 'sku' as character varying),
								cast(_items -> __item_counter ->> 'row' as character varying),						
								cast(_items -> __item_counter ->> 'rack' as character varying),						
								cast(_items -> __item_counter ->> 'bin' as character varying),
								cast(_items -> __item_counter ->> 'ean' as character varying),					
								cast(_items -> __item_counter ->> 'gst' as numeric),					
								cast(_items -> __item_counter ->> 'hsn' as bigint),					
								cast(_items -> __item_counter ->> 'item_status' as integer),					
								cast(_items -> __item_counter ->> 'category_id' as smallint),
								cast(_items -> __item_counter ->> 'category_name' as character varying),					
								cast(_items -> __item_counter ->> 'sub_category_id' as smallint),					
								cast(_items -> __item_counter ->> 'sub_category_name' as character varying),
								cast(_items -> __item_counter ->> 'mrp' as numeric),					
								cast(_items -> __item_counter ->> 'final_selling_price' as numeric),
								cast(_items -> __item_counter ->> 'store_id' as integer)			
								);
								
								UPDATE masterdata.carts
								SET cart_amount = cart_amount  + cast(_items -> __item_counter ->> 'total_price' as numeric),
									sub_total = sub_total  + cast(_items -> __item_counter ->> 'total_price' as numeric)
									where cart_id = __cart_id;
								
							end if;							

						End LOOP;
									
					else
						return 'atleast_one_item_required_for_cart';
					end if;
--                     select c.delivery_charges, c.cart_amount,p.amount into __existing_delivery_charges, __cart_amount, __existing_packaging_amount from masterdata.carts c 
-- 					left join masterdata.packaging_types p on c.packaging_type_id = p.packaging_type_id where c.cart_id = __cart_id;

					select delivery_charges, cart_amount,sub_total into __existing_delivery_charges, __cart_amount, __sub_total from masterdata.carts
 					where cart_id = __cart_id;
					
 					select coalesce(p.amount,0.00) into __existing_packaging_amount from masterdata.packaging_types p 
 						join masterdata.carts c on p.packaging_type_id = c.packaging_type_id where c.cart_id = __cart_id;

-- 					if __existing_packaging_amount is null or __existing_packaging_amount = 0.00 then
-- 						UPDATE masterdata.carts 
-- 						set sub_total = __cart_amount - __existing_delivery_charges 
-- 						where cart_id = __cart_id;
-- 					else 
-- 						UPDATE masterdata.carts 
-- 						set sub_total = __cart_amount - (__existing_delivery_charges + __existing_packaging_amount)
-- 						where cart_id = __cart_id;
-- 					end if;

					SELECT amount into __delivery_charges from masterdata.delivery_charges
						where __sub_total between min_cart_value AND max_cart_value;
						
					if __delivery_charges is not null THEN
                        UPDATE masterdata.carts 
                        set cart_amount = cart_amount - __existing_delivery_charges + __delivery_charges,
                            delivery_charges = __delivery_charges
                        where cart_id = __cart_id;
						
					else
						UPDATE masterdata.carts 
                        set cart_amount = cart_amount - __existing_delivery_charges,
                            delivery_charges = 0.00
                        where cart_id = __cart_id;

                    end if;

-- 					if __delivery_charges is not null and __existing_delivery_charges is not null THEN

-- 						UPDATE masterdata.carts 
-- 						set cart_amount = __cart_amount - __existing_delivery_charges + __delivery_charges,
-- 							delivery_charges = __delivery_charges
-- 						where cart_id = __cart_id;

-- 					elsif __delivery_charges is null and __existing_delivery_charges is not null then

-- 						UPDATE masterdata.carts 
-- 						set cart_amount = __cart_amount -__existing_delivery_charges,
-- 							delivery_charges = 0.00
-- 						where cart_id = __cart_id;

-- 					elsif __delivery_charges is not null and __existing_delivery_charges is null then

-- 						UPDATE masterdata.carts 
-- 						set cart_amount = __cart_amount +__delivery_charges,
-- 							delivery_charges = __delivery_charges
-- 						where cart_id = __cart_id;

-- 					end if;

                return __cart_id;

            ELSE
                RETURN 'invalid_cart_id';
		    end if;

		end if;

			
	  
	EXCEPTION WHEN others THEN
	  	insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_update_cart', SQLSTATE, SQLERRM, _customer_id, _items);
	RETURN 'failure';
    END;
$$;
 �   DROP FUNCTION masterdata.create_update_cart(_customer_id uuid, _cart_id uuid, _cart_amount numeric, _is_guest_cart boolean, _items json);
    
   masterdata          sahyadri    false    9            =           1255    16914 $   create_update_delivery_charges(json)    FUNCTION     �  CREATE FUNCTION masterdata.create_update_delivery_charges(_delivery_charges json) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
    __delivery_charges_length integer; 
    __delivery_charges_counter integer;
    __existing_delivery_charges integer;

	BEGIN

        SELECT count(*) into __existing_delivery_charges from masterdata.delivery_charges;

        if __existing_delivery_charges is not null THEN

            DELETE from masterdata.delivery_charges;
        
        end if;

        __delivery_charges_length := json_array_length(_delivery_charges);

        FOR __delivery_charges_counter in 0..(__delivery_charges_length -1)
        LOOP

            insert into masterdata.delivery_charges(min_cart_value, max_cart_value, amount)
            values (cast(_delivery_charges -> __delivery_charges_counter ->> 'min_cart_value' as numeric),
                    cast(_delivery_charges -> __delivery_charges_counter ->> 'max_cart_value' as numeric),
                    cast(_delivery_charges -> __delivery_charges_counter ->> 'amount' as numeric));

        END LOOP;

		return 'Successfull';                         
	  
    END;
$$;
 Q   DROP FUNCTION masterdata.create_update_delivery_charges(_delivery_charges json);
    
   masterdata          sahyadri    false    9            >           1255    16453    create_update_permission(json)    FUNCTION       CREATE FUNCTION masterdata.create_update_permission(_permissions json) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __role_id uuid;
		__permission_id uuid;
        __permission_length integer;
        __permission_counter integer;
        __role_length integer;
        __role_counter integer;
        __screens_length integer;
        __screen_counter integer;
		__user_matrix_length integer;
		__user_matrix_counter integer;
		__status_length integer;
		__status_counter integer;
		__screen_id uuid;
		__user_matrix_id uuid;
	BEGIN

        __permission_length := json_array_length(_permissions);
		
		__role_length := json_array_length(_permissions ->'role_id');

         FOR __permission_counter in  0..(__permission_length -1)
         LOOP
		 
            __screens_length := json_array_length(_permissions -> __permission_counter ->'screens');
			
			__user_matrix_length := json_array_length(_permissions -> __permission_counter ->'user_matrix');
						
            if __screens_length is not null and __screens_length > 0 then  

                __role_id = cast(_permissions -> __permission_counter ->> 'role_id' as uuid);

                SELECT permission_id into __permission_id from masterdata.permissions where role_id = __role_id;

		        if __permission_id is null then                                    --create permission

                
                    FOR __screen_counter in  0..(__screens_length -1)
                    LOOP

                        insert into masterdata.permissions(role_id, screen_id, is_read, is_write)
                        values (__role_id,
                        cast(_permissions -> __permission_counter -> 'screens' -> __screen_counter ->> 'screen_id' as uuid),
                        cast(_permissions -> __permission_counter -> 'screens' -> __screen_counter ->> 'is_read' as boolean),
                        cast(_permissions -> __permission_counter -> 'screens' -> __screen_counter ->> 'is_write' as boolean)
                        );

                    End LOOP;
					
					FOR __user_matrix_counter in  0..(__user_matrix_length -1)
        			LOOP
						__status_length := json_array_length(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses');
						
						__screen_id := cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter ->> 'screen_id' as uuid);
                   
				        FOR __status_counter in  0..(__status_length -1)
                    	LOOP
							
							insert into masterdata.user_matrix(role_id, screen_id, status_id, is_status_read, is_status_write)
							values (__role_id, __screen_id,
							cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses' -> __status_counter ->> 'status_id' as uuid),
							cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses' -> __status_counter ->> 'is_status_read' as boolean),
							cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses' -> __status_counter ->> 'is_status_write' as boolean)
							);
							
						End LOOP;

				   End LOOP;

                ELSE                                                                    -- Update permission

                    FOR __screen_counter in  0..(__screens_length -1)
                    LOOP

                        update masterdata.permissions 
                        SET is_read = cast(_permissions -> __permission_counter -> 'screens' -> __screen_counter ->> 'is_read' as boolean),
                            is_write = cast(_permissions -> __permission_counter -> 'screens' -> __screen_counter ->> 'is_write' as boolean)
                            WHERE role_id = __role_id and screen_id = cast(_permissions -> __permission_counter -> 'screens' -> __screen_counter ->> 'screen_id' as uuid);

                    End LOOP; 
					
					FOR __user_matrix_counter in  0..(__user_matrix_length -1)
        			LOOP
						__status_length := json_array_length(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses');
						
						__screen_id := cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter ->> 'screen_id' as uuid);
						
						select user_matrix_id into __user_matrix_id from masterdata.user_matrix where role_id = __role_id;
						
						if __user_matrix_id is null then
						
							FOR __status_counter in  0..(__status_length -1)
							LOOP

								insert into masterdata.user_matrix(role_id, screen_id, status_id, is_status_read, is_status_write)
								values (__role_id, __screen_id,
								cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses' -> __status_counter ->> 'status_id' as uuid),
								cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses' -> __status_counter ->> 'is_status_read' as boolean),
								cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses' -> __status_counter ->> 'is_status_write' as boolean)
								);

							End LOOP;
							
						else
                   
							FOR __status_counter in  0..(__status_length -1)
							LOOP

								update masterdata.user_matrix
								set	is_status_read = cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses' -> __status_counter ->> 'is_status_read' as boolean), 
									is_status_write = cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses' -> __status_counter ->> 'is_status_write' as boolean)
									where role_id = __role_id and screen_id = __screen_id and
									 status_id = cast(_permissions -> __permission_counter -> 'user_matrix' -> __user_matrix_counter -> 'statuses' -> __status_counter ->> 'status_id' as uuid);							
							End LOOP;
							
						end if;

				   End LOOP;

                END IF;
			
			else
			
			return 'Not_added';
			
			end if;
			
        End LOOP;
		
		return 'Successfull';
		
    END;
$$;
 F   DROP FUNCTION masterdata.create_update_permission(_permissions json);
    
   masterdata          sahyadri    false    9            K           1255    16454 *   create_update_slots(uuid, integer[], json)    FUNCTION       CREATE FUNCTION masterdata.create_update_slots(_store_id uuid, _months integer[], _day_slots json) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	 
	 __valid_store_id uuid;
	 __day_slots_length integer;
     __months_length integer;
	 __day_slot_counter integer;
	 __open_days_length integer;
	 __open_day_counter integer;
	 __day_slot_id uuid;
	 __time_slots_length integer;
	 __time_slot_counter integer;
	 __day_slot_id_count integer;
     __month_slot_id uuid;
	 __month_value integer;

	BEGIN

        select store_id into __valid_store_id from masterdata.stores where store_id = _store_id and is_active = true ;

		if __valid_store_id is not null then 

			__day_slots_length := json_array_length(_day_slots);
            __months_length := array_length(_months, 1);  

			if __months_length is not null and __months_length > 0 and __day_slots_length is not null and __day_slots_length > 0 then 

                
				delete from masterdata.time_slots where day_slot_id in (select day_slot_id from masterdata.day_slots where month_slot_id in (select month_slot_id from masterdata.month_slots where store_id = __valid_store_id));
                delete from masterdata.day_slots where month_slot_id in (select month_slot_id from masterdata.month_slots where store_id = __valid_store_id);
				delete from masterdata.month_slots where store_id = __valid_store_id;

				FOREACH __month_value in  array _months
				LOOP
				
					insert into masterdata.month_slots (store_id, month, is_active, created_by, updated_by) 
					values (__valid_store_id, 
                            __month_value, 
							true, __valid_store_id, __valid_store_id) 
                    returning month_slot_id into __month_slot_id;

				    FOR __day_slot_counter in  0..(__day_slots_length -1)
				    LOOP

					    __open_days_length := json_array_length(_day_slots -> __day_slot_counter -> 'open_days');
                        __time_slots_length := json_array_length(_day_slots -> __day_slot_counter -> 'time_slots');

								
                        if __open_days_length is not null and __open_days_length > 0 and __time_slots_length is not null and __time_slots_length > 0 then            
                                    									
                            FOR __open_day_counter in  0..(__open_days_length -1)
                            LOOP

                                insert into masterdata.day_slots (month_slot_id, day, month, open_time, close_time, is_active, created_by, updated_by) 
                                values (__month_slot_id, 
                                        cast(_day_slots -> __day_slot_counter -> 'open_days' ->> __open_day_counter as integer), 
                                        __month_value,
                                        cast(_day_slots -> __day_slot_counter ->> 'open_time' as timestamp with time zone),
                                        cast(_day_slots -> __day_slot_counter ->> 'close_time' as timestamp with time zone),
                                        true, __valid_store_id, __valid_store_id) 
                                returning day_slot_id into __day_slot_id;

                                FOR __time_slot_counter in  0..(__time_slots_length -1)
                                LOOP
            
                                    insert into masterdata.time_slots (day_slot_id, start_slot_time, end_slot_time, slot_limit, is_active, created_by, updated_by) 
                                    values (__day_slot_id, 
                                            cast(_day_slots -> __day_slot_counter -> 'time_slots' -> __time_slot_counter ->> 'slot_start_time' as timestamp with time zone),
                                            cast(_day_slots -> __day_slot_counter -> 'time_slots' -> __time_slot_counter ->> 'slot_end_time' as timestamp with time zone),
                                            cast(_day_slots -> __day_slot_counter -> 'time_slots' -> __time_slot_counter ->> 'slot_limit' as integer),
											cast(_day_slots -> __day_slot_counter -> 'time_slots' -> __time_slot_counter ->> 'is_active' as boolean),
                                            __valid_store_id, __day_slot_id);

							    End LOOP;
						    End LOOP;
                        else
						    return 'atleast_one_day_and_time_slot_is_required';
					    end if;    
                        
                    End LOOP;    
                End LOOP;
	
    		else
				RETURN 'atleast_one_month_is_required';
			end if;				
                                
		else
			return 'invalid_store_id';
		end if;
		
	RETURN _store_id;

    EXCEPTION WHEN others THEN
	  	insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_update_slots', SQLSTATE, SQLERRM, _store_id, __month_value);
	RETURN 'failure';
    END;
$$;
 b   DROP FUNCTION masterdata.create_update_slots(_store_id uuid, _months integer[], _day_slots json);
    
   masterdata          sahyadri    false    9                       1255    16455    create_wallet(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.create_wallet(_customer_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	 __customer_id uuid;
     __wallet_id uuid;

	BEGIN

		select customer_id into __customer_id from masterdata.customers where customer_id = _customer_id and is_active = true and magento_customer_id is NOT NULL;

		if __customer_id is not null then 
				
			select wallet_id into __wallet_id from masterdata.wallets where customer_id = __customer_id and is_active = true;
				
			if __wallet_id is null then

				INSERT INTO masterdata.wallets (customer_id, wallet_amount, created_by, updated_by)
					values (__customer_id, 0.00, __customer_id, __customer_id )
					RETURNING wallet_id into __wallet_id; 

            ELSE

                return __wallet_id;

            end if;                          

        ELSE

            RETURN 'invalid_customer_id';

        end if;
        
        return __wallet_id;
					
				
	EXCEPTION WHEN others THEN
	  	insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.create_wallet', SQLSTATE, SQLERRM, _customer_id, _customer_id);
	RETURN 'failure';
    END;
$$;
 ;   DROP FUNCTION masterdata.create_wallet(_customer_id uuid);
    
   masterdata          sahyadri    false    9            t           1255    17739    crm_set_order(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.crm_set_order(_order_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref1 refcursor default 'crmorderrefcursor';
        ref2 refcursor default 'crmitemsrefcursor';

	BEGIN

        OPEN ref1 FOR 
        select o.order_no, to_char(o.created_at, 'yyyy-mm-dd HH:MM:SS'), ad.mobile, ad.city, ad.pincode, ad.state, ad.country,
        sa.city, sa.pincode, sa.state, sa.country, o.sub_total, pt.amount, o.total_amount, st.store_name, o.payment_method, o.delivery_charges,
        w.wallet_amount, s.status_name, c.magento_customer_id, ad.email, o.payment_status 
        from masterdata.orders o
        LEFT JOIN masterdata.addresses ad on ad.address_id = o.billing_address_id
        LEFT JOIN masterdata.addresses sa on sa.address_id = o.shipping_address_id
		LEFT OUTER JOIN masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
		LEFT outer join masterdata.stores st on o.store_id = st.store_id
        LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
        LEFT OUTER JOIN masterdata.wallets w on o.customer_id = w.customer_id
        LEFT OUTER JOIN masterdata.customers c on o.customer_id = c.customer_id
        WHERE o.order_id = _order_id;
        RETURN next ref1;
 
        OPEN ref2 FOR 
        select ol.item_id, ol.item_name, ol.quantity, ol.total_price
		from masterdata.order_lines ol
		join masterdata.orders o on ol.cart_id = o.cart_id
       	WHERE o.order_id = _order_id;
        RETURN next ref2;

    END;
$$;
 8   DROP FUNCTION masterdata.crm_set_order(_order_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16456    customers_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.customers_filter(_from_date date, _to_date date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'customersrefcursor'; 
    BEGIN
      OPEN ref FOR 
      SELECT customer_id, store_id, magento_customer_id, first_name, last_name, mobile, email, 
        subscription_id, subscription_start_date, subscription_end_date, frequency_id, delivery_option_id
      from masterdata.customers
      
        WHERE magento_customer_id is not Null and created_at::date BETWEEN _from_date AND _to_date;

      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 K   DROP FUNCTION masterdata.customers_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            F           1255    16457    dashboard(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.dashboard(_from_date date, _to_date date) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref1 refcursor default 'dashboardrefcursor';
		ref2 refcursor default 'salesrefcursor';
        __orders INTEGER;
        __order_dispatch INTEGER;
        __total_sales numeric;
        __total_customers integer;
        __carts integer;
        __in_process integer;
        __complete_order integer;
        __cancelled_order integer;
		__year integer;

    BEGIN      
    
        SELECT count(*) into __orders from masterdata.orders
        WHERE is_paid = true AND created_at::date BETWEEN _from_date AND _to_date;

        SELECT count(*) into __order_dispatch from masterdata.orders o
        left join masterdata.status s on o.status_id = s.status_id
        WHERE s.status_name = 'out_for_delivery' or s.status_name = 'delivered' and 
        o.is_paid = true and o.created_at::date BETWEEN _from_date AND _to_date;

        SELECT sum(total_amount) into __total_sales from masterdata.orders
        WHERE is_paid = true and created_at::date BETWEEN _from_date AND _to_date;
        
        SELECT count(*) into __total_customers from masterdata.customers 
        WHERE magento_customer_id is not Null and 
            created_at::date BETWEEN _from_date AND _to_date;

        SELECT count(*) into __carts from masterdata.carts c 
        left join masterdata.orders o on c.cart_id = o.cart_id
        where o.cart_id is null;

        SELECT count(*) into __in_process from masterdata.orders o
        left outer join masterdata.status s on o.status_id = s.status_id
        WHERE s.status_name = 'in_process' and 
            o.is_paid = true and o.created_at::date BETWEEN _from_date AND _to_date;

        SELECT count(*) into __complete_order from masterdata.orders o
        left outer join masterdata.status s on o.status_id = s.status_id
        WHERE s.status_name = 'delivered' and 
            o.is_paid = true and o.created_at::date BETWEEN _from_date AND _to_date;

        SELECT count(*) into __cancelled_order from masterdata.orders o
        left outer join masterdata.status s on o.status_id = s.status_id
        WHERE s.status_name = 'cancelled' and 
            o.is_paid = true and o.created_at::date BETWEEN _from_date AND _to_date;

        open ref1 for
            SELECT __orders, __order_dispatch, __total_sales, __total_customers, __carts, __in_process, __complete_order, __cancelled_order;
        RETURN next ref1;
		
		select extract(YEAR from _from_date) into __year;

        open ref2 for
        select
            sum(case when extract('month' from created_at) = 1 then total_amount else 0 end) as jan,
            sum(case when extract('month' from created_at) = 2 then total_amount else 0 end) as feb,
            sum(case when extract('month' from created_at) = 3 then total_amount else 0 end) as march,
            sum(case when extract('month' from created_at) = 4 then total_amount else 0 end) as apr,
            sum(case when extract('month' from created_at) = 5 then total_amount else 0 end) as may,
            sum(case when extract('month' from created_at) = 6 then total_amount else 0 end) as jun,
            sum(case when extract('month' from created_at) = 7 then total_amount else 0 end) as july,
            sum(case when extract('month' from created_at) = 8 then total_amount else 0 end) as aug,
            sum(case when extract('month' from created_at) = 9 then total_amount else 0 end) as sept,
            sum(case when extract('month' from created_at) = 10 then total_amount else 0 end) as oct,
            sum(case when extract('month' from created_at) = 11 then total_amount else 0 end) as nov,
            sum(case when extract('month' from created_at) = 12 then total_amount else 0 end) as dec
            from masterdata.orders
            where (select extract('year' from created_at)) = __year;
        RETURN next ref2;
                   
    END;
$$;
 D   DROP FUNCTION masterdata.dashboard(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            N           1255    16458    delete_address(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.delete_address(_address_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	    __customer_status boolean;
        __customer_id UUID;
		__order_id uuid;
		__address_id uuid;
		__is_default boolean;
	BEGIN

		select customer_id, is_default into __customer_id, __is_default from masterdata.addresses where address_id = _address_id;

		select order_id into __order_id from masterdata.orders
		where shipping_address_id = _address_id or billing_address_id = _address_id;
		
		if __order_id is not null then
		
			update masterdata.addresses
			set is_active = 'false',
				is_default = 'false'
			where address_id = _address_id;
			
		else

			DELETE from masterdata.addresses 
			WHERE address_id = _address_id;
			
		end if;
		
		if __is_default = 'true' then
		
			select address_id into __address_id from masterdata.addresses where customer_id = __customer_id and is_active = true limit 1;
		
			if __address_id is not null then

				update masterdata.addresses
				set is_default = 'true'
				where address_id = __address_id;

			end if;
		
		end if;
		
    RETURN 'address_removed_successfully';                                                      
	  
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.delete_address', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _address_id);
			RETURN 'failure';
    END;
$$;
 ;   DROP FUNCTION masterdata.delete_address(_address_id uuid);
    
   masterdata          sahyadri    false    9            ;           1255    16917    delete_delivery_charge(uuid)    FUNCTION     }  CREATE FUNCTION masterdata.delete_delivery_charge(_delivery_charges_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	BEGIN

        DELETE from masterdata.delivery_charges
        WHERE delivery_charges_id = _delivery_charges_id;

    RETURN 'delivery_charges_removed_successfully';                                                       
	  
    END;
$$;
 L   DROP FUNCTION masterdata.delete_delivery_charge(_delivery_charges_id uuid);
    
   masterdata          sahyadri    false    9            �            1255    16459    delete_delivery_option(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.delete_delivery_option(_delivery_option_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __delivery_point_id UUID;
	BEGIN

        DELETE from masterdata.delivery_options
        WHERE delivery_option_id = _delivery_option_id;

    RETURN 'Delivery_Option_removed_successfully';                                                       
	  
    END;
$$;
 K   DROP FUNCTION masterdata.delete_delivery_option(_delivery_option_id uuid);
    
   masterdata          sahyadri    false    9            D           1255    16460    delete_delivery_point(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.delete_delivery_point(_delivery_point_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __delivery_point_id UUID;
	BEGIN

        DELETE from masterdata.delivery_points
        WHERE delivery_point_id = _delivery_point_id;

    RETURN 'delivery_point_removed_successfully';                                                       
	  
    END;
$$;
 I   DROP FUNCTION masterdata.delete_delivery_point(_delivery_point_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16461    delete_frequency(uuid)    FUNCTION     x  CREATE FUNCTION masterdata.delete_frequency(_frequency_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __delivery_point_id UUID;
	BEGIN

        DELETE from masterdata.frequencies
        WHERE frequency_id = _frequency_id;

    RETURN 'Frequency_removed_successfully';                                                       
	  
    END;
$$;
 ?   DROP FUNCTION masterdata.delete_frequency(_frequency_id uuid);
    
   masterdata          sahyadri    false    9            _           1255    17277    delete_min_order_value(uuid)    FUNCTION     l  CREATE FUNCTION masterdata.delete_min_order_value(_min_order_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	BEGIN

        DELETE from masterdata.min_order_value
        WHERE min_order_value_id = _min_order_id;

    RETURN 'min_order_value_removed_successfully';                                                       
	  
    END;
$$;
 E   DROP FUNCTION masterdata.delete_min_order_value(_min_order_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16462    delete_oms_user(uuid)    FUNCTION     ?  CREATE FUNCTION masterdata.delete_oms_user(_user_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	BEGIN

        DELETE from masterdata.oms_users
        WHERE user_id = _user_id;

    RETURN 'user_removed_successfully';                                                       
	  
    END;
$$;
 9   DROP FUNCTION masterdata.delete_oms_user(_user_id uuid);
    
   masterdata          sahyadri    false    9            [           1255    17273    delete_packaging_type(uuid)    FUNCTION     u  CREATE FUNCTION masterdata.delete_packaging_type(_packaging_types_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	BEGIN

        DELETE from masterdata.packaging_types
        WHERE packaging_type_id = _packaging_types_id;

    RETURN 'packaging_type_removed_successfully';                                                       
	  
    END;
$$;
 J   DROP FUNCTION masterdata.delete_packaging_type(_packaging_types_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16463    delete_role(uuid)    FUNCTION     7  CREATE FUNCTION masterdata.delete_role(_role_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	BEGIN

        DELETE from masterdata.roles
        WHERE role_id = _role_id;

    RETURN 'role_removed_successfully';                                                       
	  
    END;
$$;
 5   DROP FUNCTION masterdata.delete_role(_role_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16464    delete_store(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.delete_store(_store_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __store_id UUID;
	BEGIN
	
		DELETE from masterdata.serviceable_pincodes
		WHERE store_id = _store_id;

        DELETE from masterdata.stores 
        WHERE store_id = _store_id;

    RETURN 'store_removed_successfully';                                                       
	  
    END;
$$;
 7   DROP FUNCTION masterdata.delete_store(_store_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16465    delete_subscription(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.delete_subscription(_subscription_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __delivery_point_id UUID;
	BEGIN

        DELETE from masterdata.subscriptions
        WHERE subscription_id = _subscription_id;

    RETURN 'Subscription_removed_successfully';                                                       
	  
    END;
$$;
 E   DROP FUNCTION masterdata.delete_subscription(_subscription_id uuid);
    
   masterdata          sahyadri    false    9            8           1255    16870 "   delivery_option_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.delivery_option_filter(_from_date date, _to_date date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'deliveryoptionrefcursor'; 
    BEGIN
      OPEN ref FOR 
      SELECT delivery_option_id, delivery_option, is_active
      from masterdata.delivery_options
        WHERE created_at::date BETWEEN _from_date AND _to_date;

      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 Q   DROP FUNCTION masterdata.delivery_option_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            b           1255    17147    finance_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.finance_filter(_from_date date, _to_date date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'financerefcursor'; 
    BEGIN
	
	if _from_date is not null and _to_date is not null then
	
      OPEN ref FOR 
        SELECT c.first_name, c.last_name, o.order_no,
        s.store_name, sa.line_2,
        concat(ad.line_1,' ', ad.line_2, ' ',ad.street, ' ',ad.city, ' ',ad.state) as shipping_address, 
        o.total_amount, w.is_active, w.amount,  o.created_at,
        (case when o.is_paid is true then 'Paid' ELSE 'Not Paid' END) as payment_status, o.payment_id, o.payment_method, c.mobile
        from masterdata.orders o
        left outer join masterdata.customers c on o.customer_id = c.customer_id
        left outer join masterdata.addresses ad on ad.address_id = o.shipping_address_id
        LEFT OUTER JOIN masterdata.stores s on o.store_id = s.store_id
        LEFT OUTER JOIN masterdata.wallet_transactions w on o.order_id = w.order_id
        left outer join masterdata.addresses sa on s.address_id = sa.address_id
        WHERE o.created_at::date BETWEEN _from_date AND _to_date;

      RETURN ref;                               -- Return the cursor to the caller
	  
	  else 
	  
	    OPEN ref FOR 
        SELECT c.first_name, c.last_name, o.order_no,
        s.store_name, sa.line_2,
        concat(ad.line_1,' ', ad.line_2, ' ',ad.street, ' ',ad.city, ' ',ad.state) as shipping_address, 
        o.total_amount, w.is_active, w.amount,  o.created_at,
        (case when o.is_paid is true then 'Paid' ELSE 'Not Paid' END) as payment_status, o.payment_id, o.payment_method, c.mobile
        from masterdata.orders o
        left outer join masterdata.customers c on o.customer_id = c.customer_id
        left outer join masterdata.addresses ad on ad.address_id = o.shipping_address_id
        LEFT OUTER JOIN masterdata.stores s on o.store_id = s.store_id
        LEFT OUTER JOIN masterdata.wallet_transactions w on o.order_id = w.order_id
        left outer join masterdata.addresses sa on s.address_id = sa.address_id;
      	RETURN ref;                               -- Return the cursor to the caller
		
	end if;
      
    END;
$$;
 I   DROP FUNCTION masterdata.finance_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9                       1255    16466    frequency_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.frequency_filter(_from_date date, _to_date date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'frequencyrefcursor'; 
    BEGIN
      OPEN ref FOR 
      SELECT frequency_id, frequency, is_active
      from masterdata.frequencies
        WHERE created_at::date BETWEEN _from_date AND _to_date;

      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 K   DROP FUNCTION masterdata.frequency_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9                       1255    16467 3   generate_unique_app_order_number(character varying)    FUNCTION     �  CREATE FUNCTION masterdata.generate_unique_app_order_number(_channel character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_app_order_no text;
    done bool;
BEGIN
    done := false;
    WHILE NOT done LOOP
        new_app_order_no := SUBSTRING(md5(now()::text||random()::text),1,8);
        done := NOT exists(SELECT 1 FROM masterdata.orders WHERE order_no = new_app_order_no);
    END LOOP;
	
	if _channel = 'ECOM_WEB' then
    	RETURN ('EW'||new_app_order_no);
	elsif _channel = 'ECOM_IOS' then
		RETURN ('EI'||new_app_order_no);
	elsif _channel = 'ECOM_ANDR' then
		RETURN ('EA'||new_app_order_no);
	elsif _channel = 'WHATSAPP_IOS' then
		RETURN ('WI'||new_app_order_no);
	elsif _channel = 'WHATSAPP_ANDR' then
		RETURN ('WA'||new_app_order_no);
	elsif _channel = 'OMS_WEB' then
		RETURN ('OW'||new_app_order_no);
	elsif _channel = 'CRM_WEB' then
		RETURN ('CW'||new_app_order_no);
		
	end if;
END;
$$;
 W   DROP FUNCTION masterdata.generate_unique_app_order_number(_channel character varying);
    
   masterdata          sahyadri    false    9            j           1255    16468    get_address(uuid, uuid, uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_address(_store_id uuid, _customer_id uuid, _address_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'addresscursor';
	    
	BEGIN

        if _customer_id is not null or _store_id is not null and _address_id is null then

            OPEN ref for
            SELECT address_id, store_id, customer_id, first_name, last_name, email, mobile, line_1, line_2, street, city, state, country, 
                    pincode, is_billing, is_shipping, is_default, latitude, longitude, landmark
            FROM masterdata.addresses 
            WHERE (customer_id = _customer_id and is_active = true) or (store_id = _store_id and is_active = true) order by is_default desc;
            RETURN ref;

        elsif  _customer_id is not null or _store_id is not null and _address_id is not null then

            OPEN ref for
            SELECT address_id, store_id, customer_id, first_name, last_name, email, mobile, line_1, line_2, street, city, state, country, 
                    pincode, is_billing, is_shipping, is_default, latitude, longitude, landmark
            FROM masterdata.addresses 
            WHERE (customer_id = _customer_id and is_active = true) or (store_id = _store_id and is_active = true) and address_id = _address_id order by is_default desc;
            RETURN ref;

        elsif _customer_id is null and _store_id is not null and _address_id is not null then

            OPEN ref for
            SELECT address_id, store_id, customer_id, first_name, last_name, email, mobile, line_1, line_2, street, city, state, country, 
                    pincode, is_billing, is_shipping, is_default, latitude, longitude, landmark
            FROM masterdata.addresses 
            WHERE address_id = _address_id and is_active = true order by is_default desc;
            RETURN ref;

        end if;                                                 
	  
    END;
$$;
 [   DROP FUNCTION masterdata.get_address(_store_id uuid, _customer_id uuid, _address_id uuid);
    
   masterdata          sahyadri    false    9            {           1255    16469    get_cart_details(uuid, uuid)    FUNCTION     
  CREATE FUNCTION masterdata.get_cart_details(_customer_id uuid, _cart_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
		 __cart_id uuid;
         __customer_id uuid;
		 __min_order_value numeric;
         ref1 refcursor default 'cartrefcursor'; 
		 ref2 refcursor default 'itemsrefcursor'; 
         

    BEGIN
	
	select min_order_value into __min_order_value from masterdata.min_order_value;
		
	if _customer_id is not null and _cart_id is null then 
        -- Logged In Customer

        select cart_id into __cart_id from masterdata.carts where customer_id = _customer_id and is_active = true;

	  	OPEN ref1 FOR 
        SELECT ct.cart_id, ct.cart_amount, pt.packaging_type, pt.amount, ct.sub_total, pt.packaging_type_id, ct.delivery_charges, __min_order_value
        FROM masterdata.carts ct left outer join masterdata.packaging_types pt
        on ct.packaging_type_id = pt.packaging_type_id
        WHERE ct.is_active = true and ct.cart_id = __cart_id; -- open cursor
		RETURN NEXT ref1;
		
		OPEN ref2 FOR 
        SELECT item_id, item_name, item_description, quantity , price , item_image_urls, total_price, user_subscription_id, created_at,
 				pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, mrp, final_selling_price,
				store_code
	   	from masterdata.cart_lines 
        where cart_id =  __cart_id ORDER BY created_at asc;
		RETURN NEXT ref2;
	
	elsif _cart_id is not null THEN

        select cart_id into __cart_id from masterdata.carts where cart_id = _cart_id and is_active = true;

        OPEN ref1 FOR 
        SELECT ct.cart_id, ct.cart_amount, pt.packaging_type, pt.amount, ct.sub_total, pt.packaging_type_id, ct.delivery_charges, __min_order_value
        FROM masterdata.carts ct left outer join masterdata.packaging_types pt 
        on ct.packaging_type_id = pt.packaging_type_id
        WHERE ct.is_active = true and ct.cart_id = __cart_id; -- open cursor
		RETURN NEXT ref1;
		
		OPEN ref2 FOR 
        SELECT item_id, item_name, item_description, quantity , price , item_image_urls, total_price, user_subscription_id, created_at,
        	pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, mrp, final_selling_price,
			store_code
		from masterdata.cart_lines 
        where cart_id =  __cart_id ORDER BY created_at asc;
		RETURN NEXT ref2;

    else

		OPEN ref1 FOR SELECT null as customer_id;
		return next ref1;
		OPEN ref2 FOR SELECT null as cart_id;
		return next ref2;

		
	end if;
    END;
$$;
 M   DROP FUNCTION masterdata.get_cart_details(_customer_id uuid, _cart_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16470    get_channels()    FUNCTION     �  CREATE FUNCTION masterdata.get_channels() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
         ref refcursor default 'channelsrefcursor'; 
    BEGIN
      OPEN ref FOR 
      SELECT ch.channel_id, ch.channel, ch.latest_version  
      FROM masterdata.channels ch 
      WHERE ch.is_active = true;
      RETURN ref;                               -- Return the cursor to the caller
    END;
$$;
 )   DROP FUNCTION masterdata.get_channels();
    
   masterdata          sahyadri    false    9            o           1255    17639    get_crm_orders(uuid, uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_crm_orders(_role_id uuid, _channel_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'orderrefcursor';
		__status_id uuid;
	BEGIN

		
    if _channel_id is null then

        OPEN ref FOR 
        SELECT null as order_id;
		RETURN ref;

    ELSE

--         OPEN ref FOR 
--         SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
-- 		ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
-- 		o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time, o.sub_total, o.delivery_charges, o.payment_status,
-- 		p.packaging_type, p.amount, o.slot_date, ad.landmark
--         FROM masterdata.orders o 
-- 		LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
--         LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
-- 		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
-- 		LEFT JOIN masterdata.packaging_types p on o.packaging_type_id = p.packaging_type_id
--         WHERE o.is_active = true and o.channel_id = _channel_id ORDER BY o.created_at desc; -- open cursor
-- 		RETURN ref;

		select status_id into __status_id from masterdata.user_matrix where role_id = _role_id and is_status_read = true;

        OPEN ref FOR 
        SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
		ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
		o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time, o.slot_date
        FROM masterdata.orders o 
		LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
        LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
		join masterdata.user_matrix u on o.status_id = u.status_id
         WHERE u.role_id = _role_id and u.is_status_read and o.channel_id = _channel_id is true ORDER BY o.created_at desc; -- open cursor
		RETURN ref;

	end if;
    END;
$$;
 J   DROP FUNCTION masterdata.get_crm_orders(_role_id uuid, _channel_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16471    get_customer(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_customer(_customer_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'customerrefcursor'; 
		__address_id uuid;
    BEGIN
	
	select address_id into __address_id from masterdata.addresses where customer_id = _customer_id and is_default = 'true';
	
      OPEN ref FOR 
      SELECT customer_id, store_id, magento_customer_id, first_name, last_name, mobile, email, 
        subscription_id, subscription_start_date, subscription_end_date, frequency_id, delivery_option_id, __address_id
      FROM masterdata.customers
      WHERE customer_id = _customer_id;

      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 :   DROP FUNCTION masterdata.get_customer(_customer_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16472    get_customers()    FUNCTION     2  CREATE FUNCTION masterdata.get_customers() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'customersrefcursor'; 
    BEGIN
	
      OPEN ref FOR 
      SELECT customer_id, store_id, magento_customer_id, first_name, last_name, mobile, email, 
        subscription_id, subscription_start_date, subscription_end_date, frequency_id, delivery_option_id
      from masterdata.customers WHERE magento_customer_id is not Null;

      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 *   DROP FUNCTION masterdata.get_customers();
    
   masterdata          sahyadri    false    9                       1255    16473    get_dashboard()    FUNCTION     �  CREATE FUNCTION masterdata.get_dashboard() RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref1 refcursor default 'dashboardrefcursor';
		ref2 refcursor default 'salesrefcursor';
        __orders INTEGER;
        __order_dispatch INTEGER;
        __total_sales numeric;
        __total_customers integer;
        __carts integer;
        __in_process integer;
        __complete_order integer;
        __cancelled_order integer;
		__year integer;

    BEGIN      
    
        SELECT coalesce(count(*),0) into __orders from masterdata.orders
        WHERE is_paid = true;

        SELECT coalesce(count(*),0) into __order_dispatch from masterdata.orders o
        left join masterdata.status s on o.status_id = s.status_id
        WHERE s.status_name = 'out_for_delivery';

        SELECT coalesce(sum(total_amount),0) into __total_sales from masterdata.orders
        WHERE is_paid = true;
        
        SELECT coalesce(count(*),0) into __total_customers from masterdata.customers 
        WHERE magento_customer_id is not Null;

        SELECT coalesce(count(*),0) into __carts from masterdata.carts c 
        left join masterdata.orders o on c.cart_id = o.cart_id
        where o.cart_id is null;

        SELECT coalesce(count(*),0) into __in_process from masterdata.orders o
        left outer join masterdata.status s on o.status_id = s.status_id
        WHERE s.status_name = 'in_process';

        SELECT coalesce(count(*),0) into __complete_order from masterdata.orders o
        left outer join masterdata.status s on o.status_id = s.status_id
        WHERE s.status_name = 'delivered' and 
            o.is_paid = true;

        SELECT coalesce(count(*),0) into __cancelled_order from masterdata.orders o
        left outer join masterdata.status s on o.status_id = s.status_id
        WHERE s.status_name = 'cancelled';

        open ref1 for
            SELECT __orders, __order_dispatch, __total_sales, __total_customers, 
				__carts, __in_process, __complete_order, __cancelled_order;
        RETURN next ref1;
		
		SELECT date_part('year', now()) into __year;

        open ref2 for
        select
            coalesce(sum(case when extract('month' from o.created_at) = 1 then total_amount else 0 end),0) as jan,
            coalesce(sum(case when extract('month' from o.created_at) = 2 then total_amount else 0 end),0) as feb,
            coalesce(sum(case when extract('month' from o.created_at) = 3 then total_amount else 0 end),0) as march,
            coalesce(sum(case when extract('month' from o.created_at) = 4 then total_amount else 0 end),0) as apr,
            coalesce(sum(case when extract('month' from o.created_at) = 5 then total_amount else 0 end),0) as may,
            coalesce(sum(case when extract('month' from o.created_at) = 6 then total_amount else 0 end),0) as jun,
            coalesce(sum(case when extract('month' from o.created_at) = 7 then total_amount else 0 end),0) as july,
            coalesce(sum(case when extract('month' from o.created_at) = 8 then total_amount else 0 end),0) as aug,
            coalesce(sum(case when extract('month' from o.created_at) = 9 then total_amount else 0 end),0) as sept,
            coalesce(sum(case when extract('month' from o.created_at) = 10 then total_amount else 0 end),0) as oct,
            coalesce(sum(case when extract('month' from o.created_at) = 11 then total_amount else 0 end),0) as nov,
            coalesce(sum(case when extract('month' from o.created_at) = 12 then total_amount else 0 end),0) as dec
            from masterdata.orders o
            where (select extract('year' from o.created_at)) = __year and is_paid = true;
        RETURN next ref2;
                   
    END;
$$;
 *   DROP FUNCTION masterdata.get_dashboard();
    
   masterdata          sahyadri    false    9            <           1255    16916    get_delivery_charge(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_delivery_charge(_delivery_charges_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'deliverychargerefcursor';

	BEGIN
        
        OPEN ref FOR 

            select delivery_charges_id, min_cart_value, max_cart_value, amount
			from masterdata.delivery_charges
            
            where delivery_charges_id = _delivery_charges_id;

        RETURN ref;
                                           
	  
    END;
$$;
 I   DROP FUNCTION masterdata.get_delivery_charge(_delivery_charges_id uuid);
    
   masterdata          sahyadri    false    9            :           1255    16915    get_delivery_charges()    FUNCTION     �  CREATE FUNCTION masterdata.get_delivery_charges() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'deliverychargesrefcursor';

	BEGIN
        
        OPEN ref FOR 

            select delivery_charges_id, min_cart_value, max_cart_value, amount
			from masterdata.delivery_charges order by min_cart_value;

        RETURN ref;
                                           
    END;
$$;
 1   DROP FUNCTION masterdata.get_delivery_charges();
    
   masterdata          sahyadri    false    9                       1255    16474    get_delivery_option(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_delivery_option(_delivery_option_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'deliveryoptionrefcursor'; 

    BEGIN

        OPEN ref FOR 

        SELECT delivery_option_id, delivery_option, is_active
        from masterdata.delivery_options
        where delivery_option_id = _delivery_option_id;

        RETURN ref;                               -- Return the cursor to the caller
    
    END;
$$;
 H   DROP FUNCTION masterdata.get_delivery_option(_delivery_option_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16475    get_delivery_options()    FUNCTION     �  CREATE FUNCTION masterdata.get_delivery_options() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'deliveryoptionsrefcursor'; 
    BEGIN
      OPEN ref FOR 

      SELECT delivery_option_id, delivery_option, is_active
      from masterdata.delivery_options;

      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 1   DROP FUNCTION masterdata.get_delivery_options();
    
   masterdata          sahyadri    false    9            C           1255    16476    get_delivery_point(uuid)    FUNCTION     b  CREATE FUNCTION masterdata.get_delivery_point(_delivery_point_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref1 refcursor default 'deliverypointrefcursor'; 
        ref2 refcursor default 'pincoderefcursor';

    BEGIN

        OPEN ref1 FOR 
        SELECT dp.delivery_point_id, dp.delivery_point_name, dp.plant_code, dp.dp_code,
            a.address_id, a.line_1, a.line_2, a.street, a.city, a.state, a.country, a.pincode 
        from masterdata.delivery_points dp JOIN masterdata.addresses a on a.created_by = dp.delivery_point_id
        WHERE dp.delivery_point_id = _delivery_point_id;

        RETURN next ref1;   
        
        OPEN ref2 FOR
        SELECT pincode from masterdata.serviceable_pincodes WHERE delivery_point_id = _delivery_point_id;
        RETURN next ref2;                           
    
    END;
$$;
 F   DROP FUNCTION masterdata.get_delivery_point(_delivery_point_id uuid);
    
   masterdata          sahyadri    false    9            B           1255    16477    get_delivery_points()    FUNCTION     N  CREATE FUNCTION masterdata.get_delivery_points() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'deliverypointrefcursor'; 
    BEGIN
      OPEN ref FOR 
      SELECT dp.delivery_point_id, dp.delivery_point_name, dp.plant_code, dp.dp_code,
        a.address_id, a.line_1, a.line_2, a.street, a.city, a.state, a.country, a.pincode 
      from masterdata.delivery_points dp JOIN masterdata.addresses a on a.created_by = dp.delivery_point_id;

      
      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 0   DROP FUNCTION masterdata.get_delivery_points();
    
   masterdata          sahyadri    false    9                       1255    16478    get_frequencies()    FUNCTION     }  CREATE FUNCTION masterdata.get_frequencies() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'frequenciesrefcursor'; 
    BEGIN
      OPEN ref FOR 

      SELECT frequency_id, frequency, is_active
      from masterdata.frequencies;
      
      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 ,   DROP FUNCTION masterdata.get_frequencies();
    
   masterdata          sahyadri    false    9                       1255    16479    get_frequency(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_frequency(_frequency_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'frequencyrefcursor'; 

    BEGIN

        OPEN ref FOR 

        SELECT frequency_id, frequency, is_active
        from masterdata.frequencies
        where frequency_id = _frequency_id;

        RETURN ref;                               -- Return the cursor to the caller
    
    END;
$$;
 <   DROP FUNCTION masterdata.get_frequency(_frequency_id uuid);
    
   masterdata          sahyadri    false    9            v           1255    16480    get_invoice_details(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_invoice_details(_order_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref1 refcursor default 'invoicerefcursor';
		ref2 refcursor default 'ordersrefcursor';
		ref3 refcursor default 'shippingrefcursor';
		__cart_id uuid;
		__total_amount numeric;
		__cgst_amount numeric;


	BEGIN

 	select cart_id into __cart_id from masterdata.orders where order_id = _order_id;  
	
        OPEN ref1 FOR 

        SELECT item_name, item_id, quantity, special_price , coalesce(discount_amount,0.00),total_price,
			unit_of_measure, coalesce(gst,0) as igst_percentage,
            round(coalesce((total_price*(gst/100)),0.00),2) as igst_amount,  round(coalesce(gst/2,0.00),2) as cgst_amount, round(coalesce((total_price*(gst/100))/2,0),2) as cgst_percentage
        from masterdata.order_lines where cart_id = __cart_id;

        RETURN next ref1;
		
		select sum(round(coalesce((total_price*(gst/100))/2,0),2)) into __cgst_amount from masterdata.order_lines where cart_id = __cart_id;
	
	select sum(total_price) into __total_amount from masterdata.order_lines where cart_id = __cart_id;
		
        OPEN ref2 FOR 

        SELECT o.order_no, o.payment_method, o.created_at::date, o.invoice_id, __total_amount,
			concat(a.first_name,' ', a.last_name), a.email, a.mobile, 
			concat(a.line_1,' ', a.line_2,' ', a.street,' ', a.city,' ', a.state,' ', a.country,' ', a.pincode),a.state, __cgst_amount
        from masterdata.orders o 
		LEFT JOIN masterdata.addresses a on o.billing_address_id = a.address_id
		where o.order_id = _order_id;

        RETURN next ref2;  
		
     	OPEN ref3 FOR 
        SELECT concat(a.first_name,' ',a.last_name), a.email, a.mobile, 
			concat(a.line_1,' ', a.line_2,' ', a.street,' ', a.city,' ', a.state,' ', a.country,' ', a.pincode),a.state
        FROM masterdata.orders o 
        LEFT JOIN masterdata.addresses a on o.shipping_address_id = a.address_id
        WHERE o.order_id = _order_id;
        RETURN NEXT ref3;
		
    END;
$$;
 >   DROP FUNCTION masterdata.get_invoice_details(_order_id uuid);
    
   masterdata          sahyadri    false    9            V           1255    17137    get_item_prices(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_item_prices(_cart_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'itemsrefcursor';

	BEGIN

        OPEN ref FOR 

            SELECT item_id , quantity, price, total_price, special_price, mrp, final_selling_price, inventory
			from masterdata.cart_lines where cart_id = _cart_id ;

		RETURN ref;

    END;
$$;
 9   DROP FUNCTION masterdata.get_item_prices(_cart_id uuid);
    
   masterdata          sahyadri    false    9            �            1255    17279    get_min_order_value()    FUNCTION     s  CREATE FUNCTION masterdata.get_min_order_value() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'minorderrefcursor';

	BEGIN
        
        OPEN ref FOR 

            select min_order_value_id, min_order_value, updated_at
			from masterdata.min_order_value;

        RETURN ref;                         
	  
    END;
$$;
 0   DROP FUNCTION masterdata.get_min_order_value();
    
   masterdata          sahyadri    false    9            Y           1255    16481    get_oms_user(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_oms_user(_user_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'omsuserrefcursor';
		__store_id uuid[];
		__store_length integer;
		__store_name character varying;

	BEGIN
	
			select store_id into __store_id from masterdata.oms_users where user_id = _user_id;
	
	        __store_length = array_length(__store_id, 1);
			
			if __store_length = 1 then
				
				select store_name into __store_name from masterdata.stores where store_id = __store_id[1];
			
			else
			
				__store_name = 'All Stores';
				
			end if;
        
        OPEN ref FOR 

            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, __store_id, u.is_active,
				__store_name, r.role_name
			from masterdata.oms_users u 
			join masterdata.roles r on u.role_id = r.role_id

            where user_id = _user_id;

        RETURN ref;
                                           
	  
    END;
$$;
 6   DROP FUNCTION masterdata.get_oms_user(_user_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16482    get_oms_users()    FUNCTION     �  CREATE FUNCTION masterdata.get_oms_users() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
		__store_id uuid;
        ref refcursor default 'omsusersrefcursor';

	BEGIN
       
		OPEN ref FOR
		
		select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.is_active, r.role_name
		from masterdata.oms_users u 
		join masterdata.roles r on u.role_id = r.role_id;
		
		RETURN ref;

    END;
$$;
 *   DROP FUNCTION masterdata.get_oms_users();
    
   masterdata          sahyadri    false    9            Z           1255    16483    get_order_details(uuid)    FUNCTION     
  CREATE FUNCTION masterdata.get_order_details(_order_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref1 refcursor default 'orderrefcursor';
        ref2 refcursor default 'itemsrefcursor';
        ref3 refcursor default 'shippingrefcursor';
		__delivery_boy_name character varying;
	BEGIN
	
		select delivery_person_name into __delivery_boy_name from masterdata.delivery_details d
		left join masterdata.orders o on d.tracking_code = o.order_no
		where o.order_id = _order_id;

        OPEN ref1 FOR 
        SELECT o.order_id, o.order_no, o.total_amount, o.billing_address_id, o.created_at, o.updated_at, s.status_name, o.payment_method, 
		a.first_name, a.last_name, a.email, a.mobile, a.line_1, a.line_2, a.street, a.city, a.state, a.country, a.pincode, 
		o.rating, o.review, o.status_history, o.invoice_id, ts.start_slot_time, ts.end_slot_time, o.sub_total, o.delivery_charges, o.payment_status,
		p.packaging_type, p.amount, o.slot_date, a.latitude, a.longitude, a.landmark,
		d.delivery_person_name, d.tracking_code, d.delivery_time, d.poc_name, d.delivery_method, d.is_cash_od, d.is_card_od, d.is_online_payment,
		d.amount_collected, d.change_collected, d.amount_transacted
        FROM masterdata.orders o 
		LEFT JOIN masterdata.status s on o.status_id = s.status_id
        LEFT JOIN masterdata.addresses a on o.billing_address_id = a.address_id
		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
		LEFT JOIN masterdata.packaging_types p on o.packaging_type_id = p.packaging_type_id
		LEFT JOIN masterdata.delivery_details d on d.tracking_code = o.order_no
        WHERE o.is_active = true and o.order_id = _order_id; -- open cursor
		RETURN NEXT ref1;
		
		OPEN ref2 FOR 
        SELECT item_id, item_name, item_description, quantity , price , item_image_urls, total_price,
		 		pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, mrp, final_selling_price,
				store_code
        from masterdata.order_lines 
        where order_part_id in (SELECT order_part_id from masterdata.order_parts WHERE order_id = _order_id);
		RETURN NEXT ref2;

        OPEN ref3 FOR 
        SELECT o.order_id, o.shipping_address_id, a.first_name, a.last_name, a.email, a.mobile, a.line_1, a.line_2, a.street, a.city, a.state, a.country, a.pincode,
			a.latitude, a.longitude, a.landmark
        FROM masterdata.orders o 
        LEFT JOIN masterdata.addresses a on o.shipping_address_id = a.address_id
        WHERE o.order_id = _order_id;
        RETURN NEXT ref3;

    END;
$$;
 <   DROP FUNCTION masterdata.get_order_details(_order_id uuid);
    
   masterdata          sahyadri    false    9            U           1255    16484    get_orders(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_orders(_customer_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'orderrefcursor';
	BEGIN

		
    if _customer_id is null then

        OPEN ref FOR 
        SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
		ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
		o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time, o.sub_total, o.delivery_charges, o.payment_status,
		p.packaging_type, p.amount, o.slot_date, ad.landmark
        FROM masterdata.orders o 
		LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
        LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
		LEFT JOIN masterdata.packaging_types p on o.packaging_type_id = p.packaging_type_id
        WHERE o.is_active = true ORDER BY o.created_at desc ; -- open cursor
		RETURN ref;

    ELSE

        OPEN ref FOR 
        SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
		ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
		o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time, o.sub_total, o.delivery_charges, o.payment_status,
		p.packaging_type, p.amount, o.slot_date, ad.landmark
        FROM masterdata.orders o 
		LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
        LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
		LEFT JOIN masterdata.packaging_types p on o.packaging_type_id = p.packaging_type_id
        WHERE o.is_active = true and o.customer_id = _customer_id ORDER BY o.created_at desc; -- open cursor
		RETURN ref;

	end if;
    END;
$$;
 8   DROP FUNCTION masterdata.get_orders(_customer_id uuid);
    
   masterdata          sahyadri    false    9            T           1255    16485    get_orders_by_id(uuid, uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_orders_by_id(_store_id uuid, _customer_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'orderrefcursor';
	BEGIN

        IF _store_id is not null and _customer_id is null then

        OPEN ref FOR 
        SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
		ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
		o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time
        FROM masterdata.orders o 
		LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
        LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
        WHERE o.is_active = true and o.store_id = _store_id ORDER BY o.updated_at desc;
		RETURN ref;

        elsif _store_id is null and _customer_id is not null then

        OPEN ref FOR 
        SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
		ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
		o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time
        FROM masterdata.orders o 
		LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
        LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
        WHERE o.is_active = true and o.customer_id = _customer_id ORDER BY o.updated_at desc;
		RETURN ref;

        END IF;
		
    END;
$$;
 N   DROP FUNCTION masterdata.get_orders_by_id(_store_id uuid, _customer_id uuid);
    
   masterdata          sahyadri    false    9            O           1255    16896    get_orders_by_role(uuid)    FUNCTION     V  CREATE FUNCTION masterdata.get_orders_by_role(_role_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'orderrefcursor';
		__role_id uuid;
		__status_id uuid;
	BEGIN

    select status_id into __status_id from masterdata.user_matrix where role_id = _role_id and is_status_read = true;

        OPEN ref FOR 
        SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
		ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
		o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time
        FROM masterdata.orders o 
		LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
        LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
		join masterdata.user_matrix u on o.status_id = u.status_id
         WHERE u.role_id = _role_id and u.is_status_read is true ORDER BY o.created_at desc ; -- open cursor
		RETURN ref;

    END;
$$;
 <   DROP FUNCTION masterdata.get_orders_by_role(_role_id uuid);
    
   masterdata          sahyadri    false    9            ]           1255    17275    get_packaging_type(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_packaging_type(_packaging_types_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'packagingtyperefcursor';

	BEGIN
        
        OPEN ref FOR 

            select packaging_type_id, packaging_type, amount
			from masterdata.packaging_types
            
            where packaging_type_id = _packaging_types_id;

        RETURN ref;
                                           
	  
    END;
$$;
 G   DROP FUNCTION masterdata.get_packaging_type(_packaging_types_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16486    get_packaging_types()    FUNCTION     �  CREATE FUNCTION masterdata.get_packaging_types() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'packagingtypesrefcursor';

	BEGIN
        
        OPEN ref FOR 

            select packaging_type_id, packaging_type, amount
			from masterdata.packaging_types;

        RETURN ref;
                                           
	  
    END;
$$;
 0   DROP FUNCTION masterdata.get_packaging_types();
    
   masterdata          sahyadri    false    9            P           1255    16487    get_payment_status(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_payment_status(_order_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref1 refcursor default 'orderrefcursor';
		ref2 refcursor default 'itemsrefcursor';
		__first_name character varying;
		__email character varying;
		__mobile bigint;
		__sub_total numeric;
		__packaging_type_id uuid;
		__packaging_type character varying;
		__packaging_amount numeric;
		__status_id uuid;
		__payment_method character varying;
		__items bigint;
        
	BEGIN
	
		SELECT ad.first_name, ad.email, ad.mobile into __first_name, __email, __mobile
		from masterdata.addresses  ad
		LEFT JOIN masterdata.orders o 
		ON o.billing_address_id = ad.address_id
		WHERE o.is_active = true and o.order_id = _order_id;

        select packaging_type_id, status_id, payment_method into __packaging_type_id, __status_id, __payment_method
        from masterdata.orders 
        where order_id = _order_id;
		
		select packaging_type, amount into __packaging_type, __packaging_amount
		from masterdata.packaging_types where packaging_type_id = __packaging_type_id;
		
		if __payment_method = 'WALLET' then
			update masterdata.orders
			set payment_status = 'SUCCESS',
				is_paid = true
			where order_id = _order_id;
			
-- 		elsif __payment_method = 'CASH_ON_DELIVERY' or __payment_method = 'CARD_ON_DELIVERY' then
-- 			update masterdata.orders
-- 			set payment_status = 'SUCCESS',
-- 				is_paid = true
-- 			where order_id = _order_id and status_id = '40ec4239-049d-11eb-bbea-1731d3e77846';
			
-- 		else
-- 			update masterdata.orders
-- 			set payment_status = 'SUCCESS',
-- 				is_paid = false
-- 			where order_id = _order_id;

		elsif __payment_method = 'CASH_ON_DELIVERY' or __payment_method = 'CARD_ON_DELIVERY' then
			update masterdata.orders
			set payment_status = 'SUCCESS',
				is_paid = false
			where order_id = _order_id;

			if __status_id = '40ec4239-049d-11eb-bbea-1731d3e77846' then
				update masterdata.orders
				set is_paid = true
				where order_id = _order_id;					
			end if;
		
		end if;

        OPEN ref1 FOR 
        SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.payment_method, ts.start_slot_time, ts.end_slot_time, __first_name, __email, __mobile, COALESCE(o.sub_total,0),
			__packaging_type, __packaging_amount, o.slot_date, o.delivery_charges, o.is_paid, o.payment_status, o.slot_date
        FROM masterdata.orders o
		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
        WHERE o.is_active = true and o.order_id = _order_id; -- open cursor
		RETURN next ref1;
		
		select count(item_name) into __items from masterdata.order_lines
		where order_part_id in (SELECT order_part_id from masterdata.order_parts WHERE order_id = _order_id);
		
		OPEN ref2 FOR 
        SELECT item_name, quantity , price , total_price, __items
        from masterdata.order_lines 
        where order_part_id in (SELECT order_part_id from masterdata.order_parts WHERE order_id = _order_id);
		RETURN NEXT ref2;
		
		
        
    END;
$$;
 =   DROP FUNCTION masterdata.get_payment_status(_order_id uuid);
    
   masterdata          sahyadri    false    9            9           1255    16919 "   get_payu_status(character varying)    FUNCTION        CREATE FUNCTION masterdata.get_payu_status(_order_id character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'satusrefcursor';
		__first_name character varying;
		__last_name character varying;
		__email character varying;

	BEGIN
	
		SELECT ad.first_name, ad.last_name, ad.email into __first_name, __last_name, __email
		from masterdata.addresses  ad
		LEFT JOIN masterdata.orders o 
		ON o.billing_address_id = ad.address_id
		WHERE o.is_active = true and o.order_id = cast(_order_id as uuid);

        OPEN ref FOR 

            SELECT order_id, total_amount, __first_name, __last_name, __email, order_no
                from masterdata.orders where order_id = cast(_order_id as uuid);

		RETURN ref;

    END;
$$;
 G   DROP FUNCTION masterdata.get_payu_status(_order_id character varying);
    
   masterdata          sahyadri    false    9                       1255    16488    get_permission(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_permission(_role_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref1 refcursor default 'screenrefcursor'; 
		ref2 refcursor default 'permissionrefcursor'; 
		ref3 refcursor default 'statusrefcursor'; 

    BEGIN

		OPEN ref1 FOR 
		SELECT p.screen_id, p.is_read, p.is_write, s.screen_name
		FROM masterdata.permissions p 
		join masterdata.screens s on p.screen_id = s.screen_id
		where p.role_id = _role_id;
		RETURN NEXT ref1;
		
		OPEN ref2 FOR 
		select p.role_id, r.role_name
		from masterdata.permissions p
		join masterdata.roles r on p.role_id = r.role_id
		where p.role_id = _role_id;
		RETURN NEXT ref2;
		
		OPEN ref3 FOR 
		select u.screen_id, u.status_id, s.status_name, u.is_status_read, u.is_status_write
		from masterdata.user_matrix u
		join masterdata.status s on u.status_id = s.status_id
		where u.role_id = _role_id;
		RETURN NEXT ref3;
		
    END;
$$;
 8   DROP FUNCTION masterdata.get_permission(_role_id uuid);
    
   masterdata          sahyadri    false    9            H           1255    16489    get_permissions()    FUNCTION     �  CREATE FUNCTION masterdata.get_permissions() RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref1 refcursor default 'screenrefcursor'; 
		ref2 refcursor default 'permissionrefcursor'; 
		ref3 refcursor default 'statusrefcursor'; 

    BEGIN
		
		OPEN ref1 FOR 
		SELECT distinct p.role_id, p.screen_id, p.is_read, p.is_write, s.screen_name
		FROM masterdata.permissions p 
		join masterdata.screens s on p.screen_id = s.screen_id;
		RETURN NEXT ref1;
		
		OPEN ref2 FOR 
		select distinct p.role_id ,r.role_name
		from masterdata.permissions p
		join masterdata.roles r on p.role_id = r.role_id;
		RETURN NEXT ref2;
		
		OPEN ref3 FOR 
		select distinct u.role_id, u.screen_id, u.status_id, s.status_name, u.is_status_read, u.is_status_write
		from masterdata.user_matrix u
		join masterdata.roles r on u.role_id = r.role_id
		join masterdata.status s on u.status_id = s.status_id;
		RETURN NEXT ref3;
	
    END;
$$;
 ,   DROP FUNCTION masterdata.get_permissions();
    
   masterdata          sahyadri    false    9            !           1255    16490    get_ratings_and_reviews()    FUNCTION     �  CREATE FUNCTION masterdata.get_ratings_and_reviews() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'ratingreviewrefcursor';
	BEGIN

    OPEN ref FOR 
    SELECT o.order_id, o.rating, o.review, c.customer_id, c.first_name, c.last_name
    FROM masterdata.orders o JOIN masterdata.customers c on o.customer_id = c.customer_id
    WHERE o.rating is not null or o.review is not null;
    RETURN ref;

    END;
$$;
 4   DROP FUNCTION masterdata.get_ratings_and_reviews();
    
   masterdata          sahyadri    false    9            c           1255    17337 *   get_reports(date, date, character varying)    FUNCTION     �k  CREATE FUNCTION masterdata.get_reports(_from_date date, _to_date date, _report_name character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'reportrefcursor';  

    BEGIN

    if _from_date is not null and _to_date is not null then

        if _report_name = 'production' then

        OPEN ref FOR 
        SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name, sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status, o.total_amount, ol.row, null as bin
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on o.packaging_type_id = pt.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
            WHERE o.created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'sahyadrifarmproduct' then

            OPEN ref FOR 
                SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name,  sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status, ol.bin
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
            WHERE o.created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;                               -- Return the cursor to the caller
		
		elsif _report_name = 'delivery' then

            OPEN ref FOR 
                SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name,  sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status,o.total_amount,  null as row, ol.bin 
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
            WHERE o.status_id = '40ec4239-049d-11eb-bbea-1731d3e77846' and o.created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'neworder' then

            OPEN ref FOR 
                SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name,  sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status, o.total_amount, ol.row, ol.rack ,ol.bin
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
            WHERE o.status_id = '40ec4234-049d-11eb-bbea-6f57fab5c428' AND o.created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'categorywisesales' then

            OPEN ref FOR 
                SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name,  sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status, null as row, null as bin
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
            WHERE o.created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;                               -- Return the cursor to the caller

            elsif _report_name = 'all_orders' then

            OPEN ref FOR 
                select o.order_id, o.order_no, ad.mobile, o.total_amount, o.created_at, st.store_name,  sa.line_2,
                ch.channel, o.payment_method, o.reason, s.status_name,
                ol.item_name, ol.item_id, ol.varients, ol.row, ol.rack, ol.bin,
				ol.discount_amount, o.delivery_charges, pt.amount, 
				concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
				pt.packaging_type
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                LEFT outer join masterdata.channels ch on o.channel_id = ch.channel_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
            WHERE o.created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;                               -- Return the cursor to the caller    
        
        
        elsif _report_name = 'customer' then

            OPEN ref FOR 
                select c.customer_id, c.first_name, c.last_name, c.email, c.mobile,
                    ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode
                from masterdata.customers c
                LEFT outer JOIN masterdata.addresses ad on c.customer_id = ad.customer_id
            WHERE c.created_at::date BETWEEN _from_date AND _to_date AND magento_customer_id is not null;

        RETURN ref;                               -- Return the cursor to the caller
        
        
            elsif _report_name = 'bulk_varient' then

            OPEN ref FOR 
                select ol.item_name, ol.item_id, st.store_name, st.plant_code, ol.varients, ol.sku,
                    ol.price, ol.special_price, ol.quantity, ol.row, ol.rack, ol.bin, ol.ean
                    from masterdata.order_lines ol
                    join masterdata.orders o on o.cart_id = ol.cart_id
                    LEFT outer join masterdata.stores st on o.store_id = st.store_id
                WHERE o.created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'vehicle_plan' then

            OPEN ref FOR 
                SELECT o.order_no, ad.first_name, ad.last_name, ad.mobile, null as area_name, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                null as sextor, null as crates , null as boxws
                from masterdata.orders o
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
            WHERE o.created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'vehicle_wise_dispatch_verification' then

        OPEN ref FOR 
                SELECT o.order_no, ad.first_name, ad.last_name, ad.mobile, st.store_name,  sa.line_2, st.zone, null as veh, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address
                from masterdata.orders o
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
            WHERE o.created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'wing_wise_dispatch_verification' then

            OPEN ref FOR 
                SELECT o.order_no, ad.first_name, ad.last_name, 
                    concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                    pt.packaging_type, ol.item_name, ol.varients, ol.quantity, o.total_amount, ad.city
                from masterdata.order_lines ol
                join masterdata.orders o on o.cart_id = ol.cart_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                WHERE o.created_at::date BETWEEN _from_date AND _to_date;
            RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'WMS_upload_format' then

            OPEN ref FOR 
                SELECT o.payment_method, ad.latitude, ad.longitude, 
                    concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address, o.delivery_charges,
                    ad.first_name, ad.last_name, o.total_amount
                from masterdata.order_lines ol
                join masterdata.orders o on o.cart_id = ol.cart_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                WHERE o.created_at::date BETWEEN _from_date AND _to_date;
            RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'customer_order' then

            OPEN ref FOR 
                SELECT ch.channel, c.first_name, c.last_name, c.customer_id,
                count(o.order_id)
                from masterdata.customers c
                join masterdata.orders o on c.customer_id = o.customer_id
                LEFT outer join masterdata.channels ch on o.channel_id = ch.channel_id
                WHERE (o.created_at::date BETWEEN _from_date AND _to_date) and (magento_customer_id is not null)
				group by ch.channel, c.customer_id;
            RETURN ref;                               -- Return the cursor to the caller
				
		elsif _report_name = 'product_master' then

            OPEN ref FOR 
                SELECT ol.category_id, ol.category_name, ol.sub_category_id, ol.sub_category_name, ol.item_name, 
                    ol.sku, ol.hsn, ol.ean, ol.price, ol.special_price, ol.weight, ol.gst, ol.item_description,
                    ol.short_description, ol.unit_of_measure, ol.item_id, ol.item_status
                from masterdata.order_lines ol
				WHERE (ol.created_at::date BETWEEN _from_date AND _to_date);
            RETURN ref;                               -- Return the cursor to the caller
			
		elsif _report_name = 'daily_oms' then

            OPEN ref FOR 
                SELECT st.store_name, count(o.order_id) , to_char(o.created_at, 'DD/MM/YYYY'), to_char(o.created_at, 'Month') AS Month
					from masterdata.orders o join masterdata.stores st on o.store_id = st.store_id  
					WHERE (o.created_at::date BETWEEN _from_date AND _to_date)
					group by st.store_name , to_char(o.created_at, 'DD/MM/YYYY'), to_char(o.created_at, 'Month')
					order by to_char(o.created_at, 'Month'), to_char(o.created_at, 'DD/MM/YYYY') ASC;
            RETURN ref;                               -- Return the cursor to the caller

        end if;
	

    else

            if _report_name = 'production' then

        OPEN ref FOR 
        SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name,  sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status, o.total_amount,ol.row, null as bin
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id;
        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'sahyadrifarmproduct' then

            OPEN ref FOR 
                SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name,  sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status, ol.bin
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id;
       		RETURN ref;                               -- Return the cursor to the caller
		
		elsif _report_name = 'delivery' then

            OPEN ref FOR 
                SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name,  sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status,o.total_amount,  null as row, ol.bin 
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
            WHERE o.status_id = '40ec4239-049d-11eb-bbea-1731d3e77846';

        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'neworder' then

            OPEN ref FOR 
                SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name,  sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status, o.total_amount, ol.row, ol.rack ,ol.bin
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
				where o.status_id = '40ec4234-049d-11eb-bbea-6f57fab5c428';
            RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'categorywisesales' then

            OPEN ref FOR 
                SELECT o.order_id, o.order_no, o.created_at, ad.first_name, ad.last_name, ad.mobile, ad.email,
                st.store_name,  sa.line_2, ol.sku, ol.item_name, ol.varients, ol.quantity, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                s.status_name, o.payment_status, null as row, null as bin
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id;
            RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'all_orders' then

            OPEN ref FOR 
                select o.order_id, o.order_no, ad.mobile, o.total_amount, o.created_at, st.store_name,  sa.line_2,
                ch.channel, o.payment_method, o.reason, s.status_name,
                ol.item_name, ol.item_id, ol.varients, ol.row, ol.rack, ol.bin,
				ol.discount_amount, o.delivery_charges, pt.amount, 
				concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
				pt.packaging_type
                from masterdata.order_lines ol
                join masterdata.orders o on ol.cart_id = o.cart_id
                LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                LEFT outer join masterdata.channels ch on o.channel_id = ch.channel_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id;
            RETURN ref;                               -- Return the cursor to the caller    
        
        
        elsif _report_name = 'customer' then

            OPEN ref FOR 
                select c.customer_id, c.first_name, c.last_name, c.email, c.mobile,
                    ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode
                from masterdata.customers c
                LEFT outer JOIN masterdata.addresses ad on c.customer_id = ad.customer_id
                WHERE c.magento_customer_id is not null;
            RETURN ref;                               -- Return the cursor to the caller
        
        
        elsif _report_name = 'bulk_varient' then

            OPEN ref FOR 
                select ol.item_name, ol.item_id, st.store_name, st.plant_code, ol.varients, ol.sku,
                    ol.price, ol.special_price, ol.quantity, ol.row, ol.rack, ol.bin, ol.ean
                    from masterdata.order_lines ol
                    join masterdata.orders o on o.cart_id = ol.cart_id
                    LEFT outer join masterdata.stores st on o.store_id = st.store_id;
            RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'vehicle_plan' then

            OPEN ref FOR 
                SELECT o.order_no, ad.first_name, ad.last_name, ad.mobile, null as area_name, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                null as sextor, null as crates , null as boxws
                from masterdata.orders o
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id;

        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'vehicle_wise_dispatch_verification' then

            OPEN ref FOR 
                SELECT o.order_no, ad.first_name, ad.last_name, ad.mobile, st.store_name,  sa.line_2, st.zone, null as veh, pt.packaging_type,
                concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address
                from masterdata.orders o
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                LEFT outer join masterdata.stores st on o.store_id = st.store_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
                LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id;

        RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'wing_wise_dispatch_verification' then

            OPEN ref FOR 
                SELECT o.order_no, ad.first_name, ad.last_name, 
                    concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address,
                    pt.packaging_type, ol.item_name, ol.varients, ol.quantity, o.total_amount, ad.city
                from masterdata.order_lines ol
                join masterdata.orders o on o.cart_id = ol.cart_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id;
            RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'WMS_upload_format' then

            OPEN ref FOR 
                SELECT o.payment_method, ad.latitude, ad.longitude, 
                    concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as shipping_address, o.delivery_charges,
                    ad.first_name, ad.last_name, o.total_amount
                from masterdata.order_lines ol
                join masterdata.orders o on o.cart_id = ol.cart_id
                LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
                left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id;
            RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'customer_order' then

            OPEN ref FOR 
                SELECT ch.channel, c.first_name, c.last_name, c.customer_id,
                count(o.order_id)
                from masterdata.customers c
                join masterdata.orders o on c.customer_id = o.customer_id
                LEFT outer join masterdata.channels ch on o.channel_id = ch.channel_id
                WHERE magento_customer_id is not null group by ch.channel, c.customer_id;
            RETURN ref;                               -- Return the cursor to the caller

        elsif _report_name = 'product_master' then

            OPEN ref FOR 
                SELECT ol.category_id, ol.category_name, ol.sub_category_id, ol.sub_category_name, ol.item_name, 
                    ol.sku, ol.hsn, ol.ean, ol.price, ol.special_price, ol.weight, ol.gst, ol.item_description,
                    ol.short_description, ol.unit_of_measure, ol.item_id, ol.item_status
                from masterdata.order_lines ol;
            RETURN ref;                               -- Return the cursor to the caller
			
		elsif _report_name = 'daily_oms' then

            OPEN ref FOR 
                SELECT st.store_name, count(o.order_id) , to_char(o.created_at, 'DD/MM/YYYY'), to_char(o.created_at, 'Month') AS Month
					from masterdata.orders o join masterdata.stores st on o.store_id = st.store_id  
					group by st.store_name , to_char(o.created_at, 'DD/MM/YYYY'), to_char(o.created_at, 'Month') 
					order by to_char(o.created_at, 'Month'), to_char(o.created_at, 'DD/MM/YYYY') ASC;
            RETURN ref;                               -- Return the cursor to the caller

        end if;

    end if;

    END;
$$;
 f   DROP FUNCTION masterdata.get_reports(_from_date date, _to_date date, _report_name character varying);
    
   masterdata          sahyadri    false    9            "           1255    16491    get_role(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_role(_role_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'rolerefcursor';

	BEGIN
        
        OPEN ref FOR 

            select role_id, role_name, is_active
			from masterdata.roles
            
            where role_id = _role_id;

        RETURN ref;
                                           
	  
    END;
$$;
 2   DROP FUNCTION masterdata.get_role(_role_id uuid);
    
   masterdata          sahyadri    false    9            #           1255    16492    get_roles()    FUNCTION     ]  CREATE FUNCTION masterdata.get_roles() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'rolesrefcursor';

	BEGIN
        
        OPEN ref FOR 

            select role_id, role_name, is_active
			from masterdata.roles;

        RETURN ref;
                                           
	  
    END;
$$;
 &   DROP FUNCTION masterdata.get_roles();
    
   masterdata          sahyadri    false    9                        1255    16493    get_screens()    FUNCTION        CREATE FUNCTION masterdata.get_screens() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'screensrefcursor';
	BEGIN

    OPEN ref FOR 

    SELECT screen_id, screen_name, is_active
    FROM masterdata.screens;

    RETURN ref;

    END;
$$;
 (   DROP FUNCTION masterdata.get_screens();
    
   masterdata          sahyadri    false    9            %           1255    16494    get_slots(uuid)    FUNCTION     t  CREATE FUNCTION masterdata.get_slots(_store_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
         
         ref1 refcursor default 'monthslotsrefcursor'; 
         ref2 refcursor default 'dayslotsrefcursor'; 
         ref3 refcursor default 'timeslotsrefcursor'; 
         
    BEGIN
        
        
        OPEN ref1 FOR SELECT month_slot_id, month, is_active from masterdata.month_slots where store_id = _store_id; -- open cursor
        RETURN NEXT ref1;

        OPEN ref2 FOR SELECT month_slot_id, day_slot_id, day, open_time, close_time, is_active from masterdata.day_slots where month_slot_id in (select month_slot_id from masterdata.month_slots where store_id = _store_id) ; -- open cursor
        RETURN NEXT ref2;

        OPEN ref3 FOR SELECT day_slot_id, time_slot_id , start_slot_time , end_slot_time , slot_limit, slot_current_orders, is_active from masterdata.time_slots where day_slot_id in (select day_slot_id from masterdata.day_slots where month_slot_id in (select month_slot_id from masterdata.month_slots where store_id = _store_id)); -- open cursor
        RETURN NEXT ref3;

    END;
$$;
 4   DROP FUNCTION masterdata.get_slots(_store_id uuid);
    
   masterdata          sahyadri    false    9                       1255    16495    get_statuses()    FUNCTION     }  CREATE FUNCTION masterdata.get_statuses() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
         ref refcursor default 'statusrefcursor'; 
    BEGIN
      OPEN ref FOR SELECT st.status_id, st.status_name FROM 
	  masterdata.status st WHERE 
	  st.is_active = true;
      RETURN ref;                               -- Return the cursor to the caller
    END;
$$;
 )   DROP FUNCTION masterdata.get_statuses();
    
   masterdata          sahyadri    false    9                       1255    16496    get_store(uuid)    FUNCTION       CREATE FUNCTION masterdata.get_store(_store_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref1 refcursor default 'storerefcursor'; 
        ref2 refcursor default 'pincoderefcursor';
		ref3 refcursor default 'latlongrefcursor';

    BEGIN

        OPEN ref1 FOR 
        SELECT s.store_id, s.store_name, s.plant_code, s.ds_code, s.phone_no, s.is_cc_enabled, s.is_sfs_enabled,a.address_id, a.line_1, a.line_2,
             a.street, a.city, a.state, a.country, a.pincode, s.is_active, s.zone
        FROM masterdata.stores s JOIN masterdata.addresses a 
        ON a.store_id = s.store_id
        WHERE s.store_id = _store_id;
        RETURN next ref1;                               -- Return the cursor to the caller

        OPEN ref2 FOR
        SELECT pincode from masterdata.serviceable_pincodes WHERE store_id = _store_id;
        RETURN next ref2;
		
		OPEN ref3 FOR
        SELECT lat_longs from masterdata.serviceable_pincodes WHERE store_id = _store_id;
        RETURN next ref3;
    
    END;
$$;
 4   DROP FUNCTION masterdata.get_store(_store_id uuid);
    
   masterdata          sahyadri    false    9            A           1255    16497    get_stores()    FUNCTION     �  CREATE FUNCTION masterdata.get_stores() RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref1 refcursor default 'storesrefcursor'; 
		ref2 refcursor default 'pincoderefcursor';
		ref3 refcursor default 'latlongrefcursor';
    BEGIN
      OPEN ref1 FOR 
      SELECT s.store_id, s.store_name, s.plant_code, s.ds_code, s.phone_no, s.is_cc_enabled, s.is_sfs_enabled, a.address_id, a.line_1, a.line_2,
             a.street, a.city, a.state, a.country, a.pincode, s.is_active, s.zone from masterdata.stores s JOIN masterdata.addresses a on a.store_id = s.store_id;
      RETURN next ref1;                               -- Return the cursor to the caller
	  
	    OPEN ref2 FOR
        SELECT store_id,cast(pincode as varchar) from masterdata.serviceable_pincodes;
        RETURN next ref2;
		
		OPEN ref3 FOR
        SELECT store_id,lat_longs from masterdata.serviceable_pincodes;
        RETURN next ref3;
      
    END;
$$;
 '   DROP FUNCTION masterdata.get_stores();
    
   masterdata          sahyadri    false    9            $           1255    16498    get_subscribed_users(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_subscribed_users(_customer_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'subscribedusersrefcursor';

	BEGIN
        
        OPEN ref FOR 

            select customer_id, subscription_id, delivery_option_id, frequency_id
			from masterdata.user_subscriptions
            where customer_id = _customer_id;

        RETURN ref;
                                           
	  
    END;
$$;
 B   DROP FUNCTION masterdata.get_subscribed_users(_customer_id uuid);
    
   masterdata          sahyadri    false    9            &           1255    16499    get_subscription(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_subscription(_subscription_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'subscriptionrefcursor'; 

    BEGIN

        OPEN ref FOR 

        SELECT subscription_id, subscription_type, subscription_period, is_active
        from masterdata.subscriptions
        where subscription_id = _subscription_id;

        RETURN ref;                               -- Return the cursor to the caller
    
    END;
$$;
 B   DROP FUNCTION masterdata.get_subscription(_subscription_id uuid);
    
   masterdata          sahyadri    false    9            *           1255    16500    get_subscriptions()    FUNCTION     �  CREATE FUNCTION masterdata.get_subscriptions() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'subscriptionsrefcursor'; 
    BEGIN
      OPEN ref FOR 

      SELECT subscription_id, subscription_type, subscription_period, is_active
      from masterdata.subscriptions;
      
      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 .   DROP FUNCTION masterdata.get_subscriptions();
    
   masterdata          sahyadri    false    9            )           1255    16501    get_user_carts()    FUNCTION     �  CREATE FUNCTION masterdata.get_user_carts() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'usercartsrefcursor'; 
    BEGIN      
    
      OPEN ref FOR 

        SELECT ct.cart_id, ct.customer_id, ct.cart_amount, ct.discount_type, ct.discount_amount, 
                ct.coupon_code, ct.is_guest_cart, ct.is_paid, c.first_name
        from masterdata.carts ct JOIN masterdata.customers c
        on ct.customer_id = c.customer_id

        WHERE c.magento_customer_id is not null AND ct.cart_amount != 0;

      RETURN ref;        -- Return the cursor to the caller	            
      
    END;
$$;
 +   DROP FUNCTION masterdata.get_user_carts();
    
   masterdata          sahyadri    false    9            '           1255    16502    get_wallet_balance(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_wallet_balance(_customer_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	 __customer_id uuid;
     __wallet_id uuid;
     __wallet_amount numeric;

	BEGIN

		select customer_id into __customer_id from masterdata.customers where customer_id = _customer_id and is_active = true and magento_customer_id is NOT NULL;

		if __customer_id is not null then 
				
			select wallet_id into __wallet_id from masterdata.wallets where customer_id = __customer_id and is_active = true;
				
			if __wallet_id is not null then

                SELECT wallet_amount into __wallet_amount from masterdata.wallets where wallet_id = __wallet_id;

                return __wallet_amount;

            ELSE

                return 'invalid_wallet';

            end if;                          

        ELSE

            RETURN 'invalid_customer_id';

        end if;			
				
	EXCEPTION WHEN others THEN
	  	insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.get_wallet_balance', SQLSTATE, SQLERRM, _customer_id, _amount);
	RETURN 'failure';
    END;
$$;
 @   DROP FUNCTION masterdata.get_wallet_balance(_customer_id uuid);
    
   masterdata          sahyadri    false    9            E           1255    16503    get_wallet_transactions(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_wallet_transactions(_customer_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
Declare
     ref1 refcursor default 'amountrefcursor';
     ref2 refcursor default 'transactionsrefcursor';
	 __customer_id uuid;
     __wallet_id uuid;
     __wallet_amount numeric;

	BEGIN

		select customer_id into __customer_id from masterdata.customers where customer_id = _customer_id and is_active = true and magento_customer_id is NOT NULL;

		if __customer_id is not null then 
				
			select wallet_id into __wallet_id from masterdata.wallets where customer_id = __customer_id and is_active = true;
				
			if __wallet_id is not null then

                OPEN ref1 FOR
                SELECT wallet_amount FROM masterdata.wallets WHERE wallet_id = __wallet_id;
                RETURN NEXT ref1;

                OPEN ref2 FOR
                SELECT  transaction_id, amount, is_debit, is_credit, created_at from masterdata.wallet_transactions where wallet_id = __wallet_id;
                return NEXT ref2;

            ELSE

                OPEN ref1 FOR SELECT null as customer_id;
				return next ref1;
				OPEN ref2 FOR SELECT null as wallet_id;
				return next ref2;
				
            end if;                          

        ELSE

            OPEN ref1 FOR SELECT null as customer_id;
			return next ref1;
			OPEN ref2 FOR SELECT null as wallet_id;
			return next ref2;

        end if;			
				
    END;
$$;
 E   DROP FUNCTION masterdata.get_wallet_transactions(_customer_id uuid);
    
   masterdata          sahyadri    false    9            J           1255    16504 +   login(character varying, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.login(_email character varying, _password character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	  __email character varying;
	  __password character varying;
	  __role_id uuid;
	  __role_name character varying;
	  __user_status character varying;
      __store_status character varying;
      __store_id uuid[];
	  __store_length integer;
	  __user_store_id uuid;
	BEGIN

        select email, password, role_id, is_active, store_id into __email, __password, __role_id, __user_status, __store_id from masterdata.oms_users
        where email = _email;

            
        __store_length = array_length(__store_id, 1);

        if __store_length = 1 THEN

            SELECT __store_id[1] into __user_store_id from masterdata.oms_users;

            select is_active into __store_status from masterdata.stores
                where store_id = __user_store_id;
        
        ELSE

            __store_status = true;

		end if;
		
		select role_name into __role_name from masterdata.roles where role_id = __role_id;

        if __password = _password then
            
			RETURN CONCAT('true',',',_email,',',__role_id,',',__role_name,',',__user_status,',',__store_status);
			
        else
            RETURN CONCAT('false',',',_email,',',__role_id,',',__role_name,',',__user_status,',',__store_status);
			
        end if;                                              
	  
    END;
$$;
 W   DROP FUNCTION masterdata.login(_email character varying, _password character varying);
    
   masterdata          sahyadri    false    9            i           1255    16505 b   merge_cart(uuid, bigint, character varying, character varying, bigint, character varying, numeric)    FUNCTION     Q	  CREATE FUNCTION masterdata.merge_cart(_cart_id uuid, _store_id bigint, _first_name character varying, _last_name character varying, _magento_customer_id bigint, _email character varying, _mobile numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
		 __customer_id uuid;
		 __existing_customer_id uuid;
		 __existing_cart_id uuid;
		 __total_price numeric;
		 __delivery_charges numeric;
    
    BEGIN
	
	
		SELECT customer_id into __existing_customer_id from masterdata.customers where magento_customer_id = _magento_customer_id;
		
		if __existing_customer_id is not null then 
			
			select cart_id into __existing_cart_id from masterdata.carts where customer_id = __existing_customer_id;
			
			SELECT SUM(total_price) into __total_price from masterdata.cart_lines where cart_id = _cart_id;
			
			select delivery_charges into __delivery_charges from masterdata.carts where cart_id = __existing_cart_id;
			
			UPDATE masterdata.cart_lines
			SET cart_id = __existing_cart_id
			WHERE cart_id = _cart_id;
			
			UPDATE masterdata.carts SET cart_amount = cart_amount + __total_price WHERE cart_id = __existing_cart_id;
			
			UPDATE masterdata.carts SET sub_total = cart_amount - __delivery_charges WHERE cart_id = __existing_cart_id;
			
			DELETE from masterdata.carts where cart_id = _cart_id;
			
			return 'merge_successful';
			
			
		else
		
			select customer_id into __customer_id from masterdata.carts where cart_id = _cart_id and is_active = true;

			if __customer_id is not null then

	--             select customer_id from masterdata.customers where customer_id = __customer_id and is_active = true;

				UPDATE masterdata.customers
				SET store_id = _store_id, 
					first_name = _first_name,
					last_name = _last_name,                 
					magento_customer_id = _magento_customer_id, 
					email = _email, 
					mobile = _mobile
				WHERE customer_id = __customer_id;

				UPDATE masterdata.carts 
				SET is_guest_cart = FALSE
				WHERE customer_id =  __customer_id;

				return 'merge_successful';

			else 

				return 'invalid_cart_id';

			end if;
			
		end if;
		
		EXCEPTION WHEN others THEN
	  	insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.merge_cart', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _cart_id);
			RETURN 'failure';

    END;
$$;
 �   DROP FUNCTION masterdata.merge_cart(_cart_id uuid, _store_id bigint, _first_name character varying, _last_name character varying, _magento_customer_id bigint, _email character varying, _mobile numeric);
    
   masterdata          sahyadri    false    9            e           1255    17355 6   multiple_order_update(uuid, uuid[], character varying)    FUNCTION     �  CREATE FUNCTION masterdata.multiple_order_update(_status_id uuid, _order_id uuid[], _reason character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
    __order_id uuid;
    __status_id uuid;
    __status_name character varying;
	__orders_counter bigint;
	__order_id_length bigint;

	BEGIN

        select status_id,status_name into __status_id,__status_name from masterdata.status where status_id = _status_id;
		
		if __status_id is not null then
		        
            FOREACH __order_id in array _order_id
            LOOP

            UPDATE masterdata.orders
            SET status_id = _status_id,
                updated_at = CURRENT_TIMESTAMP,
                status_history = concat(status_history,'||', __status_name,'@',CURRENT_TIMESTAMP),
				reason = _reason
            WHERE order_id = __order_id;

            End LOOP;  
			
		else 
			
			return 'Invalid_status_id';
		
		end if;
		
		return 'Successfully_updated';
	  
    END;
$$;
 n   DROP FUNCTION masterdata.multiple_order_update(_status_id uuid, _order_id uuid[], _reason character varying);
    
   masterdata          sahyadri    false    9            (           1255    16506    oms_user_filter(date, date)    FUNCTION     {  CREATE FUNCTION masterdata.oms_user_filter(_from_date date, _to_date date) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
		__store_id uuid;
        ref refcursor default 'omsusersrefcursor';

	BEGIN
       
		OPEN ref FOR
		
		select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
			s.store_name, r.role_name
		from masterdata.oms_users u 
		left join masterdata.stores s on u.store_id = s.store_id 
		join masterdata.roles r on u.role_id = r.role_id
        
        WHERE u.created_at::date BETWEEN _from_date AND _to_date;
		
		RETURN ref;

    END;
$$;
 J   DROP FUNCTION masterdata.oms_user_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            +           1255    16507    order_filter(date, date, uuid)    FUNCTION     �  CREATE FUNCTION masterdata.order_filter(_from_date date, _to_date date, _status_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'orderfilterrefcursor';
        -- ref refcursor default 'itemsrefcursor';

	BEGIN

        if _status_id is not null and _from_date is not null and _to_date is not null then
            
            OPEN ref FOR 
            select o.order_no, o.created_at, ad.first_name, ad.last_name, o.payment_method, s.status_name,
                    ol.item_name, ol.quantity, ad.customer_id,  ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country,
                    coalesce(pt.packaging_type, 'nil') as packaging_type, ol.sku, ol.varients, ol.row, ol.rack, ol.bin
            from masterdata.order_lines ol
            join masterdata.orders o on ol.cart_id = o.cart_id
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT outer JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
            LEFT outer join masterdata.carts c on ol.cart_id = c.cart_id
			left outer join masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
            WHERE o.status_id = _status_id and o.created_at::date BETWEEN _from_date AND _to_date ORDER BY o.created_at desc;
            RETURN ref;

        elsif _status_id is null and _from_date is not null and _to_date is not null then

            OPEN ref FOR 
            select o.order_no, o.created_at, ad.first_name, ad.last_name, o.payment_method, s.status_name,
                    ol.item_name, ol.quantity, ad.customer_id, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country,
                   	coalesce(pt.packaging_type, 'nil') as packaging_type, ol.sku, ol.varients, ol.row, ol.rack, ol.bin
            from masterdata.order_lines ol
            join masterdata.orders o on ol.cart_id = o.cart_id
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT JOIN masterdata.addresses ad on ad.address_id = o.billing_address_id
            LEFT outer join masterdata.carts c on ol.cart_id = c.cart_id
			LEFT OUTER JOIN masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
            WHERE o.created_at::date BETWEEN _from_date AND _to_date ORDER BY o.created_at desc;
            RETURN ref;
			
		else
		
		    OPEN ref FOR 
            select o.order_no, o.created_at, ad.first_name, ad.last_name, o.payment_method, s.status_name,
                    ol.item_name, ol.quantity, ad.customer_id, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country,
                   	coalesce(pt.packaging_type, 'nil') as packaging_type, ol.sku, ol.varients, ol.row, ol.rack, ol.bin
            from masterdata.order_lines ol
            join masterdata.orders o on ol.cart_id = o.cart_id
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT JOIN masterdata.addresses ad on ad.address_id = o.billing_address_id
            LEFT outer join masterdata.carts c on ol.cart_id = c.cart_id
			LEFT OUTER JOIN masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id;
            RETURN ref;
		
        end if;
    END;
$$;
 X   DROP FUNCTION masterdata.order_filter(_from_date date, _to_date date, _status_id uuid);
    
   masterdata          sahyadri    false    9            .           1255    16508 %   rating_and_reviews_filter(date, date)    FUNCTION     "  CREATE FUNCTION masterdata.rating_and_reviews_filter(_from_date date, _to_date date) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'ratingreviewrefcursor';
	BEGIN

    OPEN ref FOR 
    SELECT o.order_id, o.rating, o.review, c.customer_id, c.first_name, c.last_name
    FROM masterdata.orders o JOIN masterdata.customers c on o.customer_id = c.customer_id
    WHERE o.rating is not null or o.review is not null and o.created_at::date BETWEEN _from_date AND _to_date;
    RETURN ref;

    END;
$$;
 T   DROP FUNCTION masterdata.rating_and_reviews_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            Q           1255    16509 *   remove_item(uuid, uuid, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.remove_item(_customer_id uuid, _cart_id uuid, _item_id character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
		 __cart_id uuid;
		 __price numeric;
		 __item_id uuid;
		 __existing_delivery_charges numeric;
		 __delivery_charges numeric;
		 __cart_amount numeric;
		 __sub_total numeric;
		 __existing_packaging_amount numeric;
    
    BEGIN
		
	if _customer_id is not null and _cart_id is null then 
    -- Logged In User

        select cart_id into __cart_id from masterdata.carts where customer_id = _customer_id and is_active = true;

        if _item_id is not null then

			SELECT total_price into __price from masterdata.cart_lines where item_id = _item_id and cart_id = __cart_id;
			
			UPDATE masterdata.carts
			SET cart_amount = cart_amount - __price,
				sub_total = sub_total - __price
			where cart_id = __cart_id;
			
-- 			select c.delivery_charges, c.cart_amount,c.sub_total, p.amount into __existing_delivery_charges, __cart_amount, __sub_total, __existing_packaging_amount from masterdata.carts c 
-- 					inner join masterdata.packaging_types p on p.packaging_type_id = c.packaging_type_id where c.cart_id = __cart_id;

			select delivery_charges, cart_amount, sub_total into __existing_delivery_charges, __cart_amount, __sub_total from masterdata.carts
 					where cart_id = __cart_id;
					
 			select coalesce(p.amount,0.00) into __existing_packaging_amount from masterdata.packaging_types p 
 				join masterdata.carts c on p.packaging_type_id = c.packaging_type_id where c.cart_id = __cart_id;

			if __sub_total = 0.00 then 
					
				UPDATE masterdata.carts
				SET cart_amount = 0.00,
					delivery_charges = 0.00
				where cart_id = __cart_id;
			end if;
				
				
			SELECT amount into __delivery_charges from masterdata.delivery_charges
				where __sub_total between min_cart_value AND max_cart_value;
						
			if __delivery_charges is not null THEN
			
               	UPDATE masterdata.carts 
                SET cart_amount = cart_amount - __existing_delivery_charges + __delivery_charges,
                    delivery_charges = __delivery_charges
                where cart_id = __cart_id;
						
			elsif __delivery_charges is null THEN
			
				UPDATE masterdata.carts 
                set cart_amount = cart_amount - __existing_delivery_charges,
                    delivery_charges = 0.00
                where cart_id = __cart_id;

            end if;

-- 				if __delivery_charges is not null THEN

-- 					UPDATE masterdata.carts 
-- 					set cart_amount = cart_amount - __existing_delivery_charges + __delivery_charges,
-- 						delivery_charges = __delivery_charges
-- 					where cart_id = __cart_id;

-- 				elsif __delivery_charges is null and __existing_delivery_charges is not null then

-- 					UPDATE masterdata.carts 
-- 					set cart_amount = cart_amount -__existing_delivery_charges,
-- 						delivery_charges = 0.00
-- 					where cart_id = __cart_id;

-- 				elsif __delivery_charges is not null and __existing_delivery_charges is null then

-- 					UPDATE masterdata.carts 
-- 					set cart_amount = cart_amount +__delivery_charges,
-- 						delivery_charges = __delivery_charges
-- 					where cart_id = __cart_id;

-- 				end if;
			
-- 			UPDATE masterdata.carts
-- 			SET sub_total = sub_total - __price
-- 			where cart_id = _cart_id;
			
            DELETE from masterdata.cart_lines where item_id = _item_id and cart_id = __cart_id;
				
        else 

            DELETE from masterdata.cart_lines where cart_id = __cart_id;
			UPDATE masterdata.carts
			SET cart_amount = 0.00,
				sub_total = 0.00,
				delivery_charges = 0.00
			where cart_id = __cart_id;
			
		end if;

        return 'items_removed_successfully';

    elsif _cart_id is not null then
    -- Guest User
	
        if _item_id is not null then
		
		
			SELECT total_price into __price from masterdata.cart_lines where item_id = _item_id and cart_id = _cart_id;
			
			UPDATE masterdata.carts
			SET cart_amount = cart_amount - __price,
				sub_total = sub_total - __price
			where cart_id = _cart_id;
			
-- 			select c.delivery_charges, c.cart_amount,c.sub_total, p.amount into __existing_delivery_charges, __cart_amount, __sub_total, __existing_packaging_amount from masterdata.carts c 
-- 					inner join masterdata.packaging_types p on p.packaging_type_id = c.packaging_type_id where c.cart_id = __cart_id;

			select delivery_charges, cart_amount, sub_total into __existing_delivery_charges, __cart_amount, __sub_total from masterdata.carts
 					where cart_id = __cart_id;
					
 			select coalesce(p.amount,0.00) into __existing_packaging_amount from masterdata.packaging_types p 
 				join masterdata.carts c on p.packaging_type_id = c.packaging_type_id where c.cart_id = __cart_id;

					
			if __sub_total = 0.00 then 
					
				UPDATE masterdata.carts
				SET cart_amount = 0.00,
					delivery_charges = 0.00
				where cart_id = __cart_id;
					
			end if;
				
				
			SELECT amount into __delivery_charges from masterdata.delivery_charges
				where __sub_total between min_cart_value AND max_cart_value;
						
			if __delivery_charges is not null THEN
			
               	UPDATE masterdata.carts 
                SET cart_amount = cart_amount - __existing_delivery_charges + __delivery_charges,
                    delivery_charges = __delivery_charges
                where cart_id = __cart_id;
						
			elsif __delivery_charges is null THEN
			
				UPDATE masterdata.carts 
                set cart_amount = cart_amount - __existing_delivery_charges,
                    delivery_charges = 0.00
                where cart_id = __cart_id;

            end if;
				

-- 				elsif __sub_total != 0.00 and __delivery_charges is not null and __existing_delivery_charges is not null THEN

-- 					UPDATE masterdata.carts 
-- 					set cart_amount = cart_amount - __existing_delivery_charges + __delivery_charges,
-- 						delivery_charges = __delivery_charges
-- 					where cart_id = __cart_id;

-- 				elsif __sub_total != 0.00 and __delivery_charges is null and __existing_delivery_charges is not null then

-- 					UPDATE masterdata.carts 
-- 					set cart_amount = cart_amount -__existing_delivery_charges,
-- 						delivery_charges = 0.00
-- 					where cart_id = __cart_id;

-- 				elsif __sub_total != 0.00 and __delivery_charges is not null and __existing_delivery_charges is null then

-- 					UPDATE masterdata.carts 
-- 					set cart_amount = cart_amount +__delivery_charges,
-- 						delivery_charges = __delivery_charges
-- 					where cart_id = __cart_id;

-- 				end if;
			
-- 			UPDATE masterdata.carts
-- 			SET sub_total = sub_total - __price
-- 			where cart_id = _cart_id;
			

            DELETE from masterdata.cart_lines where item_id = _item_id and cart_id = _cart_id;

        else 

            DELETE from masterdata.cart_lines where cart_id = _cart_id;
			UPDATE masterdata.carts
			SET cart_amount = 0.00,
				sub_total = 0.00,
				delivery_charges = 0.00
			where cart_id = _cart_id;

        end if;

        return 'items_removed_successfully';

	else
		
		return 'invalid_cart_id';
		
	end if;
    END;
$$;
 d   DROP FUNCTION masterdata.remove_item(_customer_id uuid, _cart_id uuid, _item_id character varying);
    
   masterdata          sahyadri    false    9            r           1255    17744 *   remove_order_item(uuid, character varying)    FUNCTION     
  CREATE FUNCTION masterdata.remove_order_item(_order_id uuid, _item_id character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
		 __order_part_id uuid;
		 __price numeric;
		 __item_id uuid;
         __cart_id uuid;
		 __order_id uuid;
		 __existing_delivery_charges numeric;
		 __sub_total numeric;
		 __delivery_charges numeric;
		 __total_amount numeric;
		 __order_type character varying;
    
    BEGIN

        select cart_id, order_id into __cart_id, __order_id from masterdata.orders where order_id = _order_id;

        select order_part_id INTO __order_part_id from masterdata.order_lines where cart_id = __cart_id;
		
		select order_type into __order_type from masterdata.order_parts where order_id = _order_id;
		
		if __order_id is not null then

        if _item_id is not null then

			SELECT total_price into __price from masterdata.order_lines where item_id = _item_id and order_part_id = __order_part_id;
			
			UPDATE masterdata.orders
			SET total_amount = total_amount - __price,
				sub_total = sub_total - __price
			where order_id = _order_id;
			
				-- if __order_type = 'SFS' then

					select delivery_charges, total_amount, sub_total into __existing_delivery_charges, __total_amount, __sub_total
					from masterdata.orders where order_id = _order_id;

					SELECT amount into __delivery_charges from masterdata.delivery_charges
                        where __sub_total BETWEEN min_cart_value AND max_cart_value;
						
						
					if __delivery_charges is not null THEN
                        UPDATE masterdata.orders 
                        set total_amount = total_amount - __existing_delivery_charges + __delivery_charges,				
                            delivery_charges = __delivery_charges
                        where order_id = _order_id;
						
					else
						UPDATE masterdata.orders 
                        set total_amount = total_amount - __existing_delivery_charges,
                            delivery_charges = 0.00
                        where order_id = _order_id;
						
                    end if;
					
				-- end if;
			
            DELETE from masterdata.order_lines where item_id = _item_id and order_part_id = __order_part_id;
				
        else 

            DELETE from masterdata.order_lines where order_part_id = __order_part_id;
			UPDATE masterdata.orders
			SET total_amount = 0,
				sub_total = 0,
				packaging_type_id = null
			where order_id = _order_id;
			
		end if;

        return 'items_removed_successfully';
		
		else
		
		return 'invalid_order_id';
		
		end if;

	
    END;
$$;
 X   DROP FUNCTION masterdata.remove_order_item(_order_id uuid, _item_id character varying);
    
   masterdata          sahyadri    false    9            -           1255    16510    roles_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.roles_filter(_from_date date, _to_date date) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'rolesrefcursor';

	BEGIN
        
        OPEN ref FOR 

            select role_id, role_name, is_active
			from masterdata.roles
            WHERE created_at::date BETWEEN _from_date AND _to_date;

        RETURN ref;
                                           
	  
    END;
$$;
 G   DROP FUNCTION masterdata.roles_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            k           1255    17668    sales_entry()    FUNCTION     f  CREATE FUNCTION masterdata.sales_entry() RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref1 refcursor default 'salesentryrefcursor';
        ref2 refcursor default 'detailsrefcursor';
--         ref2 refcursor default 'cashdetailsrefcursor';
--         ref3 refcursor default 'carddetailsrefcursor';
--         ref4 refcursor default 'onlinedetailsrefcursor';
--         ref5 refcursor default 'walletdedetailsrefcursor';
--         ref6 refcursor default 'walletcrdetailsrefcursor';

	BEGIN

        OPEN ref1 FOR 
        select st.plant_code, to_char(now()::date, 'yyyymmdd'), sum(o.total_amount)
        from masterdata.orders o
        JOIN masterdata.stores st on st.store_id = o.store_id
			where (o.created_at between CURRENT_DATE - 1 + '04:00:00.000000'::time AND CURRENT_DATE + '18:00:00.000000'::time)
				and o.payment_status = 'SUCCESS' group by st.plant_code;
        RETURN next ref1;
		
		 OPEN ref2 FOR 
        select st.plant_code, o.payment_method, sum(o.total_amount)
        from masterdata.orders o
        JOIN masterdata.stores st on o.store_id = st.store_id
			where (o.created_at between CURRENT_DATE - 1 + '04:00:00.000000'::time AND CURRENT_DATE + '18:00:00.000000'::time)
				and o.payment_status = 'SUCCESS' group by st.store_id, o.payment_method;
        RETURN next ref2;

--         OPEN ref2 FOR 
--         select sum(o.total_amount), st.plant_code
--         from masterdata.orders o
--         JOIN masterdata.stores st on o.store_id = st.store_id
--         WHERE (o.created_at between CURRENT_DATE - 1 + '21:00:00.000000'::time AND CURRENT_DATE + '21:00:00.000000'::time) 
-- 				 and (o.payment_status = 'SUCCESS') and (o.payment_method = 'CASH_ON_DELIVERY')
--                 group by st.store_id;
--         RETURN next ref2;

        
--         OPEN ref3 FOR 
--         select sum(o.total_amount), st.plant_code
--         from masterdata.orders o
--         JOIN masterdata.stores st on o.store_id = st.store_id
--         WHERE (o.created_at between CURRENT_DATE - 1 + '21:00:00.000000'::time AND CURRENT_DATE + '21:00:00.000000'::time)
-- 			and (o.payment_status = 'SUCCESS') and (o.payment_method = 'CARD_ON_DELIVERY')
-- 				group by st.store_id;
--         RETURN next ref3;        
        
        
--         OPEN ref4 FOR 
--         select sum(o.total_amount), st.plant_code
--         from masterdata.orders o
--         JOIN masterdata.stores st on o.store_id = st.store_id
--         WHERE (o.created_at between CURRENT_DATE - 1 + '21:00:00.000000'::time AND CURRENT_DATE + '21:00:00.000000'::time)
-- 			and (o.payment_status = 'SUCCESS') and (o.payment_method = 'ONLINE_PAYMENT')
--                 group by st.store_id;
--         RETURN next ref4;        
        
        
--         OPEN ref5 FOR 
--         select sum(o.total_amount), st.plant_code
--         from masterdata.orders o
--         JOIN masterdata.stores st on o.store_id = st.store_id
--         WHERE (o.created_at between CURRENT_DATE - 1 + '21:00:00.000000'::time AND CURRENT_DATE + '21:00:00.000000'::time)
-- 				 and (o.payment_status = 'SUCCESS') and (o.payment_method = 'WALLET')
--                 group by st.store_id;
--         RETURN next ref5;

--         OPEN ref6 FOR 
--         select sum(o.total_amount), st.plant_code
--         from masterdata.orders o
--         JOIN masterdata.stores st on o.store_id = st.store_id
--         WHERE (o.created_at between CURRENT_DATE - 1 + '21:00:00.000000'::time AND CURRENT_DATE + '21:00:00.000000'::time)
-- 				 and (o.payment_status = 'SUCCESS') and (o.payment_method = 'WALLET')
--                 group by st.store_id;
--         RETURN next ref6;

    END;
$$;
 (   DROP FUNCTION masterdata.sales_entry();
    
   masterdata          sahyadri    false    9            u           1255    17676    sap_cumulative_order()    FUNCTION     n  CREATE FUNCTION masterdata.sap_cumulative_order() RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref1 refcursor default 'storerefcursor';
        ref2 refcursor default 'itemsrefcursor';

	BEGIN

        OPEN ref1 FOR 
        select distinct to_char(now()::date, 'yyyymmdd'),s.plant_code, o.store_id
        from masterdata.order_lines ol
        join masterdata.orders o on ol.cart_id = o.cart_id
        JOIN masterdata.stores s on o.store_id = s.store_id
        WHERE o.created_at >= CURRENT_DATE - 1 + '18:00:00.000000'::time AND    
                o.created_at <= CURRENT_DATE + '18:00:00.000000'::time;
        RETURN next ref1;
 
        OPEN ref2 FOR 
        select ol.sku, s.plant_code, ol.quantity, ol.unit_of_measure, ol.total_price, o.store_id
        from masterdata.order_lines ol
        join masterdata.orders o on ol.cart_id = o.cart_id
        JOIN masterdata.stores s on o.store_id = s.store_id
       WHERE o.created_at >= CURRENT_DATE - 1 + '18:00:00.000000'::time AND    
                o.created_at <= CURRENT_DATE + '18:00:00.000000'::time;
        RETURN next ref2;

    END;
$$;
 1   DROP FUNCTION masterdata.sap_cumulative_order();
    
   masterdata          sahyadri    false    9            /           1255    16511 ?   search(character varying, character varying, character varying)    FUNCTION     D  CREATE FUNCTION masterdata.search(_screens character varying, _column_name character varying, _search character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'searchrefcursor';
		__search character varying;
		__search_id uuid;

    BEGIN      

		__search = CONCAT('%',trim(_search),'%');

        IF _screens = 'orders' THEN

            IF _column_name = 'order ID' THEN
    
            OPEN ref FOR 
            SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
            ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
            o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time
            FROM masterdata.orders o 
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
            LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
            WHERE o.is_active = true 
                    and o.order_no ilike cast(__search as character varying) ORDER BY o.created_at desc ; -- open cursor
            RETURN ref;

            elsif _column_name = 'order date' THEN

            OPEN ref FOR 
            SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
            ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
            o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time
            FROM masterdata.orders o 
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
            LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
            WHERE o.is_active = true 
                    and o.created_at::date = cast(_search as date) ORDER BY o.created_at desc ; -- open cursor
            RETURN ref;

            elsif _column_name = 'customer Name' THEN

            OPEN ref FOR 
            SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
            ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
            o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time
            FROM masterdata.orders o 
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
            LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
            WHERE ad.first_name ilike __search or 
				ad.last_name ilike __search and o.is_active = true ORDER BY o.created_at desc; -- open cursor
            RETURN ref;

            elsif _column_name = 'payment type' THEN

            OPEN ref FOR 
            SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
            ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
            o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time
            FROM masterdata.orders o 
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
            LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
            WHERE o.is_active = true 
                    and replace(o.payment_method,'_',' ') ilike __search ORDER BY o.created_at desc ; -- open cursor
            RETURN ref;

            elsif _column_name = 'order status' THEN

            OPEN ref FOR 
            SELECT o.order_id, o.order_no, o.total_amount, o.created_at, o.updated_at, s.status_name, 
            ad.first_name, ad.last_name, ad.email, ad.mobile, ad.line_1, ad.line_2, ad.street, ad.city, ad.state, ad.country, ad.pincode, 
            o.payment_method, o.status_history, ts.start_slot_time, ts.end_slot_time
            FROM masterdata.orders o 
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT JOIN masterdata.addresses ad on o.billing_address_id = ad.address_id
            LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
            WHERE o.is_active = true 
                    and s.status_name ilike __search ORDER BY o.created_at desc ; -- open cursor
            RETURN ref;

            else 

                return  NONE;

            END IF;

        elsif _screens = 'customers' THEN

            IF _column_name = 'name' THEN

            OPEN ref FOR 
            SELECT customer_id, store_id, magento_customer_id, first_name, last_name, mobile, email, 
            subscription_id, subscription_start_date, subscription_end_date, frequency_id, delivery_option_id
            from masterdata.customers WHERE magento_customer_id is not Null
                and first_name ilike __search or last_name ilike __search;
            RETURN ref;                                                                -- Return the cursor to the caller

            elsif _column_name = 'Mobile number' THEN

            OPEN ref FOR 
            SELECT customer_id, store_id, magento_customer_id, first_name, last_name, mobile, email, 
            subscription_id, subscription_start_date, subscription_end_date, frequency_id, delivery_option_id
            from masterdata.customers WHERE magento_customer_id is not Null
                and cast(mobile as character varying) ilike __search;
            RETURN ref;  

            elsif _column_name = 'email' THEN

            OPEN ref FOR 
            SELECT customer_id, store_id, magento_customer_id, first_name, last_name, mobile, email, 
            subscription_id, subscription_start_date, subscription_end_date, frequency_id, delivery_option_id
            from masterdata.customers WHERE magento_customer_id is not Null
                and email ilike __search;
            RETURN ref;  

            else 

                return  NONE;

            END IF;

        elsif _screens = 'stores' THEN

            IF _column_name = 'name' THEN

            OPEN ref FOR 
            SELECT s.store_id, s.store_name, s.plant_code, s.ds_code, s.phone_no, s.is_cc_enabled, s.is_sfs_enabled, a.address_id, a.line_1, a.line_2,
            a.street, a.city, a.state, a.country, a.pincode, s.is_active from masterdata.stores s JOIN masterdata.addresses a on a.store_id = s.store_id
            WHERE s.store_name ilike __search;
            RETURN ref;   

            elsif _column_name = 'Mobile number' THEN

            OPEN ref FOR 
            SELECT s.store_id, s.store_name, s.plant_code, s.ds_code, s.phone_no, s.is_cc_enabled, s.is_sfs_enabled, a.address_id, a.line_1, a.line_2,
            a.street, a.city, a.state, a.country, a.pincode, s.is_active from masterdata.stores s JOIN masterdata.addresses a on a.store_id = s.store_id
            WHERE cast(s.phone_no as character varying) ilike __search;
            RETURN ref; 

            elsif _column_name = 'city' THEN

            OPEN ref FOR 
            SELECT s.store_id, s.store_name, s.plant_code, s.ds_code, s.phone_no, s.is_cc_enabled, s.is_sfs_enabled, a.address_id, a.line_1, a.line_2,
            a.street, a.city, a.state, a.country, a.pincode, s.is_active from masterdata.stores s JOIN masterdata.addresses a on a.store_id = s.store_id
            WHERE a.city ilike __search;
            RETURN ref; 

            elsif _column_name = 'state' THEN

            OPEN ref FOR 
            SELECT s.store_id, s.store_name, s.plant_code, s.ds_code, s.phone_no, s.is_cc_enabled, s.is_sfs_enabled, a.address_id, a.line_1, a.line_2,
            a.street, a.city, a.state, a.country, a.pincode, s.is_active from masterdata.stores s JOIN masterdata.addresses a on a.store_id = s.store_id
            WHERE a.state ilike __search;
            RETURN ref;  

            elsif _column_name = 'status' THEN

            OPEN ref FOR 
            SELECT s.store_id, s.store_name, s.plant_code, s.ds_code, s.phone_no, s.is_cc_enabled, s.is_sfs_enabled, a.address_id, a.line_1, a.line_2,
            a.street, a.city, a.state, a.country, a.pincode, s.is_active from masterdata.stores s JOIN masterdata.addresses a on a.store_id = s.store_id
            WHERE s.is_active = cast(_search as boolean);
            RETURN ref;      

            else 

                return  NONE;

            END IF;

        elsif _screens = 'cart' THEN

            IF _column_name = 'customer ID' THEN
        
            OPEN ref FOR 
            SELECT ct.cart_id, ct.customer_id, ct.cart_amount, ct.discount_type, ct.discount_amount, 
                    ct.coupon_code, ct.is_guest_cart, ct.is_paid
            from masterdata.carts ct JOIN masterdata.customers c
            on ct.customer_id = c.customer_id
            WHERE c.magento_customer_id is not null AND ct.cart_amount != 0
                and ct.customer_id = cast(_search as uuid);
            RETURN ref;        -- Return the cursor to the caller

            elsif _column_name = 'customer name' THEN

            OPEN ref FOR 
            SELECT ct.cart_id, ct.customer_id, ct.cart_amount, ct.discount_type, ct.discount_amount, 
                    ct.coupon_code, ct.is_guest_cart, ct.is_paid
            from masterdata.carts ct JOIN masterdata.customers c
            on ct.customer_id = c.customer_id
            WHERE c.magento_customer_id is not null AND ct.cart_amount != 0
                and c.first_name ilike __search or c.last_name ilike __search;
            RETURN ref;        -- Return the cursor to the caller

            elsif _column_name = 'cart amount' THEN

            OPEN ref FOR 
            SELECT ct.cart_id, ct.customer_id, ct.cart_amount, ct.discount_type, ct.discount_amount, 
                    ct.coupon_code, ct.is_guest_cart, ct.is_paid
            from masterdata.carts ct JOIN masterdata.customers c
            on ct.customer_id = c.customer_id
            WHERE c.magento_customer_id is not null AND ct.cart_amount != 0
                and ct.cart_amount = cast(_search as numeric);
            RETURN ref;        -- Return the cursor to the caller

            else 

                return  NONE;

            END IF;  

        elsif _screens = 'roles' THEN

            IF _column_name = 'role' THEN

            OPEN ref FOR 
            select role_id, role_name, is_active
            from masterdata.roles
            WHERE role_name ilike __search;
            RETURN ref;

            elsif _column_name = 'status' THEN

            OPEN ref FOR 
            select role_id, role_name, is_active
            from masterdata.roles
            WHERE is_active = cast(_search as boolean);
            RETURN ref;

            else 

                return  NONE;

            END IF;

        elsif _screens = 'users' THEN

            IF _column_name = 'name' THEN

            OPEN ref FOR
            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
                null, r.role_name
            from masterdata.oms_users u 
--             left join masterdata.stores s on cast(u.store_id as uuid) = cast(s.store_id as uuid) 
            join masterdata.roles r on u.role_id = r.role_id
            where u.first_name ilike __search or u.last_name ilike __search;
            RETURN ref;

            elsif _column_name = 'Mobile number' THEN

            OPEN ref FOR
            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
                null, r.role_name
            from masterdata.oms_users u 
--             left join masterdata.stores s on u.store_id = s.store_id 
            join masterdata.roles r on u.role_id = r.role_id
            where cast(u.mobile as character varying) ilike __search;
            RETURN ref;

            elsif _column_name = 'email' THEN

            OPEN ref FOR
            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
                null, r.role_name
            from masterdata.oms_users u 
--             left join masterdata.stores s on u.store_id = s.store_id 
            join masterdata.roles r on u.role_id = r.role_id
            where  u.email ilike __search;
            RETURN ref;

            elsif _column_name = 'role' THEN

            OPEN ref FOR
            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
                null, r.role_name
            from masterdata.oms_users u 
--             left join masterdata.stores s on u.store_id = s.store_id 
            join masterdata.roles r on u.role_id = r.role_id
            where  r.role_name ilike __search;
            RETURN ref;

            elsif _column_name = 'status' THEN

            OPEN ref FOR
            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
                null, r.role_name
            from masterdata.oms_users u 
--             left join masterdata.stores s on u.store_id = s.store_id 
            join masterdata.roles r on u.role_id = r.role_id
            where  u.is_active = cast(_search as boolean);
            RETURN ref;

            elsif _column_name = 'status' THEN

            OPEN ref FOR
            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
                s.store_name, r.role_name
            from masterdata.oms_users u 
            left join masterdata.stores s on u.store_id = s.store_id 
            join masterdata.roles r on u.role_id = r.role_id
            where  u.is_active = cast(_search as boolean);
            RETURN ref;

            else 

                return  NONE;

            end if;
			
        elsif _screens = 'order_rating_review' THEN

            if _column_name = 'customer_name' THEN

            OPEN ref FOR
            SELECT o.order_id, o.rating, o.review, c.customer_id, c.first_name, c.last_name
            FROM masterdata.orders o JOIN masterdata.customers c on o.customer_id = c.customer_id
            WHERE o.rating is not null and 
                c.first_name ilike __search or c.last_name ilike __search;
            RETURN ref;

            elsif _column_name = 'rating' THEN

            OPEN ref FOR
            SELECT o.order_id, o.rating, o.review, c.customer_id, c.first_name, c.last_name
            FROM masterdata.orders o JOIN masterdata.customers c on o.customer_id = c.customer_id
            WHERE o.rating = cast(_search as integer);   
            RETURN ref;

            ELSE

                return NONE;

            end if;
			
        elsif _screens = 'frequency' THEN

            if _column_name = 'frequency_type' THEN

            OPEN ref FOR
            SELECT frequency_id, frequency, is_active
            from masterdata.frequencies
            WHERE frequency ilike __search;
            RETURN ref;

            elsif _column_name = 'status' THEN

            OPEN ref FOR
            SELECT frequency_id, frequency, is_active
            from masterdata.frequencies
            WHERE is_active = cast(_search as boolean);  
            RETURN ref;

            ELSE

                return NONE;

            end if;

        elsif _screens = 'Delivery option' THEN

            if _column_name = 'Delivery option' THEN

            OPEN ref FOR
            SELECT delivery_option_id, delivery_option, is_active
            from masterdata.delivery_options
            WHERE delivery_option ilike __search;
            RETURN ref;

            elsif _column_name = 'status' THEN

            OPEN ref FOR
            SELECT delivery_option_id, delivery_option, is_active
            from masterdata.delivery_options
            WHERE is_active = cast(_search as boolean);  
            RETURN ref;

            ELSE

                return NONE;

            end if;

        elsif _screens = 'subscription' THEN

            if _column_name = 'subscription type' THEN

            OPEN ref FOR
            SELECT subscription_id, subscription_type, subscription_period, is_active
            from masterdata.subscriptions
            WHERE subscription_type ilike __search;
            RETURN ref;

            elsif _column_name = 'subscription period' THEN

            OPEN ref FOR
            SELECT subscription_id, subscription_type, subscription_period, is_active
            from masterdata.subscriptions
            WHERE subscription_period = cast(_search as integer);   
            RETURN ref;

            elsif _column_name = 'status' THEN

            OPEN ref FOR
            SELECT subscription_id, subscription_type, subscription_period, is_active
            from masterdata.subscriptions
            WHERE is_active = cast(_search as boolean);  
            RETURN ref;

            ELSE

                return NONE;

            end if;

        else 

            return  NONE;
        
    END IF;
      
    END;
$$;
 x   DROP FUNCTION masterdata.search(_screens character varying, _column_name character varying, _search character varying);
    
   masterdata          sahyadri    false    9            z           1255    16513 !   serviceability(bigint, numeric[])    FUNCTION     w  CREATE FUNCTION masterdata.serviceability(_pincode bigint, _lat_longs numeric[]) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __store_id UUID;
		__delivery_point_id UUID;
		__store_status boolean;
		__plant_code bigint;

	BEGIN

        if _pincode is not null then

            select p.store_id, p.delivery_point_id, p.plant_code into __store_id, __delivery_point_id, __plant_code
			from masterdata.serviceable_pincodes p
            where p.pincode = _pincode;

            SELECT is_active into __store_status from masterdata.stores where store_id = __store_id;

            if (__store_id is not null and __store_status = 'true') then

                RETURN CONCAT('true',',',__store_id,',',__delivery_point_id,',',__plant_code);
				
			else
			 	
				return CONCAT('false',',',__delivery_point_id);

            end if; 
			
		elsif (_lat_longs) is not null then
			
 			select p.store_id, p.delivery_point_id, p.plant_code into __store_id, __delivery_point_id, __plant_code
 			from masterdata.serviceable_pincodes p
            where array[lat_longs] @> _lat_longs;
			
            SELECT is_active into __store_status from masterdata.stores where store_id = __store_id;
			
 			if (__store_id is not null and __store_status is true) or __delivery_point_id is not null then  

                 RETURN CONCAT('true',',',__store_id,',',__delivery_point_id,',',__plant_code);
				
 			else
			 	
				return CONCAT('false',',',__delivery_point_id);
				
 			end if; 

        else
		
            RETURN 'pincode_not_available';
        
        end if;                                                  
	  
    END;
$$;
 P   DROP FUNCTION masterdata.serviceability(_pincode bigint, _lat_longs numeric[]);
    
   masterdata          sahyadri    false    9            G           1255    16514    stores_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.stores_filter(_from_date date, _to_date date) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref1 refcursor default 'storesrefcursor';
		ref2 refcursor default 'pincoderefcursor';
		ref3 refcursor default 'latlongrefcursor';
    BEGIN
      	OPEN ref1 FOR 
      	SELECT s.store_id, s.store_name, s.plant_code, s.ds_code, s.phone_no, s.is_cc_enabled, s.is_sfs_enabled, a.address_id, a.line_1, a.line_2,
             a.street, a.city, a.state, a.country, a.pincode, s.is_active, s.zone from masterdata.stores s 
			 JOIN masterdata.addresses a on a.store_id = s.store_id
             where s.created_at::date BETWEEN _from_date AND _to_date;
      	RETURN next ref1;                               -- Return the cursor to the caller
	  
	    OPEN ref2 FOR
        SELECT store_id, cast(pincode as varchar) from masterdata.serviceable_pincodes
		where created_at::date BETWEEN _from_date AND _to_date;
        RETURN next ref2;
		
		OPEN ref3 FOR
        SELECT store_id,lat_longs from masterdata.serviceable_pincodes
		where created_at::date BETWEEN _from_date AND _to_date;
        RETURN next ref3;
      
    END;
$$;
 H   DROP FUNCTION masterdata.stores_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            ,           1255    16515    subscription_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.subscription_filter(_from_date date, _to_date date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'subscriptionrefcursor'; 
    BEGIN
      OPEN ref FOR 
      SELECT subscription_id, subscription_type, subscription_period, is_active
      from masterdata.subscriptions
        WHERE created_at::date BETWEEN _from_date AND _to_date;

      RETURN ref;                               -- Return the cursor to the caller
      
    END;
$$;
 N   DROP FUNCTION masterdata.subscription_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            l           1255    17740    tms_consolidated_orders()    FUNCTION     <  CREATE FUNCTION masterdata.tms_consolidated_orders() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'consolidatedorerrefcursor';

	BEGIN

        OPEN ref FOR 
        select now()::date as date, tracking_code
        from masterdata.order_lines o
        LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
        WHERE o.created_at >= CURRENT_DATE - 1 + '04:00:00.000000'::time AND    
                o.created_at <= CURRENT_DATE + '04:00:00.000000'::time;
        RETURN ref;

    END;
$$;
 4   DROP FUNCTION masterdata.tms_consolidated_orders();
    
   masterdata          sahyadri    false    9            q           1255    17743    tms_order_push(uuid)    FUNCTION     )  CREATE FUNCTION masterdata.tms_order_push(_order_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref1 refcursor default 'tmsorderrefcursor';
        ref2 refcursor default 'tmsitemsrefcursor';

	BEGIN

        OPEN ref1 FOR 
        select o.order_id, o.order_no, now()::date as date, o.payment_method, ad.latitude, ad.longitude,
            concat(ad.line_1,' ', ad.line_2,' ', ad.street,' ', ad.city,' ', ad.state) as address_detail, ad.city,
            ad.mobile, concat(ad.first_name,' ',ad.last_name), o.delivery_charges, ad.line_1, ad.landmark, ad.street, ad.state, ad.pincode
        from masterdata.orders o
        LEFT outer JOIN masterdata.addresses ad on o.shipping_address_id = ad.address_id
        WHERE o.order_id = _order_id;
        RETURN next ref1;
 
        OPEN ref2 FOR 
        select o.order_id, ol.sku, ol.quantity, ol.total_price
        from masterdata.order_lines ol
        join masterdata.orders o on ol.cart_id = o.cart_id
       WHERE o.order_id = _order_id;
        RETURN next ref2;

    END;
$$;
 9   DROP FUNCTION masterdata.tms_order_push(_order_id uuid);
    
   masterdata          sahyadri    false    9            p           1255    17742 $   tms_order_push_status(uuid, boolean)    FUNCTION     T  CREATE FUNCTION masterdata.tms_order_push_status(_order_id uuid, _status boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE

    BEGIN
            
        UPDATE masterdata.orders
        SET is_order_pushed_tms = _status
            WHERE order_id = _order_id;

        RETURN 'updated_successfully';

    END;
$$;
 Q   DROP FUNCTION masterdata.tms_order_push_status(_order_id uuid, _status boolean);
    
   masterdata          sahyadri    false    9            s           1255    17738 �   tms_update_delivery(character varying, timestamp with time zone, character varying, character varying, character varying, boolean, boolean, boolean, numeric, numeric, numeric)    FUNCTION     A  CREATE FUNCTION masterdata.tms_update_delivery(_tracking_code character varying, _delivery_time timestamp with time zone, _delivery_person_name character varying, _poc_name character varying, _delivery_method character varying, _is_cash_od boolean, _is_card_od boolean, _is_online_payment boolean, _amount_collected numeric, _change_collected numeric, _amount_transacted numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __delivery_details_id UUID;
        __order_id uuid;

	BEGIN
		
        INSERT INTO masterdata.delivery_details( tracking_code, delivery_time, delivery_person_name, poc_name, delivery_method, is_cash_od, is_card_od, is_online_payment, amount_collected, change_collected, amount_transacted) 
        values ( _tracking_code, _delivery_time, _delivery_person_name, _poc_name, _delivery_method, _is_cash_od, _is_card_od, _is_online_payment, _amount_collected, _change_collected, _amount_transacted);

        select order_id into __order_id from masterdata.orders where order_no = _tracking_code;

        return __order_id;

    END;
$$;
 {  DROP FUNCTION masterdata.tms_update_delivery(_tracking_code character varying, _delivery_time timestamp with time zone, _delivery_person_name character varying, _poc_name character varying, _delivery_method character varying, _is_cash_od boolean, _is_card_od boolean, _is_online_payment boolean, _amount_collected numeric, _change_collected numeric, _amount_transacted numeric);
    
   masterdata          sahyadri    false    9            h           1255    17145    transactions(date, date)    FUNCTION     X  CREATE FUNCTION masterdata.transactions(_from_date date, _to_date date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'transactionrefcursor'; 
    BEGIN
	
	if _from_date is not null and _to_date is not null then
	
      OPEN ref FOR 
            select cm.customer_id, cm.first_name, cm.last_name, cm.mobile, cm.email, o.order_no, st.store_name,
                ol.price, pt.amount, o.delivery_charges, o.total_amount, w.amount, o.created_at, 'FULL' as payment_type,				 
				o.payment_method, ch.channel, 
				(case when o.is_paid is true then 'Paid' ELSE 'Not Paid' END) as status, 
				s.status_name, st.area_name, ol.sku, ol.item_name, ol.quantity,
                concat(ad.line_1,' ', ad.line_2, ' ',ad.street, ' ',ad.city, ' ',ad.state) as shipping_address, o.slot_date, o.payment_id,
				ol.varients, sa.line_2
            from masterdata.order_lines ol
            join masterdata.orders o on ol.cart_id = o.cart_id
			LEFT OUTER JOIN masterdata.customers cm on o.customer_id = cm.customer_id
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT JOIN masterdata.addresses ad on ad.address_id = o.shipping_address_id
			LEFT OUTER JOIN masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
            LEFT OUTER JOIN masterdata.wallet_transactions w on w.order_id = o.order_id
			LEFT OUTER JOIN masterdata.channels ch on o.channel_id = ch.channel_id
			LEFT OUTER JOIN masterdata.time_slots ts on o.time_slot_id = ts.time_slot_id
			LEFT outer join masterdata.stores st on o.store_id = st.store_id
			LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id
        	WHERE o.created_at::date BETWEEN _from_date AND _to_date;

      		RETURN ref;                               -- Return the cursor to the caller
	  
	  else 
	  
	        OPEN ref FOR 
            select cm.customer_id, cm.first_name, cm.last_name, cm.mobile, cm.email, o.order_no, st.store_name,
                ol.price, pt.amount, o.delivery_charges, o.total_amount, w.amount, o.created_at, 'FULL' as payment_type,				 
				o.payment_method, ch.channel, 
				(case when o.is_paid is true then 'Paid' ELSE 'Not Paid' END) as status, 
				s.status_name, st.area_name, ol.sku, ol.item_name, ol.quantity, 
                concat(ad.line_1,' ', ad.line_2, ' ',ad.street, ' ',ad.city, ' ',ad.state) as shipping_address, o.slot_date, o.payment_id,
				ol.varients, sa.line_2
            from masterdata.order_lines ol
            join masterdata.orders o on ol.cart_id = o.cart_id
			LEFT OUTER JOIN masterdata.customers cm on o.customer_id = cm.customer_id
            LEFT OUTER JOIN masterdata.status s on o.status_id = s.status_id
            LEFT JOIN masterdata.addresses ad on ad.address_id = o.shipping_address_id
			LEFT OUTER JOIN masterdata.packaging_types pt on pt.packaging_type_id = o.packaging_type_id
            LEFT OUTER JOIN masterdata.wallet_transactions w on w.order_id = o.order_id
			LEFT OUTER JOIN masterdata.channels ch on o.channel_id = ch.channel_id
			LEFT OUTER JOIN masterdata.time_slots ts on o.time_slot_id = ts.time_slot_id
			LEFT outer join masterdata.stores st on o.store_id = st.store_id
			LEFT outer JOIN masterdata.addresses sa on st.address_id = sa.address_id;
      		RETURN ref;                               -- Return the cursor to the caller
	  
	  end if;
      
    END;
$$;
 G   DROP FUNCTION masterdata.transactions(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            R           1255    17593   update_address(uuid, character varying, character varying, character varying, bigint, character varying, character varying, character varying, character varying, character varying, character varying, boolean, boolean, bigint, boolean, numeric, numeric, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.update_address(_address_id uuid, _first_name character varying, _last_name character varying, _email character varying, _mobile bigint, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _is_billing boolean, _is_shipping boolean, _pincode bigint, _is_default boolean, _latitude numeric, _longitude numeric, _landmark character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	    __customer_status boolean;
        __customer_id UUID;
	BEGIN
	
		select customer_id into __customer_id from masterdata.addresses where address_id = _address_id;
			
		if _is_default is true THEN

            UPDATE masterdata.addresses SET is_default = 'false'
            where customer_id = __customer_id;

        end if;

            UPDATE masterdata.addresses
            SET first_name = _first_name,
                last_name = _last_name,
                email = _email,
                mobile = _mobile,
                line_1 = _line_1, 
                line_2 = _line_2,
                street = _street,                 
                city = _city, 
                state = _state, 
                country = _country, 
                pincode = _pincode, 
                is_billing = _is_billing, 
                is_shipping = _is_shipping,
				is_default = _is_default,
				latitude = _latitude,
				longitude = _longitude,
				landmark = _landmark

            WHERE address_id = _address_id;

    RETURN 'successfully_updated';                                                      
	  
	EXCEPTION WHEN others THEN
	  		insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.update_address', SQLSTATE, SQLERRM, '009d88ce-df5e-11e9-a5a4-533ffa965c3d', _address_id);
			RETURN 'failure';
    END;
$$;
 �  DROP FUNCTION masterdata.update_address(_address_id uuid, _first_name character varying, _last_name character varying, _email character varying, _mobile bigint, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _is_billing boolean, _is_shipping boolean, _pincode bigint, _is_default boolean, _latitude numeric, _longitude numeric, _landmark character varying);
    
   masterdata          sahyadri    false    9            x           1255    17148 '   update_cart_prices(uuid, numeric, json)    FUNCTION     �  CREATE FUNCTION masterdata.update_cart_prices(_cart_id uuid, _new_sales_amount numeric, _items_list json) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
		 __cart_id uuid;
		 __existing_delivery_charges numeric;
		 __cart_amount numeric;
		 __sub_total numeric;
		 __delivery_charges numeric;
		 __item json;
		 __is_dc_updated boolean;
		 
    
    BEGIN
		select cart_id into __cart_id from masterdata.carts where cart_id = _cart_id;

        if __cart_id is not NULL THEN
		
			if _new_sales_amount is NULL THEN
				
				select delivery_charges, cart_amount, sub_total into __existing_delivery_charges, __cart_amount, __sub_total from masterdata.carts
 					where cart_id = __cart_id;

				SELECT amount into __delivery_charges from masterdata.delivery_charges where __sub_total BETWEEN min_cart_value AND max_cart_value;
				
				if __existing_delivery_charges = __delivery_charges THEN
					SELECT false into __is_dc_updated;
				else
					SELECT true into __is_dc_updated;
				end if;
				
				if _new_sales_amount = 0.00 then
				
					__delivery_charges := NULL;
				
				end if;
						
				if __delivery_charges is not null THEN
                	UPDATE masterdata.carts 
                        set cart_amount = cart_amount - __existing_delivery_charges + __delivery_charges,
                            delivery_charges = __delivery_charges
                        where cart_id = __cart_id;
						
				else
					UPDATE masterdata.carts 
           	            set cart_amount = cart_amount - __existing_delivery_charges,
                            delivery_charges = 0.00
                        where cart_id = __cart_id;
						
                end if;
				
				FOR __item IN SELECT * FROM json_array_elements(_items_list -> 'items')
				  LOOP
					UPDATE masterdata.cart_lines 
					SET store_code = cast(__item  ->> 'store_id' as integer),
						inventory = cast(__item  ->> 'inventory' as integer)
					WHERE item_id = cast(__item  ->> 'item_id' as varchar) AND cart_id = __cart_id;
				  END LOOP;
				
				
				
			elsif _new_sales_amount is not NULL THEN
			
				select delivery_charges, cart_amount, sub_total into __existing_delivery_charges, __cart_amount, __sub_total from masterdata.carts
 					where cart_id = __cart_id;

				SELECT amount into __delivery_charges from masterdata.delivery_charges where _new_sales_amount BETWEEN min_cart_value AND max_cart_value;
				
				if __existing_delivery_charges = __delivery_charges THEN
					SELECT false into __is_dc_updated;
				else
					SELECT true into __is_dc_updated;
				end if;
				
				if _new_sales_amount = 0.00 then
				
					__delivery_charges := NULL;
				
				end if;
						
				if __delivery_charges is not null THEN
                	UPDATE masterdata.carts 
                        set cart_amount = cart_amount - __existing_delivery_charges + __delivery_charges - __sub_total + _new_sales_amount,
                            delivery_charges = __delivery_charges,
							sub_total = _new_sales_amount
                        where cart_id = __cart_id;
						
				else
					UPDATE masterdata.carts 
           	            set cart_amount = cart_amount - __existing_delivery_charges - __sub_total + _new_sales_amount,
                            delivery_charges = 0.00,
							sub_total = _new_sales_amount
                        where cart_id = __cart_id;
						
                end if;
				
				
				FOR __item IN SELECT * FROM json_array_elements(_items_list -> 'items')
				  LOOP
					UPDATE masterdata.cart_lines 
					SET price = cast(__item  ->> 'price' as numeric),
						total_price = cast(__item  ->> 'total_price' as numeric),
						special_price = cast(__item  ->> 'special_price' as numeric),
						mrp = cast(__item  ->> 'mrp' as numeric),
						final_selling_price = cast(__item  ->> 'final_selling_price' as numeric),
						inventory = cast(__item  ->> 'inventory' as integer),
						store_code = cast(__item  ->> 'store_id' as integer)
					WHERE item_id = cast(__item  ->> 'item_id' as varchar) AND cart_id = __cart_id;
				  END LOOP;
				
			
            end if;
			
			RETURN CONCAT('updated_prices_successfully',',',__is_dc_updated);			

        else
            RETURN 'invalid_cart_id';
	    end if;
		
	EXCEPTION WHEN others THEN
	  	insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.update_cart_prices', SQLSTATE, SQLERRM, _cart_id, _items_list);
	RETURN 'failure';
    END;
$$;
 i   DROP FUNCTION masterdata.update_cart_prices(_cart_id uuid, _new_sales_amount numeric, _items_list json);
    
   masterdata          sahyadri    false    9            3           1255    16517 8   update_delivery_option(uuid, character varying, boolean)    FUNCTION     F  CREATE FUNCTION masterdata.update_delivery_option(_delivery_option_id uuid, _delivery_option character varying, _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __frequency_id UUID;
	BEGIN

    	IF _delivery_option not in (select delivery_option from masterdata.delivery_options) or 
		 _delivery_option = (select delivery_option from masterdata.delivery_options where delivery_option_id = _delivery_option_id) then

            UPDATE masterdata.delivery_options
            SET delivery_option = _delivery_option,
				is_active = _is_active

            WHERE delivery_option_id = _delivery_option_id;

        	RETURN 'successfully_updated';  
			
		else
		
			RETURN 'delivery_option_already_present';  
			
		end if;                                                       
	  
    END;
$$;
 �   DROP FUNCTION masterdata.update_delivery_option(_delivery_option_id uuid, _delivery_option character varying, _is_active boolean);
    
   masterdata          sahyadri    false    9            0           1255    16518 H   update_delivery_point(uuid, character varying, bigint, bigint, bigint[])    FUNCTION     w  CREATE FUNCTION masterdata.update_delivery_point(_delivery_point_id uuid, _delivery_point_name character varying, _plant_code bigint, _dp_code bigint, _serviceable_pincodes bigint[]) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __delivery_point_id UUID;
        __pincode bigint;
	BEGIN

            UPDATE masterdata.delivery_points
            SET delivery_point_name = _delivery_point_name,
                plant_code = _plant_code,
                dp_code = _dp_code                 

            WHERE delivery_point_id = _delivery_point_id;

            DELETE from masterdata.serviceable_pincodes where delivery_point_id = _delivery_point_id;

            FOREACH __pincode in array _serviceable_pincodes
            LOOP

                insert into masterdata.serviceable_pincodes (pincode, delivery_point_id, created_by, updated_by) 
                        values (__pincode, _delivery_point_id,  
                                _delivery_point_id, _delivery_point_id) ;

            End LOOP;

    RETURN 'successfully_updated';                                                        
	  
    END;
$$;
 �   DROP FUNCTION masterdata.update_delivery_point(_delivery_point_id uuid, _delivery_point_name character varying, _plant_code bigint, _dp_code bigint, _serviceable_pincodes bigint[]);
    
   masterdata          sahyadri    false    9            4           1255    16519 2   update_frequency(uuid, character varying, boolean)    FUNCTION     �  CREATE FUNCTION masterdata.update_frequency(_frequency_id uuid, _frequency character varying, _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __frequency_id UUID;
	BEGIN
		
		IF _frequency not in (select frequency from masterdata.frequencies) or 
		 _frequency = (select frequency from masterdata.frequencies where frequency_id = _frequency_id) then

            UPDATE masterdata.frequencies
            SET frequency = _frequency, 
				is_active = _is_active

            WHERE frequency_id = _frequency_id;

    		RETURN 'successfully_updated';  
			
		else
		
			RETURN 'frequency_already_present';  
			
		end if;
		
    END;
$$;
 q   DROP FUNCTION masterdata.update_frequency(_frequency_id uuid, _frequency character varying, _is_active boolean);
    
   masterdata          sahyadri    false    9            w           1255    17681 ,   update_item_from_orders(uuid, numeric, json)    FUNCTION     �  CREATE FUNCTION masterdata.update_item_from_orders(_order_id uuid, _total_amount numeric, _items json) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __order_part_id uuid;
        __cart_id uuid;
        __customer_id uuid;
		__items_length integer;
		__item_counter integer;
		__existing_item_id character varying;
		__existing_total_price numeric;
		__existing_delivery_charges numeric;
		__total_amount numeric;
		__sub_total numeric;
		__existing_packaging_amount numeric;
		__delivery_charges numeric;
		__order_type character varying;

	BEGIN

        SELECT cart_id, customer_id into __cart_id, __customer_id from masterdata.orders where order_id = _order_id;

        select order_part_id INTO __order_part_id from masterdata.order_lines where cart_id = __cart_id;
		
		select order_type into __order_type from masterdata.order_parts where order_id = _order_id;

        __items_length := json_array_length(_items);

        if __items_length is not null and __items_length > 0 then
                        
            FOR __item_counter in  0..(__items_length -1)
            LOOP
            
                SELECT item_id into __existing_item_id from masterdata.order_lines where item_id = cast(_items -> __item_counter ->> 'item_id' as varchar) and order_part_id = __order_part_id;
                
                if __existing_item_id is not null then
                    
                    SELECT total_price into __existing_total_price from masterdata.order_lines where item_id = __existing_item_id and order_part_id = __order_part_id;
                   
                    UPDATE masterdata.order_lines
					SET quantity = cast(_items -> __item_counter ->> 'quantity' as integer),
						total_price = cast(_items -> __item_counter ->> 'total_price' as numeric)
                    WHERE item_id = __existing_item_id and order_part_id = __order_part_id;
                    
                    UPDATE masterdata.orders
					SET total_amount = total_amount - __existing_total_price + cast(_items -> __item_counter ->> 'total_price' as numeric),
						sub_total = sub_total - __existing_total_price + cast(_items -> __item_counter ->> 'total_price' as numeric)
                    WHERE order_id = _order_id;
                    
                else
            
                    insert into masterdata.order_lines (order_part_id, item_id, item_name, item_description, price , quantity, item_image_urls, total_price, user_subscription_id,
															  created_by, updated_by,
														pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, row, rack, bin,
													   ean, gst, hsn, item_status, category_id, category_name, sub_category_id, sub_category_name)  

				            values (__order_part_id,  
                            cast(_items -> __item_counter ->> 'item_id' as varchar),
							cast(_items -> __item_counter ->> 'name' as character varying),
                            cast(_items -> __item_counter ->> 'description' as character varying),
                            cast(_items -> __item_counter ->> 'price' as numeric),
                            cast(_items -> __item_counter ->> 'quantity' as integer),
                            cast(_items -> __item_counter ->> 'image_url' as character varying),
                            cast(_items -> __item_counter ->> 'total_price' as numeric),
                            cast(_items -> __item_counter ->> 'user_subscription_id' as uuid),
                            __customer_id, __customer_id,
							cast(_items -> __item_counter ->> 'pack_size' as character varying),
							cast(_items -> __item_counter ->> 'unit_of_measure' as character varying),
							cast(_items -> __item_counter ->> 'weight' as numeric),
							cast(_items -> __item_counter ->> 'brand' as character varying),
							cast(_items -> __item_counter ->> 'varients' as character varying),
							cast(_items -> __item_counter ->> 'inventory' as bigint),
							cast(_items -> __item_counter ->> 'special_price' as numeric),
							cast(_items -> __item_counter ->> 'short_description' as character varying),
							cast(_items -> __item_counter ->> 'sku' as character varying),
							cast(_items -> __item_counter ->> 'row' as character varying),						
							cast(_items -> __item_counter ->> 'rack' as character varying),						
							cast(_items -> __item_counter ->> 'bin' as character varying),
							cast(_items -> __item_counter ->> 'ean' as character varying),					
							cast(_items -> __item_counter ->> 'gst' as numeric),					
							cast(_items -> __item_counter ->> 'hsn' as bigint),					
							cast(_items -> __item_counter ->> 'item_status' as integer),					
							cast(_items -> __item_counter ->> 'category_id' as smallint),
							cast(_items -> __item_counter ->> 'category_name' as character varying),					
							cast(_items -> __item_counter ->> 'sub_category_id' as smallint),					
							cast(_items -> __item_counter ->> 'sub_category_name' as character varying)
						);
                    
                    UPDATE masterdata.orders
                    SET total_amount = total_amount  + cast(_items -> __item_counter ->> 'total_price' as numeric),
                    	sub_total = sub_total  + cast(_items -> __item_counter ->> 'total_price' as numeric)
					where order_id = _order_id;
                    
                end if;							

                End LOOP;
				
				-- if __order_type = 'SFS' then

					select coalesce(delivery_charges,0.00), total_amount, sub_total into __existing_delivery_charges, __total_amount, __sub_total
					from masterdata.orders where order_id = _order_id;
					
 					select coalesce(p.amount,0.00) into __existing_packaging_amount from masterdata.packaging_types p 
 						join masterdata.orders o on p.packaging_type_id = o.packaging_type_id where o.order_id = _order_id;

					SELECT coalesce(amount,0.00) into __delivery_charges from masterdata.delivery_charges
                        where __sub_total BETWEEN min_cart_value AND max_cart_value;
						
						
					if __delivery_charges is not null THEN
                        UPDATE masterdata.orders 
                        set total_amount = total_amount - __existing_delivery_charges + __delivery_charges,		
                            delivery_charges = __delivery_charges
                        where order_id = _order_id;
						
					else
						UPDATE masterdata.orders 
                        set total_amount = total_amount - __existing_delivery_charges,
                            delivery_charges = 0.00
                        where order_id = _order_id;
						
                    end if;
					
				-- end if;
				
                return _order_id;  
                            
        else
            return 'atleast_one_item_required_for_cart';
        end if;
	  
    END;
$$;
 f   DROP FUNCTION masterdata.update_item_from_orders(_order_id uuid, _total_amount numeric, _items json);
    
   masterdata          sahyadri    false    9            `           1255    17278 %   update_min_order_value(uuid, numeric)    FUNCTION     �  CREATE FUNCTION masterdata.update_min_order_value(_min_order_id uuid, _min_order_value numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	BEGIN

            UPDATE masterdata.min_order_value
            SET min_order_value = _min_order_value

            WHERE min_order_value_id = _min_order_id;

    RETURN 'successfully_updated';                                                        
	  
    END;
$$;
 _   DROP FUNCTION masterdata.update_min_order_value(_min_order_id uuid, _min_order_value numeric);
    
   masterdata          sahyadri    false    9            \           1255    17274 <   update_oms_packaging_types(uuid, character varying, numeric)    FUNCTION     �  CREATE FUNCTION masterdata.update_oms_packaging_types(_packaging_types_id uuid, _packaging_type character varying, _amount numeric) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	BEGIN

            UPDATE masterdata.packaging_types
            SET packaging_type = _packaging_type,
                amount = _amount

            WHERE packaging_type_id = _packaging_types_id;

    RETURN 'successfully_updated';                                                        
	  
    END;
$$;
 �   DROP FUNCTION masterdata.update_oms_packaging_types(_packaging_types_id uuid, _packaging_type character varying, _amount numeric);
    
   masterdata          sahyadri    false    9            X           1255    17159 �   update_oms_user(uuid, character varying, character varying, bigint, character varying, character varying, uuid, uuid[], boolean)    FUNCTION     �  CREATE FUNCTION masterdata.update_oms_user(_user_id uuid, _first_name character varying, _last_name character varying, _mobile bigint, _email character varying, _password character varying, _role_id uuid, _store_id uuid[], _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	BEGIN
	
 		IF _email not in (select email from masterdata.oms_users) or 
 		 _email = (select email from masterdata.oms_users where user_id = _user_id) then

            UPDATE masterdata.oms_users
            SET first_name = _first_name,
                last_name = _last_name,
                mobile = _mobile,
                email = _email,
                password = _password,
                role_id = _role_id,
                store_id = _store_id,
				is_active = _is_active

            	WHERE user_id = _user_id;

    		RETURN 'successfully_updated'; 
			
 		else
 			return 'email_already_present';
		
 		END IF;
	  
    END;
$$;
 �   DROP FUNCTION masterdata.update_oms_user(_user_id uuid, _first_name character varying, _last_name character varying, _mobile bigint, _email character varying, _password character varying, _role_id uuid, _store_id uuid[], _is_active boolean);
    
   masterdata          sahyadri    false    9            d           1255    17354 +   update_order(uuid, uuid, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.update_order(_order_id uuid, _status_id uuid, _reason character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
		 __order_id uuid;
		 __status_id uuid;
		 __status_name character varying;
		 __first_name character varying;
		 __order_no character varying;
		 __mobile bigint;
		 __customer_id uuid;
		 __total_amount numeric;
		 __payment_method character varying;
    
    BEGIN
		select order_id into __order_id from masterdata.orders where order_id = _order_id;

        if __order_id is not NULL THEN
            select status_id, status_name into __status_id, __status_name from masterdata.status where status_id = _status_id;

		    if __status_id is not NULL then 
			
			
				SELECT ad.first_name, ad.mobile, o.order_no, o.customer_id, o.total_amount into __first_name, __mobile, __order_no, __customer_id, __total_amount
				from masterdata.addresses  ad
				LEFT JOIN masterdata.orders o 
				ON o.billing_address_id = ad.address_id
				WHERE o.is_active = true and o.order_id = _order_id;
            
                UPDATE masterdata.orders
                SET status_id = __status_id,
					updated_at = CURRENT_TIMESTAMP,
					status_history = concat(status_history,'||', __status_name,'@',CURRENT_TIMESTAMP),
					reason = _reason
                WHERE order_id = __order_id;

                RETURN concat('order_updated_successfully',',',__first_name,',',__order_no,',',__mobile,',',__customer_id,',',__total_amount,',',to_char(CURRENT_TIMESTAMP, 'hh24:mi'));

            else
                RETURN 'invalid_status';
	        end if;
			

        else
            RETURN 'invalid_order_id';
	    end if;
		
    END;
$$;
 c   DROP FUNCTION masterdata.update_order(_order_id uuid, _status_id uuid, _reason character varying);
    
   masterdata          sahyadri    false    9            5           1255    16522 (   update_packaging_types(uuid, uuid, uuid)    FUNCTION     y  CREATE FUNCTION masterdata.update_packaging_types(_customer_id uuid, _cart_id uuid, _packaging_type uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	 __customer_id uuid;
     __cart_id uuid;
     __packaging_amount numeric;
     __existing_packaging_id uuid;
     __existing_packaging_amount numeric;

	BEGIN

    	select customer_id into __customer_id from masterdata.customers where customer_id = _customer_id and is_active = true;

		if __customer_id is not null and _cart_id is null then 

			select cart_id into __cart_id from masterdata.carts where customer_id = __customer_id and is_active = true;

            IF _packaging_type is NOT NULL THEN

                SELECT amount into __packaging_amount from masterdata.packaging_types where packaging_type_id = _packaging_type;

                SELECT packaging_type_id into __existing_packaging_id from masterdata.carts WHERE cart_id = __cart_id;

                IF __existing_packaging_id is NOT NULL then

                    SELECT amount into __existing_packaging_amount from masterdata.packaging_types where packaging_type_id = __existing_packaging_id; 
                    
                    UPDATE masterdata.carts
                    SET cart_amount = cart_amount - __existing_packaging_amount + __packaging_amount,
                        packaging_type_id = _packaging_type
                    WHERE cart_id = __cart_id;

                ELSE

                    UPDATE masterdata.carts
                    SET cart_amount = cart_amount + __packaging_amount,
                        packaging_type_id = _packaging_type
                    WHERE cart_id = __cart_id;

                END IF;

                return __cart_id;

            END IF;

		else
            --Updating Guest Cart

            select cart_id into __cart_id from masterdata.carts where cart_id = _cart_id;

            if __cart_id is not null then

                IF _packaging_type is NOT NULL THEN

                    SELECT amount into __packaging_amount from masterdata.packaging_types where packaging_type_id = _packaging_type;

                    SELECT packaging_type_id into __existing_packaging_id from masterdata.carts WHERE cart_id = __cart_id;

                IF __existing_packaging_id is NOT NULL then

                    SELECT amount into __existing_packaging_amount from masterdata.packaging_types where packaging_type_id = __existing_packaging_id; 
                    
                    UPDATE masterdata.carts
                    SET cart_amount = cart_amount - __existing_packaging_amount + __packaging_amount,
                        packaging_type_id = _packaging_type
                    WHERE cart_id = __cart_id;

                ELSE

                    UPDATE masterdata.carts
                    SET cart_amount = cart_amount + __packaging_amount,
                        packaging_type_id = _packaging_type
                    WHERE cart_id = __cart_id;

                END IF;

                    return __cart_id;

                END IF;

            ELSE
                RETURN 'invalid_cart_id';
		    end if;

        end if;                                   
	  
    END;
$$;
 i   DROP FUNCTION masterdata.update_packaging_types(_customer_id uuid, _cart_id uuid, _packaging_type uuid);
    
   masterdata          sahyadri    false    9            g           1255    17264 J   update_payment_status(uuid, boolean, character varying, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.update_payment_status(_order_id uuid, _is_paid boolean, _payment_status character varying, _payu_id character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
Declare

	__status_id uuid;
	BEGIN
	
		if _payment_status = 'FAILURE' or _payment_status = 'failure' then
			
			select status_id into __status_id from masterdata.status where status_name = 'payment_failed';
				
			UPDATE masterdata.orders
			SET status_id = __status_id,
				payu_id = _payu_id,
				payment_id = _order_id
			WHERE order_id = cast(_order_id as uuid);
				
		end if;
		
		if _payment_status = 'SUCCESS' or _payment_status = 'success' then
		
			select status_id into __status_id from masterdata.status where status_name = 'placed';
			
			UPDATE masterdata.orders
			SET status_id = __status_id,
				payu_id = _payu_id,
				payment_id = _order_id
			WHERE order_id = cast(_order_id as uuid);
			
		end if;

        update masterdata.orders
        set is_paid = _is_paid,
            payment_status = _payment_status,
			payu_id = _payu_id,
			payment_id = _order_id
        where order_id = cast(_order_id as uuid);
			
		return 'update_successful';

    END;
$$;
 �   DROP FUNCTION masterdata.update_payment_status(_order_id uuid, _is_paid boolean, _payment_status character varying, _payu_id character varying);
    
   masterdata          sahyadri    false    9            1           1255    16523 6   update_rating_review(uuid, integer, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.update_rating_review(_order_id uuid, _rating integer, _review character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
		 __order_id uuid;   
    BEGIN
	
            UPDATE masterdata.orders
            SET rating = _rating,
                review = _review
            WHERE order_id = _order_id;

            RETURN 'rating_and_review_updated_successfully';

    END;
$$;
 k   DROP FUNCTION masterdata.update_rating_review(_order_id uuid, _rating integer, _review character varying);
    
   masterdata          sahyadri    false    9            2           1255    16524 -   update_role(uuid, character varying, boolean)    FUNCTION     e  CREATE FUNCTION masterdata.update_role(_role_id uuid, _role_name character varying, _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	BEGIN

		IF _role_name not in (select role_name from masterdata.roles) or 
		 _role_name = (select role_name from masterdata.roles where role_id = _role_id) then
		 
            UPDATE masterdata.roles
            SET role_name = _role_name,
                is_active = _is_active

            WHERE role_id = _role_id;

    		RETURN 'successfully_updated'; 
			
		else
		
			return 'role_name_already_present';
			
		end if;
	  
    END;
$$;
 g   DROP FUNCTION masterdata.update_role(_role_id uuid, _role_name character varying, _is_active boolean);
    
   masterdata          sahyadri    false    9            y           1255    16525 �   update_store(uuid, character varying, bigint, bigint, bigint, boolean, boolean, boolean, bigint[], numeric[], character varying)    FUNCTION     R  CREATE FUNCTION masterdata.update_store(_store_id uuid, _store_name character varying, _plant_code bigint, _ds_code bigint, _phone_no bigint, _is_sfs_enabled boolean, _is_cc_enabled boolean, _is_active boolean, _serviceable_pincodes bigint[], _lat_long numeric[], _zone character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __store_id UUID;
        __pincode bigint;
		__lat_long numeric[];
	BEGIN

		IF _store_name not in (select store_name from masterdata.stores) or 
		 _store_name = (select store_name from masterdata.stores where store_id = _store_id) then

            UPDATE masterdata.stores
            SET store_name = _store_name,
                plant_code = _plant_code,
                ds_code = _ds_code,
                phone_no = _phone_no,
                is_sfs_enabled = _is_sfs_enabled, 
                is_cc_enabled = _is_cc_enabled,
				is_active = _is_active,
				zone = _zone

            WHERE store_id = _store_id;

            DELETE from masterdata.serviceable_pincodes WHERE store_id = _store_id;

            FOREACH __pincode in array _serviceable_pincodes
            LOOP

                insert into masterdata.serviceable_pincodes (pincode, store_id, created_by, updated_by, plant_code) 
                        values (__pincode, _store_id,  
                                _store_id, _store_id, _plant_code) ;

            End LOOP;
			
            FOREACH __lat_long slice 1 in array _lat_long
            LOOP
                insert into masterdata.serviceable_pincodes (lat_longs, store_id, created_by, updated_by, plant_code) 
                        values (__lat_long, _store_id,  
                                _store_id, _store_id, _plant_code) ;

            End LOOP;

    RETURN 'successfully_updated'; 
			
		else
		
			RETURN 'store_already_present';  
			
		end if;

    END;
$$;
    DROP FUNCTION masterdata.update_store(_store_id uuid, _store_name character varying, _plant_code bigint, _ds_code bigint, _phone_no bigint, _is_sfs_enabled boolean, _is_cc_enabled boolean, _is_active boolean, _serviceable_pincodes bigint[], _lat_long numeric[], _zone character varying);
    
   masterdata          sahyadri    false    9            6           1255    16526 =   update_subscription(uuid, character varying, bigint, boolean)    FUNCTION     �  CREATE FUNCTION masterdata.update_subscription(_subscription_id uuid, _subscription_type character varying, _subscription_period bigint, _is_active boolean) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __subscription_id UUID;
	BEGIN

        IF _subscription_period in (Select subscription_period from masterdata.subscriptions where subscription_type = _subscription_type) and
          _subscription_period not in (Select subscription_period from masterdata.subscriptions where subscription_type = _subscription_type AND subscription_id = _subscription_id) THEN

            return 'subscription_already_present';

		else
		
            UPDATE masterdata.subscriptions
            SET subscription_type = _subscription_type,
                subscription_period = _subscription_period,
				is_active = _is_active

            WHERE subscription_id = _subscription_id;

    		RETURN 'successfully_updated';   
			
		end if;
	  
    END;
$$;
 �   DROP FUNCTION masterdata.update_subscription(_subscription_id uuid, _subscription_type character varying, _subscription_period bigint, _is_active boolean);
    
   masterdata          sahyadri    false    9            m           1255    17741    update_tms_order_pushed(json)    FUNCTION     =  CREATE FUNCTION masterdata.update_tms_order_pushed(_order_pushed json) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
		 __cart_id uuid;
		 __existing_delivery_charges numeric;
		 __cart_amount numeric;
		 __sub_total numeric;
		 __delivery_charges numeric;
		 __item json;
		 __is_dc_updated boolean;
		 
    
    BEGIN

        insert into masterdata.tms_orders_pushed (tracking_code, date, order_category,poc_name, poc_number, payment_method, shipping_method, 
			latitude, longitude, address, village, shipment_slot_selected_id, customer_number, customer_name,
            customer_group, target_dc, shipping_charges) 

        VALUES  (
            cast(_order_pushed ->> 'tracking_code' as character varying),
            cast(_order_pushed ->> 'date' as date),
            cast(_order_pushed ->> 'order_category' as character varying),
            cast(_order_pushed ->> 'poc_name' as character varying),
            cast(_order_pushed ->> 'poc_number' as bigint),
            cast(_order_pushed ->> 'payment_method' as character varying),
            cast(_order_pushed ->> 'shipping_method' as character varying),
            cast(_order_pushed ->> 'latitude' as numeric),
            cast(_order_pushed ->> 'longitude' as numeric),
            cast(_order_pushed ->> 'address' as character varying),
            cast(_order_pushed ->> 'village' as character varying),
            cast(_order_pushed ->> 'shipment_slot_selected_id' as character varying),
            cast(_order_pushed ->> 'customer_number' as bigint),
            cast(_order_pushed ->> 'customer_name' as character varying),
            cast(_order_pushed ->> 'customer_group' as bigint),
            cast(_order_pushed ->> 'target_dc' as character varying),
            cast(_order_pushed ->> 'shipping_charges' as numeric)
        );

    return 'added_successfully';

		
	EXCEPTION WHEN others THEN
	  	insert into masterdata.error_log_table (function_name, error_code, error_msg, other_info) values ('masterdata.update_tms_order_pushed', SQLSTATE, SQLERRM,_order_pushed);
	RETURN 'failure';
    
    END;
$$;
 F   DROP FUNCTION masterdata.update_tms_order_pushed(_order_pushed json);
    
   masterdata          sahyadri    false    9            f           1255    17561 4   update_wallet(uuid, numeric, boolean, boolean, uuid)    FUNCTION     J	  CREATE FUNCTION masterdata.update_wallet(_customer_id uuid, _amount numeric, _is_debit boolean, _is_credit boolean, _order_id uuid) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
	 __customer_id uuid;
     __wallet_id uuid;
	 __wallet_amount numeric;
	 __updated_at character varying;

	BEGIN

		select customer_id into __customer_id from masterdata.customers where customer_id = _customer_id and is_active = true and magento_customer_id is NOT NULL;

		if __customer_id is not null then 
				
			select wallet_id into __wallet_id from masterdata.wallets where customer_id = __customer_id and is_active = true;
				
			if __wallet_id is not null then

                SELECT wallet_amount into __wallet_amount from masterdata.wallets where wallet_id = __wallet_id;

                if _is_debit = TRUE and _is_credit = FALSE THEN
                
                    UPDATE masterdata.wallets
                    SET wallet_amount = __wallet_amount - _amount
                    WHERE wallet_id = __wallet_id;

				    INSERT INTO masterdata.wallet_transactions (wallet_id, amount, is_debit, is_credit, created_by, updated_by,order_id)
					    values (__wallet_id, _amount, _is_debit, _is_credit, __customer_id, __customer_id, _order_id);

                ELSIF _is_debit = FALSE and _is_credit = TRUE THEN

                    UPDATE masterdata.wallets
                    SET wallet_amount = __wallet_amount + _amount
                    WHERE wallet_id = __wallet_id;

				    INSERT INTO masterdata.wallet_transactions (wallet_id, amount, is_debit, is_credit, created_by, updated_by, order_id)
					    values (__wallet_id, _amount, _is_debit, _is_credit, __customer_id, __customer_id, _order_id);
						
				end if;

            ELSE

                return 'invalid_wallet';

            end if;                          

        ELSE

            RETURN 'invalid_customer_id';

        end if;
        
			select to_char("updated_at", 'DD/MM/YYYY') into __updated_at from masterdata.wallets where wallet_id = __wallet_id;
				
		return CONCAT('wallet_updated_successfully',',',_amount,',',__updated_at);
					
	EXCEPTION WHEN others THEN
	  	insert into masterdata.error_log_table (function_name, error_code, error_msg, sub_id, other_info) values ('masterdata.update_wallet', SQLSTATE, SQLERRM, _customer_id, _amount);
	RETURN 'failure';
    END;
$$;
 �   DROP FUNCTION masterdata.update_wallet(_customer_id uuid, _amount numeric, _is_debit boolean, _is_credit boolean, _order_id uuid);
    
   masterdata          sahyadri    false    9            7           1255    16528    user_carts_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.user_carts_filter(_from_date date, _to_date date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'usercartsrefcursor'; 
    BEGIN      
    
      OPEN ref FOR 

        SELECT ct.cart_id, ct.customer_id, ct.cart_amount, ct.discount_type, ct.discount_amount, 
                ct.coupon_code, ct.is_guest_cart, ct.is_paid, c.first_name, c.mobile, c.email
        from masterdata.carts ct JOIN masterdata.customers c
        on ct.customer_id = c.customer_id

        WHERE c.magento_customer_id is not null AND ct.cart_amount != 0 and 
            ct.created_at::date BETWEEN _from_date AND _to_date;

      RETURN ref;        -- Return the cursor to the caller	            
      
    END;
$$;
 L   DROP FUNCTION masterdata.user_carts_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            a           1255    17144    wallet_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.wallet_filter(_from_date date, _to_date date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
        ref refcursor default 'walletrefcursor'; 
    BEGIN
	
	if _from_date is null and _to_date is null then
	
	     OPEN ref FOR 

        select ad.first_name, ad.last_name, ad.mobile, o.order_no, 
        (case when wt.is_debit is true then 'Debit' when wt.is_credit is true then 'Credit' END) as transaction_type, o.reason,
        wt.amount, wt.updated_at, (case when wt.is_credit is true then 'Reverse' END) as action
        from masterdata.wallet_transactions wt
        left join masterdata.wallets w on wt.wallet_id = w.wallet_id
        left join masterdata.customers c on w.customer_id = c.customer_id
		left join masterdata.orders o on wt.order_id = o.order_id
		left join masterdata.addresses ad on c.customer_id = ad.customer_id;

      RETURN ref;                               -- Return the cursor to the caller
	
	
	else
	
      OPEN ref FOR 

        select c.first_name, c.last_name, c.mobile, o.order_no, 
        (case when wt.is_debit is true then 'Debit' when wt.is_credit is true then 'Credit' END) as transaction_type, o.reason,
        wt.amount, wt.updated_at, (case when wt.is_credit is true then 'Reverse' END) as action
        from masterdata.wallet_transactions wt
        left join masterdata.wallets w on wt.wallet_id = w.wallet_id
        left join masterdata.customers c on w.customer_id = c.customer_id
		left join masterdata.orders o on wt.order_id = o.order_id
		left join masterdata.addresses ad on c.customer_id = ad.customer_id
        WHERE wt.created_at::date BETWEEN _from_date AND _to_date;

      RETURN ref;                               -- Return the cursor to the caller
	  
	  end if;
      
    END;
$$;
 H   DROP FUNCTION masterdata.wallet_filter(_from_date date, _to_date date);
    
   masterdata          sahyadri    false    9            �            1259    16529 	   addresses    TABLE     �  CREATE TABLE masterdata.addresses (
    address_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    store_id uuid,
    customer_id uuid,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(50),
    mobile bigint,
    line_1 character varying(200),
    line_2 character varying(50),
    street character varying(100),
    city character varying(100),
    state character varying(100),
    country character varying(100),
    pincode bigint,
    is_billing boolean,
    is_shipping boolean,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_default boolean DEFAULT false,
    latitude numeric,
    longitude numeric,
    landmark character varying
);
 !   DROP TABLE masterdata.addresses;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    17221 
   cart_lines    TABLE     �  CREATE TABLE masterdata.cart_lines (
    cart_id uuid NOT NULL,
    item_id character varying(25) NOT NULL,
    item_name character varying(100),
    item_description character varying(1000),
    quantity integer NOT NULL,
    price numeric(15,2) NOT NULL,
    item_image_urls character varying(1000),
    item_category character varying(100),
    item_shelf_life integer,
    discount_type character varying(100),
    discount_amount numeric(15,2),
    total_price numeric(15,2) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_subscription_id uuid,
    pack_size character varying,
    unit_of_measure character varying,
    weight numeric,
    brand character varying,
    varients character varying,
    inventory bigint,
    special_price numeric(15,2),
    short_description character varying,
    sku character varying,
    "row" character varying,
    rack character varying,
    bin character varying,
    hsn bigint,
    ean character varying,
    gst numeric(15,2),
    item_status integer,
    category_id smallint,
    category_name character varying,
    sub_category_id smallint,
    sub_category_name character varying,
    mrp numeric(15,2),
    final_selling_price numeric(15,2),
    store_code integer
);
 "   DROP TABLE masterdata.cart_lines;
    
   masterdata         heap    sahyadri    false    9            �            1259    17208    carts    TABLE     $  CREATE TABLE masterdata.carts (
    cart_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    customer_id uuid NOT NULL,
    cart_amount numeric(15,2),
    discount_type character varying(100),
    discount_amount numeric(15,2),
    coupon_code character varying(100),
    is_guest_cart boolean DEFAULT true,
    is_paid boolean DEFAULT false,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    packaging_type_id uuid DEFAULT '16ee2dda-38aa-11eb-8096-d35472c5a6a7'::uuid,
    sub_total numeric(15,2),
    delivery_charges numeric(15,2) DEFAULT 0.00 NOT NULL,
    store_code integer
);
    DROP TABLE masterdata.carts;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16558    channels    TABLE       CREATE TABLE masterdata.channels (
    channel_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    channel character varying(20),
    latest_version numeric(5,5),
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
     DROP TABLE masterdata.channels;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16567 	   customers    TABLE     �  CREATE TABLE masterdata.customers (
    customer_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    store_id bigint,
    magento_customer_id bigint,
    first_name character varying(100),
    last_name character varying(100),
    mobile numeric(12,0),
    email character varying(100),
    subscription_id uuid,
    subscription_start_date timestamp with time zone,
    subscription_end_date timestamp with time zone,
    frequency_id uuid,
    delivery_option_id uuid,
    is_active boolean DEFAULT true,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 !   DROP TABLE masterdata.customers;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16574 	   day_slots    TABLE       CREATE TABLE masterdata.day_slots (
    day_slot_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    month_slot_id uuid NOT NULL,
    day smallint NOT NULL,
    month smallint NOT NULL,
    open_time timestamp with time zone NOT NULL,
    close_time timestamp with time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid NOT NULL
);
 !   DROP TABLE masterdata.day_slots;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16905    delivery_charges    TABLE     E  CREATE TABLE masterdata.delivery_charges (
    delivery_charges_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    min_cart_value numeric(15,2),
    max_cart_value numeric(15,2),
    amount numeric(15,2),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 (   DROP TABLE masterdata.delivery_charges;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16581    delivery_options    TABLE     �  CREATE TABLE masterdata.delivery_options (
    delivery_option_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    delivery_option character varying(500),
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 (   DROP TABLE masterdata.delivery_options;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16591    delivery_points    TABLE     �  CREATE TABLE masterdata.delivery_points (
    delivery_point_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    delivery_point_name character varying(255),
    plant_code bigint,
    dp_code bigint,
    address_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 '   DROP TABLE masterdata.delivery_points;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16598    error_log_table    TABLE     l  CREATE TABLE masterdata.error_log_table (
    error_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    function_name character varying(200),
    error_code character varying(200),
    error_msg character varying(500),
    sub_id uuid,
    other_info character varying(3000),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 '   DROP TABLE masterdata.error_log_table;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16606    frequencies    TABLE     �  CREATE TABLE masterdata.frequencies (
    frequency_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    frequency character varying(500),
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 #   DROP TABLE masterdata.frequencies;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    17281    min_order_value    TABLE       CREATE TABLE masterdata.min_order_value (
    min_order_value_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    min_order_value numeric(15,2) DEFAULT 0.00 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 '   DROP TABLE masterdata.min_order_value;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16616    month_slots    TABLE     �  CREATE TABLE masterdata.month_slots (
    month_slot_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    store_id uuid NOT NULL,
    month smallint NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid NOT NULL
);
 #   DROP TABLE masterdata.month_slots;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16623 	   oms_users    TABLE     �  CREATE TABLE masterdata.oms_users (
    user_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    first_name character varying(100),
    last_name character varying(100),
    mobile bigint,
    email character varying(100),
    password character varying(100),
    role_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    store_id uuid[]
);
 !   DROP TABLE masterdata.oms_users;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16632    order_lines    TABLE       CREATE TABLE masterdata.order_lines (
    order_part_id uuid,
    item_id character varying(100) NOT NULL,
    item_name character varying(100),
    item_description character varying(1000),
    quantity integer NOT NULL,
    price numeric(15,2) NOT NULL,
    item_image_urls character varying(1000),
    item_category character varying(100),
    item_shelf_life integer,
    item_packing_type character varying(100),
    is_returnable boolean DEFAULT true,
    discount_type character varying(100),
    discount_amount numeric(15,2),
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_subscription_id uuid,
    total_price numeric,
    cart_id uuid,
    pack_size character varying,
    unit_of_measure character varying,
    weight numeric,
    brand character varying,
    varients character varying,
    inventory bigint,
    special_price numeric(15,2),
    short_description character varying,
    sku character varying,
    "row" character varying,
    rack character varying,
    bin character varying,
    ean character varying,
    hsn bigint,
    gst numeric(15,2),
    item_status integer,
    category_id smallint,
    category_name character varying,
    sub_category_id smallint,
    sub_category_name character varying,
    mrp numeric(15,2),
    final_selling_price numeric(15,2),
    store_code integer
);
 #   DROP TABLE masterdata.order_lines;
    
   masterdata         heap    sahyadri    false    9            �            1259    16642    order_parts    TABLE     ]  CREATE TABLE masterdata.order_parts (
    order_part_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    order_id uuid,
    order_type character varying(20) NOT NULL,
    fulfilment_id uuid,
    shipping_address_id uuid,
    discount_type character varying(100),
    discount_amount numeric(15,2),
    invoice_id uuid,
    is_shipped boolean DEFAULT false,
    is_picked boolean DEFAULT false,
    is_packed boolean DEFAULT false,
    is_paid boolean DEFAULT false,
    is_sfs_stock_blocked boolean DEFAULT false,
    status_id uuid,
    status_history character varying(500),
    status_history_timings character varying(500),
    cancellation_reason character varying(500),
    awb character varying(20),
    coupon_code character varying(100),
    amount numeric(15,2) NOT NULL,
    rating numeric(1,0),
    tracking_url character varying(250),
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 #   DROP TABLE masterdata.order_parts;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16657    order_types    TABLE     -  CREATE TABLE masterdata.order_types (
    order_type_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    order_type character varying(50),
    order_type_code character varying(10),
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 #   DROP TABLE masterdata.order_types;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16666    orders    TABLE     H  CREATE TABLE masterdata.orders (
    order_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    cart_id uuid,
    customer_id uuid,
    is_paid boolean DEFAULT false,
    order_no character varying(25) NOT NULL,
    payment_id uuid,
    time_slot_id uuid,
    is_return_initiated boolean DEFAULT false,
    is_cancelled boolean DEFAULT false,
    is_delivered boolean DEFAULT false,
    channel_id uuid,
    status_id uuid,
    subscription_id uuid,
    total_amount numeric(15,2) NOT NULL,
    payment_method character varying(30),
    payment_status character varying(100),
    feedback integer,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    store_id uuid,
    billing_address_id uuid,
    shipping_address_id uuid,
    rating integer,
    review character varying(1000),
    status_history character varying,
    invoice_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    packaging_type_id uuid,
    sub_total numeric(15,2),
    delivery_charges numeric(15,2),
    slot_date character varying,
    payu_id character varying,
    reason character varying,
    is_order_pushed_tms boolean,
    store_code integer
);
    DROP TABLE masterdata.orders;
    
   masterdata         heap    sahyadri    false    2    9    2    9    9            �            1259    16681    packaging_types    TABLE     )  CREATE TABLE masterdata.packaging_types (
    packaging_type_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    packaging_type character varying(100),
    amount numeric(15,2),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 '   DROP TABLE masterdata.packaging_types;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16690    payment_transactions    TABLE     �  CREATE TABLE masterdata.payment_transactions (
    payment_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    transaction_id uuid,
    order_id uuid,
    total_amount numeric(15,2),
    payment_method character varying(20),
    payment_status_id uuid,
    merchant_id character varying(20),
    is_success boolean DEFAULT false,
    pg_message character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 ,   DROP TABLE masterdata.payment_transactions;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16700    permissions    TABLE     -  CREATE TABLE masterdata.permissions (
    permission_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    role_id uuid,
    screen_id uuid,
    is_read boolean,
    is_write boolean,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 #   DROP TABLE masterdata.permissions;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16709    roles    TABLE     �  CREATE TABLE masterdata.roles (
    role_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    role_name character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
    DROP TABLE masterdata.roles;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16718    screens    TABLE     �  CREATE TABLE masterdata.screens (
    screen_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    screen_name character varying(100),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
    DROP TABLE masterdata.screens;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16727    serviceable_pincodes    TABLE     �  CREATE TABLE masterdata.serviceable_pincodes (
    pincode bigint,
    store_id uuid,
    delivery_point_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid NOT NULL,
    lat_longs numeric[],
    plant_code bigint
);
 ,   DROP TABLE masterdata.serviceable_pincodes;
    
   masterdata         heap    sahyadri    false    9            �            1259    16736    status    TABLE     
  CREATE TABLE masterdata.status (
    status_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    status_name character varying(20),
    pg_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
    DROP TABLE masterdata.status;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16745    stores    TABLE     j  CREATE TABLE masterdata.stores (
    store_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    address_id uuid,
    store_name character varying(255),
    plant_code bigint,
    ds_code bigint,
    phone_no bigint,
    is_sfs_enabled boolean NOT NULL,
    is_cc_enabled boolean NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    zone character varying,
    area_name character varying
);
    DROP TABLE masterdata.stores;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16755    subscriptions    TABLE     �  CREATE TABLE masterdata.subscriptions (
    subscription_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    subscription_type character varying(500),
    subscription_period integer,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 %   DROP TABLE masterdata.subscriptions;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16765 
   time_slots    TABLE     -  CREATE TABLE masterdata.time_slots (
    time_slot_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    day_slot_id uuid NOT NULL,
    start_slot_time timestamp with time zone NOT NULL,
    end_slot_time timestamp with time zone NOT NULL,
    slot_limit bigint NOT NULL,
    slot_current_orders bigint DEFAULT 0,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid NOT NULL
);
 "   DROP TABLE masterdata.time_slots;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16897    user_matrix    TABLE     #  CREATE TABLE masterdata.user_matrix (
    user_matrix_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    role_id uuid,
    screen_id uuid,
    status_id uuid,
    is_status_read boolean,
    is_status_write boolean,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 #   DROP TABLE masterdata.user_matrix;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16773    user_subscriptions    TABLE     p  CREATE TABLE masterdata.user_subscriptions (
    subscribed_user_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    customer_id uuid NOT NULL,
    subscription_id uuid NOT NULL,
    frequency_id uuid NOT NULL,
    delivery_option_id uuid NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid DEFAULT '009d88ce-df5e-11e9-a5a4-533ffa965c3d'::uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
 *   DROP TABLE masterdata.user_subscriptions;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16782    wallet_transactions    TABLE       CREATE TABLE masterdata.wallet_transactions (
    transaction_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    wallet_id uuid NOT NULL,
    amount numeric(15,2),
    is_debit boolean NOT NULL,
    is_credit boolean NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    order_id uuid
);
 +   DROP TABLE masterdata.wallet_transactions;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16789    wallets    TABLE     �  CREATE TABLE masterdata.wallets (
    wallet_id uuid DEFAULT masterdata.uuid_generate_v1mc() NOT NULL,
    customer_id uuid NOT NULL,
    wallet_amount numeric(15,2),
    is_active boolean DEFAULT true NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);
    DROP TABLE masterdata.wallets;
    
   masterdata         heap    sahyadri    false    2    9    9            �            1259    17087    __status_id    TABLE     8   CREATE TABLE public.__status_id (
    status_id uuid
);
    DROP TABLE public.__status_id;
       public         heap    sahyadri    false            �          0    16529 	   addresses 
   TABLE DATA           &  COPY masterdata.addresses (address_id, store_id, customer_id, first_name, last_name, email, mobile, line_1, line_2, street, city, state, country, pincode, is_billing, is_shipping, is_active, created_by, created_at, updated_by, updated_at, is_default, latitude, longitude, landmark) FROM stdin;
 
   masterdata          sahyadri    false    204   o�      �          0    17221 
   cart_lines 
   TABLE DATA             COPY masterdata.cart_lines (cart_id, item_id, item_name, item_description, quantity, price, item_image_urls, item_category, item_shelf_life, discount_type, discount_amount, total_price, is_active, created_by, created_at, updated_by, updated_at, user_subscription_id, pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, "row", rack, bin, hsn, ean, gst, item_status, category_id, category_name, sub_category_id, sub_category_name, mrp, final_selling_price, store_code) FROM stdin;
 
   masterdata          sahyadri    false    235   ��      �          0    17208    carts 
   TABLE DATA             COPY masterdata.carts (cart_id, customer_id, cart_amount, discount_type, discount_amount, coupon_code, is_guest_cart, is_paid, is_active, created_by, created_at, updated_by, updated_at, packaging_type_id, sub_total, delivery_charges, store_code) FROM stdin;
 
   masterdata          sahyadri    false    234   pg      �          0    16558    channels 
   TABLE DATA           �   COPY masterdata.channels (channel_id, channel, latest_version, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    205   ��      �          0    16567 	   customers 
   TABLE DATA             COPY masterdata.customers (customer_id, store_id, magento_customer_id, first_name, last_name, mobile, email, subscription_id, subscription_start_date, subscription_end_date, frequency_id, delivery_option_id, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    206   �      �          0    16574 	   day_slots 
   TABLE DATA           �   COPY masterdata.day_slots (day_slot_id, month_slot_id, day, month, open_time, close_time, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
 
   masterdata          sahyadri    false    207   ��      �          0    16905    delivery_charges 
   TABLE DATA           �   COPY masterdata.delivery_charges (delivery_charges_id, min_cart_value, max_cart_value, amount, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    232   7s      �          0    16581    delivery_options 
   TABLE DATA           �   COPY masterdata.delivery_options (delivery_option_id, delivery_option, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    208   �s      �          0    16591    delivery_points 
   TABLE DATA           �   COPY masterdata.delivery_points (delivery_point_id, delivery_point_name, plant_code, dp_code, address_id, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    209   |t      �          0    16598    error_log_table 
   TABLE DATA           }   COPY masterdata.error_log_table (error_id, function_name, error_code, error_msg, sub_id, other_info, created_at) FROM stdin;
 
   masterdata          sahyadri    false    210   �t      �          0    16606    frequencies 
   TABLE DATA           }   COPY masterdata.frequencies (frequency_id, frequency, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    211   f�      �          0    17281    min_order_value 
   TABLE DATA           �   COPY masterdata.min_order_value (min_order_value_id, min_order_value, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    236   ��      �          0    16616    month_slots 
   TABLE DATA           �   COPY masterdata.month_slots (month_slot_id, store_id, month, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
 
   masterdata          sahyadri    false    212   ��      �          0    16623 	   oms_users 
   TABLE DATA           �   COPY masterdata.oms_users (user_id, first_name, last_name, mobile, email, password, role_id, is_active, created_at, created_by, updated_by, updated_at, store_id) FROM stdin;
 
   masterdata          sahyadri    false    213   �      �          0    16632    order_lines 
   TABLE DATA           D  COPY masterdata.order_lines (order_part_id, item_id, item_name, item_description, quantity, price, item_image_urls, item_category, item_shelf_life, item_packing_type, is_returnable, discount_type, discount_amount, is_active, created_by, created_at, updated_by, updated_at, user_subscription_id, total_price, cart_id, pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, "row", rack, bin, ean, hsn, gst, item_status, category_id, category_name, sub_category_id, sub_category_name, mrp, final_selling_price, store_code) FROM stdin;
 
   masterdata          sahyadri    false    214   ��      �          0    16642    order_parts 
   TABLE DATA           �  COPY masterdata.order_parts (order_part_id, order_id, order_type, fulfilment_id, shipping_address_id, discount_type, discount_amount, invoice_id, is_shipped, is_picked, is_packed, is_paid, is_sfs_stock_blocked, status_id, status_history, status_history_timings, cancellation_reason, awb, coupon_code, amount, rating, tracking_url, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    215   ��
      �          0    16657    order_types 
   TABLE DATA           �   COPY masterdata.order_types (order_type_id, order_type, order_type_code, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    216   �:      �          0    16666    orders 
   TABLE DATA           	  COPY masterdata.orders (order_id, cart_id, customer_id, is_paid, order_no, payment_id, time_slot_id, is_return_initiated, is_cancelled, is_delivered, channel_id, status_id, subscription_id, total_amount, payment_method, payment_status, feedback, is_active, created_by, created_at, updated_by, updated_at, store_id, billing_address_id, shipping_address_id, rating, review, status_history, invoice_id, packaging_type_id, sub_total, delivery_charges, slot_date, payu_id, reason, is_order_pushed_tms, store_code) FROM stdin;
 
   masterdata          sahyadri    false    217   P;      �          0    16681    packaging_types 
   TABLE DATA           �   COPY masterdata.packaging_types (packaging_type_id, packaging_type, amount, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    218   ��      �          0    16690    payment_transactions 
   TABLE DATA           �   COPY masterdata.payment_transactions (payment_id, transaction_id, order_id, total_amount, payment_method, payment_status_id, merchant_id, is_success, pg_message, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    219   ��      �          0    16700    permissions 
   TABLE DATA           �   COPY masterdata.permissions (permission_id, role_id, screen_id, is_read, is_write, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    220   ��      �          0    16709    roles 
   TABLE DATA           r   COPY masterdata.roles (role_id, role_name, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    221   ��      �          0    16718    screens 
   TABLE DATA           x   COPY masterdata.screens (screen_id, screen_name, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    222   ��      �          0    16727    serviceable_pincodes 
   TABLE DATA           �   COPY masterdata.serviceable_pincodes (pincode, store_id, delivery_point_id, is_active, created_at, created_by, updated_at, updated_by, lat_longs, plant_code) FROM stdin;
 
   masterdata          sahyadri    false    223   C�      �          0    16736    status 
   TABLE DATA           ~   COPY masterdata.status (status_id, status_name, pg_id, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    224   �      �          0    16745    stores 
   TABLE DATA           �   COPY masterdata.stores (store_id, address_id, store_name, plant_code, ds_code, phone_no, is_sfs_enabled, is_cc_enabled, is_active, created_by, created_at, updated_by, updated_at, zone, area_name) FROM stdin;
 
   masterdata          sahyadri    false    225   U�      �          0    16755    subscriptions 
   TABLE DATA           �   COPY masterdata.subscriptions (subscription_id, subscription_type, subscription_period, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    226   K�      �          0    16765 
   time_slots 
   TABLE DATA           �   COPY masterdata.time_slots (time_slot_id, day_slot_id, start_slot_time, end_slot_time, slot_limit, slot_current_orders, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
 
   masterdata          sahyadri    false    227   h�      �          0    16897    user_matrix 
   TABLE DATA           �   COPY masterdata.user_matrix (user_matrix_id, role_id, screen_id, status_id, is_status_read, is_status_write, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    231   �      �          0    16773    user_subscriptions 
   TABLE DATA           �   COPY masterdata.user_subscriptions (subscribed_user_id, customer_id, subscription_id, frequency_id, delivery_option_id, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    228   r      �          0    16782    wallet_transactions 
   TABLE DATA           �   COPY masterdata.wallet_transactions (transaction_id, wallet_id, amount, is_debit, is_credit, is_active, created_by, created_at, updated_by, updated_at, order_id) FROM stdin;
 
   masterdata          sahyadri    false    229   �      �          0    16789    wallets 
   TABLE DATA           �   COPY masterdata.wallets (wallet_id, customer_id, wallet_amount, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    230   �!      �          0    17087    __status_id 
   TABLE DATA           0   COPY public.__status_id (status_id) FROM stdin;
    public          sahyadri    false    233   V0                 2606    16797    addresses addresses_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY masterdata.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (address_id);
 F   ALTER TABLE ONLY masterdata.addresses DROP CONSTRAINT addresses_pkey;
    
   masterdata            sahyadri    false    204            8           2606    17220    carts carts_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY masterdata.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (cart_id);
 >   ALTER TABLE ONLY masterdata.carts DROP CONSTRAINT carts_pkey;
    
   masterdata            sahyadri    false    234                       2606    16801    channels channels_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY masterdata.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (channel_id);
 D   ALTER TABLE ONLY masterdata.channels DROP CONSTRAINT channels_pkey;
    
   masterdata            sahyadri    false    205                       2606    16803    customers customers_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY masterdata.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);
 F   ALTER TABLE ONLY masterdata.customers DROP CONSTRAINT customers_pkey;
    
   masterdata            sahyadri    false    206                       2606    16805 &   delivery_options delivery_options_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY masterdata.delivery_options
    ADD CONSTRAINT delivery_options_pkey PRIMARY KEY (delivery_option_id);
 T   ALTER TABLE ONLY masterdata.delivery_options DROP CONSTRAINT delivery_options_pkey;
    
   masterdata            sahyadri    false    208                       2606    16807 $   delivery_points delivery_points_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY masterdata.delivery_points
    ADD CONSTRAINT delivery_points_pkey PRIMARY KEY (delivery_point_id);
 R   ALTER TABLE ONLY masterdata.delivery_points DROP CONSTRAINT delivery_points_pkey;
    
   masterdata            sahyadri    false    209                       2606    16809 $   error_log_table error_log_table_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY masterdata.error_log_table
    ADD CONSTRAINT error_log_table_pkey PRIMARY KEY (error_id);
 R   ALTER TABLE ONLY masterdata.error_log_table DROP CONSTRAINT error_log_table_pkey;
    
   masterdata            sahyadri    false    210                        2606    16811    frequencies frequencies_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY masterdata.frequencies
    ADD CONSTRAINT frequencies_pkey PRIMARY KEY (frequency_id);
 J   ALTER TABLE ONLY masterdata.frequencies DROP CONSTRAINT frequencies_pkey;
    
   masterdata            sahyadri    false    211            "           2606    16813    order_parts order_parts_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY masterdata.order_parts
    ADD CONSTRAINT order_parts_pkey PRIMARY KEY (order_part_id);
 J   ALTER TABLE ONLY masterdata.order_parts DROP CONSTRAINT order_parts_pkey;
    
   masterdata            sahyadri    false    215            $           2606    16815    order_types order_types_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY masterdata.order_types
    ADD CONSTRAINT order_types_pkey PRIMARY KEY (order_type_id);
 J   ALTER TABLE ONLY masterdata.order_types DROP CONSTRAINT order_types_pkey;
    
   masterdata            sahyadri    false    216            &           2606    16817    orders orders_order_no_key 
   CONSTRAINT     ]   ALTER TABLE ONLY masterdata.orders
    ADD CONSTRAINT orders_order_no_key UNIQUE (order_no);
 H   ALTER TABLE ONLY masterdata.orders DROP CONSTRAINT orders_order_no_key;
    
   masterdata            sahyadri    false    217            (           2606    16819    orders orders_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY masterdata.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);
 @   ALTER TABLE ONLY masterdata.orders DROP CONSTRAINT orders_pkey;
    
   masterdata            sahyadri    false    217            *           2606    16821 .   payment_transactions payment_transactions_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY masterdata.payment_transactions
    ADD CONSTRAINT payment_transactions_pkey PRIMARY KEY (payment_id);
 \   ALTER TABLE ONLY masterdata.payment_transactions DROP CONSTRAINT payment_transactions_pkey;
    
   masterdata            sahyadri    false    219            ,           2606    16823    status status_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY masterdata.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (status_id);
 @   ALTER TABLE ONLY masterdata.status DROP CONSTRAINT status_pkey;
    
   masterdata            sahyadri    false    224            .           2606    16825    stores stores_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY masterdata.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (store_id);
 @   ALTER TABLE ONLY masterdata.stores DROP CONSTRAINT stores_pkey;
    
   masterdata            sahyadri    false    225            0           2606    16827     subscriptions subscriptions_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY masterdata.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (subscription_id);
 N   ALTER TABLE ONLY masterdata.subscriptions DROP CONSTRAINT subscriptions_pkey;
    
   masterdata            sahyadri    false    226            2           2606    16829 *   user_subscriptions user_subscriptions_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY masterdata.user_subscriptions
    ADD CONSTRAINT user_subscriptions_pkey PRIMARY KEY (subscribed_user_id);
 X   ALTER TABLE ONLY masterdata.user_subscriptions DROP CONSTRAINT user_subscriptions_pkey;
    
   masterdata            sahyadri    false    228            4           2606    16831 ,   wallet_transactions wallet_transactions_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY masterdata.wallet_transactions
    ADD CONSTRAINT wallet_transactions_pkey PRIMARY KEY (transaction_id);
 Z   ALTER TABLE ONLY masterdata.wallet_transactions DROP CONSTRAINT wallet_transactions_pkey;
    
   masterdata            sahyadri    false    229            6           2606    16833    wallets wallets_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY masterdata.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (wallet_id);
 B   ALTER TABLE ONLY masterdata.wallets DROP CONSTRAINT wallets_pkey;
    
   masterdata            sahyadri    false    230            9           2606    16834 $   addresses addresses_customer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.addresses
    ADD CONSTRAINT addresses_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES masterdata.customers(customer_id);
 R   ALTER TABLE ONLY masterdata.addresses DROP CONSTRAINT addresses_customer_id_fkey;
    
   masterdata          sahyadri    false    206    3864    204            ?           2606    17230 "   cart_lines cart_lines_cart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.cart_lines
    ADD CONSTRAINT cart_lines_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES masterdata.carts(cart_id);
 P   ALTER TABLE ONLY masterdata.cart_lines DROP CONSTRAINT cart_lines_cart_id_fkey;
    
   masterdata          sahyadri    false    3896    235    234            :           2606    16844 &   order_parts order_parts_status_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.order_parts
    ADD CONSTRAINT order_parts_status_id_fkey FOREIGN KEY (status_id) REFERENCES masterdata.status(status_id);
 T   ALTER TABLE ONLY masterdata.order_parts DROP CONSTRAINT order_parts_status_id_fkey;
    
   masterdata          sahyadri    false    215    224    3884            ;           2606    16849    orders orders_customer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES masterdata.customers(customer_id);
 L   ALTER TABLE ONLY masterdata.orders DROP CONSTRAINT orders_customer_id_fkey;
    
   masterdata          sahyadri    false    3864    217    206            <           2606    16854    orders orders_status_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.orders
    ADD CONSTRAINT orders_status_id_fkey FOREIGN KEY (status_id) REFERENCES masterdata.status(status_id);
 J   ALTER TABLE ONLY masterdata.orders DROP CONSTRAINT orders_status_id_fkey;
    
   masterdata          sahyadri    false    217    3884    224            =           2606    16859 @   payment_transactions payment_transactions_payment_status_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.payment_transactions
    ADD CONSTRAINT payment_transactions_payment_status_id_fkey FOREIGN KEY (payment_status_id) REFERENCES masterdata.status(status_id);
 n   ALTER TABLE ONLY masterdata.payment_transactions DROP CONSTRAINT payment_transactions_payment_status_id_fkey;
    
   masterdata          sahyadri    false    3884    224    219            >           2606    16864     wallets wallets_customer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.wallets
    ADD CONSTRAINT wallets_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES masterdata.customers(customer_id);
 N   ALTER TABLE ONLY masterdata.wallets DROP CONSTRAINT wallets_customer_id_fkey;
    
   masterdata          sahyadri    false    230    3864    206            �      x��}[sG��s�Wt�y<\���dQ7J��흈���+^  J����Y�4H5Hxwg�l�THTgge~_fVu�Dzk�@8��&?�*���BdB�<W�8��tQ��p�_��R�f2eM'�M'W�뱻�c7�T^C��o7�sq>�n~���u�	'VJx��O�o��IƳ����-���v�8�WS�O.�k����U��}W	�~���k��02�l�IM�!Շ�����K�>D,q���W��'dfe�\�@x���Qjf*�6����x$�-��y��M�/f���|����]����\�v�v�����Ϣkk���Jc+
�����&��t�bu�~ԟo���t���vڦp��E۽���B���;�t�5g��j"Z]��ឃEn�YG�NZ��fr�T�8�����b#�Q��luv�����������S���\l1bk�	��7M�A���ht�>����7�O��W���n~����;w�ꤘ�A�U�u�q�ָ{M��L�%��23�\PMQW{�1n�q̆�)5�L�v@8τy�9g�s0���	ǹ�8-,)�#�)b*w�����p�+��^�W[�RD�Lu��[��Ym�#^���U�L��{/&nRO����N�O�M��֕��tGUD��������������֤�H�j��]���HH&>HʼӔG��қf��Q��G���$��l^!-���`�`���ؼ���Ze����@q�����l��ϳ���Wqz~p���G��w�����g��}��Gwu�?7v�	]���U���Ң;s��P	-xq{�5vO�#
�Ӫ_�'�\��c>�B8���M�l��b2�����*���F��wU}�\�e�Ka�������⬎���M��<�.�S�t�[�_�/_[�(���;��Yc���AĽּ��3ҔZi��D
���ܲ8���M�Q��3D\m`����_޽=;��1��y[݃U��i��>�2��lt<�4����������7���[�p�q�q����q��˧O�wo�7����'�w���d_���n�_�9�5%k"=�r�(D<��ڃ���r��`�n���w��%$ayȍ��3OL�qde�����E*8�@��+����N/�R��𼼢֘��j��3BÇ���dV�e����4�Lc�uv5	�>N.����͗i~P����bY�⹛MW�q��,��ܻ�ψ2P�m���"�~A��P(m�^�ePn���:�K�Т�*+��m���%i �U��K���~���ع��qC��8k��;vq�r?�"�օ�+�MZ�a�lL��$6/�	��Aʥ�ADG{.�<+��] ����gA]R��P͔6��&�֘U�9E�E�z�Ђ��;i��^7/'Ě��M����M��G�q��_Ob���8��8{Ͳ�s��!Q�T��%t��P2k���)�@� ���K�MY��	�\�	Z��(��F�d�"V���G`6����i��y=t��t��z�тV����m����SZE�m��kz�P��Pҡ D��f�\D��I�4�;��+i�9P�q%5�Q�2-�cDn�M �V+\� X��xr1Y�.ίgK�����y��nC�8���v7�Q� ���ª���|20V p=Ex�}2�� ���hy
����kҪ���a3B���afxY�{�1j@u!�:PծpG&�L��N�|-j	p���<h�g�L&���)���;���$�K�K��o�q��%���t19/�*p=+L�P��5�}��S�t{�t��lZ�x�A�9�}���ǉ6�?-�u-k�Lk���LPZ5܃f�	n�OE�W�b@����0�r$�Sנ� ��%m�eV���$���i�(��r>Y�� M`Ч�t�����;X(~|qY�>���êW�"��V'�C�P��)g��h/�po��p��+|��L"���`�|1������ga�A���IN@ɫQ!Ѡ`a��r���˧H��>�s���l����~���iron����e�i2M����o'oa�T��g�VA�CƇ��*�b	]��x`o��-R66WZhHVŅ�ȓ,�g � yP�G��a|{U^����j�Wۼ�2V[XUHx���x�3p�K��n`�r�y�����G�Դ��w/��~�2[TFJ�b�h8��Et�;r���K�������`y1XVh/�V�������d[	��o\�l�<�չ�ޖ\�<u|���\�y�!%�Q���������xv���g�0I˻�m܋�sg�zv5���u��{�&�M���t�`��2P�����=��$2$����[`��d���T�b�Ⴈ�8�-�ǜ� �*���̫��]����>ܽ�����஧.�P��ˉ��a�E�f����Xћ�����jR��FN��XeA5=�E�"z]Ҧ"�;$��,���":+"'��
�	gV+���-7�Z֠��V��q�qߌG��:�����#� ݧ���&�h P��"�F��i��������l���<:�v\�~��>��>�R})�ћ���q�98�r�n�f���z!���n�$��r hDI��XBG�4Q�6��6.���$8;m�`�S����5�
�cJ>_�Dt3R$�W����P1���$	p2)���R܁�*�}��Z�	� �<����L�ѐa4�u\	���=���8M2zC��TT�$�#L9�XR~�9N	fu�_�",������ ʇP}E6�ur	޷j� ����M��Fq�Ug�Kp�Gc���o��F�SE[�5�M�	����� Jj":&	�R2����WҬ�Ե����%C�9I�_V� >��z��N,Vg� ^W ��@����G�a���~=�-�i���y����A}����
�xk���ѹz��S�`��~":
T�I&��;��KI��� 5p�TQ�k���퀑g��D� ��Dށe�|��,3-M1I!Y��J�p��ͣ���r ��pk-=O�&����(��,��B6;؟RK�f��=����
�u�dc�6��v�e�U�d�DGy"�Ҏ�X��Bw+��tt��'����=rp�s�O�ov��ՒIfiK/��/�>;~����S�ut:z���m��r6�������q�Dk�sOm:��|7}%ׇT��پP@Gɚ�� ������=ș�谁�����6��i�t������t:�=:}��i��=���MrX���"�1;����hlFQ��/��f
.{༣�:-�h���;d�|�8<�r���PN��i�<�_���pX�Q�~����r�Ҳ/Ȣac�L��C!K� ��
d�\D�1 e��	m~��Ղ�()|�` ���خaº]�@<v@���%�yA�KS5-/�����Eښ�DKJ!lV����)/���˯n*oۇ����׼��25���J24��Ta\{��p�+}���l�#�0��
`U&;�(����o��Ix/�շ&�y+;��@�'`۳��P��E�~�6T��L�j��C��Rr@�%j�\DG�N'��-��{�fn ��0����E}����Q,ǍG�`��swqΠ73�*� )�Iq��5�\�]����n�Xr�|lmbP���+��yJc���������eG�����<=/4���q��_T������臚g��F���L��ճM²�k�W]�x"�jBB���|��o���/��Zv�o�:ڱ:���I�*�ɿ�v��ļL=�"6�����0�g�������1C�U�����'�D,VhLn��¢֚���J�a�1G���׮B�Z'a�����tSab~���7�l2��(@�:����rw��2�Ϯ��-s�F�V��^��@l�Շ��_��/�E>"�5��ú��I*i��U��@����W�Ć �aQ�d����K�l@T��6�>Ē�V*-��`PM�㳻<Q߸�e}�n6���>��DR@\�n�h    �bI��pw�Gz�.�A�f��*Ō-0m":&�=K�"�@��=�J`��[ē�Ѽ'ޙ�_�R9�N�a�8X�ZL/����r�މ�|�s�Tk�M�W��)sz�;��דyuݔB�ǝv٢�^�Y/�TJ�\1��)� �cҰ�2�؈�E���j�r��DRW68X�5�$�.$����w܃V�o�y�*C�F�w�$Cɺ����~���5��JӐ��&㜑Ɣ� �c�xlp�y]��P`�@��4Jp-��(�W�N�4�:��")����j2M��"�=M���;�^!c{��k����re�N��:`�\��+�y|����|�0ѹC5���.c�<U��6B�nXɋ�� ���&Q�y噽��%�9;h1z��!��k}���,�^g竳[\��o�By1ğs��͵�5��$���l6?8�zuZ,�#wWx��KIf���������])�.(|~�����Q����JvH��r�1%{�'oA\d 	�+�K��ͣ�)7�Լ�XRe8��ل�A�J�B�+}�8���}"}�`��c�֓��RGT¿B����{ѱd��O�0@Z�j�J��]W-��l=�4Jึo��<0�!������˧��Z����V��T�B(,�q��?^.��� �59�.�}�����n����H�ڲ��\���P�׍.O{겣��t�k*]����)��ɨ�XD���S��:{�� �Hf�cMJ%������b��RS�ܽMDtk�Y�ۂt;�"sp3��ښ����a�ջ�����<�|X�*)9���z�kQ���ώ�c��ɪ���N�T�\��9��1�(ĳ��g]�.[0�}��F.�$��=�>p�WcF����2�3�ٮ\�"ѕ��K�Q��ܝ+o�m(W�.����,�p�88w�X�ϐ<G�4Z� s�U�&j��;�p��T����M|�XH�,:�ꓛ��aM3�%�~�����l�]op�5��}���!ؔh�0{��L�0� @re[玛���@�M!�_���Q�:�W·���]z����'q�EU�7�`��<��"�t�B�poUhS?�[�Ɛ���]�#����h즷��t1N�k��������t��@Q�=w�4��s6��iyRr14UD��AD�x�*1���x��0Y�H���6��["ʸ��S�K�[I��P���t�~`R�/W���p�0�0f庩��O]@A� ��J��o�8�C����Y���T���Ɇ�HA�݃�n�������
XBp�	��[����]R}��q����w�S7��AHCdS+݃�.}/~Hun�E*�3x"Hr��CS L�nH5$t��B���4Ct�����]��R5n�:_�#醟W7j���m�����B\jV�=Ϳ��Ḍ����U2��{��A�=dvH$x覩��":�6�#%�ӈ�Ę�g�n�m@@���º�H���v�":A76��3ܴ�?���M֭)f_��׳+0M`!K�Y�nv���-A�qR�o~���S����O�V���}Ql��Kls ��Ell���)����I��!GX�^*NJ���<�Un�1�-gND�^<:�3Dm�*�F4�;�R��dzY����m��˲u��)�����̯ێ��
�9���l�~��.��P�A�VĶ��^iD�G߿�����f{��`�.XX��p"4��Օ�OS�w�V�/��N�O��wP�)vqF ����Ŭ�!�os�O�ї�4J,MBLR3�̐�p�=��xpB$��C*�$}_%)x�@y�m��l 7#�(��B҉�S�3�-m���3�m�����eu3w�S�>�嵃Щ= �߆q�/�p?���]_��ϒ�� Жg>�e����͝z��;�z]�z�*C���� C���m�A�6�Rm�~�}1 �JH�Tz�Ip��� �앀��Q�U8�1�Aq�Y�J0�]�����^�i+��q���:�^S\+I��8�b@mJ�[ރ����γ�?;ǂ� � ���'>�X� �z8��2�o�G��Ǧa^�c�)����^s}p�Yi��b_�{�U�2	pxv�=�^�X,M���R�b�;wNxZ�e��Oճ t겟�t����"�����u{`W��Z����S��<L��"�n5�b�&1d
����V�El��r�O2����3��u�Q;J�P��m��$�~vV�:h��f����b�50[7q��>�c��{�ɻ��,t�.At9����M�{�^�e�
�]�s�1�	�v ����}���6���;�����u���sY�wbl���
��X�����G��t�Ai\���|(�d|���I��	��r0##Pc�~[���O����H�A'�"�8g��u��-|��+*�B��&v�����d�#�:S��z�����6y'��4�0 �y�˶Ȗ��d�9�cT^��쇻��O����rH���7�Y�c)��WT �U^~���/���^��Ԏ���dM�}"6�:>�e�J�A�>HV�5a�'�}�:�ʪ����3F��*`i�Ps���H��g�Wx��}����\�>o
h<����7���
s��׵�U��4��Q8Jۍ�}f� ����{W��{���_�y� M�q:��QAС�	�;����U��$�!� I�̫�n���?Yw 5������-	/0	�
���6�� ������Js���� 0�vP�'}��y�xp(�f�$}��ݷ�K�x�H	��M���!�	���ݔ�혈9Lݧ"�ڀ�6{�%%��RR�Dҭ�����-|eԶ9}��j�5��:~��z��M�����@L�ʛr�������9��l�y��׆�^}�8�xf&8��l��K�I���ٲN�i�{̉�)�Rѯ41iB7%�S��d�%�(DsW����U�����n�QP�0U�jId}���ӂ��r��G���y�6�kn"	�,ˁ\��r�2��m4��v�� ���L�7�5��g,����nkrѪ���������s�VW��T��}k�Yg��=���:���^,���4��k~]�X�4��&(E�D_,�k�����J��i��'��6S�J���D�ԸQߵ��i��*�D���{.0み=F�@݌2)��νf���3� �264�a��\{�q�:+ܑѶU9-�5-L6>�H����vfq�C�w߁�'�J�sQFDS�݃�.e�@�+���,�n�U�ar�[m����{uzv��n���u���v��g�9���C�!6+Kv���]DGAB���,i��8��	D7��� �}�Ԭ��Iapא֨� ��%�x����G�/1A ������f����V�T+'z���j^.��7�6�N�� YZ˜������K�~�[wa�}7͡�{�|�����],%���]�->�d������I�����9��tRR�칵�"������R<a�Y]�>��<PP��E�:.r�*G��nN���k����a��/�w��w߿o�o���U��#)��"`��7l�u����}�yd���3�������G��*��6{��x���ѵ6,j�������*�*�{�[&>3UJVm�_?���$�ܫ���³KV�@��Ȍ�h�p+�kz{�`G[u����^M��AD}f�Yt#���!�7�Z�ADɏ`T�����Z�B�_�Yj����v�Zl��e��2Jrox_􋧐��[k��(%eu��
�],���o�I-S}2�T�_�A�f�n�m�PQ��T�5��r� �m��s�u���	�3��\Bc�#����`����M0yՔ#�FR�p��ɟ���ڕ��d�0��,<k6�Te��cIC��T��e˳��8˙��_j���E�+b"�}��Ґ$���Ж���ς��\�ޚu>T�~����h���QM��K/��quv���A��:���~E�|�����ן���xԶ6���D��g�c��1��9,�	>{�*v�"n���V��2��;��Z�����D�h]d����
P˦�����n v  ~����|˦�g#��r����1Z�X!wZ�O��@1��V�ŕv0׸{��qcq���|7��[p����l�����x��	�ږ���I�0K����h�nta�xFau�&X]t77e���k���I)�.�
�w�[EtӁ�h�H�>��Y
���`�����0��/Wb�zb�	�iÛǑ�AD��UX�/<�㖏?��V7�_����x�/�
���a%Ɓ� �k,1��m��{ ��:���s5���ߩ�>��˒���c.��"��v]��s�<3fǽV��`U��v���]�n/�$�.u["ejs�Ϋ�g��t��5 ��0��2We��ᠬUZg�=�����9��s��{ʹ��!�����9]���]���3�d��R�>1��&����
1���A�;Όv#tWj�,(h�۟h����Wn6SryHɐ���/��1����l��n@�6��i��"�+�J+�D2�p�spcة7�h�I�t?��S�S�U7��ۃ��O$�M�i��g3(n��xv�
\��J�n�Ul`��ʚ ䷠�ލ�w?k�ܨ怯���9��썔w'���S݃�&�2��q֊��#1e<�Ɋ�`�i�b�v����s� $�W�'�>�X���n����2�\�g�K3D�`��>�*���A@�DTZamp���n�y1-^IFi�%���~���p�]��\�ݒu˟d����;W�K�L�!�!�U�����ww���^W8ЩXz���O���y��r��_^�d%�oǆ�g�� +�,��ʇ"r�r�p`���sE��[��n�6�Ȁ8���m����]�@�ƃj��5�<�t�	����?N���\חIy���ٽ���l��Tq<��ώ�v�Pp���b'u>��؇J_�'^��@Q%��Ђ=#��]D'�)��J�X2[���������p�p����ЕH�Y�
��q�^�} �>gY�J�6�=����\`W�n��#ApK����[�>�o5�KkQ=%����v��\����6����ݷ�x�0�=��W��ϕ��Z�����F�_��A�G���4{c��
��Q���r����x��r6����'ǩ�5����k%(|�-Ѹg�K�3/p��"���Ç�P"�oSԊ��Jh�#D�T� e�y8�p'�QpgS|�5 ��i����&���Mݤ�*�k�e�(�=�螓/W���-��A�7�52�sѻ���bϨ�S�0/w�����#G��3l��Ϊ��ψ�Ϧ�DTF����j��^��}��7z�jx�A�RIg3>yo�L��g��H� ڃ�]�&|R�h~�z^e����;ײ��U7�ٛ��"�K�jyR���e�s��M�2#KT[�Rv��}���W��{'�      �      x���r�Ɩ?z������uD�4t.�hY��#�*I�w��*� "b��� �(W���9ws{^cΛ̓��V7@���-d'��lۢ�F�^��l��\q;���!c6j�gC[D,2R%R���ppgffY�������͏e�Y`�Ǖ��?Ջ2�ì�����Wu�qRf|v]�<�X-���2�6H�(��jQ?>3��|5�����˲0�Y=�W��>_���3���yfVfZ�?_,�|���?ga�z�����j�q���Fi��0�]�Iy���Ƥj�Cr��1c�2q)�P���nN��A8�jp�W��%�
���E�� I?�������ep����.�G�n����b����>���!��i3�Q��i'E��#�D넉��*�Y����v�X��Q�����庄c4K,m�������
λ^�`51s�����G��S����G������?��� -���zt�	ɑ��~�2kj[��@f?ð�S��a�;xՏ�2{j{�(��	̂��`�"�y��MS[�A��< ��H����z��`j�Q��v^�a��Z��@��C���&�LW���Z��j��mȰ6S���k���L�8);����q��e5�1�������Z��r���+���Z��E��[u03��I�`���Z�Y�M*�a��\\��=~՟�b�/��r�vZfe�g85�yU?�0���\Y��}��Y�z^��5��Y�ua2\��)�p?�T�j�r��E�LIe��jӂ�:	����-S�E|��HG2fxɞ>B����k*��,�[�������S �	F��}F�ׯ������4�_��[�݌���'�p�e4�~�s��(&��ݚR��a�Zn�L�`ҡ���ˇ�����o�5����je�ޕ�	�z>+�yo�)��M��6ܗ��0uk_T�˓u�7��ч��;8ڲ�j�d�x?T��>7��(�҈���ЂC!��:ʦO�C���X��P�T,��#�a���{�ia�0�H@4�77����No��7߿����r/���25������P�\z
ρ�y�D��	˔HG�� �x���l�����	>�q�}P,r'��^�\f�3��<Uib��6��c��G�)�dfC"vۓrSq:��^ݜ^��n����b8+tu�	��ȎR?�Tr����dT$�D� �y\V ���f:p����:H��i��P@��]�H��%�M/@LA�,}wa�Ŕ���$ط(o�r������b#2A?�w���֫#����ɭ�D�G`.�zE��A�Y,��6����7���H8K��C/�	�-Qh�/�i]�̾<���2����L>۱���%���a��/�4(��0��f�����}	6
��<���T���QpZ
��N�=�M�u�Dn�y~�`e�P��@�3��l ���"�^v�i-
�!5�r�ԨH���pK�c��e8RB��xUz�M�[�)8���Ƃo���2R��7Wg���E�ÿ�o�~%ȹ�N��z���42�#�yQ�:?9Zx?�>Y��;�:CjDR7e�w!E��r�%�E���gG�/�,�=�|QMK����Q�%
6AZރ�����M����Oˑ2I\��x_�	/a�uY���8$����;d�_BʇO�@��"��&� ��u�%L}*��M>�K��>��p�~sD�t���ǵ�w]�l0_��%M6�й�Oq����5�G�>����z_���]�42���t��D�4�Z�E�w�@�d%F@�a����ګ �c�*(P��O����j�{���4xq~z�_ᙳˁ[)\	~��1<cF�h�Tl�	sLb���L�M����p�\/��\�v��/�#�8*�l��H�������Yf *�h>�@/K$$G�H5j�@����R��A^�W�`�33�3A{�[i} �GI�	b./�ɑ��@9]��r�0ߖ�z�;~f������ꁘ�R+TY��I���@4���̀�����e��20�`Y�I�P8�G�=�jV���7�9L�٥(;��ހ7��.�a�Xhs�pZ`d��\�N�]$/��-���5�YЯR;��]��T	��:ɒ^�cR�i|"��.�`����/�ħ5�� \�T�b��� � >�U<�Bs�צ�!Z��=r��z��kM8x
S���~1�o.O���ߝ�7���o/�97l8v+��&��0��5I�
��!/���@4�������JyUf�����������(8��&� ���i �v�ɹ�6 q������gH|�j��8Tbt������8���»�Ł�W�#^�e	�!��os$@��)4���>�E(�lw��4��m�C�5��X�����"PHz���7�������eq�������]��	��������R��SN������i�(.� ���p��i&.c������@�Dl���D�r�F!f_��YP�0q��x8h�&z�i<}ݓ����opzG/KD���&�{�i>�D��R�&]s{��C6��qF
lCt(����������>�nN_go^�n�[9;�I ��.p�R3ո�";L�E��:3
�M$㛛��߃i����3G)���5�rF�F�F�ПG��!��E ��%��KԡwMV��s��SC�nc A�&��˹Y ݔ$���,
gGf�r/^f�%?,��u�^#B�U=1�e��<~b��]���.�p0];��%=�A�{lIHO���VD|�4Xʍ�����otɘh*<��(�q�H����H�O�f�?�#QS)�SD��ZG��0(Yp�6S�B&��i"�(U&̾��?�eƜ�윆̲,M��Y��Xx�(�"!��?}�ߊC+�p�b�����,��PGaFƑ�n�띡H�
���Bzi��I�CmY��P�r�Dn��h��u7��k���v�l��}꭭}��������v��	����
���0Α�նi���/��x �}�3�?���^ܟ}M�����-�N��5
6-�������,�'�&0W�7.uѫ�#p����k"��]r��+�$lL��Rr�da�c*���
zE���Q�d$�3U�<D�"��L��}l��_���W5���8ލo_�_�ݽ����� ��,�:	%�bDqh�Oݠ$b*��5�@x��n/S`�)�Ϣn�?_>w�����=���ʧ��ʴ�:;��<�"f\���-ڡ�U2��J����!~}�S��ф2���F3 ;�T��p퉆j�"�(D�Kǃ�o�7�{3/��ʪ�z\����K��\,��6ȈV��PI� �5��g3�\�X��%ݠ��d˪�����A.�W:��{��JD :;�`
Q�q)teIa
�9݄t8~,�X��x�=�&� ��7���in��}ʉ��w��$��?y.nу���� �e�h#
e�ѡ�
�8oGlp2)��҇��ym�o��2�<��2� ���ڻŦ���T�t�b<�q"�%����f%����=Љ:�gk�321�E���`b��$0z^��
(=.�}�\}��-��8��5BìԲ���*�\#�aEe��m�� Nh�5�>D��]���q�t����>��8�nNO�ڠ+<�s�0(��AJ�N��Tn1h5a��UE��I�}D�u�MI�;�4�*�2� P����8�,q�5'���!>���#�In5�V�&MbLդY�q�1��?�>ы.��)l��
���Ncm�<�+�F���N��!�t��2���������;{o�Pj�<�����o7�tX������G/I�(��c��kLw�ܨ\X����|�"6���֋e����&Hs�_��5�l0ژ迂udV`��.yj��'1g`oXJX�>��nE� ҋ|	�QP��:7���7!� ���܇���	!<r�e%kln���`��bdm6Ԙ���&bឦ�n��(L�    �>��26q��:uY(�s./��j�1jۤ/���.�<�UO*�{K
w�b����\2�%�-C�E�����8�r�h^\�a��2\��5l��Rn�D$o�>�����;��1�1�e�3���ې��l:����<��4Cu|];*��cG6�Y�_3��lG%�KP�V�a�ҦU�DM�)��dY��f��%� �?�&X\w-��p�Q��_���X/]����:�W�j���W�c��?mR�O�K���{ '�����bP��͊���i�8�[V�/f�Y�D��<z�&lZX�Y����z�C��h����==1��H��`{��K2N�y&��
��|7�d�G��t�Pr�Ӈ�#,\�<vِaM�����j��o�g����ۓ��w���i�����n��Y��̡P�(���Ԁ��Tb,M$�C���1X(����ݙ8�E�<Y��Ԓ|�g.����K7�a��/��?��؀\�I���%aTu�1�Pb]ծ�.��d1���{��=>��^o&A9� �>��Y���Y�E��-B��L��X��z����z3.R[�W�I�M�aQ$2�@�"��!�!��%�� ��H0�ao:`1�7F`r��a�?�,�PZV�U�_|�1�Qq��q��1����5�F��XA����`3U��ʁ��=�<m�M4�$�f8Œ��v���y5������"g�;U�3*FL-~��������
t`�N��5gf���?��V��۴�%2nW��&�(�����2�5��l
B���9 |���|��$���u�ZUp�\e�UF9�%�G�#e��g_h�)�:g��9�8�V�Hǭ���X�2 F@�.���ܔ>W�Jv�l�۷ק7�������<�9?9�VpD1Vp��qXh����H�$T��%�K
im,"&B!���71�139��{bKbP|� 5�Jt*�(TئrK�e�F\e��|���p1/����yw�ͷ����~4��O�[�?��g��KAG�;��jSn�"� ����s|���_f�}Wib8Xܺ��$�"Q�#��u�v�4c~̒Q�`�6��<}��<�1���>F�CG<�e�,�|{�mpyzd���p��W���(	C
��lJ��XY�bT���yp���epV����03*d%�w�a�!ר	+Z`V��z�hô���ɷ�:�R��t��������w���9fm㈊���9��Py��֟Y_�
�bUYOB�����s���WiMkUv�ġ���Nu JY��^J(�r�{��3�X}R�Kei��fC��^ܞg�x@^�A�x�ׁ[&�JK�{<���U�D�a�Fy���H!��j@D���b��,�B*��K�0�j�l���6+I��ݒg��p�8����7<��r��*ɢ�ރ6�H�]�m0���&�o�[O¦�l�=h��P3�h7��XDLE�xĹ��f�`Y�w'p]���4?���1�.ʊ+�z�C��]�x���7�,\a�
m
�!�]9���@�9i�o�U.�ɻ�4�t�|q��)�C�p\�����
}4��9Mb?1�����Vj��
�$��Fc!��L���a�}#O����躝�|&��ʁDWW��y��j|v��f��w":��gK
�Ɏ(e
�^���\'Z~�������=�����k�-Ri2�K�*.�>2�%��ZJv���:a�~�0D���GB��������M�c�N���4��'TH�d��]�]:j��{�$X},�ޫ��䫯�j�f,�d�]$٘��q��5yګ�n�\�� ѩ�[��C� �m���O�:j���4�~=�8��i�>�#�M5:��Ox��5όaY�>�è0Qt4J�|����7�u4������	�.��r|q��a+�tH~�K>,7qF:MNy���LD�N[�b�;����b�\�ςw�-�v�|����T{�ȁ>8ſFl���j����4�3�V���a�!��Ic*/f�	��b���G`�B��杤��!�xQ� �st'b�&o#>��L׶	M�tA�'
�V�&�����(�@�����`�^2���襝}��M|�J!#��a���&��N�����x�0�WV��!:Ԭ�� sm��)�v��Z`����!�}��!m�<�C�&�Y;KT����g����
giǑ�݋<]���i��}��N��$��B�O��&�F·e�E�8>H��Y�LM�$�����$8�zy>����}�M4)�F�P���u��XxSP�(�m���1RO��N�L
ō�ugd8�Y���f:���
L�����Pm���h�O;3`B�(2��@O��/&�%���Hy2l���͆t��(�E�N���X�GJ	W-��!:�x<Q�X<����y���;'�[���*�g������$h|��[lpR-K���f��`C��C0���bn�R�]�?
6_-[`&Z <y�@0���v��6��ve %B�uڪo9�H���#��Ĭ�D��1�?k��@k�T,�(���Ta�T�h�v����#��X����!:\l?6��j����O�ܜ�5pz|�xMW��6�*��I�P�B�:��4g_���\���RN�M����9(mq�E�<��-B�����Ҿ�!>k�l��K?�7]][-c��q�b����2iun�Y4��-+W�HF���;�,�@��y�6�X㥏���c>}�__��;�r��<Dh�M�������"e\�"`-�`\{��W��#��!����'�OM��3�y�Q8�Ց�$�l�&_��Oѳ�vW���� ���vlei=j�{��ȷ�|�'���(Z� � ሒ`� �l��}LQ�NS]5���i����zXx�/�5�YU/�h~Q՘~C�7�f����܆���eeΑCQkj4ٮԉj~���.�	$��e��ʫ
��kgݠۭi��0��Q���������U����,�6�]�B���R�N7�)���s�U�Y�!#~���,��Ϡ��Q.ho�<Gn�侹��;���ͻӛ[�-r�E���.Jҽ^<��t��DdCEՃ�6��)��$�,����H�)�RQ��]R�q���y\خA�ҷDF��D�'�ލ?JJ'��QX0�McMe4㈛�2��j5\�<��k`(<dR��	���P��=��jˋTL^���#�U��&-w��P	����b4*���wg/��`���  �����a���|,uO��n�/nί�2���^�_�wz3�9��9�`����/u��s��r�/e>�d�A|Zf`�h��s���0*D����Tq5��̀5gE�l�/y0�� �E�0q!���}�����@��:���Z⚍n���h7΋4�}ph-�Qg��-�0*��t���nn"B(4 �1�N��0���9�V�D^eI�L��0��l�T��~8��Ys�vg+���b	ζ�!F��c����%�0�"�˅U|(�oRs4�x�dL�J�!t⁤��Y5���~p���R�}����s�Qn�&�cЩ
�uf���:?�dFFO�ؘ����]��C���T��$�	JSe�l5���*F�ŨX��!>KN�rAd���8��7W/��	!�b/���EU!��i
����~pEU�Vg������l�ƞT�T�6�H�v���f�g��Jy�>���F�I5#h2L���Q��Ż�S����,�ܠ����T��*��k̆�DWg����b�.
P��%tW��Ƒ�J�&:��g��l�:F�w(���(1/p<Ŧ?�������yF�
X�ɑkG�X.%�&9��(�6_vS���
��*��c��b�8zR1V4�@�R<��;����ʱ��r���x�w��X�?�!E�L�; ����Pr�ű�R�MS0ċ�����4/�s̓���;Kn�%٩@�9ڙ�n��7����a7�L���)�>��F�|��'�l���pA���0�M��?�9�|�    ���0%�����e.�OU���a\O>�{hwk��v8�Y9�0��r�� ����wf��b3��>.�J�ry�z��(��7[YE�>�'c�_a�BO
m"z�\�T�IhM�ͦ�\�Z�0
�Cĵ@��a�������OpF���������o/�(t�z|��<8��|{u~�=}�<�֋d�B�qv	�����D�a,��R�@؁P`��B� �h˩}�H�#|�`���U��~����,��R�$���N��:��d��.V�Q�y
�O��S�	�A�N�Ȏ|��V�8򽦖����ي��~L�k����I��u�^QM1�`�*�W?QR^=�S�꼬�!�Rv�XO�ؾ����Y����C�T=tz�.A�J��"�9Д6�q�4��v��zb����$J��C�9Q^
h3jqݝ��7o�X����{�g����ۛӋ��ˁ[(���v1��F]RJ�4�B�y��4Y����j��ˇƃu�4gq�N�Lj**�˼i�4��񺜕�|By�&���y�SJ<��.��]w}7����IwT��:5�N����[D�J`�nru@Ԃ~ԟK,QA���Zg�h	ӹ�ͲM��c�Cyo����>��ѵvň�a݇mF�[���5�[ET��)�{x�*��2-vi.!�7�Uށ��!:J8��-�c�N�<�X��^�|ߨ��W�����E�DG�I�F�����/��y��gߟ�g_����tC �0�YD��a�՚[#C@�1��0DGG�Gv�;�V�!݊wHT[�{���F8²�#��4�N�aA(�f/0?j��U����ݤ%�<Ii�]�d�_o�dI}��Ʃ���CL�Կ�@A:��������չ��h@�3�������A�5�Y�4+�fS�I�k��I3�΋P���oL�K��i�\9Kof���H�Uj���,	��!e���0Đef��U
�HD<��Ƨ���6���E��� !T||P���8�I��k���Q`{�"1ʘLbd���S�o��~�l����2����&QQD����:B�&��#)�R����C��ݨ�Js�5�/M��4�~bS�()x�0�KjQ��4����.��"ԣ�s���0�/3�>�j�<Kx� Ǎ��Y�|���Ĥ�QNE��H�riđ)�����.�����!?;���\lk�u��3КS����2��w.�v�^�B�~	�5j7@��U�!���L����nmS��&ב�r�4���A�\(&Q�J��zm�v%��y>}��#���,a�#�/�|�=�6�?k��y��m_�O�Ǯt�ݤ���T��?�E;�݋&��[��Tj
���NM�T�%��7KW���D�l���#D�~�	��)�8S:�����c�)
��U9�!���WK�!S�[{��LP?Wx�1=�н��F�SE�����S^��(� u7��[s��b[ �X��Q���~�a���~��h���j'U�����Cn��1
�n��V���(j�LrUUlY�����Lm���C�B�8�-�E��M������#X{\7��Y���yj������v�B���0�X�-\"����?Ko�f��?�_8�n��tXQہ$���k�ceP�� �^�*ڕ}��q��g �]H�"�nr����|�$)qMɃ=�e�qb�Ln���q�E"8�S�AT�"=�����<�E�y���W(W�� �.�8�T�#z�\����/A�]��\7^�W�P���P��)Jj���j����_�"ُ/4�_����U�ݙ�'C�"%J�D��"IP�\'���P��ξ��f�A�L��ͻ����i����m�B,������D�G�d�'�m��]���k$n��!�L�l�^���+�#o��׼W	�nj�Qu<�M��.B"q����h��+����aG�
�tJ�נ��J����Ay^�#s�t�`Y���Mt�u�%�]_P��po�MEQ:E״{�����`�ʢ#�N��G��s��D���4��ҋ�Q�6�E�e\���4�Nh�z��g+��R�B�}�ca��n!},�3�X���Sd|�\�il��?�?q�e�t�z���&�"y�ݍ��5e�P^@-��n0���0.�~"a��Ks_�]竭��_m;�����s�呮��Z�M�2f���)����(M�J:����b����q��3�@/�%���4�Kg��e�x�@�M�o��~�Gn�������li���Mf���J��W���.��|j�4���]n�����"�<4D
W1�B@-�أt�Q�h�h����P;	$�O`m�����G���m&�d��/X�*ƨ\�Q���0FD��FK���Pb�_;��Ӈ����X�/�}|���0�T�br�������
^�`�����MdXi����ٻҳ_�+�o�dqb����$�$���q��:��}�J`�1O(���!Z*�w�?��G� G�)%�"�q�����i�\�,9F9���%<}���mba�	�C"	�e
Ĭ�I*Mb�M#0ͅRrpc0Ӏ���y$ȥ��Y�+��	��bY�^��D@�P��.˧k���|G�=靔5��k��f�t˛WH�k`3�2k�3D4���I��^4��s�|�&�m�~!k�T¤Fd�<x[�Ih�<�&�v)Da�.�?\��0�/����Yߌ�oϯn=�ZCS���c�:f�(��;S6V�C���c,m�닼��ҒJ�����ǉ�2k��͕�axJP.�v0�=�9�Ϣ7���ȇU�O��,�r��pP=�l2!i]�j����y�>�S��m��i���.�n!�8�<}�C*�~�lsR�����tu��v�9�-{F��/�h���=��]*٬z�0t^� �Z���J�pY������tF���mBS��
�TsP�+�8����[��+0d&݆�G���T�N�x	f�1W��3���h�-p�҄�.�v�#@k��$�Q�$�'�b!�=u�����w�-��H{��B�ފq�M�ۋ�㛻q��b|�m���֔�]�x�8	�0d���5����������Y�N�g�_��J_����h[\�P��r���~���l�ԍ�3���+��Mi�ƃ}�2���ak�u��Cd��9��k�N>����+"����.:�!�OI�������3Rk���Ȓ�K}��!��0-F�,[�Xp[��R�&�Q���=����e9/�o��ؾ���~E'��O&�<�:ߦR�	D��}R)�L���mm}�>���uX7�F)�f`��$u�@z3U�%#��Q��(x����o���Lq�{��y�d8Иҕ��+
pw�������e�d��(f&�"�Zo�&�X�¦6ea�!�Q���S��S�|��!�S>y}~qрr��1�6n�ݛ�����H��6�^��%,�tK�J�~D`M��"1v��q�����:�?}�����L�:�T�i���k��͋	�.��� ��Dv�^����Na�>���?ӣEG��U�a[��]���!A��"N✳|���\Mb�h�ګ<y����1�^�^=���R1������X�xp��[�{,��]�֔I����dk��Z����N���a�&|{��ԗw?N�h�+�`v���j�b��<^${|�c*RE<q�#�>�/k���o��rϹ�s~r������>����Zmx�@`�륙N�v1! ŪZf�Y9�e[ZT㓛�<C]�H;�\��g~�I �=B ��(�mZ���JIDL5�k�#�O4�(�:�eO�C �r��]�%�n�oo�WN�l|Y�N���>�F;�E�ͅ�����惒zH`�|�BP��P�~�\�&��v�N���6:��a�����rؾ�0��rX�<5Q܌���öpQpid���P0l��Ě{�+���;k�;,D����o.�O6�9�S����X�/1�����}sU�����+�1ȗբn���TSz�R�7=K0#���96%������Ӎl�Ԛ�=֤�+^3�'�Ȳ��G    �EF#�5��sU?y���޿���Q�&~qz�f��+��a�h0殖����E�wU�9���I&����]m&kP���z21�ߗ���O��~�[_�і(d�0έE5�	m�d�h����l@9)؂v']v�S�L>�cmrgwg�,�,f���\�J�3�JqU@O�M�D\w��۳�h���P.���!"0m!9yF��6ͱ�i!Ub�{�JPA��!���`���ԤΆ!md��ð�}R���x��$h0��е$z�-_�D���I7L��h;��F��Q��<[I�:����E�&��N�/�[_R���ԭ���47����3k�����Q��#׀��!:��w����I��"��3��aZ09��a�������~]47��c��$ϕ�	�A��qJU���Lb!#��z�nN�x0��l�����&3YX�[����e	�{�[�\�s�b���Xp���H�]�����Ǌ|��!�3��X]_x1�\G��Z����0������1�"�SY�Ӈ�Z���(b(�f~y~u\�����������px�2�N�惙�0|s6�@I}�~��f`[��� E�����+4uj-rdauS��*���0
���pS���s_�޶L��%�&�7_/�R�I�=��P�����y"�&V<g�k�-�P%��:XT��tm=�jJY2�?���&�`c���(i�_w�o�hQA�\y�!�oB�f��� ��Ϧ��x��+�2���t	 �ЦL��E��}
��(�?Īz��+���_F������w� �r�_�~�r��|��ͥ������.���`l@>��܀�~����җ$:�2��N]��C��z���)�@3�$�M�$HD��S}4ؽ-]��}C��f����$�._	o ��r���o��-�K�*y�6�5�Aff~��őr��%*�^*c׶6'���h��%��" ��#�I͵r>�.�NM���f*� o�|��U#R֩oya��O��,m��~�B/���	���bP�))���k���:�F���4
D�s`Eu�ߒg�z\�5qY5�?ͭɏ��w`g-�N�\�8:����%T�~ny����X�I����]�^05���mA9�v�X�	"J�Q䑜�<����'/9V'��SN�?��6��:����+��_���NƷ��j̼;����0[F7��C#·2Qa�/������]�8O��p�K�,U�V����MN��2�G�V=�_�äw$����M�m5���}���l}�k7���aj>�_D�9Et�5���MZW�ԥ�5�R�_=+�y�(YC��HȺX��NW��5�ࢃ��2�V|+�E��zms��E�ꬔ�PO�Q��"��@y.QG�[A�`L��
8w����Ez&�=a������i�Z��
��R���(�cR���ܣ���m��e�W��T�,�����j�ķ0�a�_�?c�{9�}s�k� c/��B%b���PCo�-4�~�����#(jmd��~n^������7DE�a������mM�<R������n"L6a��{�M;�Y#8�1:G�:���f�ސT��-ՠ�{�i��P�,QI&p�F�x�8N��!�a�C��O��-sP�7���K���/ ��?��?�w�Gf�ĬA��a���?�m��"3�։�P!�PZ�y�r��]/���M2�vw�I��kc`��Cm�G��]���:���ES�C��pl���O�tF}Z�6Z&�1�t�;͖�@8���k�<��R�k�eJ�k��\aiN�6c9�N���Q 7{�Fn��I�Ŵ,V�ϡA��Yaә���B&���Lp�ĦtM�[0F����o�j6/M�j)��~�Ôf�=��}�ů�X$R "j
�>���饿�e�e�o����k�����K��a��G��ni7�۹�/㗧`�]\�4m!L� q�3qb����Eh V���u������.y��.}�E��8US��'�Z��q� ڞ>�/��_�`��Xl�[�0�X�$���*kND�һ�Z>/A%��Wf���zAɝP���b����/wa�=_} �Q}l��z+�8ܞz=k��|ˌ�>j��H���������J�'
0����.��b�w_{C��-P�E�܂AP���Tܾ����mr�&v��}1��D�Q-<�u�������9��.Q�5�_�/~�.Ѕ��S\�0��a��\���#-�(�Jg�=}�ڨ�3R�77����k0��������z5�'���<�v��٧�QC��"Γ,11֙&lp�q��$��4��e�S��>+]��@�g;6>p�S�F�����qM��祩�]:�^�[ЁV��w=��.�N�����N�m�
$2r.��~tQ�_�NaN�+h�sO���TS�nzހ8��7�V$��`K�)�2�`=��*�ɽOY�}d����~I��?���s]o_*�0���>�) >�Ğ~�>���g{��^��N^ߌ��Ήn���E{� 0�H3��u�tJ�f�	-
cZb�3J��W�3���imK9��8߮���,Ѥo ����A��.�j���s£��t�ra����C�gMA�z�P��t��G=����۰#���M���㻥��G���P�Ga�'��}*׃O�j�B��q����X6Z<��nG<Oxs����z6{�Mݏ��s�ڽ}�"
J�J�]�`iƘ�@m��Rr�I,�	����h�,�c�	��gԀ�E�ZM�+��e|\��x �u ���B/����A�6�c}�Ր���*n��O �`׌��%�4�
�QP ��v�'7 vЀ!7f���.��J��e��� ��p1�]Bo0h��d%$>�ơS��M������/�נ�е!jŞaE��}Pj��o���6=��l���YSMu(G B��M���nÏ���%��ka��2u,f����lm��=%?ŏT�{X�� S6���[xʇF�$Q��n`H���'d��0D�I��>�K�-�C�3B�@��`#�i�8~M��kt���=H�qpw3�>���i��#q�\�(+���4BQ�lXR[ec:�H�-���&� ������Wl^�h�����)rof��&��P�Jp���2ڙ?���hMЗ?N�q�|�p_ZD�O�$Ď�Ѿ��å�`��#)2I���0��<�)�R�Ǻ��n#.\M�Ӈ�!$8��;��@f����e|vvz�}�����yp�]�M�����0(���/z��So.4SYw=&cr�E�b&�T��(���a8�U�#��!~�z�\�/�`�\0�,U:�}˭
Q$�gi(�.�%\I�A�Z�>��nN�Y.�a��K���V���]��D2&EhD�
���{b�2CpF���I��N���B�m����dB�a�uv26ԩ�e�,��N���A3�u$5QBCtt�O��aF���6.����5.��Z!�$0��t��"�Ckg���!\�܁-l~�����w��*�G�7ޙ�3
η̐Xo�9��WO%�a��37f^�X��}�t�c?O��.@��ΒV�x�G,
E����������H���ߍ/� c_��NO�ZD4X)"i&QeJ-q�:l�f�3 F,�P~�P<C1y�-�J���".��y�X�n@|�ıP#�E�(Ӿ�!:4��`(fQ����f:���R�)c�T�;@���4/���l=G�ӑ1�	���m��V.͇�gd��b6�=���S`I����V�����KhԸ@�yortLhd�V��N�Y�l��#�^=���zZ�G���|4�0�Ԧ�l�\g�B|m����wD_ǿ������CU½���֠��NL��[Mc1M�^������A��i�{�ya��Df���Ҧ<��V��\3��ѪV��Gdw��v��^�/^�痗o�����@¤y��'�4�U� j��,f ��&U*�d_    :!���서�&S6ܣ�\p^�,�a�v�J~�n.	����_�rX(n�ts��	�i3�~,
a��޸����_���W3�D�e���ֱ�&��R	$ܿ�PN��}!p/��1z�������ރ����&,K4߉�8�����V�v��b-6*v��}ׄn���S�?Cs>��%��l�H9'pe�A����� �K��$_?1D�D��P��K���D	���:"X'dYd��U���nq�FA�z�h��N���,�ɲ'EX���ؔ�0��,5�CYa�5$ᱲ*7����)u#sZ���a��&���	�}$�& ��j�+Gz�����j|v������;�.`�1:(Q�)kВT2l �B���0JJ��p�4"=�����<�;��P>HE�z�:�S���jYՔLB�B��@���ayz�ƪ݅"�f!b���vk9��55u��_ ���ir���t��1r_�W m�P<����A�)i=��|��Q�J�$bJ���8c�P�P:�y���̑�8���c�Ǡ]QkCt���Hv�p�1o��a����=X���Y~I�ܗ���.�aj�̒`���җ��M��5�j~o�=�l�j;��#}u����<x���v����	7}v�C5�����E�`����UfY[*:,�"A�
(n��|t��Ϥ����4��ߣ����	%�⯱���V��%ُ:>RY�<��.
ΥK�,ta�h��U���$Tq��TY��!:��cH������C��c �777�/�N�=��%c��A�)b˰�Jl��0�bh�(.��B�
C\þo����7N�v���h �O�����i��M��t��Z���r���]�M�)�T�X��r�E,�FHO�7�s�x8���8���bT
�&tl��oZI�E�HЯ�Ů4����> f�<�=�a�"X�=��4L�8�yS����*D!���h
6�-���x��y jFy�=�R$���a�4�f���\�/P�ݥ��?�5���)J��I�����~�L࣍��)-�3z�r�˻K�f\��h���(8�Z3�L���1]��D}5�IǛ��D1Q��h�@����Z�%��]�°���K��!~�9)��.ހ�u�������Gy%~XDu5�Xxjx�}8H<�G���� �6��\���ieDA-���yr�:R9r>1!���8B� ��#��T��/ H��G�vD@ƌ�毫����yI-�Ѓ\��s�:���*�W?��ME�G:��(��ƚ�7�~�h�;�]�d�K���I&��X�GCˆGE�
ZB��0E�C�30�	�5�H�ȕ==y�_�e������������W����v���@c�ĭ�!
a�6�IQ�����Ϫi�пa�y9�ݸrȱ������os���g���_��1}@uYz�*x�^:�����;��y΂VA�tQ6���$^��g}�-�z׫��}�䟘� ��'��)��n�Ο��y@G>��y�C��O�n��=�M�I	�s������V��s��Lj�x�U�I��69�`��ە�yd����a�-v�X3���{�c���;pq4�3o>��{��iv�o���7�d={��[7;��Y$ w,��j��<R���HE`�}���~�H�v2��_[$����g6�R�@"t��"�R'�>�o`CsU��C3/R	w#/�4QFY#5��D���w���
��6^�JO�AƲ�_}��������b��k9Ţ�m���U\�6*E�����MA��p������R9�[lU���	�S/�x�_g�4sH����]R)�y����T�ݠ��H�"r��Ӈh� {$�M~K,}h����^���U��w����Wgw،����4�nn�MP��f� q~����(d�{$��<�V����'g�w��(�{T=A�R%1iҋ�N����\�=3#���}CuO#�}�����s��`*?`�,�GP,j:�X�����36φ�L.7�%L��(�@�򐜊=q O�t�Hr�mrs�28�x��t�9�#�ƙK��"��)�y���L>�Z�&�>SCg�H��y����U2�"m1�x{�I
G�"�a��0&ω��C͔p]{�C ��\�gzO��TH�e�$,����9IB�RL ����֨v�.�����7p˹� Uo�]f��R`�����E�uw�������R�4I��=H�<��4V�y��ux�P�Qr��s��+$�5f�W[F��c����?yn�f��P�ՙ�J��Κ�@c�Qjs�",�� 2^�~0^�������\#���d�����R��z�!���k���\o�5�����W�}��`P^�M�u���4��a�CQ���Y�� D1>�k2�s<�-�	�e�T#��q����.��X�R��cV��)��ˮo�r���l�G)Z_�KC�VG&w�����(�(�*�c	���B�����a�.��D����KFo�O��/o�o���Ec�� ���Y�C�n��gmM ������b���$�S��3����s�|�&�mƾv�<H��M"5Y����e�"��NʧB�4�@Euա=���� j��$����|�*B�1c.�A��a��%�>Yb.B&��p;,R�Z-r0�v�Hm�H*���C�M,�7a�zW��@!��Ŭ�_W�}�t�,,�.,R���G�li,$H7������)�cV�T<��ACt�:�	�α�f�>�`P��A8$��Fd�Kiz^.rY�)̺ȿ@��� zD��Iԡf��b�aO�DZ�{���K��Oo�a7����Ы�
�K��
?��ޣl+��$�M�����hę�Z��a7�߬
���s�+hܱ��j��
T����Y��?C���n=|�K�H��q����RQ����Z�d�4
\�.�OP{��V���u�
w��.6��!�f8�1�q��4�d�p�ۡ�R&�4O�T�z�ɞWϳf)?�I��(W9���ni.T�T1#:q�ߖ��"&dL�����f��|J��_�U�*N#Nٷ�5E4L����&M��rnZ8��柏t�!���I�E��V�ܶX�M��|���r�����oZxdj���T��삪XQ��&�&o�$�c�F˚|��L�߳�]��SG��G�����U��T<��ho�^����p�,�26[�e��u���D��]?�zږ:�v��Y?�����V�x���2T(�M��
q�>�'*s'}��4cnR��[y`���#�r���G���r�!�G�5g|��Ɉ�%ÿ��{9p���a���[�.A�i�Ԡ���[ɢ[�;X���'p.K����L����֖\w�c������TJ�s�i�m�K(��򀥉���|>Es��}�i�Mm��a\uN���w�5~9��+O9zŭ���3�1(��	�Z�ʣ	뼙,%�7}�(��2׵�\?�o�A���\W3��;mr��oʿ�<�"�WA���sG��GRN��D�y�\�Q�D~��j4O�2�,E�CAQ�VZ��
�[��q��i���z�)�<
�5MI�;�
�B.�2x׀� �ɽ��X�.��Y�M6Ԛ���5>0��ӁY������6��.�	g֔,-�Y��f9����ݥ���｝L9��9�j��_am��1۷4ϯaG�w�0*k�x��d��ݨ���:�1)��7_��i3i�N��)d1L@m��5�j��)�H#��tsz����3��R��@���n1�o.O�n�pO?��$��D&��)�~ژ���p6\"������ڥ���J��C?8��ɨo�9^λ���X��[1�Z�g�n ;���??�����zL��'DunY�ѳ���0F�Q��Lw�;Ux́�j����:��>at��}~��=_\��z��=�^X���@����0O��T�79�͇�PB��"�Ï�`|s3vII j����z�����e�Rz;U�`��Qټ��j�m�K��v5rt���L����&6�ں�@:�Y �,��P�H�]#ͦ�    �я��<0|�e[�������c�\�	����^X,8�ƥ%�;���J̵x��-nTVD�8m���|y+��b�V�d��C�~���0`����\:��J�������L�CQYR�6�jG�慈xJƵ�A��F��������1X�&�Bf7��؁,F�E�@ݔ1�]Ct��o�T��$���*��V25d)��P)�X���.�Y���[��������v��������!��JB���bɩvCT����#(V?_<w#�@#��S��u牒|w�����$�Y'*F;8�.� L�������?��7�M�u�΂7W�o��o�N^�Y��K�q�7�f�II+5'��Y�H�a���5�ʆfǭ($j=aEn����4'�$qG���8U�����[��8Di�aJ�8]��i�_�z�*?P��9Ц�+��墪-�o��r����z�I��]�9�8��kBłh�R�qc�����Г�2����{��j��~<o��`��˕���vE2$p۸�_�#.���mm����VKo]���6�����=�D	2ᡙ��ΐ̦ f�¦��{ʁ���z��4&L�J���.�����Ă��g��=�1E�#)��:�a%������h�/y�a����G����f�>��Y������ƳOzb|���-�D��v{�'fQ��zF��縉����{I.��c.<��1q�Ȇݙ'�RaD�t�{ k�%|溏�0�g���*ş��@B�
������o�O�^X{��⺺ <�/i"_�D�hi"�(4ca���"ʆ:VY���R�]��8LF�%�<��!ܜ~�4�e:�`��hPظ��@mc��7nȮ>=�jt�4jb��P�����
+��֑��GAZ���7f��?�@�^���
�+�0����)��@pɱ�m_=�����0�|-�Ό."�J��aqQ�,�x:{�ʉG<�Cw��Ӈ�E�NpeWi�w�w"�$AG�����8ݓ���(%�����3����M�>��Hr���JbLZ����H���	u"`������.�ڔ��f��a��4!�� ?�Йy!w��gq�;��q�nPDo�P��.�\Vմ|6���r�t����W�eA�,�Z9Q��jlk�����������9����!klＵ��-]���S`��5�6z���T$��9; �������Φ�� �m����Z�vD�������w7��{US2��CxK&�\渘��M./�L����
��m���R�TK�G���{�l����M>!���/���!�(@$27m������|���}�Y���A;�P�$�Ƞ]Y0��Ѫk����_�?������򜿙P-����TS>��>E1y&2쥼���wi�����NO�(�4���#.*��!:4�+5HS�fḈ3Z�v��������V�����X(`#��� X��aS�]�<C@�t�<����d�Ű��p �p����gլ��$H5C��r�@|�<�68��Lz�^IP"T���^�(�Җ�$���gװ�#0}�k!"NasG�r������d���9�	C�����r��|����hf�
�H��mg7'�P���>Ȯ�d����D(���։�w��\�,�Su&m@	fi��R�$�ᨒ��s׈"8+7f�:N�Pk�ٰ����i�c8?�K�m.|o��A�v��:�"�6�:PIIL��Ď*���Jl`���� �����ϟHCT��^������[�~S�u��4¢b��9˸Ȓ�d�4��d��$t@=�!3���.{Η�9��r��Wn�wo/nσ���J��ίn��8HUb�E(%��lZ~j+�"���6�,���G��Y^$�(����,X%��i�c�s�o�\9$���ES�W
�����ت�|U��2�4�D�~���������M��Mz�����B�"���"�.´S2M (,�JY��������ۢ���U��
B����0����O-�F&�a�r�XS��`PaL������˺^�ٺ~��5(�GM{�ˎ���Ĝuׅ#��44��%y�TL ��th��e׮��I��;5Hz/'J/�P��W����ǜsj�r'�[�l�S�'r9���<�G�>L��1����1�5,N�������Q�tB)�O�k5�i�[H]>J���l��-�L�C�*�bs��BJ65�<�"�{%>�O��"�	q�� �Gd�0�I�֙�c���挄��wC|�7���c�s�d�3s����<�U����/nǿ��h���p��P�R]$Y��҅�n���"�~���%�_��xM�3�����
<�e#O�a&I���Q�shL�p$5]�IC�F,尞�J��3G�7�کy6�<����� y�Ϧ�z/&��?_��P�0W�㺔�������Ʃ�Vy_�#��}��>�4����������6�rz���A��u1H��]>D5�̨/:f�k�aMk�y��C�!����ޛ%Ǎdۢ�1���#�1B�7ht>ʂ�$���T���5Kst$���F#&���~�3{Ϭ���PC���ݸ#%���Te�4Ub4 |��n�^�3��\�����\Řm=�N��qQ(���Ӥ�4�fE��MyBϋ��:ʙb���Ci�!�R�)������*Ӣ�e����
���E3�>�'ø��L�N����K�kogx��Y���=��,j�TV�e��N��nݘ���R"�6ǅZ�"-}bF�%P%��Ty��Z�lΦ��$����!����.��?=�ʣ·˜ImNF_&�uD���YÂU��W
��e���f���43���7���U<��
j��`�O�h�+����*_��g��������+�ƣ��~N�23ij�
g�\�A�z7����}7�/E��'��5��jk�v`/}�|��e����G���6/��^`���:l<��r��F�$/�kV�&닍��C|2���!�b���
pW�~�/��O��(��&h,��m�%�%�S@9٢g�ۙĞWT�ڍ^�����p�q�͹�mF3˝)=۟�9�%g�)�����Nq���xg��'�*Y��_1w��ߴ���#8gP�xvk�{T��6�~�`Ċw�="�5~��l�ی�h�h䤹ґ�E�_;�-��Ӝ� ��2J�2JdYn��k�/��?�퓇��GF�o�S1������p���;xs|vty��q��l�ݝb
֚/��ܿ����\x�i��v�"�<zs�s��͙���"��b����7��I3��	�9B��d�l9�vq����G��$-g��l#��*�}8p?��\��e?̘"6�
'M���z�(n� �l�]S�s��c���=�VT�z�j�LyXq˨�Ul�
W��C>�P4��4@���"�	���V����~u0��WEs+�B̐��������@ ���!�o;B�v�B�Q�8+`O��q�9*�%�?����H]���"9��fl�
g=��hI@�Ύs��G�~������Q 2n�K��(���p��p~��!�.?�zv3�ӭ�鶷s|p�t�z{��oW�i9��\M���p�c����ׅ/bu������=/������a��I���CT���tR����g�����a1A�T+�À|GFa�ƣ�.;�Ģ�؆Hw�&*Je��,��:�M��Tgz��`���`�O�����Q�k�:?^��Izt�h�%�3bZ���L�}���"j�Ш"�Z� D�O ��c	�Sn�G�R�?%��z��<�:'���<9��U���,�g(�fL�g1������������w������/o��v3���;�fO�ݤ��`;s.��%i�+nބNQ
���l������PF�p�L�����X"�N��G#���}bn��Xq�� J�Mi��Q�/����Y#������O����Q"#�Ib����ũD%��`�Ƭ�G �����w��'�z+hm��"R�h]3^�~%�6�ҹ�i�    �V�rI3�k{�2��WM)E�o+z�GUy�u^��պ#��~�s`�.v"(�R�X;�Y7��W�Q	�UE���Y'�K����&�����`�`2e�6>�jj�<s\et�K�X��ĺ?�k�!�S_�M����+�x�vxЁeՊ��OS�[ۙN��e����(*7�S��,*"?�M��!R��BYԭZ���^t��M����㳳�5Z-|��;\~�ʅ��6�-�KB&]��|�V;����̐7�(�k��(�Zܠ+��[u��Y��c��ۊ̏��3J��L�*�i����q����)'�=�.l�x�_��0V�!����±����+f�h�GN��$2�;3wE�O)�md�r��W�U�f))��TYQ�G�f�����T'�;�������_�-��ptr2|ks�ι���]��WۭZ����o�լ7��Nw즮���V�B9�T�K�؛[G��fS-q�X #�I�j�nuA�z7R;jE.s
�zZ���TO��y�DfBH��j{��wWD�Y��!�mu��E�]��І�oN��v4d�l�0I�P��+]�#0�<N�����K���n;�-���}�C����������3{wx�z��&��`@�{+�Y�ȴhK��Ny�ڐΛْn�/kBz%�U�&/8ɹN+j]L����;Z/�#r�:�T.��|,F�;�/P�������qM�5wqmgz&(\�l��Vg�&,6�O��$�'~����ܪ��Eș��h�o�x��v!�~?�����
�p��q�F�3������w�,�8�$e����)%�NT|K��,�R)��}y�E�d��j��t0�	����@��``oC����o�U�{�0��?׬"�zb����/=4e�g�v`����I���X�?���Mj��yf��ܬ���f�ZHn�J�Xj���~���+%�+�<p������k�񊟧�*�o����kLEnn0Q�����;�l�B��&?�;�y��1ViI����DǴi�o�ʞ����,!N_�V�༕�7|d9�I����&��_��N �[�?[ryG�gF�n��MgX;v�$��6!��?,K>?>��$xe�YEb��H��|�D�k���VT�2�sS�[���P<��!R=^�X�$�VI����b����{u���jG]"`�Yw^���$���;�]��?=o��t����|ƽc����}��r<�F���}���bN�'�b'W��&e��y��4����ŎXƶr'Q��Y6�Q���RJ��R���퉧:����Qێx��Y#Qڻez p��Xڏ"{?�WG�G'�1F����>}����\�Ь�ݥ}k��-!���R7S>	ָ�(O2�<�v��|�����M�7n��K-LD���սO�$�g`~>�Y���)���n��H�঺]>Gh�v���Ŝޜ3;,�5$�o������1��=�W׳j�py���@Tˢ�+�,�x�R`qKt^,�A�˫݂�ݢ�����
�Y��'��ۙ氐R3+�=��$l{m�+�d2�����]���$�G��Q�/�5.N3� �	EjC���Y5Q���4��d��pE����K_D��{���râ�ft �l��>�k������z���[n+`x;=�ol�_%���K��ئ��<���&MS�Û����+���ɭc?�SC4��7׃ng�a�jcS���@�:���k��̾�|���X�&d���A+�Ӓ��	1~�t�,m�s�$���w־	*=�^2n�c�Kŏ���9@J��D;����\1�����������cL�kX�בT�]?-��p���00�e����n�����#f�d�Rc ��©f��ZͶ.$j�Je&/S�X�K8Vb!����;�/
=���.����������J�I��}	i6����GY�M�s��MBar,KCQꃅ�~�Ҥ�VT��m`�<�}�����7�I���0/���^��2N��3���|J�wN�(8�G0�Z~�A���I�%,��|I�si�����%K"�F�&w��\��������E��,��[\g(�}LwI2Q9d6�2z>4ʪ嘗a��ċ�c�����N�R(	�#:A N�(6�hU��R[�B��qY�ŦY��*T!�(���1Jݩpj�H��;�^�����d�����C�������ɚh�,v����[���/�]��[	�~;�+�8�3 ���9���A�~�;G��=/�3W�b<cc�1)j� ��c�vuw��a����gcpܠ�h����hb7�	2.{8����6+�%ذ8m����zL�0W�ƮI��.�AF؇��,�����vF�y�]�K�˯����P�H�i�qɜ:��y1LǤ��ǎ}�+��]	፧5���u#1Wn%#k�VXC��)�<ݍ�s�h)/1�V�����tB�VP��"��D��� �]A�e����#��(:����7��!��� �a�^a��~�/�g����������l=��瀙�vU�v��[������̛}Cpf�|���ɤ�o����>�<@x�$����f��)��D,�,+�!�=��{�[c�<�(I�M=�ѭ���5jnK�yp؉�m��{͍�B&�:��BJ�P<��&��ζ;Tߞ�-���z���s���l�W�N!y�S�ڑۥ����t�H"-S��.5�:i2+
������!̔/U4Hp`ƒ?}��Vl��uAx�tKfYW���bH�9�/�^�����b@p5��^g7��_�ŭ�T�bQe^k�����R�|<}�v9���
�v���oV��S�)�~�r\�:����m
ȃ��כ��kVw���]��-x	N�s:��L�Ė���}wS>���p��V�ߪ�5Hv���u`���NÝ}1:~�V0-"��i��JX���a]��8;����,���H�kYG���TخT���	��G*b����|"'{��������ś!��^�6s9�-�v��y!S�i�8ph�2P}E�P�6�,?�*�k�T٨T�YF*�|Y�|<GU��(1}R@��_�BD�@�����d�Q.?F~-ߕEe
�Lb?Uq�����U퍿����A�F�ߴ�}�R�6�7mZ��b���!�L%���;�qZ ��ωĕW�y"��������;Drq�%)u��[B,�(�{��5;N^j"�����u0�S#��b9Yĉ*"l���4M�Ϥ�8�3_P�C�����N�et0��4"�ǰ�HF�Ԥ�}��Љٗo�Xv�`�x&HX����֐l9ݙ���2V,?�qB�@d[�6`����j�$����6�{��`�qb�q].��<h����/p�cN\����L�bZ�l��-A��7 l((�8sL(�O],�ЏER4�0�G��Pr���!�����0�K^�{'G�?]Z	�����vQ�N����Vi���j��~"����=��aOO�X�s�6-!)#?�q�Ma&�_�p%"d]���j�t�JX�"l��%6hDI�~���[���۬�Ӏ����'ܯ�8(7��%u�G�R����!��oڬ���(|Ӽ�X�<u�$y>�������z�kS��ش��TYd��(6��"N����^����*K|哯V�p@����e��(+����+�Ԃ�E:����+KS
�,�MC���R�`�ƞ�yLm��(�y&dSF�$��G2�a��R�jbk�:95YȊ��`�.+�U��Ho�j��F���5����J3�i�X���j�B�4�PJf�x�|ImX��e?>#|��!Fm���|�ž�],i�K��^�<E*TY��Y���&��J�@1���C���X�S�M�7xb�\a|d@N�o�X���k��N$
�mN�/}-�L���;� �p�"����}���z�y�9��ȕ����t�����R>x#|��{�'�Y��\�+f%��.� 3�`��[y5'�)�]]A�>���B��h �@��ȧ7��d,X�g�#��ٖ��qrtz~������)�{o���%N�9b��>4c�    �@�}�Y���pe}'��&_��i'�5���
.X+{v]a�rM�z?��|�����9����K�\C���{ӱk�7����V�'�|9���#FlB�$q���;3s�vx=]�&�ق��(q����+�g�w�{WY���{�Z{W܁��Q:�{�^n��{��,�6&� ^=Q�^ �+��O5�5Gbv�����\��0�Q~~:"�)l�s�PS���{�F�Z��Q��W���~��li�^#��p�Y��^�6�kC�8v��S"1t['�i��ΛQ9��"��w]ڽ=K%���JsZD�.�L���[*��K��㘪r��t�(��x����92���z���nxv6D���O
����Չw0�<��]cU��{�R\<����*�w0"U��������w|vx<���7?Vg��⦘�s�˒dh�a�j�|/�>,s$c��L��8Sdw�q�o�S=�.VmPc�=�1n��C2��B�*������i�������&�Szʶl�EޏSaT�y�l`�ǲ�G"a����>�)n/�j����h���1��./��Em܈<(��P��$n�!�E�f��"��oշ�<��e�K�'yMZ/
������h�1
xE��t$"�5;��Ӷ܂�d�<�sv�7Z��f�;��A��W��o�{�8��O���}��	�E�(!
0��M�?Q���a�8�Ad�p��?W(��w����.�.���^���x��ת��Q
�`~l�ve������JQ��g�o����@�(�����>ħ�i~���|�T6�8�/��=��~��ݏvr�I�27o�5�A ���2K�"
B���R�b� ��ڌL� |��7��n�]0�)w�!��q=���6_���m7S ����3���U��Ng7S��Y�
�gJs�M#�H�&c��ix}nlK8�E�C)�)��E5/o��xd�q�-6�iN�M\��;n�-иNg�����)�����S�H�S�YRg�<��w�N���۱�tPF�eVY�F��~�,��\�}��y�9@%a�eBU��hdaZ�������Vg�e�d�݋��'����p�iW#Ӯ�ځ�[�gt '�Y�*�K|�����4���7�X�wdUh	H�1 �0��X)=vƲ�r��j�$kT"�{a�2��1��O������y̌C	jس^��,C ���GN-����l	Q�� iT��*&y1�2m$�m�]<)m�(�RyC4,�J�S���đt��^� �-ߟ�:9�pt��m>£��V�X�H�"ͧE�q��Wb���~T��E�&zG�OŃDI6�����ƙ��iT��Xf7��xoo̬�u�?�WQ��ї��.3��"�����!E:ؠ����|Nb��Z^���T����-�-��~̔y:����n�|��H�8"]<��#$���{��.��j�UQ��0�A�'��a���5��DO��-�+jh�@��r���3��FHrHJ,�t�+uJ�V1&�=�-�pn�Bk��T�?�-[�U0TťC�����Ow�l<+�`(\�n=&�����UA�;��-G��]qm�DQ/� �<{���ջ�Z��^+|�A?��NY��+0��:kG��$�M�t�e���ꅐ�l{�*�$�����!+��먇m6��������M"�U��e����9��@�b"!]P�;^�̵,�2�u�g�v��kF�b턧���r�v�X��F�-���{���3�8`lf��������_�o��/���虛e�z���u���&"��u1�;!�.^�*�ߺ�6�|^`h�N1��%b�X�z�%"ʛ�m"�s�'�B�0�a�� бf���hd��;�hu�D�e�|j;��Mq@�ax����������������Z`�O�VZʦPqɸW���/�@�y��e��4E�^��۩����̗��: �e�,*l\F?lu>��l����p�s^!�`fMhɧK��`	Vૼ�c)��:k]��$�A�&-E���O#K}�G����.� @���=}�Ʀ�yfF~=�8�`f7���4&��<q�$�j\}bL��d��e'eaF�{�8��|[C��8����Kb��(��w��-�i5�:�C��.Gi�X�s[D�VI��)�~��R!�u�����6��������,S�ω̯N��Hvź�L�{ �����s[+-n�7����Ed���"&ENTqײ�dLg�����P�����@��U&h��H�rQy"��d�p �\%�ԡW���/e�F�0a$�OI�D*�����CԋF�(�5�+���(L�m\O�����1r-�'�o{|�H�٪I�������/>'�0Yd�MK�"�`p(�}��� ��Wa�l-�p=~��s���[��/m�Կj�p[|�%��i���)�a�H�����-J1�JĬ����7���Q�U�}�i/ݗI_���|e��'�X:��l�����tG�5�k;8�l2EF�9x�3�DQQ꬐�k1�`HMl	�L�0���Ѱ�p˾��)��)a]N���Ѷ^��{x�݊�B��cW�qE���(HS�䰠sDM�\
��*��rq���x"�T���s��\F"�YP4���{�;ߢP<��0�_�84p���~ �<;��{�f�*����MM6-q��Q�JE*�e��
2��Qvm҈�r�x��>�����p���w�m��1�[������o&�}6E� _I{L�n�YPɆ��Nأ�mKr�*Yls���K���L�T��"���G��i�[N��.J��`�Za��[�l����D�Kڀ��gg��MzZv�
D�%��9R`��S��p9s:������c�w�jG&�\�Q�'���"���΃x��G���e ���O�,��jo%`$�$˖X��kڊ%ož����\����.�]{3}�$��'���NH��*V�#hYF.D.|��BĆNR��)��Sg��n9���u�Nd�u���O�"��YE�6�2)fAx��lƆ�6�-�86!Ȧ�-�+a �⬪W/
Nڮ��p w�n��[��pCF�Cj9���["CLA�̠$b8��قD�9�o/���ȩj��(�����%���3�5(J��X7���,�,/��٩-^��,������q�bd�7��9�J\҇��S��'t�a�=�28�_0�"�NL �~�4�e }����[��["|�?����!�Oo-���A:H�٪�������5�ϯ���'*RRR��QJ�~�~��� ��[�u6�ǉC�7'/��#N��/�D��Ƀ8R�c;�y���_e����kN��+J8˴�f�_�G�k
���+R��.`
dA1?��K?�ȏm���p�e���
��0.5if�0(�"1ߤ�3�d?O�p{6�H�Ou�*�ᔏa��1�SC|2��+J%���L�f*~��T�'.��BB���/&\��w�ZA�c��*����i5��u������;�$�886�����u���?� ��8di������p7�U��'�CytB�v{Þh��hɵþ8��^�E]�8#�8���꟔8��NG>� JWK��;�q�q�xÁ��,gW�ʖ�|�
���l���*�9̶�\�'�I�F��M)��^����"�mj�� ��+��F�rl&5z�KM��
C�6F��tq��V] \�GW������ǔML~ �%�/V!QV������XL��*�Ũ�H�?7�cH=-��ߠ�OI�d���W�Q�����Ή���}�����m�����w���h�U9`��0*'���iJ�/�<Lu��J��&z)�A��"�GC4֝�V�C|�x�z���o��j��������������'���wo���(Y�h�;� uD���,T�:��Њ�g�����ߟ�|,�ޫ*[Οs�"3�b��5�<�Ʃ]թ�P��U<�q5���Jzׄ�������$b��|�qZ���{��g[4�z1��    `h��߸��T�:�w0���Y�c�~��3�e�DY���DQ�N^�r�B	����d*Y7�z+�����;�u}�#���wZ�:AN��8<�*
�81R|��~�H�L����6g#O����0�bӀ��Z�0>���W�Tę)t¥K��D��i�+�i�D�ou�'����k~a�"�1���N��2�R�:�?��5���
�=�H�b�ɍ�w���#3��|�B�p���	4?�!j��"�w����6p�1��\�-�E?MC#e�d��S�����! l�A� `A�f:���xNE��J+�,����-	-m A���Ӈh�Am `�C��k�
M�.�

�g�T��0��ۄR\\��KTd����*.����蛆�W��w��&�v�](ܺ������v�H��AG�l���W�dA���YO��	<�]¦d������������Lac�>2��A'*�M�G���E�>8�*���H}Xe2�L�����ޘ��!��V�z�V|��+:��Wm38�e��w�,$�}��1~��Vg5��2�#� �W&�Ȋp�u7�fm��872��O�kR;(���*����4�z���(���b�*$PKB�A(#�Dc�؅�����BN]��.�go`�=~��ĳL�p�`Q2�O�wa��r�!@�ms�[��h4�ϗ3�e�Y�V���5p��
S3_�"3�%ߘ#��w��M�
9����d��#���,H[>f���뢓���y1����৻�-˯k@aE��|�p"�i��r3��4�(��Xr��C4��=+t2����Ko�dx��Bx~ǘp��,*��$�Q�>I
�EP�ɖy��2�J��8􁹛Wk��NUy�7�xd��j��<��/���#���;t	��/�Q�/���q��o`��?jS��R�ظM�wޢ�x���n��h��aߗ3�yU|t������O6oo����m���`FE�f��d��w�s��LR)���;(0o��K�~Yw��!>Պ�Vb��������e�<����|�l�lO�: ��xͽC��`-W���Mq�|��5ԧ��I�@���(�}-C���%8&R�Ja�?�|��e0"����Gh��#�b�?����|Y�g�o�޽_�F�np�8}�Џ��!��V���<�X��.���]6���Z7uo�<bsOY���uq�],qPʮ-��aU��ƈk����&HuBGQ����(U�r���S#��;d�zT��[�[�j���7�ތ��e�������h96��bs���J&R�Ʉۡ���s��e�h��H� �ʙ??�X���8xy��=�����ǉ�d����.n�!gK�Q$��9��a�⠫2<��zG���/�R�/�"
C��p��!���������&��������xu�]5��5*�n_Tbj:g!�����ޚ���Z�=��a��*ۙ�(fSW�����S0�E1��;�������#Ai�.X�����q�M��j����U�+��;jX��Vg7� u1�BGڼM�a��P�I��jL&�BE���c�a��#��!�t�}ʺ>kw�ҥ_~8:�� p8�ja�2��<��PU!R��.���|������^�.
�/ӱ��۰i�y|�rw��b��;˻�D��拺"�V�ۍ|�+�P�e��d�4��</�4I��Y$/��i�żvO�/��d��]�&we�;^��?0�����<rbwi=d��s�\��Pk��K��Uy�����K����l��bf��"ћ�!��3�a��#v��0^;���^��2j�!�Ô
v{`E��\�?1�����zxP��!�pw֔G�Cđ�,�90�=uGd�x��"MSS6,��e&��1��mBX_ҡ�����C|�
�������/�_�O6hS1h���2�!��>��O���ߘ�%8��M�Fߋ_d�xz�ЯӴ��z�AfccKRլ�Ϧ�p�^q}M`�����,��x���@���F��E;����\�L6�qmw��Y�y��)8dS� �4��cPY���R4�v�M_G�0�
u(6���Vb+G��y�>D�t��kck,$����UI��g��������/��6�F�3"�;J���j�a�|F2��y��ed1��;(h�@��㾑����+��
�D�e�'��w���.aYH?2Y�#�z7l�ن] �;CRo�1v�EO�U�ʣ�1�:,�B�y�&���9��%��!�p����8��#���7u����3���F�D";l�J�K��J�,P>�	��F�vL����U��W��)U3ѫY����L�]A��x*]��d&{��c3�mf���!!C�{�8U�lp�$�>e��3s�\�7�LRgR���m����� ��i���b�DR��-�eWc���խ�f��8�"D��1<���e��ke�f*���H�E�Pd�VK�u0D�{$]O�y��<=���������]�n�w�KZm/��J�I�C��h<���C8�7"�"������x�q,���c^1����F�1��|�g>���R�$ ���嘼�&�e^ƑNX��1mfNb��Z�ə��0❲S�a��������'�n�?�KP�G��&��T�S���4"��Na��1y�*W�4g:��H��,-e����'eI��������)n�;$�M��O=BQLk�\u������Un݃4M"C#�=�����H)���o
p���Xv�V��-�kA;��U��h6CUS���t�ʌ�p�.�6+�e1|�4��!	w��F�2L��
�(�@�R�>FY�����Z�����o�CSѭrQ�6�0	0p�٢cޯ�{������u��c���57%��M��V���k5���R�(l�8e�aU��piu�F-��cư��e0��j��Rg⨰��84o��W4Ô�'�\8RM.���=���!jc�ZP"����̷+D��k>��2F�MIٺ6�t�\�cv�~���O�,�;"P���˨�d��Y�e_E%
�+_d[���Q'~�)|�`��O�˄�d��7ĕ����������5�E;ɵ��"�_=�"�����_���o5�����ʜq_Xͨ�^��{WLI�`���DS�RL�Y�%F�j�8ö�`��u.�H+��<���$�޵��P?����3ZZH�
J?�
���"���b�u��b�����U�*��tH�U�ˮ�z�5�1#C\��Y�,�-w��9:-�{"5��̱��0��ΰ �{p+lkC����ɻZb�'[X�������2�E92dKc���|)��9LBJ�u0D��-�Jw�h���g�	�٨�Fx�Ȱ�G��o����k��̾�|�búC^0�u��İ��zO��C�b~gFpf��D.��	�t��]*~���]si���>@3$��/Y߷^�����?�r<�� ٕ�9�"IҸUs�}S�Y�8M����i�`�u/�u?}�V�-Śu�	rq�����i�1a���ܡ$�ΥI�9��UmG��������e�������#+7ù���5�L��|�;#��W;n|2q�i`�]�|I�f���iJ�Q�9w�.�P����d�,�gQ��VVw��^=�%J� Tl��Q�0/����JT��OW
����]⍙ɩ����"�!�l{�/������\YA�����J�M�e�_G�Ph�R������ы�o{P���;�䕿f����I���VQe�QO��\)��mA����3Q�1�����9�ɚ5K0�c�g�
�k�� 	c�b#�bAh{�����K�
u�&�*�Ƙ�"X�]6�M�V��f�
ޯc�zߍ�يݙzU8��[�����+�#fnAG���U���?[>�3�	?'���3�W�y�j�݆�UM�b�^��Z�M�h�f�Y��9E�{.�ث�����z�?N)��7��4����h��_֞)��.�gV��$�
ޣ���`�n-��V5�"DEc�_龄�"k    e�Dm���M*�"��b��^s�cd��Ĉ.��V��p臽7��K��C�V�����n���V�����;��<���w��ȑ��89]BݡU�L�K�YeS�+ ��-���s*,ܜ�����2���Nײ2���5�X}�q�Pw���;T�a�N3sF2��c����ؒ#B�L��d;|�|M�Bݘd�@�����hx��w<�8��8>|}��*����2ؤh��j��\��<h�w�h ���:{1��Wf���*uSO�T�a~ s?��uq��ߤ)���!��xZ�N�Wf�W�KbwY�F�Հ�D�	΍��&�=E�>X�2ڄ)�:]:X�׆��&�3w(}�S���tnx����+L��vvB��vc�T��kJ��IT�?bK���q�k.	t0D�=8����w1<�܁�&�y���T�܏䚰m��0*u쇙�������&~U���� ��7u��\�~�*�r�ܱo��'��IO������֎NF�gb��`X�"0���%����  �k����Rz`��)M+51]���VڛG#FL8X�@�I�@J��cM�8/����@�c�jֈ�k��-���ڃu�� ��^p+vR��ȎE��q������Wזl
��G�A�Q�x����h4R���_��j�}���h�+���������1[��=������U�T:	���r~�22��a�ͅ}|��6��c�|�E<�]1ov�҃���;�����=�������O�܈S�	��!>�G51�ܟx{�u�6�nN�_��V [B�i�gj��.r�Q�#�&F;�Tn�K�Z���/P/fN��38�d�h�%���L�x��DTʹh8"6�q� i����1����1d?v:�9�P�t9�����n��o �½���傯�L�ͬ�$
�P!��0{G�l��"Kk3���Z�����Z��P�s��� 5�t���Q$1�&;����0s�&|���_/�����޻)�}���
w��w����Mgi'�yG:�U"���:,��di��Hg~,���jP���Js7�Ӈh�_��R�t���H3Z�T��@�h���a�`�!=���M5�v��ƃla��r�?� v)� R���d�ժF�$���䍂�J��]|Ϋ�r�3����*u5l~�u��-���;�P�I%@����~i�Q q��~c�����7.���*q˲�.���VpB�IvS�|�T�u�u�F6��dY+ I�8�
c��O�/��*dC4R�0r`��c���
���������;�E�	�"i�Viy&}�������Et��]D'� }��@�U��0�R	��[V����U�bV~����7U�n�z�C�������̢$2ʨ��,�@��ө�,�V%O2�����tIf��e���{�0W7K, #��;5���;)�A�x�M��~fL�iP-�8s:'ؿ[�����a`�f���&�L�\�H?Pq������Ͽ�_M�d2��؍ &]��O���x�\�1C
ր@؈C٢,����x'JHbX�{B���v�';��~MX�2]3�(����B�$̓��SH���!�(���j�8��uO��}Ԝ<"L��f�u�P�s�k�A�jz�O�@��͐'�Lq"�R	)̎�I�A��# :��ྲ��)��rR���#�^��iAI��/���%�q�Wx�zJE��p��{��ܲ��m���1��\T�(�>MB�]yY�p�u�����r���NsC|�(lh�����G������5�o��h��׊�X��w@(sǭ���7��"fb�N�p�>m�L�J��Q�X���t\�˴�@�!d{���7�QN�Oe]������"����4R�~!S]$��h4 �|��@��k����0
�
��:���?8G�Zg;��v����5�$��&�yFMs���[<����tVղ?H�H�d�UĘx��M��[RF��+�� D9u�LAT��콷b�|�:���s�s[�
��/��L�᳇ ������vQ��e�0�Uy9z�"4��8H0��j��IZ慌ˆ8��b D�+�>y��u���TM.��xm�n�=c�A��rK��b;^
���:�6��sy��6�����r\�vSƷ�,q���]δT;�H�`Rf���4�e� �7���dS
�f	�8��g��C4g��t�+��ӣ�7�[�p�n'Y�"�)B 
#����g%l}	by���(J�W�����'���/���Bn�+
1b� ��G��c���P�e)���7���%o`��4�:4~s��D��#��<(�$�N�-�A�TR���3���Zr�먷_ ���h9�X���Kw����&0}Q�Hq�3���r���9lo�I�4"��z>�(�-B�|Ca�C�~釃�O棃!~٩@��4<��N�_���]��@.��!��A|���$������g�]�o3{�{?������ndvoL�8��`�e��������?8�6��﫺����L*"�q=�f^���A��ĵl�C9\#��W`{����E�W@9�Hd$L�V�֖Ӳ2J��o�q_GR�R�[��(��|�`���r�ΊEʦh/-A��Ph���=��ް�BU�e���iA(u&Li��I	�4ӱ�~�@�P�[j�>��ň��;�wrSZ68萊�SpK��}� v'���8~σU(�f@���Acic����C��Ș�x�j�y4���Ái\�W�b���0(�a'��v��I9��N��}��F�Ld��*�Y�;��`̓��M�PNǋf|���}�f�o������?~f^�~V׶z�$����7c,btׁ�;�߮M��Wy����>�#�u. z) &����/}=�*Ǌ	p�<_�gz���������������B��>�I6�9"̞#Ĝr�%w��/�ͪ��G�����aӭ� �`���-n�����FT��)���! �P�ye�&��	q���E���z�0!UR.��l�{hY5)��߅)aGU��o_�T�(��|���!�8�|��U������rx��1��^��C�,f^��.����������ѡw~|������򂓫�&���.?��,H0�ܪ���(GPh`�W��K\�+�Hm�}��Q��a�/}ќv��$Mu�s��d�y0Dv>_�6�����9y��\�H�K�4~��7��k�}xÄ^��*����R᝚�m�D6�w���Yqv�=�#��G�w_f�g�z�U.7��;z:�m�l;�p�rq�����Yu��;N��������g����Xhԍq`'�T�٭�.kn���$���y��EŃ�E�����B)&J��Ŭ�?�=���m���U�LK�C�ڣ��e�d��i���×�@*��`���}�^'q�L�:Wo�]�������[���zےH�]����XꝯP%<w r��챁	n[ycg^k"��X�n$=�r���`��u�,��YVX�� �s�O�g�Ӊ�S��칡0+f3]�l��S�<ȍ����u��}���D����u֚Eq=�Q�yBEت��\�Z0�6�p!�%�gq;o��:���t�d�Ư<`<$���%ӳ!@xg�k�vQ�r�z"��A��V��/#��Ml��;� h���$:�^=z��Ѥ�.����S��h�I�XN��CK�Ti���y;��U��Z���w�:�����w5YWE�fB�?GI�9�*�Ogi�JI�N�8fв��U`�۩nə"�\!�8!��KL]Z�����rf�,ic�E{L�ӸS���uB.���Dw��1VS���m�[�1e�\gč�H�P� dF�򓏛���L�I�xeE�x�m�����+t�Cds`Z'&�As%�+Af�	T!�l�Tb)iU:��G��W��=<zo�O��[Br*���lI������FZm��YL���5sʰ�:�4��YƁ2Y%�Z�Aƒ{X:�i*�ș���rW2G:    ���&�g�!F��]A�e�c�������G��C��v��54�_AtΝO�8ճW�j�w��`���ji��K�p���P
�8��_M�k�4(��{�l1�N�ަ��UfbAo��bRef�	�:����!zlO�0,�ҏ��BȨ�#�A\hm�dD��A0����EC��n�e/���û#�bt���.��Y�ҷ�}��d�D��5�rTy���>o�<xG�Q�!�m�����򵬐`p�c�!�禜¡���^JyטD�0�Z��?AE.�Pֱ!��'���9d5���n�<`337�=���|ps���;D��t���kp*�����yGl���4�Sw�ja�"���Oe��-����~��
[�}�{�u۬�l/��Uxz�t�XI��!m���Gh����DeR��'�aҗ`=��E'[�A���*Yk��C|�H��	����!XH6]x}��K�����v�g҂�a�����y#��!R��׃��@+D`�K�����T���R0c���8]Լ�a#7��߬t'l�3�����/O��yv�
��qW�E��O���@\���սn��އ�}��9TTݡ�|%CP�j�K�7�����E��M(Ue��e����@�E��j�������}7��jXۊ���~~�^��
������V<�m���zK� �_qK���aU�"vH�%6��(�S��oY�/JU�Bf~Vlmb1bi�G�7���Y=��DJ'�h�r���|b�n{hw�~k�������>��c¼Ծ�d,���"?IT���آ�WRB��st��!���o�>_�~���*c"�̂(PȚ!�$�������P_p��� sw��_�:����[f3ō4'��_w�����_�	p��:��c�>���Ȫ� X�U�V�q��Fu�!����i&�j���������b%�DPݚ&ӂSr����M�@�*MZ,���Ş���1�䘊Q���j�̓-p6��T���[K�Qn�x�b��B'�6����K��
B+��!>�J��d�j��z���S�rn�M���˥-M`b�Xc<�ޡ��R� ���)�(��g[�'s�H	�����kz̏+6��T	]!�f
��R]�UH�JR���"v��w����}�HjG�{\,D�5wUUl��������ŜI,����4:��=�u3�-���RF��&�b�#�ev�$��;�(IvGA���%�Z)c��
�i+������5f:˜魨3�=1����������4C�a�U��]�R�v�����t:U�{t| �Y�X\_W���]t�zM_��c4�g��f�t>�R�E�������g�R�z���b���}`u�FN�9����T�� �����I��!>��JgR3y������������RXCP1ŵ��b�`9�.*k�:��e
��h"X:�u��V��3pA0L������C�
C�A<w-�ŬD�\"t���l�{�'뜪�L�Q����˔i4o:)`B�2�s�g�/WmLA�Al��Yq�����C|&�b��g��G]F!<����)� p\^^z����ԍ,p��l������ bQ7'`e�)#���ߤ�^U(_5����l� S�&AjZX'D:���OA����y$�8��^��A&j�Y)t�E��C�{!)��G��s��Z=A,�b�Ӎ{�1
�1��S�Q��ϱ!5�:%�R���j���)Ňkw�K_d&�`+�7fPP�k,��e�;���FJMu���jxu���S_{�H�u��Ag3�-�H=4�α0�;�yn1���r�YXT"�	��m���t΀��Ww�Ga���}��-�<�j����8��ܪgz�3�J&`����[6�f�/�1���hюg�o
���h����VT��o	��w�d
��!�9E���G�������X.sUH�e��PVs�8���$��zQ�jI
%�D���MSvԝ |�x�0��<I�j�L��)�C�_R�Bl����C�e��;�^/b�zi>Wb֥�,�E�۸��/���s��}7<x��[ǘ����Q�M��__�f9W,Ǽ6�	8�Rd�ʸߵy�ss�!��=y��'V~5�vV�����T�Z�Y��<���hY�Ci�22�4�&v����(f������e��EI)z���^ü�W�^�=ܝ�q��X���9>_̪:i
�8.�\�H�m���03#����įa���a�"������Zp�A��0���gD�C�=_ �������%@�WBƛf���{�Qn͘�sg��%��*�s��=*&aG8�KL.�0�h����SG^w ����p�I&�v¦ѦB�Ș��@���`�"D`i�i�`����	C{�g÷G�����s��.n��XZ.���qeg�7t�gL�r���C-8x�����y�����G��fPM��؂ވ1 �Onp`%��`5�:��m�&�	�P��''�|$�ff����Л�:��9�P̪�9������"���n(&T9IW��@N�-�4E�j0D�,��ǁC���:�VX�A��f�b�u�����ư_¬�4	x���������ԁ�mW]L:k!ou���ȅBǉ*Dsy Cn�e��R�r��l<�#V{}��\_��k�:ꁽ�WG�o����G���~�]��-B.�4��ipF�"FQU(p�#�;?�K�+�I�
�!����{��m�1�1#��Eal�}j�]�����k�}yG����ّ��T۰d;��%JK��m<� �(J_��f��a�!�h��8n�<�,��F�n�\#�����'���3\������_���/�{�����#G�ߪW�A��N���H����B�"�r���ԽL�q8ѡ�Yo>�H��Os��f'��>��Z!��=}�.0U�֝`�Ƭ�`J�r�[�H��ؑ3	��������g����}�c5�;���lΨ<�b� �0l~@�4�#l~�/y�Db��~��y<]����¤ؚ1^5>"��,���	 [rL��.d�C}C:�q�͕k
?�i�jY��ޒ �-H��JRf��!>��1{�U5�=�^��vp2���Y�z�wu|��Sk�k�8S2g���Z��)�b_De���7m���	�O���(h�x��[���	[�;�a��_�E;댃��[q^ܯ<Fk��,�W�ù�׊��Fw3�I�c���2�pІW��������\�zT&���������d�O��Z�J�M���}Y�:���jt�;EmÕT7�V<Q�0r���0�*��q.5M�g��t>w[k7�;4�h��)~�Z��@&:RO���͹{� F��&Qh�����I�P��]4�v}�pQ����]|/���Z)�Lz\Q8�A��-�5�K��ژz�d�%��CT�x��W�8��q��b��Y4j��N̅��9�К����0RFWq��
�Y� p!C䜗��U����Æ0��H,���P�5�&ɑ��P*�5��v-ŷ{�����_JX������}	������!�3�p��kC4,wW�{\�@.���ST�kɁ��d��!ؖ��X΢jo���+wD)�;�M���F�H��	6��&�{8<���h6�>JK{�5�f����;Xڄ���j\�p�i����<ѷ�7��o���3˚�����7�>eY��L��<a�$dbo���S���cw}��ܳ��^z>cJ=�dݩj?�;q����N��������4lq��߶��C�$*��-��g�>[�(������s{�l���[`9VN��z"��
��0��%���ѓV��X=a�4������=^���.ߝ_���p��	0����}mW�7�_D�6�`����!>cV�q�_ja�,�k��F�4���XgQ���)-�޻�@�p��'9�/�6�R)�w�[}����%�~�S=�.�cs�Y_ �u�!C,�(�{����R�$Rp�E���,��,E�J�X���e _J�b�}��    �`���2�� )$ʼY�w~z����#�[t��pǨ��J��e?��.S�� S�+M'��X4NM���(G'B�U+�e��>�'���ñ�k��"�j�r-X��~��/�w%��H���%�A �~B�Ws�ƪ�V(�������"|
1���5��+t������������Z�>b�nq\�Y�b,`jYF���})���NRٓ��z��k���8m�@��0��^#C,GwXc�����>5��"�Fz|��'|��>P���}�.�F�ԅ�5��<�DB����G���<CBd�!�#3D,���f���Y�m�hWm+���a��ZĂ余���ͳ`�/g$NYe7���g<,�n�CZ[>�XeQ 3��cɵ�U��e +3Y��l�/E���B�DS������j�G��m�k���u2���=�b\4
����i�f���k�k�U��$E&Q����Ù��}�����tAG}�
��ل�u������c�j�� i_���Ϝ�Ӛx[�cI�z�X�����^�3����;�Ҳ�Y�\����7�Y��Y����Eڭ,[$c[Ow��t~Ջ�f;M1��_�X&-�rQ!۹�U^5L�	YZ�r�`���b�NXg�-�	�����lf�d�������CKY�/6�A��GJ��d0�:���
�s�G�W'�W�b����T����?n9��d����pӺt����`^k?�2�x*��ג����E������y����R�.]�d�~/���yu���Z%��3��R��U�S漡s�:D	[�د���>���f�E��)�����X9b-�-��	�=����+!���y0pڔGSB= �����oB�����p	':*�?�	�����U�X��M�խ0OPr�B1!�k��mm:����;1\��[��$,�gRnf�j���*�g5��A0ߖ;73T�`P�����Ϯh7��a1Vx�z���Y�K��u^~�����|�������Y5��,pN�j��)-[5��������ֺ�Ǘ�|���� ÙV�&Ѕ	U��4_�~P���EiP^.T����лD�
v�g�W��s�n��c������w0���F6� L�aRB�O���� 8KK�bL�Mg����|I^?-���-�)y�d�Q5���P��wv�/X཮}����º��%M��\�������\Yr�O�}�Ax�lf~�s�(���"k�eRB��&s=��C�(�ɚ$_�>�̑������L؍�*�h�L�h��2e�h��{�[���y*uB�.4
����,�2�ð��U�<���w1��U��}��g7��/��ǰ��%m}�O�U��}�䖰U/��O༘8sFY/n�<�{k�U�q9�9tw��=+��Ҋ�L �����,��|+f!N'�:�z�L+��h�X�!�'��܄�����4e� �Z���H��p�z�\���U�*r.���ٯSJ�+vD�i
m-Y�i��Pm�I*s��ٖ޸�X!B�3v0D�#����Y17���4�m�K���y{���������ű')�e��'�NQ+��v��ցMT��~]�C�#�j?ن�J?%`�� V��&��hXP�;�ݤ��BG��%:�^�q0�}����:1��R��@�§ibˈ6�{���#|�ӳ+3K�ӟ�7_�t�3�=��!�ۈ�SYA������x�g��̾��[�-�)
�љ��w�Z�#��(6���+.�X� '<).b��X�ї�ekC�6$v@Ƀݏ�n��6,��� n5��B��G'أN�C�|�>����?��;�ۥ�� �_0��
�}���٪fv��`؊`���)FN5�[�H͏���cs�-S��̑������V¡��lzn��<����6Rֱz�����s)NoQ֨�,��Sp&���{���K��Nj:�fv�&�����`c��ND��Qj�����9o�G	�}y�{m�:�"��a'$������8v�qj���W��"z��J~�B�X�?BN70tl���Vd�Xm�L&*4��'�h�c��ӲHT�2��f#*�����%��`�����*�����aeL5C�6�ea0�ICc��Q�"�3?L�菭�����l�	@|�ⰱ�so��y�4�Ј(T�Q�O�1뿥�2Xd
fjJ�t�=�1����q%R(�	�<�c��x��<!
��!{�s��/fHx��.5���Q��y��ފ��hd�"*��`ls{[�g��gb��K��2��/l^��&,	ތ�d�eY�$M�>��<^f7\tp����N wF���@��W�6TǢ�hܡ�;�8Ljp��И�,�Y�"!
�퍈�L&HC�q2���C|�D��jF����M8:9�=f�F�w�Ac��U샣�'�c�MT�OJ��M�G�h��wb��UE��g�7�$����HE�2�7���֘���<�����WJr�����Tf�]y`����Q�S��,uD�:p|�T�(2��U�J�+���*�ҧ"HC|2k�'���{4�o��WzZ�!;Ŕ�m�T���!l�u��H�}_�/Th�Sq���3_��e[��Pf.l3
��4�A
�N�+G$�襊_B���RH6u0Ě/�8S|;_&�C�Үq�+oR�r�A/Բ�8n[��SD�=��������1�8���ǟֽs&�;3�w�Y��$y959^-����d��ڴA����$���78{�7[R[)!d�c3C�*~Ɔ�:{��Y�Va''���r�?%�nS$]H�D(�e;�:I�Xu��Q�c��q��n/�ϊ�<����-�r^6�T
�18`I��ӳ%����Ny[\�}��Y���괿ș� ne���5�i� L�#�D_F۽D�k�T�Сm�o�����{��6�$]t���ZL�dF@����1PbIlI��Ruu;fm���$� ���٫y���eo�k�}�y����H �
]�*UUӦGE�@ 2��?���ȀsPd��\�FRJ�Ǚ��_�k��T�~�NǊ�i�wB�H���||��$;�x���v�n&��A��AN���o>zN���y����	�
}���q�VM"��m�)>n
mc�K��ղ�Dh@�Gɚ\L@�#?K�-�t�g���8q����NI��,CʭY�T��)����}"b+��~�[�	i+��TG�K4��eJ�-��M�"�M����|�6��<4�ɧ�D �����a����6(����ڀq�m�G��fun�҂�wH�9e\N���h�]eD��G��= v�9}$)H�.y�#=\Ċ�v2����d��j!�[DK���"e��*nŞ2F$�q_K������q��Ȟ����[�L���O��t�Y�5z�.�����[ �oV='�׳��	�В���G��|��p>X-b'to� ��غ��P�.�����;#u�<�y���C�-Uc��/��8�+8V�z:ț��y�}����	�\x�z��C�W%+rV`��5#J@M��b�\07P��d}�������R�R�y	�2l'���E���AaoH��H3��2729����[i�/N���J46��FR}�6A����X
��ĐB�?��@*잲�����?k���6�q���T��9ü��La���H�2��O�a�����q�]����L4��;]��!�i�Ԙfi{��ah��\�:�-n��r��50�r��b��Z��;��g�W7�� �'�f$��?���'ĒxR'a�g
�y���ܴd�k�]G�0�g)�<��"	����� hhbC&�[��q����Oq��o�m�<+��5����9����}�_�=�7���iL�h�UkV[�{�*Ow/��#�B"<��!�-��Z-&~i�h/{ ����di�V Ο25R��ш��D��-�{?��w�5��v���{߼N/�u��3q��M%��Y3�E��-�`j��@)��I$��QG�����o����}�i�>*[��z	�����]��S��4#g������K    b����ĸ�!�鎣�׌���Қ���l,����Bk>8���/&]C}X�Ds1xv9�N#���J�ɢ�|�*�e|��Z+�J:��pC�����J;D�\F�N]x�K�&�ʧ���/n"z�5;j��I,6/W���j��#Gg?	�� �K	�BTye���VB'����+x~�����#�t����
��/Ϻ��"�i��^��~���:��D�HK'�Af;\�5ģN醞S� K e,�c0a�k��8-����ͯ䍽o�c>"��sx���P�&������ ��3��Q."IQ��?�P<W�!�v<p8�f3�JX��ۧh9��訛���K�&��>�ߌ!(x����g��\l����!�!
l"�c8���O28�p��4�H�S7��&[�&�4nصO���"sOs@�Q�Ųe�I�Z�c�	1UW����g�%�3"D�舣lgo8 �%�/i�&�Į����*�� �vcJ�e��B��J�3@���R&�����ɻ��[�����+��������ׄr�M���x���ט��1��tj�@=,�� }��|��26��t�A<zw9�O���r���H���7T�l�+`�<+�kPE1��M�b}]L��K�Y���Tt��>Qe\��yX�lt��HSMH��T�'Og���el��-�cbՉա�b=���0LR��*�\�>yW�y�s��(���1��PY��șp���1'��U䐾�
��L���l��cd�V_]г�w�O�}������������h`AEB*������#�^\B ^�����B�b�%��|R�<Pcq�ȷ���2`����������{v.�ح�'S���w��t�LȁffaS���I�q �U�9�-�s�6�š��������.�(�8{�P ��,ǖ�8���.:�|*�ǚ(��ќ�Y��뼿Y�N
ޖ%LCꯩ�I� 2���m��O����,O�>gj�*�-7r]�9ֶr�Y���3#��<�5���!�#�	�ش��/���e�'�ϣ/O��|����7M�0�����>{N��+���$�$�c*k[����^�g�����g�����m�/�������ն�b����6h�*�>=���w���MD��T��X��.H�$(��	��U�	�iP�Q�-�s5�JV4�k9K�D�t�����e>Sc<�d�Qv�syK��m9��������M�����T���\�e�/��n&�<c�>Վ���<���Ij��[����T3"C1/���p����5��R��!A~"e���%���p�ߓ������3��c��~� #Ik��H�eB��I���8!�섐5�W��ӛ.�І>�܈ڙ_�T�X���<Zl���h�f��s>KdY3��ޥ`����s�b��dGo��0[���(L�.K�� b�Y��;��:�>6�9�V�B=Y-[^����4}e����9�+��KKϖ�W;�p0�/���x��ׁx?�%o<�X^�������n�Zc6+��tO����\\��&n�<eȱ�מ
�`��B8�∫��!6�r�_�P�m��������]2\-֦�8�,AT=^��5����T�Yғ��ik-�*����@�8��s���Y�%�ؑV����yu۠�"op��B�>��1��2%�#:ʾ���Hq:?��"�!'��x�4�Ύ�%D2f4��g��d�Sw��i�C��6G�7J4��_K�پ�)|?&)�Rc+)���{!�e�׵�y��N?��`8%�{����s�Ź6�ز�O����ǧ���Nv��bQn#<0�0b��F�d٣��r��=n^ ���x G�H�@�����f2}=�Y��V���§XN�a���IJ��$
�ꅦdT��,/���i�VڐsnC%v�!�1��\:�_�+{Z��4Q$ ��������9���}z�,wށ�J?ބm���#0ݗ8c	fD�ގ�%K�[.���A�%� �]������dzZb��|)\�[ᓷr�
fK���z�,�Y4?dzX���e�i�GѺ�m�����A&�q[�6���هZ�D�pU(����x��A�ށ\�Z��*
Ƿ���)wO�������_�������h�u��F�x����D+e�z�����L'�C�H�a��v�Iw�4��h�eF�=f?["B�Xu1�G��}�[��|�~�\�_i���Af*�b22/�-=Pp�G�B�}� �!j��,���1U���dS����wo��!ު��{_���@�k��f�`�R��?�6Uˇ��R���j �r��+��x��*��K{g!�M`�X�����P�����fb�3䀑8�!��������Iui�m�g®�m�?�}�SZ���X?�	�	����V�G��	I��z(�+�b����vW��.���»�4��@���j�ST͟�����j1�!/�i ��F�i�7�f'���|h�d�����%p�y_�;�{b��q��,\�8.�'��X)
U��kxA_
��ۑc���AK�Rv'�������l���9�7�#G#��AS����1O���j��s�a��#�N�U
���tZ�k�qP5����7h2� �&���88CdE�96�g����hR���H���e�k[�v[��"7l(l�E^[�k��Rr����D�Ag��^I"������$���#��e��;F�z�KD�c�%����)e�Z���%Q6�'B#f�t��udS.Ƌ��	V+�4[+9���Y��|���>稹T�[Ȩ�7�l7�1��ݢ�(;k.����(��f��d1�k�lVe��7��6KLHL̦ɷ��#mj�+��~L�ۋp�����r���q�UO,C�)�*��ea��U�+BL�Һ�Ժ脗���}�v��
|=,�����{۴e�����o�3 �؟1.��$i8~ �a*���<�/���X�4�+��f�jX׺t&fT���P����¸��$�س�Bo3���"R�	�h""�GJ����d����ށ�����}�<ň몷��%F $�w�D�@*�6P5��:��D0c9�7a��|w������i�|Q�!�ܦډ��]}"����� ��R�.mL!�r[��d,�Z�m8Y�].�{��Y�"�9r���5~=~�=z���l����=�3\r���[�ĉ|���zz���6f��&j"���M�S�8�(v��Ϛe������� -sg,L���MfW���J�V�����`�Hs3]�Ѽ[ �D��c{<.&`���@�*�(.>�Z��M�˓�4��2�h'�\Cd���@7���t)�J�h�8��kb,+�]f�6P����N+�]qp@�8�6k��_���J'����[)ۅ(�#ܠ��0� �]��E�8F� \�Bhk��v_�e�DVPN�����	�u$��a��s��e�=�u����&࢓&]��:Z�̵����3P�s�{% �k��
�� ֌�a[�oGY?Q%��:�Ė�DՕR���
U�I�w>+�IA6q�R��3�)�8�$������k����ͬ�TѠI����c�:跓��Q_5-�)�1�-�2*mj%UR�K��
ͭ��RѶ �)aut�{X��{�q��`���������ߞ�ؑQM��͝>�B��3�[��D":#H�+�;"p�7��y�s��µ�>��z�7,lL��	�Oi��M���;@�����k4��w��-A&:0��h^�c�<E(ѭ��������m���K%+z��r0����S��	�OѱlM:��|
��~�Gɾ�ϗ��t)Gn��,B?�&��r����.Ķ��rBĽ�B������+2#p�5���ė��8�p3�5m��P���|�h��`�>+��t�'^:����ɔ7�YƷ`�˰*���LY�0橖��HKAKtlɯ���PÒ�7_��|˲ėB���wa2�(C7S��0��!���l�~%I��ۧ�@L�B�*%     �
y�sL�U,��_�C���?eC��[Ej׈X0"RV�����P3��Fd懺�`u�}����pUYv�S�
;��(��� �G�O��\(KQ]KtT�l�NeY�3�;h�"�-�u��sg$N<k�%��?���vR���S+8uR&L Z��5PdF�(2u.#6:1�wg!S6���"v���/ls#�z���d���5n
�j	�+�[Y�O�!�tFx�F\�}�ֈ�c��=�U+��B��cg�����`q&�SmG��j��_��R�3�[=�	����}^}�H����%�ݒ��Kɼ��h�WVrxU��`��bd��N��%�(��X��(�'�u���\ȡ.��Y�>����~�ơ�wtA5da%+�	���!^y�@AUaK���E���� m��?�=�L#Nka���F�ʤ���Ca��^��v��K�b�E�v��!:1_�;���(|dD 1���_K�1���Q�LG�0gerB� ���,��_q�y���Q�&祪���� i�%��|�;OT�7��_Ku^���q�� ���u]�_s@-~ހZ䍔8�x�ɦlX�B��ZȎ��388F�#c��	�����F�Zhc��h\�J]!��A��Ӿ�p��s~>���'|���+e��%x�Si�m˅p����%�����A;����3�>�|�]��݃5��\�hO��,��n���-��$>��\DhNKtt�/�=(m��v�X3h@�m�Ή�Ut����K�-�r�T`ڋڨ�G��!U�����i�{X�+=~ej�-ڝ��ņ֊R�%ְ��/�k+S	%u�}����E����id�u�4����Z��@Y��kS�7f8�/e�ϛD~l�k�S�� g�S6�ϯ��rr=�*���a����C��YB?t�R��+���Ĝ�&�Z�mq�&DG�^!
�I��e��e������|]^R���Gf?���%ޯ��E�����X!�&�	��46�0��> J����m�����݇^� gGU��1ev��`V�Ȧ��-�98�6g�I���鳷���i$X��d�a��߱-�B3�h}�xˇ�.p!�g	s���k=,�l��k_c^v�b<gr���L���u��~�&������e���f���:M�bd�q���=,�Y�L廀�����;��5��r�Vk«�l6__D0EsY�o%�CG��!��2!�T�&����BE�H���Q��zZc^lwk:�%�:y�&¸��Tg�m����c����#����7�zԐ  ����K"Ig!ݟ�Q#��Z�H���&l�k�џ�*��5>߁|�lj=���$Ey=,�O&�v�t9w�)�W�ggo�wS[ȁ k�+����8�ɶ3.\14�֎��1G�$<�#!">tl����K?��zV>��Ŧ�_����B}�m>:i��)���eK,��V�|��)~�o(�Z�?zs�?�-�����
�]:i�@Ӷ�I�bw1��f��l.�"�4�[�!}�o��Ask���P^v��=�qh�;m�$��/ё�ϒ۵�y��go�O�g�OγG�^���N7�yɝ�.2["ZVX���TŒ|(�
U`���(��P�(�NP�XT��*���ؕ,�Eh��p}{<$Mqt��59�q�jKt]�� �&i��h,�	>�[㘨�� e�;[[`)&!�ix?��썟!���G�;�WK:j�S�C8%��J1݃�?���ǦQ�æRj��"rI���!��Pס\E��A_^5�pdi�<xbg
8<�uKz�l�	����~�vG�bZ|5�E�
���6�/V�t-kɘ���]XM~��r�=,7u� �W�l����۳q�f|�<���3�n/�?��8��BFk��Y���ua�.���>z�(����E~v�s 8���K͇�䅃�X��i7�V�X������q��J��#��5bN�G����x�}q���YG��m��m;&��L�?���"#��o��K"�'���<�(nFlVI��݇}9��nc�r2�EY	�5����"���Wߕ�L�C��{X�#qGV�Ĩ�x5��Ul�	���xAߏ?���9y���$'{���{_�xLYo���������逗�L��K3,�gL׎^?�K=�K}�^��rY�vEHغ̱'����� ��G����v�%➾H/����R<aW;�t���rX���P�=�ʙ������_/��c��_�FS�4��]��c�t���%^�Ms�Qpo�Ћ��)�ۀ��*ۍ&D��1ܣd�p̮���¢��H�<��og-�D[�=�P���)4Ew�����	�� �x~�t+L��׳f�t[XZ6�dF}ه�'�'tg�MCj���#vya���<Բ�����	FX~��YKt<�Y�Ѳ1��ߍ�4ξy��d;�
Sf>g�#CC�/�EYZ+�R�P���<A���������`�f�2��
��Z\bS1E�=,�ݯP𬕮����WE=,!�,��&w�A��\+Y���݇�(D^�*�Q;҇j��X�&��/�uX�R�`����^� �wQ�BSz+�%[i�Ji�w�.T�#1o�U�ފ�|��F�Z����Kt�`ɶ�5%!Nx��Ʊ��g�������&�v���u|O���|QQ�~�������Z�2`Y`���]S�]��~JU��&2���h1ʙ�`��e��@��-�B�H�m�a���!ȭ:J�U�;�1ٚ\U
�
�mJ�^�1��Og� �����%F��a�i~���4��Q�#������J-����ǰ,�a��$�����nDCw�6�H���� ���ؾT�Ӆ�kȸʺ��W輶�R��;��S&G���v��zr�R 1}������c�b^�~�������D3�9�x��>ĩC�55he��D���!���B���=��:V'����+�S�J�5-,X~]U��WjǠq\��L�!}�D�P����n%��ݣ!��:��RX��)��5x��s�p����T[i����}�T������}<�t#˅����D+��0��Z���ʢ� �uel��_i�fm�̔���9˕��0~_�q���`��/�u4������9�	�`�KW����GDdK�J���=f�suQT`�vq��I��H�������3P9Ɲ�d�nٕ�0Hjn9+hj�C����ٺ���lWL�V���o���GVMC7�į1�s*(�T�
o�]G��Y��5Hc���i�a=]6B�!��Y��ޞ���>�NϞ�����o�a�T��af$!�Xޞ��l��,7��\��j]a�v�C���7��Cge�K��UJ�ͮq4�|:Y^w&wO@V�6~
�C�U �n�S�>J�p�!����!V S� �9�!�i�v��c��9fE$V��qS���QT���&��h�����A�p2Ξ��O1�هӳA������qy�dݽ _H��M�L-��1Br�G�xċ���/�z��(PGh�b�8�0���.���H�6���6xP��FJהKx��@�Oc��|?=w=�%��`��#
#��l'�/�X[�Z����H��� ��e��A�m<�$���¥��3�z��WTR�e��@��Q+�Gr���a%�˛9�!�AD4��@����N*b��mk�p@n��׷x�{+���?���Jwo�-�5�4k��ծ@����l_����	!c�����{"�����O��5���HNW���N�x���^d�d/��~x���3u_�$á鄵]��3�F֡�Tn�3��$X� ��̎��
���y�\>8;�m� ]���������D���L�m��
(�������k0+�uo��f#`e4�ٸ����(��B�Ą��]
St������{?�\SxxM*���~��a�G<zn�q
�?���AS�Lte]�麀O�e�X�1fD�܁��{ƪ�9    e��s��S!GZ�\D���/Ѻ ��ͣ�Ǎ[����ٷ�ߝ~x��߿��x�/�9��[�������t`�</������5����k$Ln���E�N#�����������B��To\&!ʻ����!�\w��Ml�(/�7G��m{�;"�����'D�e��l���~q�vi�&��-��ulH�
8`e�7]~��n� 2�.n7��Θ��&o|B1o8Ü��Ç7�����f���a.��iB��ˉ��Ц'�o�Ş��d��WLy�+(�+&-rol �؁!�&�Hp��ؐw�%��܋d߈�O����oߌ?�m��M=R���K����A���Y�*�4��0E�uY���8��ѻ[������(�p�U+�Y��$Y����!ٌ��̯+�\T8�^��.<����M��J��p��xh**�����ao���;���#��?�=���7��Q�R�1��f�\VY�����"ҍk��=,�	�K<6���ߞ��=��O�o�������4ɚ�M!<k�����6�f>�_� ^��{���)��E��inj]0�U��)�O�aR5B�zX�������E|hv��6��4:FI⫅�錎[K��'��ov���
D��$/ғx�D���9ɇ��YIG��B�4y���P�:#gc��qn�����/J��\a�CeL3r�P~u�]�ޕ8�K�����б� {�f>�N��A�Of������hW��o�Wc'�b>O�
�x'D��wOk���'�O�����w�mJ�]]A�عn��T�HX���3N�ǅ�����N�Q�a��C�����m� �!��$�������/v� E��9���@Nme��6h�e�1���*hpq��CJ�_'%�+���K����>(���T��[�1��������,˚x�80���@q��"��B����Ue�>AxȇVB����������F9b7�������>��������1}���D�Z-�7T lXb]φ�j��IZq��P�c� ��ִ�o�� 6yOR��>m�k��-&t��v�Ձ+�)s�3[:"v����#j���_�^`E�ׁ_��y*�)��4�;j�TD�5V\$�r>����O���47F�G��m�N�B<o�p>�>�%�)�1eug�sM��O��8���h�x}	�%c��34��5�i������(�7��;�d���5�JN������:V���{�����2g:(yk��F����ը���}8�q$�V���J=��������8�S�.�"W{P�����H�^��Y+`���PB�"��[��uK����&��*ͫZ0N(����k�I)*וLT�[H��F���Kt��m�����oݭ;� ��UQ�y�s?�Sx-���b���zQ�e��ؕ<�8df�%���
_KtK�����}K�v6��(y�Y�(�!:)�ի6W���%V�%�:�%��	��r�3_. rnp[�p�h���>~�qX��UY���;�1,57�s�n��u�9�(=,�D�5�襟V��$t$0�> tzsO�x�:�8p��r6���u��� jФ�L{Y�\�/&�,=W�8�z��P�M]6V"�����H�W>[FYZ%)�H_��Q�����T�L�eT=��I%
oP���-7~��,##μJĨ�%��\"�>�[�K�]M� �[ڞ�$uǔQ�Bk	>�.�U7��Z�a(ʒI/ h�;�Bj*�J�bᡇ%:
��v�ަO�[qz���|Ù
o�p�� ^o���,=d'�e��B�u�7y��Un($�(�qZi��@���Jg]$+����줭53�%�L3�����:��^�o�2ȯ'+�woX.�B��-��.10��0N4��]�����-QO!��Tv�E�mּ���}+U���1± ����
)e^�3�u���\;��D����R��hQՒu.΁`s˅�B��u�f�
��b�>��K#Y�C��3
gO����{�f��w�_���+YK��5%8��`j3$BYPW�a��;/��V�^�2�B튯�^-������	��QW�?���7ה���͑��9��yP�� �ԁ���H[�^袨v1��EB6�U,��_�5��,�tq-D���A+�k�=�rdz�F��' !�w�oW
P$γ�N������^9r��J�e��
��ai7�f\+� G��)W�V��'�kOY��$
���"g�Q��K�z���}�{38ؕjXA�\j_U���/&��4;��ώ�Uap���b^!��N��W��6�;�hF��Ms &�0L)�,\\3T�ץdF���#�:%	��C��-6k6S���p��!	G���n�d��}(���$�\�lP=���;X�d[��-E�n���CF�C �]Un,����P._�BG��c�_��=�6�HWs|~z����������8;~=~�j{��	�%It6�@��q�5���,��O�������p.�@򤲋ZVy�eG�]�4Pa�k���lD���D�ؽ�IS�}�#T�/�X�\��_�r���xG����C��dH��[~����$�:�cAv׳��r�(z�Ss�������q��½\m�����{	B��O�o���r���E�ep�Y�3(�rȭ�`�uY��g��(�QPv��%:��� ��.�;�6���������>���}[o�qD!\.h���y]����aDkkdX��+ʢ$.���]e��ԥؖ�n>��bO6�HJOx,{a����Y䖢�"�5��S⠡���j��OAͼ�MY��X�Z�8˥;�/Q-�F�&���@�'e•v$��eqN������t?*�}��j�kĚ��Ӥs���iu=_�u�כ��"�=2am����y�h��287Q�S�K���l�ʳ%��>_$�D�����d�4	��<|�j~f���0��������m��)p����τ�(�h�JS����B{�3R���e>F�s�a��iz���o>������S��{�������,��z��q���r�OQ%�sC����q���p��C������-�M���_�N�����g���dU㬎�*�+Y	W��Y���_��q.�ܹ��j�ja@[?>��Ͼ=?9{���{")>�bxV�0<�#�b�^b�
�����nW��cb��>a7�pb(������%�6�9f�-O��9�tê �&�=�Ÿ���kE/b Y_�0b�~�n�{m*��Aۢ`$��%X��8i�T�Q�\�)����1�wΦ��t�xם= "g?6��q� �p915p9S��0ְ-��<+�^lmE�t�3;�������u��o�S�мsa(�E�E��j3q��s����O�q\/�$��	�`%��#�V��|��#�*�qu�`�/@�a�	��j��$xW�Uy��|�^�;D0��j3vٜ������֋պů�Y�,����!��M�^$r�� �jkd���8p��ţ|�'��n��o��iC1�[�[w��\�t~��&�(�Ǥ�A����B{�+��}神��r��'e��\%m���O�{
~1�5����a���ןu���H@[~��UB���޼��2���(8Ep��Hq��^�*�P�y5p� +#!�e��w��V�+��~V���7X%V��W{���9���
�ɘĮ2p��\R޸�%~sV�΋�k�رf>^%I*i
m̃_��q������-
U�*mȅ.���%:eʌ�ܥ����͝��.K�5^s��e5�eU��T��'�_�_���{C����l
��"l��a�%FZJ�����o��P���(o���?X�m��J����K� mjR�%
��f���BV]��T���	��2�=,��;A�R����Fk�9�]��Ѣ�ש�
�k�k�{7
)}�4��LX�����+I�����q�z�aҠ$<�/�!|��K���K?���$�?�
b���k�9h?��pf����w�D�E��7�    ����]���v�.@3���|�J���[e	�S���h_�T>�?)�K�+߯��gm),jΒ���
���so<���*��o��j�b�����Ծ^�3B:5C�����'�٣g/�gg��7��,J��(Y^T�\U]p��r�*�B��R氖ng�-#vr'�I�����I]~����(��7���e�f��N'W!���Vp�-y��/~�#ź��b�z6�?�Ԝ
��&���~��2�"�〤l�.��Q��?�\����8��+,ou�.p�1�XE:�����s���:���i~��Y�a������B��Eg"�phH
���o�q�e���&E��Fp��.~2H5̋�+'\U�j���J>���إ���W��ҝyi��l�F�~�,g.�Pf%[{(�@!�
��mH1�ʀ;�ʃQ�S'{>x�"�X�w�
tٖ
]���M�Jf7s���5.�!V#JО(D��K�u�u!y޽�B�jh-+e��>ߨ(
>@K16�rzN=,�Oi���7�gv'�s�؏��� ���0�QO��i�����.�u����N�88��]/��@�s�77�S3{3�e�^�,&���Q�i�Q�CҐ���nCT�_P.7 #'k��qRD�#kgs�П�
$�
ߘ�*8���A�|�K��W!͞ɓ��i+|�{G�7^WB�"te�)������	�q�:B����8��ǧ�O��'V��ZB��##���ʭuؘ���ƹm����qr�\nd�@�*ks���;*
k��u!�ȕ`�ll@�����H�K��Zq��ȼ���
֗���=����2��]@/1k�a�N��=�8<���M�a��3�%Y���2[DJ�.��t���2�|Ki�s�J��|T�SX��X疩�����:�zX"��QZ�'�)��A�����6�[]z���,����}��OO�b����_��V�.�1�*(�����S�R���;�Da}k$-w�۲�%Zu�������9���!몸��.k�J����J������$ܾ�R�^LÌz���S���"���ʈ�Y��W�8�u�Bq�8�Y����|S��D:�
��8%9�4 �U���48��i��Φ�њN1D��h��z�_d��!h1f����78�~M뀕��)�"�d��(rQ��,��������zʋ����gH�&/@7�"A�m�� �BЈz�K���=,�#��o�M�(�$��ލߍ�2ކ�:FÕCW�l�oj!��L�'n�p�il ��Dr�Q`��s�;XK"O�dg��r�?��i���ᗤ����N�d��!��'���hRj��f�&�`JJ����)�;\�v���E$ QX7�=�v�G���g��i�Ĵ�ח����U�i����y�r&���������cIgo�f,��%���-?�_�4y����AU�WB�R)�00�7>0��˒U~�{�tN����Οj9rV�8/��+����5AUL�.T�3釶��I�DP�����e�0��]q*0��d�r⒈<�˫��NQB��%➾x��9gR�G�.�ר ��WU�[�����m�ԕfo�G)�������i�{@�����Jo<�+�a��,x�E�����H�H5K0t�i�KX/�D�<�r��>j������J;��<��1;M !�ƾ+�Sg��,q��A��d����}����<��l��,{����v�x�32�A��6����<����{>)��}7�i�)�p�P��;>���U�|��Qv��_�+�VG�=]�u˺s��Pй�I�˴�4I����r��U��<q��e�A�;�"�
����(;�?�ǟ]�O~z/ɰ*���f�(���&B�ܳ�(�Y$�����!��i�ʃ_��r�I����Ǥ�i1�!
� �c
�)ۿ��a���2���⒋5|)�����������%#
-����i�肣���VQ�~(d�Kg���b7�&��������K�=a������"�ݫ�c�yތ?�f��0���Q������܁�)���r���i5�d�BX]�L���Ͷ�����3�No}D@p^5����noHv�[��^X˫����"�T��Mp��@]<����,�NR�W|&�yN!�1m(�^����w|���~v�G�qI�Y�ȳb�0x/2J��J�`9�!.�,�c�1&`����ҏ�0�\��^=��pR���� cË7g��DS ��D5��7G.e���"�8�k4���������)#��+�-�g�BQ[��#8EU񡳌[A3����4#唉SX{X�����DQ/:mu_n��w���Y�<�Z���lxF�����p�rBK<���I��`C!vE!/x%��։bK۫���d#.��nKt\�_��aȢ��?ӬUά�l���Ee�,�JuJ�	}��jP����|�����W�i&Z�*x���rH׳��� ��$X$V)��x�r�[nY���H�/�?P�s~���I�lz��r>�f/����q�����H�ꀣU�S9k��,t[�u�*�.��Gkg!��9S�}��k";O�_+�u-|6��%N-���U��@�qr�Abi~(o�yXf�9�8���U��u����VuJo��	��^�}�M�%3���C�5h�P��;$ʍ����f�����}P-���Lf�쑏Ʊ����H[邞��{}y��7�g��e9���@i=,-���~�Z+LA]u2�Q��r��*��ṅuK��6tS~�hcz��.�Uș���I�dm�u�BK%�[���������Z���J�$�(��������>	��:r�)s� �Y؀)��d1�w�^^6E�z�����|:<N%�w��bR��>��\V�Յ�3�_T�I�Ñ%��I=��XZ����I��%�CrW���ի���xA��3��x0��p��/��ƃ��O��?-�������������a�c�}�o�ª�\�(�u����o�L.�b�)���-�E6��I")ו�>>h�{�*�E3ҮK�N+�:�B�.�o���4`�F�#�r栻���~-���O<��e$%�
������L]�9?�r�^���R����|��X��=k��i��O�?`�!,��11י���`}f�9i�TB�J��q�z���؏ʶ=��r��MᐲͳJϢy�1׍�>N�v�% �,������O%���8�AX[c��lKje�b�ВWr7�,��Ya���m���=_��oY�۞�������Y���5V{��1'}��T��(yr�7]�")���(K���� �b�Ӝ=zf<z:�ߓ�a�����8�)�8+�a£����͚D$x�ӓ�'�]�
��'���ʺ��j�43��5\U�WBV���#�Ư��S0w�:��> �	����,ut���R���O߿L���(Ω?�7)�R��+<��I?�S���x�b=-:��/�g�_�ӨЦ����m6'pd�Y��^��t6��Ȅ�#!��������H��i��''�߾��s�w�g��@�����i-J�("��zK��C�4.�-Y>�c����Lu
Ov��������	��VM�1�<S
�Z���k�k\�
=�9D' F�t�+�*�T{�X���;�Њ�+�5�w��:x~�K	|@G\j�Im��D�SSJ��G��A��B(��yv<����0�����w�'��k����g�����M,y�
䄩j��_���2V����;�,���Ǆ���I�BK+��m<=,����d'Ё�`=!_�'�*-ҕ*_�lXu�-={�7�����%~���L=!v+���-�Gow�@�l-��2H!����'�Dn�u���WRL%�`���Dd��i
0Y����_JΕdj��:Ԍ�<�P�>;��A�3n�i�a����Ag���1�����b�d���2[*����L�e�^_�8�x�cc���!e��_��f��z�ٜ�O�D�Nű"��_�8w6�wOW�OA�u��U�9'��Ξb',�)戰���"����,$    |a�:j�k��aI0���ֆ�t>' T��{+.RK?VR=x̗`Q��z�$�&�j��C6_���G��j>e'���'LG�f�kV�-L@H��Z�b�e�����j c��-RV�/�j�h���]£������?B��|jNj��8}��n ��\T�gl6�mq�pj��%��(���A�b���x�̩�4�&�bQ��ɞ���Kj�{g|�1,��s�/O#��k�}�(b]2N1��n
��A6(��t���>N�	ö�XQ��b�����]�yyTDR��j%v�bQ;����sO�q��8複%:�H���,{��[s��w��h��^�������˓7߽�	����O·���p�����g/�`h|�0��PH���w\Մ�h$!�5"��H!��h�V+��&��%�����D^Uu���Ar����n�E�]����(��A�t�î��"<6?�����}�&}�I\�I��I�Ry��&�1/X��S��z~7�2��Es�Xb�:6h]�kK�{���>� ��*�0�]��p��9���,!:�j
J>�9|��a�c=�}�Z���Rv?������`ϱ�'�j�
�l!vhJ�$��B�Ծr�%~$�%�v�y2��=�>�P�=??}����Y.e1˥�&J����OW�<Dг������k�E�Qb�j3�n��H�I�cq��֌Q��j2#�.��{����զ���I~����_��Tz�G�\#2�&YpAO�;W�i	���ux&��GE��z��������2f�5}�v��u�N\T�ѣ�:�南D�+���M�42�Qc�-Ϫ5et�� ����gb?��6w�a��,�� )�����{�w%]a�����ѧ=,�D%��QAq���;~��9={�r�'��F���%��������[�w��z>����N�M���~�~�Y��),#�:�>�F�8>O!��^`�#�wS�����Ͽ��>��^�nDo�XQ��&ά�#(7���7+�k�r�?��s�o��T߿� ��x��P���N�����D�s�d�\��6S �>R�=��p�?jN7�Jr�K��O��$MW�.�U�@M��,g2���ď+|����7��㿌ϲw�{��٫(�w�|�h��.�g�ĹGp,��u��2|��xl��A�k��X@��-�p��fϼ�������e~]��b�D���N�o�Qe�}}���k�Jj���`�Bm�ZE,t�HɄ%e*�����B��Dj��Y�Bd����`�#�p�옺hMO�I���!���k�-���"����̤�"�3�� ���W�H!��:�{E���׻E #�� ^%:�3��a�[ꟁ�TZW�NB���;qYi�N�݁��FWu�jU�>5��s0�ܑ�x��Rڲ2��^o�ͺ����*#x(�C9�+��LYـ�ܶ�Mn��"5+w�l*5R����IK|1P��iJ��X-]�
]4K�L5,
oj^-�;���GF2�ɧ�a�_�bB��l�;?/��ų���D��8v n)�-�\�?��o���>P��� �:�e<6��0Z��є���e��iS��R���o�D�E�"w��
���9B��U8�G����>'���:��0C��]�Da��=��)'��R�ӽ��{�"��2u�~��7ٻ���8�dRd��~x�=�?ī&���6S4退���b<�\xo�ѿ���˴n4�
���ǌ���=���u!�.�.�3(z�F�k�����D�V|����ܘ�E��CUTeP�3[�����g}�`��}6U�<��[_;&i.����jK|-�@����LU^��b���C[0%u�����SO��8�QG�{�����`oEK>�����O��B �~�"y�s�$*W3"�ç�K,�\c[Bty@g�B=�����
�L�\�5t��Y7B�&�����P�Z�"��XX\�F�Ҧ�
	>����~���	gi�8�	,m5�e����8��ȁz���XA�:���xZ�R��8������i��~�_���!���H�P\	����n�H�_p�=�<k�u�J����1O]1ӹb��Ǒ�qp|��
�����f�?^5|lD"�{UE���P�|���-����YP�
���
�kJ~��"����F�S����RTR��զb��WaXI�M^�t���#�)Ƀ�a�N���D�ń�a[O[�,����B	�KYZߙ���BF��f.��q9j��J�>�Pp[����bg�i�c����=,�\��ˊYY��U�O��v̔ʖ-���> ��e'�*'��z�|6���6��_�l8nU6Vm��1T�����&K�k_�9�M���ƛ�X8��j��h����
W֦����UtO5�?F�3���a�y�T�P��-���'�o�Ķ��3��ᐤ�8��J�F�h���G����H���9���y���u^��+',ؔ�	�;��3p��Tl�;%�����%�?3>Gw8?�@��}��+�k>��E2�F�!\+�����}�:�I�\׾2�Ϧ��p�W�V[�W8�[�Y�$���j��*�u��l��r����bL׎^�}��KI�s��y�8��E+ԑA��N��"�d�P��E\�r��x��DˆDw��"��ލr�z�Z��[�FI�\��߽���Җ��J�\����
DVIe����%�����i�I"�O�g/^�=>id���e� e�Km���`����;�q�x��k
3P
V<8@��E@���/��D�ǥ�?�	,N��Ml�T�V͝(�	��-��F���#��{����D�ݝ��kb����}���	zM�U$&=�bL�82H8�5��ޜ_)�Ua*k%<&��"]}4���q���-�}B.��>e�cC ���$l\Z�;'��hi��Q�Sg>�6��)�B�G��|ImP4�g�eہ^S��L�|��+#�NT2q<���H �\ۏ�9�ls�"�4����� �`��9���vdh�#m��1�����{��wŏ��������&˯������0'�I�B�p�����j�xpLN	�(#
sI\f� ���Mc��hC'~�O��T��6��H!�Yi�Z5��8�*�4�� G't�z���>����ɁI���;����*�F�_t3Qi|zX.����ϼ����zr�&�6.N�#�#U���Df��]vƷ!�2��[QM"�2H��k�6D�{�[�(�"羰�3Q-�e5�q�[^�2���8QM?����l���H5�3��ձ7���[V�(�DD7����~����/2�$�<�=%ץ��.� ���wCn�լ��$9�{2���)�ͻ�����9���T���yUytA�w���ϕ�:ΨɘD�ɑ�Jӽ��
�0�7~|~z������w��ǧ��#/���&z�r��f��0��-�'XC�X���%+Y���sf �ނK�����/Y?ڍsqWcj��N��0������J�+�ǝ>ՠ�8���-zX���W�I��.<�ٚ��n$����xU_��7-|�*4���}��a_>A�h)+ĂyѤ`������e]�zsvg�����*�W���v?��̀�U��߃ ��F֬P��caD��DG�X�|��D'����I,
߼�'}��������I�� �.�I,S��I�#3ì��*�c���(�7CQ�ð��0������'�Z�U���>>/����ܛVÁ�I9��8g���a�����:��1+�4�vFD��F����z��T�GL*��b�{��F��C���)L�o� ��p���u����+�BN���1�M���;[�D�]LA��n�E�.��	+>�)�0�z�]����F	w�ӑ>-��Fl1}%p1ǣ�;�R�)�P@��t��,���b����e��ujB�L�����r(�+����E�[��XR�KGv��%��������N�O�<��zH��X]���n~��O�t�,��_$8�����a�gJ�7�    �Q~��D|�G]5K &�V�;���F�&x�]LrF݊���O��\u<�������^Pј�	˰@ls�L>"4��.U7��4�)�L�e��$��'/d?�8��!ѡ���j��"��J$D&��Q����D�"��kR(�X��(���Թ�]�s���
|<%9�����
�ݍ���2�(�|���go?d����d�E�f�EcO�A���
����3$���I�6��Ey�8!����N.q�0D�@��Ej��>F#1|/՛����W�h(lYGy����
���x1КD 2@�,��1�~쳲��Q$��v�Ժ�ݲ��lX���Z��~Y���{-(_��ݔ��3�Bo�DuN_�>ݙ*
o%�Ȱ����!*������/��깟6?�C�qnh�W��01MLU�N�E�ВKa{H� t�l�Y���N�&6$X�K"�����a�,6��`%.�yIe�ɒ�i�x��}�Ǿ\�d��u�m8ǌ�Qs��</^�Mn��"kT��M��:4~��f���������7"�-�;��h{V)"��zb) ��"�>�F�M�|u�q՝�:�58ڷ=�Ed��)R�����69��e�w��mS��BZɝ# ^��G�JBL]��_"�>�$��e�����oϑ�$S�Ϻ%k`�e��AGG�FT&/��ժB�ai��������ep{w��5LC�Z�;�T�O�ʖz�����?��0�o��痝�b����h�9�+r�ʔו2(<�>4&ʑ�t���/�_�k��N�O��Z����"
a�"p&}�+A�2��~@$����c<���۽ں��"�F�-@!@8)�rK��������<0a�P��*]�7�ҔZ2_��}夲���;`k!j/���h*��D��cOɇ��J�F;n)�v�y�󡨙.s0����ǯyԶV^#$y�ٰB� ��$ۗ*�FN��D�"�D+��0���"����
+����-�=w
!; �D�f�=z㯮���m�,���o*�M�;m�B�;Xab�5Q���o�*{o)�[�'S�r�����N�Ev�f���#���MbO��R	x�����w�ܖm�\.�����EWW�y�K��# ���Eǥ�%:�m��h
���h��O@r�:ۙqDI-�Qn�.X�(��ɇ�U�Km$H���7��:g��Ϯ{L�Q����u��f �������d���KSh���|X�
g�D]>ض�c��F�}��l���Tu�"��R��l�����Z������n�Gq�`�O�B��C|�Zy�����##j���_�B$��E��8)�u����m=[���a?��"��'0�i�-��*�;{�b��웰�!x����R���] �{?�#��i��L=,�Qa9H
<��O��rF<�y���/^���%;~y��4{���Q��ǃx�8����ab���6{��ՃqUZ;��b
%�c�sd1�Nl�����m��ҩc�(�鶉���R�Y�J9��ii\G`�0�b���C𼮇�Q>�i@N��(��"���i:�R$$UK�R]F�L'BĦ�fE������4Ҭ�&tpӔN.��e��M�9%̩������n�3�?��Ic+�n�t��8%����U�T��J��L��=,��:�3*��VBmR��{1>��31����s߇	>S�(*{����|+O�
�~?��@�H��5��H2�3�*�y�.#�d����������mo�Sl�m�j=[������D�7�����u7�U��zO	�N���O�4&�o��k8�x����|�J�[��J_&���W	��7�j�m�}��򱀔��i+-�89	�Pt#ӯ�y�L\ ���}2D�zh������ncVL������D����?{��6���_�-��;B�Q'TA��ZV�[�CrwOoLDG(Hl���{�W�{�ϲ��O���*���6[���fbƒH@V��w�1r	D�]/�8�s�������ZNe&�@�`��\ᬾ�a#�İ���j� $i��~�M�S���7���f��E�qVK|�#�#���<��}�v6F�^�wA=l���v�V�f��Y~	��> \��g�g��*QB��j9A���ix�X��
G�M�~�u#��P�QYa�B�0�R~&d�}bY�|V����h\�T1��TE3����9�pW����	[�f~��v������%33&>�jI��>��5�������A$1@¾��C*vp���Ɗ<.ܦ :יu��)UpAk򾈣8=��q��Nu|�B���(�P&:`
/�]���u����OO�	Rx^�z���'�2Z��fB��Aޕ��D�T�q���a�a*��E�f���J�=�|K|�<h�X�J�7��"}W��V�iy���~>z_C����of���d��W��{S���W��x�Rk�Ї���y���N���W�}o��l���7��t �ŵW���l-�"[��,��!@5����<k�ֺꑳ~�b��x��
�yTԾӉ��h��R��4�	�El�B� �%SṵU�W��u����|��#�bO��}.��Tc��Q��*���y�|���o��-�Dиqbr^R�hML�̖����v?hbU(�1�	�����xFBƸ�APÍ��4�������輪�/�"��Z>k��w·P�C��9�}�����A��Ѯ6O5c�$Z�rڶȞ���� ��~��Z�������)0'K,1�p������z`gr������ȷ�l-(O?�D�(�������-3�8�txV��&bLP��w]��)#���B�U"r�*ӆ|e�L�1"b.s���!_j %g:��-����!�i��h�'?^\��8�tz����� A�h{�Fd�%�۔+iʋ>��fjf��f쌙R�"����n�K�Kאnľ��@�����b/�JM|�f�O�{�+���7p^0\W�|�c
���:����P1���~J��+|�e��7�UΗ��9f��Ӹ�Ȫ�7p4�+���=&f����ɱ z�k7�P�<v绮�ɣ�#�>�� t<M�a���WkJ�L��D���2>�@@�A���W�hf���'�ı���di���/�G�/@��m�1�����E�3�.�h��UzO���NtH" C8<\��b��G�֣z׺��R���&�f�h�y���}>G���t9�nM-郳z���ٛQ^�]�`!�xM�f*�u4'�q��dOCsC	g��yw4�;��D�tI����j� �a�4�bR�>��h��j�-_�.�^^F??;{s�{U�%":brE����]�k��<'t����c]��9N
$��[���)g�r+D˝R�Ȓc�ISM����{�Z8N��X�{��9� ��,�0Nի�<���2~��K�����ڰ��*Ҡ?KĂ��8�W�J(��t0;���`�n�9D�E��w�vUY�;�Ƴ8����J���S�Q��D�wQ���38%ť,��ɖ�hR=Soݻ!��9?�XOth����=��{:��с�)E�d��=V�i?��p�c���ʔ|����+��%�鏧�ӻ����Q��`��4n���=O�f�����L�����2/��	�~�E,PD�c�P<��`m���h5�gNCQ{� G�rf��A�~�9���(M�E jx;����t�l���uɹY��&A��ʸ��}�룫PM�Pm<A�]G�_�l��ARea�$�z¥��H��4I�U�#�z!��&�DK�$�C=�����{ W�r������/��p��w:�"6��,E�v��yJs|ވ����&�{K3�S�N�*ф#�-�ꂯ�e�>ۛU�m�	�25T�#�)�yG���m��D?_�|a�S<��Y��w;����=V p��4 ~�_sOq��kf�ӟCr�׺�U��
2W�V���R��P�*W���=�582��2)�.MZl�Hũ���ʏY�`���n'<g�L���n�������ɫ�N���gÇ�ūWoVj�g���+�L�892���    �,��Bd���˼���]��,��)Y��)CM�A�%*�࠯		���Ftv�\K|T�����=G��|}�_�Kc����d��u�Ã�#�vN��RBJ�';X��9��K�O9�� �R03H�{Kt�pлV�x���!��$"��{8~���a_d����`*�f�������R�����l;"P� ќ��/�5�8uY�f��d���ϙ�2�,���>˿g��s����6����������� p��EK|ڂѰ������������8رm��F�"=�֭'�q���,�����J��;V�	�w�5������uweU��U���w�=C�Z��QD빾�b;^b��)���j�Vig�#K�vM��5E�d�,q�۪���o�[��+m¶�,�@$�'ҷ�/�:�d7�v��p�jϲ�:�ū_p�����n�{�%��:=������u����?õ���'u!\�fx����#VN�M@D� ��ľ�%�e�xm��tDd�9	��x�>Lu�eM�JM&��?΃2E�����@w�h�M4Zf�����%	��l�xF6gv#���1K����������n�ܳz,���±,�<]�q��[2�Y�D�mr�1�"P%w��Ws0r'K���1���X�u	�%�B�{8���'rSRm�K�l�h��R�#v]JB�v�D�d�9f���,��x{>aɒ�-�2�5��{������Ȥq��-����ӝ�V
�����J:w��Y�}��8���F����ǤjO��}3�ǚ�e^���v���P&���ە�FB���f�×h����k?%�tg.�[�]�G�S������*�}@�����������%1�K��T�t��g��*Mᖱ�x81s,$�򱈓��gK�DBm����@G��X�Z�}��~��o�g�9�� Ee��@��L9i�Y���	N֥�%ZR�����++�')Rm68	k���P��-�X'g
C@4z�i���`�5=���L��k1c�x?���7����`,~�y)tad��村�B0��"-�f��g<H��&���Q��ܶ����^]�8y���<K��/�9�L��0�MK�W��N-8{�B�X�,��:�/�8O5�\�/�>>�맭#�e����˓gۨ~A�R����3���a�X�*�.�26;���<c���M�XruwM�b�d:1�wA�"O�$�'�֞�9�g]*�������3��w����������L��=�����[quV�>ټ?WKD4<Z������Z��G�������(9n�E�)A��G��-��^R��*xm��ɘ�'wp��A�]�L��c�ͤS��K��Ȑ�yKr�t8��Y,ֲ
�[�<�X+F��h��Z�m�S�T���Wφ����)���V�J��
��gq݄�$^N���y�6J�4g�lfpP�$����'�OH�<��6�=�at�[*哯_ӱ�,Ǟ��SNR�8$I,F�:n0a5C�}�m��*�����|��:7�mܬ�:C�0���ۢ�*�W47�r���a4f:Ya�C�����f�|�E�x[��
�%\f�p~�wGS���L�ĩ�T$�D�1ŷ)Ѹ�%/z��&����Y�y�SY���I�ı�8�5!�M��×�t�-z3����}��k�v�&G��uG���h��;�g�y�,��;��s���y�e^�s�Ҿ�у�d�,b_����D��F�+z�a#�6��G�3;�"O鎏�
�DGe�t�^�}���s8!�O{DÈA��R����A蚄�&��/I9�P�=e׀�Z��C/]���v���B�quS�B�D��[�'R~^��߇���3�|DwuE�d���<�})�z\FaU,���r�gz5P�sT�HF%t+?���%Z�l�3<TƠ�,��h�O�49�5<�8�I�ڀ�ng�9��{Z�LRS
��61(�Q��M�xz�V%�i�w!�2^H��Y���F1�E2���=�nK|6OԱbq�d���ZPk-�̒2o�6�x���ۗ�ˤ"��(��)�e�|�����:��1F����Qx�w=C�'b����q���� �{��ʜP�,��|�&]�"���ʠ_��(�U��׀�@�͚�AP���ү��K��ږܘ�!�d �$�ۢ˪�XFe8_�n�	�:�� �	\*az����6���#>�<<$4���������!k
��|��R��H�*m�G��%ZJSo+Mنɥa�k��z���h��z �5�Z/�
Γ���B)�h���h"�j�H��K�@cރ&�$hB����L�:t��6���u�����"3���Z^�5�W�R�|���v�Dsj0�U!&>_�IJ���wGΫj<z�#̟������'����m���*�y�b���
�@���"B�������:�Ӆ[��V��`�����H��Ɓ�Ƕ�A��3ס{��%>������&�_%�_�������Ȯׯa�Cwj҈�F���U���[�\3N�X _tV��c�gܦqVrkZ�6K[��b0�JU���#��9�u�X���UyO'
�
�BjS���/]#�t&�S��w@�ikʲL7����p�|���K�������W�ϐ�y2�\�*��j�TS	�u"M��l���� ��r}Kt�!���YTf-����~X�G���󦈺x�Ԛ��!7{v�.�k�`=Hh�����^`�R��R�Rk)Au��=���KF1oK�G��#o����捔�A(��U(f"fI^�Vr.O�%�Ķ2������6��ta�l�B����4Mp�i������`��,�M���NPn�FDҭ�fi��Y��,�I�{��BM~^]�l���q�5�	O�PdC`��U�����PЀ���T�j���{�yװr��ۦ}g�!�畟���{��[tU�
p��y��R�-��(��	�Ѧ�l� Ң�N��uK�0<O���x������Y�TD��'��:p7��:�q��?}��x7v:��->-�m�û�Ӵ2���Sev��=�)#14Z��"+!�Μ5;�z`Rm�����z�Է1l��p����������0z<�<�9���Gʧ�s�L�ބ�1$2�h��2&-�Sh�����}�$` n�R�{�"O[�7���� �TE�R��F-�d�Z�ԣ�:Xb����|)<�K��p0�Rʔ��2�:V�yғJ��k{com���~��?�}%
�䢙R_�1����y���{գ�V�R�k���o1F5�|���@;�6,N5����ދA�f_��i��c"}��e	�3:��j���� 3���גց�L(`�q�m�l-�y[TU�;��I�yd��~��f<��F��4J�,g�fY,�����t�D�/�!�l��X��7�W�z�z�K�7�'c ������i��)P�w/�W�ViS	|i� ���<�e���Fv�㑍$е�����2��Gǿm�=�gO�?*ǡ�?�g����DNT�o!�yf&�F���4�W��{�f9�Y���$������G>1�e�P�&����V����l\�0T���U�~8����Ŭ��d� v:7�{�&7�3���1�`=�D��n����3�o����Dg��R�Kǜ�'}��:�����z0���M
��]���n�
U�`�vfr;5�A>��=�_ѫ��˧������?n���Տ�E�G��hƙ�RK�5���-�/`�]���E1ьx
��6���RFm{���8��'�ܩƦN��az�Y%8 ��A�xX?���%��h�Xa�=P�������g��-�Z�E����qN�z�)��0n��޳���]�G�
q����
�m�]��_@m3�D��t�/@�e4\Z��3�^�g%�-'ٸ!�[�?3t�I����Pt��"p�A�]������kf��	n�	P���K�G"O!g3D�P�q��5����[��S%���J���\�vM���Ʋ    T�E^k����$KS�]�Ub��T"��ƃ�hɲ��N�������������t2����/^�|z���<[w-8v��;�s���=��D�1ϒv��a<���X;�o���1��R�3�/��G�t��΃�7�ĂLי�6s8����F���Cl��4�*�p�eBw���P��۔�Tz95F��.�n�_/o�(��S�����T�m�%(w6������-1����]=���ul �s�g�C_��|��5\�[���f��.|"��@`��T�#b+m'�������V�|�+��
UIt�����p�C�s�IW)o��(��&vBIU�5AI�CBMɔ�A��f5��ձR<��MK�Ev���[d�
���A����yu>|��f�<}CȔ��Kƣ��YٯW��.`�p�D�@��f�Y��>+�2��
kڤ�>�X}�9^IxX�/�s�Ca%����ٝ�g������ƴՏM��"Bъ-ϣ�+�(����������i����Յ�!�v5^.�
�H��:�P����Nkz�Gˣ�I='G�����V��]A��tE#����ڦ�(x�E��=�,���S������*l��2;�|�UҶ!,�}���2]̑�<�܌�arz��K�zO��4�>� ��n�� 쥄?�x�ѿF*>����ad	7	ހ��O���d^M\Cl����Ss8\ȗk�k�~8�o�(�ΗZ �'����ÓG'�IЪ�}�Yu�é���x\7qj�YjxY�F���5�$[�2N��Xk?����*�k�n��ʷp�;n1��??{�e�g��7���ʩT	^�^��y�]���M��`�r.r��D���6�x.u��|�θR�,���m���>�������z��%�,��B� ��xf�0_�|/����#�����<�	��T΀�w������1��q�s6�F+I���h9��GY(�Å�55��/��K�4/
�e\��}x��!֣�7_�@�>Յ�/	$���s�O߭7�~5���Z}��@�쿚��}g5r>��<��e�>[P)/�G淋�RbPKշ
»�)G4_�k�5���Ty���i2l��&�@��i�F�j�`�A��#���
���@l�ȏ6ѡ�6�����i���z�9-��׀����0�U�P)c�|3�S�5�%:���
Ϣ~�~��Qk�(k0X��-U�|<�]�g�z�7�k��v�'�Tf�b_���_���f��0ڭ�T���-��I�Ԕ"�`���x�n��ƶ�(U���6�~x����7>=��S��)E���0~��r2E3*>v�Pj�U����Say\fV�	zP��L��}�=^��&�EA�j����W�!V�h���'�|{@X��F������i�n�fj��=�Cm����-�Zl`�Σ������_�j�Vu�0;;��`����*� ׾��j�jM�Q߼�)E%x��A�UK4y�����|P?k:��[�j�!�~�rEp�(�ZC
F��"=i1oc���a^7�ֿ�u�P��_�q	��5°�i���_R��y����&���9�yAa�@%��s���N����Z����߅E��ۅ|�Ζ\�dSts��N���M�DLé��c��x�CWh���|����-4�<p�_�^�zuy����[q��]��21���a��=�o���E&�I���B��R�<�r*��C:W�bpX	p�k�.������M�'����D��0E���q�@WZ��,\��8@^��H�b��,�ʐ|�$��'�J{���������Q�s
zt��R���cTgi'�e��W�ˎ�F;�' �OnUaPŭe6Y�d]92���3�0�']:|��h|z"������7����Χ��hdE�k�~�D�b�c�8ԭ�������'�D�d��p�y��� [�x�f)f�8������zU���Vr�qץ�<I]��	^���s�יu�U9sr��:��Pb;�S?)��%ZI�]<�����,����/�;�BL8�+���b,�հ?��}Qj%�1�.tħ��<έ�}�͂����#L��v0wT��&m�,¡o���'#��p��)i��v�e�v)�쭟���
�X�T��T��G�!�5]�Z�0*���f�[uK&}
:�NC	�6o]�$���~��?����q��,��O?)?��M��M5��Wv6�I�sP[Fxn^7B��?ts����D�.�W��h�e�!�9{�cp�Q��}���O����Q�Ln�_�ʀc,�hTwZ>]&i�"�ݮ;a�@�1����_��n�(v���5�U1�_������x��T�a�^�|o�&�kw2)���B	���Y�8��?ǏaD�E�d��[��4�L�Ll�� �� �t,�G��@>Xd�6׉����M5H�f%c�6M��ʤ��qY$�w�s���M��`����N�,�����I�\��1��L��4j��� :����|�<��yU����U��dSL�,H�[oi��R�H�'_a-����HQiJ��Ӗ"χ(�B�g2���Q�(5����&����vM����W�nB��r8~z��"���f��&��?q�=�Ȓ�hB�����X`��8��!
Qg)����A�2��� �c���sS�G?���%Z´#S���P�����P�՟G�Ɉ\7�
�'t,���mg7�L�~!r)�]%�u췑+wE"s�n�Bf
��R��o&�%��i�cOxy��\9R�ʌ#Ӷ�+NX�~��d�B�{?7 ̟���n{�������W��Մ�T�T%�����
���'�7���җ^���Z�$���|X�{���#�P�T���f�b~D�����/��9|�؈�o}�fp �����!��r�k�D�މ���ܼ���^
�[4���o-լ��2�K���#��$�]3R�:k��B�Bn>봄p��.+cۖq�=+=H9�%�q��c����<�� l����O�OO��yx<�|�:.���{�Kt��h��MU]��璘����%g��#����1��k�<�Ԓ���M��ڰ<�-�lS R�@j#��3r�k��ǯ�+����-hB�&���eC�����mt�� ��#z'����DWYңvi����ɫ�/o����*c�m��!�Ԏ���~�5�ݺ���e���7�-�q�`k4��%^2�Z[�W�?^>��O_�CQ��p�ވ��Y�Vn�W(7�āO���%����m3V�8��^�qi���υK�#&ͪ8��u�M2��2q%���qE2tt4���<w���S@�}~X�]�7+��2���n��v#�$ѥ��1㧼��.�����I>������_-�Ѣ~�&�����'�s�ض[��}Q���}i@p,�>�N��^mOUb�1��
�P�TK�=MƄ��^��f��yJD^���w0b�.��7���6=e3�S3�	�Y���1�$��W#���[�9�4�lя��<�����9\-�C��+<������5��9s=�a�j=�sL�=Fo��l��y-����kZx�y����x�>!v��E���q��&�?B�\���-�+ =y�T<"��{[<�-�_�^�Ye��A�
�5��2�X.Ba�HED������m_����'�C���^�A�/}��_9���$���6􅮊��:¾�AW��Q��܂>�r���\_�`�ߔS��%/��BN�c�@M�؏�?|���p^�f0����
��.��/�OϢ�g�'?���ߜF?�]\���F��؇X=���̶+،c+MV�R&R8v���G`|&F���rS�\iE!�Mc��O�4�e��WhE'_����r��5�]q)O1?�I��7���;{2��"�y���;����9�|n���Kj�'0�`�F�>̼�ɻcℷ�a&�|��7��8�k��|syiS]���K�$N]�ʭ;���T)��|���d��IJ�u�ė���� �KS�7q,    �R�.D��ʯ+V�BqǛ�5%���<����V�Ovv�D�}X1#��8�D8]���ϵ6��ӴHlOI��'\�����ߖ=�s�u�c1��S�=F��O,��33�'5�d׆� B{_c�+m,k�_RAS�XNg�
�H(��+87�Z�6�������ͧ��b�����!�1���Nc�#3�Q=jlq�fk���WЌͶKʱa��3fo����lfi�LD�6��)A�(��E+~��#6�"F�y��4�H�×���!VoJ�׻%E+=�W�g��eO�{"�{"��Ad\�2+bdW\�Se�����ve�[aw�����*_i>|��y��YUKd]9�ō���pǗ���<�G��ytR!��Z�����7�����𶠪��tlᰌP����"�'+Ú
��i�ra>/�.2���܅S�˧�h@%��Z��3�1��W�^�N����f�z�%���5�9��>�
��'�s�AYP'j��w/&�1hP�>_��k^�� ,�~�l	~9}�b�<����g�d,2�|�Q-��$�.��;��z��R�d�)�FSwegp�_��Dg/��w������s?�d�S�޹q�v���A!��l�����g2G�N��W�9od�f�KG.�J;I��&�Q�
��^짡b�8�)W���s�VvU�G��y��6�n����=9��~:{y�tx�v���B%F�p Vi�7�8a\�R�=f>�j��!_1%��C�v�XY�R|~�mH�*�0�wFk��y�(��d�	30��Q:Xb])�(^~�֌� ���=D�FH?�=M�R����|��y`S���GSQ�#ϡ��K���]�^
p,�"�h�sz<��<j��?�
?�f5ә<��Y4��\S�.E���v�:�X7uL[]�o ��nD,��=�gį_�Ķ]L��:�^�o��vO�/$'��48�׊:���k8�yn�bY�h�<�WX��p��!�3��g!-[�ӈa���ao�A���?��?��ّ^V�6��>lN�N����H�a� {f�Q2sJ�M<�8fl�m}{��K�#G:m�W�	�ӛ�xtC����z2��xy����3�s�ۨ����ϰ�<�3Ն�<��G,-QpJ���ᜃ�֙c>_±�Һ9�=���%ɔdqپ'Ɓ�͵�`���50cD;&`)YL,�����T�]��Rj8�������z2�@!�3�fu��U�D0�u=/
��|�ʪ`�����C�}q4�O":��n ��
 Y4Z|��D�Q0�RoS]ā%I8�
�;eX氮"�V��mf��17�k�aK�$,�p��K12[��������.�j/��=iM`���}g��c,�<xz����>l��(�O y�h�g���jACI=�6��������b~1��`?��R;�w����y�Y���0�(FE�@� �
{ p�.������D�!Il>�n����Ӑ�"�k�BܞG�gΆ�QH	y8�:�n�������*Hw��Z�~�>�>�"ut R��?a!���q���_f�u�Ŕe[�c����	mw�
k�x+����2�aߗ�.�?_F�O��<}v�ӓ�C���uq��/��^e�$.)KӮ�Y���5ɴ����.���������mJ��$�o���cD��ە×X?Y_Խ�"Ӣ�x��
~���V��ȵ.�cR��P���sWĚb{��"���f�w����R(��xm�K�E)f�t�~���+���I�IЅ���/O�5Zzv�z1s��#`1
<fI<���p�@��Ze�,�t�-f���e��x���L���B'�mV��1��IlRIG��%�⑯%C�b�����)�B/8/���<7�H�oə|^$'I�,s��-�S�1]�<㻁�`|��P�CWh�����,0�)�����9[8)�Gz	��N�̷>xcg�`���G*	5��׷��V�U���G͆X�G�����s��R�3����
�'}-�͂�����1�yI2l%C�]���\nݩX�ؙ��E�n$����J�/�w�D#B���v�bo���D�� ?6�tQ?�]����>���Ӈ=K�!�,�k\n��EQ@�{��r�a��2�v4/��mM��5�k4W4~]�:Y���-�2�y�&6����X�Tֽ��X�(�Y�����7�m��/�s�yaX�[ϒ��]p%��R��W�/� ?�K�t���IS�R��4������/_�(���x7k{e��6��/�#�����z>n�Im�\)q�)-�']:�K��¦'�e�0���ߘ�IRrE�{�i4��D��a� �5�I� D˪�v@8��ĭ�_-�z?rn���$(�h~3M�"�	���W�`<2mu�yJ \����)Γ��Q�9����O�� =�Na�&��\�����n����;�}�ŜͫG�GtWݶ�5̳���&����ĩ���Y��Xp��@PY���`��ěmuY���3EϏß�m�&МZ
h���zc�ǘ���g)�Ϗ���l��M�\4=��Uê� L�><��庚��>�� cݴ>OID��	���é�2Z.�i�?����Sd.����ϗ�d]�|��(���tt�0�B��I��m/�b
��W'5�I�4��>���d�|�����F���ގ<x�+C��_��y�Q�9��|�qhz �-�,�:r�l�mW�o-(��o����D5�����W(����"aw?ࣈ"M(VO�!�L�J���8�ԾR�^C�{k{�u�!f7� ��58��>GM$���D����f��$�6�M��5B!��s����7�/
�d�h���������#���76�Q���B��X�<ή�H�
\aV��:� �sXn�����v�7���L�P;�<���~?83��L�
���Wp�/DZ&1/rg�e5E�W���j��`�V���i��G����+z=|=�%������E�����+���6�ע���¹���]s��lXE�8͌���,P�@�z�,$(A�F/�+�}K�W� �q����g�ʂy�iʋ�1y�c�0-�E���3R_ޯ��^	�2/J��v��0��M�c�j��x��� �C�|r�{db)M�A���O~<�����E�[�Ta�]l�ʒ���J�]��y�I�$8�6Ue�zB�$
I��$�mq=}�X؇~.	��t�Ӿ%)�}��YI��V��e�-4�#�<t1]���R��Un�0[��z�D�e,���HF3���M�6�+��Itd�/ђ�x�t���I�t��L\\��9�$n�r�L��5�d/i���^XL�+zp^U��C?��g����9/D;D��o�*xuHR4��Ӣ�^�<r�������#��_g���[� ��-+cӺn�0N�W��I�㡉�ϻ�B��hC[#�=�G�
����O�.�����VI2F.YgR�-�'v9������ ��*�Ih��"�Ifn(���!��{>^� z?��(��d��0o-��0gC�Ĵ�-"Z�!?w�Y?L,��[���zI�8�i@oQXM<��v!��0/���r���W���l�R���\�6̦��#E��n7:�����,+�+�)w��ZqF��Xv:N��(z`����ZK�%�|q����˳u'����Tk)�=ۏ�!س�ct�{�!��B�����N�����`3ޒg�o(2�f�_�󂺻[<��Ƹ2��y�M\MGմ�La��;�1�/!��nx�V���;���R�jA]b8��K�K�� � ���T�6X�:+����Ynr�vH�h���$��/�D�����/WR(�}鏟/���/�'��%��S�;I4����YaG��)Z�>^ڲ�U��E$'���7�ɫ/Lk���T���^���ߏAt�0LxR��=��(
�@�bBK����1����^!uh�k�$(ZXg�����;Q�����t��	W���b>�n���-���4s�3`8����1�y � v��6�1�h~    ;��		��u"�9�1u�%rpD���б2Y�5>E�2�o��|e�d���[��~5��v*�2��47���vZ�O�Ķ����}Z@�&��0]��%>���f� [R����}�Z�7����4���$]jzpul�!m�
Q�j����/���7��qf׃�p[g1뤻w1(� DJD!!.CWݙ@����^W�d	ӶË̥q?�6�U�3TW[OR�������}�-a��0ۏ��՜C�r�^<=�P��$R{)�BIcU���8��S`T�K3�P���O�g�s��`����<&b�����TӺ�� �-&#����+�iL�y�h�ΰr�ZpKy��r�ӊ3��F��"�n�
�}���~� |a�8�B��F3�Yx�)�[�g㪢~�����r\��>���noGRxk3�v4-*������76'F�j�	
�U�r�"��gt�}���x@[�l#����/��<S*�V>4�{L*����w���.=
�Ï�������p!�l�x��jD<X�a2B�,�����B��@��b��T:ȁ�b=�c4��*!�c&�H���T���s���:j�S�n���(�Q ��I�/I�0a�js߮�B2OR��d�����N?��~���&��R��V�΢TY���e�w%�Y�B�<ߩ[DE���%���6h���%D����v��ɳ�_.�/�<;=���я_]<9��������_�<��{�`�.SlR�Ѫf����?xfg6zrm��[�l����R��]}����(��w���ln�}��wg�iK4(�f�h���)�� ny�<�Q3��"7!�YR����M��z�ח���uV*��m�R#bS��1e����x�yֱ�h�٧���O^]�_bg���g×/����;$�C��'ZL�y_Z]4��Y?ѥ2q�K���b�<��^�&a)�]���S����8��*0|��ד�3YQ:�3���,�8���P9Y�u4F�,s�&|s�iYX��9��\�\��1�OC��[�:X������L[cD	��`��j�77���~|���>��4&U�@`�TI�)\':-�\�̬!�M*H> �V���q�"S*?m�2V0D7*ͳFS�~�K�,cٓi�z�����	��6.���!bă��X��ɍir].�ǎ�J ���栚\��j�S��{d�G�-�j�ݕ��C�x�E�:��4K@�7� �MNoۄ�#u����\2�	f���\�Fr��-V�q��5L��=b�L[�����&�(-1^VKW��tE�PMs������=�>q��q�]���S����Ck|�j�]��'��#�ït�O]�og��I)�8�,����:-�h��q�t�Ƃ�#,����R�-?�8{�<:�|�
-���&ؗ���/J�PmK�.�?��3>n�$��e����L'pe�L�f��C8�������S}�^��J�a���5&�� ���;�Hj:�����E���y��,P����=��%)k:����S:�qu#��)w0M�!�hm���y�flBA,�a�^0	i�'�>v� k����;`������ԯ�p+��$գ��?(�b���1��Oe)�g໮�Jпa���tl(29|��(�}�� m7zw�D��I0�۽*{��3K�|��F~kk��P�ڼ�2��t�y�,�Ӌ.qs��,F�8.�άN�U]�3j<K�c��F�Z"C:|������"mGw���1�L�j�y]��E�eI������/к�[v�+�58٘R�2����5@'}��q�&��YS#�qL}JB3㧎v�D+\�t��Z�?���&���Yh�3����þ��	,w�}�-/���m���eֲ�1O��&M�H���^�k���Ҫ��Z����0<��P����˷p^2�e���(@�a�l�<ҍP�+T�L1�ҧ�%��y��tx����Eܓ�F���|����<�s{�<Ҙ�XgfS��H\2��$�8B�`Μ&�����9�\3�=1�t5�\�>��(K	�"V�N��w9l�C�吖
"g�.y�����X���#�Xa�9��@L9c)�4����%Zn}�˯�{����#�s+|2"�!"l�q��(a3�\_�IM�+�?ֶ�Y.��.�7�Ҁ���t[2p��Xs�Z�e"_��dl��.��K��\�������?�O�ށ����T�ˤb��9c;؂�Ŕ�,oK��8�ID�'���8�o?�{o��[��[f�%I�y��)�N�e���e�,�>��)�i񇢃%����c��=��xw�H�"T$.M�Թ�=�MI�āM�Ȳx��l8v�(ͤ�n��hٓ���d?�����F���t���C$���ڞ���C�e��M�w��Y[��#l�z�ɞn<Sھo�����Ǘ��5����ޓ�d�M�v�'�f��҄)�a��]�Z�媟�q�v7EO$R��s;�F�'v�[��݀��d�-aꎈ����FD�&�y�y�A�5b�q�C?Ǎz�_S��o���4/=s���W�*�"��Y���;������@6���StP#�Q}�\_�!�-a�g�NV�|�G��B7�^�F�#�;������w4C��r��$n�yz��n�`v�Қ�r��o6	�Z���U�c�j��Ɩ���XfDxf:r�!t٪�JS�C �8*!�&c��>@a����F���T��{�����<��iτ��/_����_D2�VH=�H���k5�L�e\��m.��`2תH5(C!L�#��I5-�/�~	c�=q�?<F�6��_�h�'�7�!�f�r���y�j�!2����r�6;��X�
�H�~��%�mR��P�u
�A=_�b��Wh)����5�'����=�������h3�$�b�f�na|!m�q��1���,˯��T��I��yqb��y�K�J����&��h���X��4 ��<Յ%�ٺ]Rs�f�[0����o"�i�`���MQ�,8`i���c��$�\���w���Z*sW��5�3s������&K�y��X0N�os�E?ق����L�i�r�e�z}:H��'%�`��Z�/5�"M��r��E���<cʤ
�Fi������[M-`�o�r{������]���̫	��1�1����[�7�c�`�����V|C���%*)��vQ9
'�� ���k��]�D�h�qT�M�c"��|rQ�2�%�.�fC�aZC`�T����up��/{� �a9�77/�3J�kx�S�8�-�8�͡���}D��]����$�vr^���J���z֙p9%Q�|�I@�c� ��I1v��J��;p����o����O�OO��}<�|�?��kE���Vyn���d�̖:y+�`c��V��Kp6%2��MO�c��6�=�՟���vy\63CM;.7w[dij5x��kUE�i2>�K���z�{h����^�=�����Y��'�4��8z��źœFw���E�]%�tJ�i�c��:+y��R�lG�Q&��tb:X�ϔ����-�1E���:ě;7ˁ �p��a,��Ez�@s��4��W��0[�IB��4��V���y�T����w���2z5��HvR��j�G㷽s,`6%���EC��⤘�W�s�Z)�D_�EC�4�U�P��*�����9�&����0���gqY�"sq�m"�A��Ɔ����,���L<`p��������W?�D���0�o���_no��d @R�|��R�(�OA�c��5�+�yQpQ�B뿼\��e�M��=H�2\#{�؄T��́��/�&Oi�(�r��r�5��G��5y�0������+���W?�BIQ�d��v��<�e��|��+<�8��gJ���XS���wWx$8FZj$ӱNMfK���X10w��an�A�1M�� �}��CO���|�n}U���AL���U%`�M=*"J���i$, �ձ������95|�MՉ�AxZJ?��[�]����Stl� ����s��ūa��'��<���0 y�XbŪ�0M��-h    ��
�0���-����~�iu�nn�K��!��|��al��#���_�~l/���2�d)��S��,�s-3A���xMұc�X���BKK��>,�����Jä�����D��E�K�4�#�����D�Q�GN�b��UXGm��9��a�o�I�Mﱝ���������2��%���լ����G<T�gn΂��[X�.�(�I{0j��o�mȍ#�eQ�a�8�SǇs�M�ݎ�l5�t������������bF����׳�XⱮ�}!a�X�+[�+#<�`ѹ��Z�|*����8��b4�ˣ,Ҕ�Z�|�z
�(�����BA�ݐpX����U��}�J n*�� ����8f<_P9��	.6�f��U���h:��1��q��� �Hq��׻߂q&�6���C.&��B�ڸ��	�kG������r�~Oϟ~ht���EU���a<|	��.�?G/^��<��Kőt)M���/��F�q�"���*��x?)mZ��������<�;�J��<��ǧff*&�QNB�o
�ij���`�����TY���#ƒ�����U\�}�9fa���������$g�H�߈Aj��JV@�\�kv��cDX��2L�9|�����M�s�2kj�:}^���L���������c�Cں�'�Y��o2��A��1A�`�o�h��*,�TW�0���SsWRc58�\<�3Ƴb�	OR?ű�%�I�}���瓦o��Ů�y�����1�bK"0ۢ��SJr��u��t�����o�s�n]�L�Jl�]ɕᲟ�IV�ئ��;�*�J+��`�6Da[4�k�yS��CU԰7�}5��[t��U�{flS�xK��$sy]9��-������Ʒ@��uFv�N�"I�R0�c��@�-3�IO�x�-y���:����S���	Q��}�,�b�k���-��4<�\P��O[�l���-:X���ڈ(UOG�kC"}�&���ɴF�S�F�k;�C�!��]�Q��#�&�k�"����TM�cO=��׾�,�!�ABT����%z _�zɸ��J�!0�n�Z��?����ط�*����(�榅��n�RT�j]Ʒ��QEh;�^��$����o�Fx�'��Z7x�ợ�{�$�%����ฺ�f{+�5a(Q,MRhC����c�@Υ)�,��</#��iK�ar�7�)��a�m�ZY]���EL�G��	��vL���޼&)��/�Ų$u�!�qa�p1��yMxV�~�i�L�t���'�b�P�A.��Q��*��[�Ɣ֬���??���k�P-�<�dK������)�;�	�.�ϖ8�.rc7q��������Bx��Uٙ�}�?CP����C���i�]9ʃV��:�=�'�NeD~`�$�V��c��0�=ؽ�_�������opB��n��vO,�ԋ}7�p�*�!Ri�=�Fpn�4�����͕C����P��͛F���8�(��q��A�-�[7�� &D���s����6_����Z)�	'����ʁ��u��NPK��(�*%�l��(S���%�����FM����嫋7�O"?���7i����^�^K���<�gϰ^}\W��X��{h��?����^�{k{�`�����p�ӂ�S��-q>­�D�$NsO҃1y����8\�q������U���~�M��*86Wuq ߞQ� �Z$��s�xl��_��i8Fpr3G�b�`9#Wg��!�ȷR!��M�g�sXn4�'|��� 9X~2���:��܀�����׍C�[p%���LL��p�$��K�r�;q��u�ĳV��������/�u�ݠ�S�U|�{Wf���٪�gLXvs]{0*V}^�����}%�_�-(K��@�$ �"kG A����|�×�kU���,`��֗;Z<� "��v\�һ��Xр�T+-����-�LoGFt�d�h��
cȟ69&I?V�9V��dm�+u@Mo_���^��7±��������K��n��n��6<"��zu�������R���;��?D�M^��2�s\׾�d�aOa���G���,��`^K�o�Z�R`�S��u��>��
7�X�	��3]`���s�����Q_�n�_���.k(�5��a�9殚q��]"��[��>��p:���s�<3/Ct�I����s~�v!�'w=��Xb�@#�����%>�("��z=l�5�Fg��x��i���K��uU)��9���
P��,�1�
+$2It	���31|MLwda(����}i����E�g�ID�1xuM���	��4�H��V'$�uD:'a�k�n�3q_�߯����ĳf���^��WⒿ��qՉ��m� �93Hb!�>@��K`��qH�\���ЩF訶�]�M��*�#�N�B~��S~��~_�-��s��-�h��Հ��_=8 ��Ba���D]qKYƉ�O�'�,���:`E�-ȅ̕4�����K��B$V�Z�덇�$>�X�>�:|��*�եQ�i	`kH ����,>�^^��6{�ұ��=�X�u(�^h�.̢��+)��DIm3�h#ﮤhx��)����X�S��礤Dʷ�{t�"�b��J�èLڻ�A�|���}���Q?WSp��ц�G"��ۧD��p "s�:&.�[G� zu
27��:F߄�o����a�ص�h����}�N�Ow�����@�+SΒ��ŕ2[�])9+�NmY�P\|���JK��h�2_6y1|=�|}�rx�����z9_��^Wz��!�@�D���S���=|E���I�HQ8�Z�N��Eh�����V�GYMOB�r4�ˊ�+��q!�q,����-��:���F�`\E.OS�7�����U�A2r�Z��cp��)!�9|����6C��O���D�.�/��n��5c��Td����I| aȞ��E�b��#x]��c�mL�&��g�o� ,uRo�H�Y�:XbY���b�5�
\�'��Z�༪ƣ����h��+>�Eb�X'�;��-��p>���h9�I-�ifz�P�dۍ-<xOi��c)o�
k��o�	6c'[�aAU�c�t��$�×��=k5�"Q�j����UO�.����<$�����=ks�8������3�{l��z2sk�ev�O'����Q4\,�WD�W�~�Ϧ�{=�g� ������-�hT���X�)���YfߢJk8Fjz�x �g��{�y�Z��6$��T,zdn�C�j(���4Y�k���rq�����ӧxlm�SQ�pP<�m_��-r@�F�ӹR\�w�v,�����H;��t�Ӟ
;ޖ�
�e��$�)ҍ��[�2���F�?<��G��G%<��˪�m��t��:O22uy�4��8�U��%=�!�xu�ȶ�(z5�4;2���?Y�`��(r���%����m1�]؉=��c�0��ߟ���/X�b���!����|��,h:F�4|fy3��#�~V�f����z*ܥ��<a�PJ$l#fh��4 ��P�RjB�!�Y
�k`$�1B��YaE�!bDLx'����%ZR�����!z�b�/$��]�����8�gO!�x�`������b�A&���T���A�&^��5D��i�{���g� �l%���
V�N�v>�WO�/�N���OΆ��?�o˫�Kx�<)Zt�4l�&ˍ�V���Ų@�6���{	�0C�����2<�I�pM�f�&<��dE>瑾 ��!5& �W�M�0�`�=��jCX��b���J�Į�ľb�����ys:\��3��<�&�҉�	�i@�?(�bGZ= �n�Q�I �8@זh#W��m���(�~�z��H!���S�0�j���>_6�T��Ԍ�NãtD�P�cp�(�D�Rq�N�q���4qBO��%�|�ﾈ�{��Cd��vV5k�]���X�Ajt������7vN!^�9���h: �	  �ރ�ZIt�ݎ����vܣ�o�߶�(�#J%!�0��߽s�2��6s<�S�B����<6n�6�gj��|4�٪kdY�#��[mj:���d�~ņaD?�UqX1l`9;��L�g�{�	(����"4Ɠ8�c�#�I�u�v&x��5:��7Q)��RL�m��nG�1DB�t�������%ZH� S�c���5k�5�瞿^L�ׅ���!8O>��0��=�QZ�g���լ 
�o��[�����'�w���ߢ�E0Kp���PR�C�[��o �vA���9L޳w�����1�����2\�����l��9����c�WN�v3������{o(T������p��� o��N�[j_�������[����Sw7��wΟQ���#5j:�1�  �?L�r�ɓ��������!Iq�QRf��H}���%�9��� �~���IB��+p�xv(��hu��h�?w��[h�ϬU����mX��e\��ǆ�l�)�
��*�S��v�DKP��{d�O����u�S�~�M�-V�o��-X���Qڒ%R�m1�FfY^�2^{~��1g��Ԛ��-����@�/.��%���S}����h��Ŵ����6H Hx+_sb�#p�#�d������3��݌-}<�q����%� ^�-�\ۈ&`���wi<�X���Ʀ�rd��,�a��Q䉉���x-����z��5Ȁ
(ɡ��}4{dg3�+S���m���4b��J��8_�y6)x��g٨�eB'���� �@e��Wh�]�*��ڶ����Ϣ�"�a
����,�ܧ�^l��x���B�ˤ��Ő��L��'�����T"c�佋%<�����GK��u���5�r�Z@L;�~@�� zj��N��'^y���E7�!KD$��!bT�I�F����S�:c�f�������S�.s#B>KK��	x�XVAl,��T��Pw����b��*X��Rk�,��x$]_fZ�L'Ҙ�BF1�(� ��CjKl�����2s���#F�Yס�
���j��D�~����,��ӧd=%��I_%c����;Ȅ��!�\N=-~���d:���%,��%V���4�ۺ��c��Zr&��J���SjyfeӔ�`���9��/V7�Ï�_3J��1D#��=��}��F4�˅�Ysz���D�ޅo1����`/���g�[�H��۶>Bq���M�r^7"��cTn��[tU�7��%2sSW���V/;�N߁vjq��ˈ��!z� �8ya�	�M�|�AtG��cT��G?�����p@��p���m ur�������L�����-�E]�z��1:�������s0�qy
?`�H�r��ǋ�×Oz�jq"�݇Ƹn4���Frᅧ�S&n�3:a��_���6�s�+�$�������D[����ű��4�Kl�
'~��_¼�]�I�n�HI���ޙ�}o�V2��ѣW��j��<���av�Þ��^D\0|ɬ�_2��k���e���uUq��㕤���%.c;�M7�HwϚN#'��$�B�y�?�-���`�V���_�B{Ɉ|�XTP@����Y�:Lf\K ��I���
j�ڕ?T��T���u���HK67)��cs�����-*�1.��.���TiZ6�X��qOUU�<�^�6f9b��:���?r�+eS���� ��F*��!7�+�g�
����.xt��P��W*��i'(�^ ��}�z��ܒ�}��tB]��"�Np����.)� �D�bRR_vI�_��z�e�'��<���Г�����̄G}��ѵ�p����f��4�?$K�b��F^�n�I�YI��-��֠�1��C��Dcz����D��prvj�� �8|3�h����G����@�8�b� ���cu�V������>r�:R����-U�VukG��^��~	�
�-�����̌N\?����x�B�L&_�[�� �i7B�+Ə���%hL�TP7���nf|�S�Xt��.C�P�d�A�@	� �Q��f��M�^���I7S1�U�e�x�HsbB�T�����n9�A�Д̤��:��@������܅(����zE��٪��9���(�H�b��%W�}���z�֝J��>QV99|B�L�A��L���u�e���l��"N4��OQoޭ�t���n�����m}s�>4�.L��F'=���e
��f��#2�����5](���`;�jY���q�ؕ�|��HEj㛘n�X��K)s!�G�g���Q��.p�I�UM��Thն8�ҥ�io
گ��*M�@���<7@��W��@әp?3O�Py�
,�!E��ue�:�km�}7��45z�Q��Ru�C��(Z8�%9	.�2��+'`>EC��~�ϳ�����9����^�5��!z1�\�PK_.ޝM>MT��ڪw"�-p�$�Yk�j��(�X�� �Wy�6wvv~S7NH      �      x���[��:��~k���o�A����������왖��e�VE��3�| ��z�o>�~����H��>��ه�}[z,I��G�\��ʹ�E�ݘ����?�;���;�I���ҍ��L�����;yO.�� �6�N�囓�"L���g�!�̏����qk)�\o>F�X2�v��#p�n%�Lt$�%x]L�n��d^�8�g����q�A] bj^�������+u5z||u�5���.1j��#QRK�����g3��o�-���c��DNXGu����y�93�����~��O���\s)�����/��\�H�vۈ)��ŝ����܏?��=�kX�u����q�N���r\z�[������[q���`z�K�.�Mt "65	�.ў��'�eo�bd�3�'x���K~=	��;Lq71�Ă����}�7˙���F)KɅ���8�]�O���O���s�����O?&ޝ��iU�ߋ����njj�-�lT�=�j
}ܼK1�P<y�Ԃ�����p�+�h�Ύ���?�/�;�,�u�/1w���8q�%:0�.�d��y$���/�S2��G�Qj��Θ�l1�t65S���`VJ�Ǚ��69���SS#����F��q��ߘ��qs#7n��+i�Rzϑ�Di�L)U���5�竚�u�q�ptX��D�@M������
u�п���i��9v���D���rR��&�����Y�~<�n��z�"��̶��S�B4E!p��{&1:5-��t�[��C��u���l�L1��YOf���{	s��rɔ���P�8G')f)�.��bI�#�!�V�0�1���l�̰���q��6����s��935� }�,�`�)�_\d���K�$ёH�S���i�|j�fX�����`RX��"�f�w ��$��y��\�A�{'�,�r(�̑���1��7{����.8�l�3�.���"�&���C��W)R�R[��0Ƌ+�H���^�Cw�*f�����������{	��4`	��d7M�H�"e�Ij�o<��,���t>'3��E��!�U;\ ��
0\鵯�2<>
_�9�z(���\|h�9G�\j��k�Y-�?��X_��1?����W�^Ĝ��93-%����'�.����ż$`Y���>�,G�����W�GC=��
���&��D�j��1�+�K�k迮ȓ�K�%�X�l:����D��,L�Nzj w��4��~�N�m�ɺU�~/bnjHvS��Qۀ̓�Fu#��M�20�	�zL�Dei\°�/��Nq����N���] bjf���{�@��y�F(к`i~�y��ߖ�"���C`lI̙�rx��ܻ�8	!��/+��@�܎��}3tL`�[�ވ}��v����@Bq�#Qw����P�Mg�w���j{{������{svi�?���_>�,�z�&��PB��p'�KT�Wob�b�Z�	�?�
�K����E���6�_$S��V�o(OT�$ o��
�HnҍD~!*����Ғ<8�Ż3�;��z�?�~TY�A��%LFc��~�8_V���u �pO!v��.ҫ�a�����p(��0�=�3S���t\�z��V��Β�mS���Z_PT�' ��s깗hA\����#���%ɬV�LO���`s��p�W�{�@o�����~�<�48y@	w�J�cM�[x���s։q]`�N'f�� _��ʆ�̺���3ٻy���e���~�4|�78fNZ���W�D�g�H�e�S <��oT��8�	�K��*��%�헴����m\W�ߞU#�<FI�r�/�4xsE�D���M�ܣ]ζ��~���{��n�.15/���Z�͎�}܂��C���Aj�ES��p��#�uً���Z�M����ȏ��u�R�Z_ b�b_v0�S�4�qz�ĔoÕ�
��o҈��|I��U����2��:��&Cw�@���|/������)�#������HK�z��Hd���	��tV�������Gd��}V@a�^^B�)A�����!�yY[!��HԊ�B]Q<s�X����N1��B������{�ژ��1��]���%��-2��\�W"?�E��\�?��)փ�g~��C����R.1�@sMb«�%�g��ب&r�K眜�;�=Qu˦W�,|bݏ��z�*ָu\����(� �y�l�э�>�3� Kw�C�+��;-��Dc�#Q��C
{p�L�L�t����L!l��D��{U[� ����۬n-���zN�8쉳/�Q����/�g�z�u7,Kz�	Z�u��9x�;�-��j�z��7,M��!w@��h����i� 1�(и����U�����ˏ	w����%L��S�zk�ݗ�������Y]%��Z���H�?�F%u�twۜb=\#��$\܀�"&���W�\%�a���|ӌ��w�RL;L��#Q��N��ϐ�1}s��u\��FsRc����D�M�w�Dc���d*����]: ��e(��<����%� �><�b�y���H�[���fY.�A�o6_���Zl��g��I��>�ϵ��l�����{�ֽo쭆�-A���f��4n��ޙ-w�<S�<�[p0x�Ǒ h�h�E�G"7 Z�<�8@�3�=��20�C��D-\�u`��2N��n�3-`Mضg0� 7����%ե�V]ո��Y��Q�����9����֛��`���@�����%Ӡ˰->�[o@�B���RC����Kr�����M���7k�� �䰪�D|��5�B`��$<>�
l���P<�m��%��ZzO���B�)�77LS���b��ίi>�uX���ɵ�C��>>[��X��M��a�[��둨o�ȯץgx��eP�r��;C��.1w�v�M �Q5���G%j �~P��Âow�ps���[�9}q1ú�14'C���ELb�c�oϥ���)d�I�LR��h�j�mM��"qz���+{�c�8_���G�n��G���"�ffͳ��>lNOl�/�:�J�6,,5�l�ͧ�H��J��荮�/�Z�,�j���Q  �c�>0�:�DL>_�]��dM̺W�HT&xjə����ok�D;"�l���9NS�/+�f�� �hlܮQ���qr]�(��%���fS�­��l#�H$nD#]�ᬟ]c�qi����1m���E�)`��2�C��[�=�M� ����di5,�¡�<�����M��:u��8_EkR*ߡl�6�D|�2�]�"K��,�a1�u?Đ,e���G�44N,�=���)��AaDQoY9Q��M��@��hŅ�f�>U��z�j�[#\{� ��!*��{�"�%��8�y���'|���^ b2�����rg]��\��7�I"N�d��;$�]����AΔ�~�z�X��`U�Ι����@ĤU�]a��5����e��&+Ō yK(V�q����*v$����)���Ȭ�ݖ)��D���9�0���[b <�R���`�JG"��ʹU�1�k�)�àV?'xo��8�{h_��f������woT�p��(0�&�H4F�"&|��̰F��3ܣ-c�����'��)���V�4^$��NR���D�E�CƁ�r��`��0(Qd�c�ք��%��7�M���|��d+���pXSP�,�Jl~;j�D���)5�T���`��ː�ȼ"yt��^���٣�V����gWF�6��.�.1nv�;"8(�F�S��;�+S��c
?��P�G'nC����%酕O�&]�Owq�oUʹ���^R�hF�D�p�J�����;��$��i���;���n.�Ib"S���s�\�o�$��b%օ��w$r�M�W[M-��g;f���rs�DX�� }/b���y�i)���y�s.����X�2�(�^u$�0��V�.N}��}�`�r�	�ľ@��5��M���j��Z@ᑆ�#��p.hb��5 �l�$�(a73�H��US�����N�(�-    ]��=��b�yhz�^lx2E�=�]Q�jh�%v��xgOdЅ�и?�IS�����g�Cđ�I��_��C����?����$��x;��0��A��#Qv�$p�͇ŚS�;�{����݅D6�y���g{���I2X�����_K'����@K�.&�x$߈�<�.����)�_噞�?|'�_�"��&��)��X�K�W�%�0n̵6��9/g��؏D�F�ΖdZ9w �8+n~(�)P�V�8���tb���P�K�fl)!5vԖ�z���G"�uŇ�Z�����α���Lа[Z�"&�gw�J�f�J��QJ�nT�t��,p�{��Q�H���E�4{h�����Ŭ���Q͸;L�Wk�^��~�^�"i�m�MqJi�u�#�9�:;B���<~7Ź_�@���V��{��`g��`��-iM���
&D�#�����;�)�?_:��}/�;}_�����=�b�6�b�T�X|�*���4`��+�)�=vJ��T��̩���&8��(�A��ce���i���H԰��$ݗS�z�q�����~a/�XL4�����(=�"tK8���@����'�ŏ�C)���M��jY�KY-~�� ����{�D�z4p��Z�	���
U[}m����ֺb{"X��C��V��ˁ)΃�c�&^<ǚ�q��9p����Ш�W��B��R�Ѵ�
3��[:p�j-��Y�����3�d�tX�Y��D�m��~cU�d����֊X���WS�l��ɕ�����[]o ����)���k�ޭ��e�\ b.$��?��L_}�.,Q�E�I@<�sU�g[5���p�=ۚ�)��o��0��2$����ÿ�0�f���4�{��<��=a������ha�f̑���jF"���O�gX���X�[���Zxߋ�t�I��-�p�g�܈���,�ײ�a�a}��'
�����;U5S��I?�Gs�����&�\ b�8�k�J�z���>�dJ����8B�QYo��M)�W%5r-����U�'�+���>�����J��M:��#n�ͧI�J���#��)b5�,Ts$R�.5�ZX�g�x*"���.E^����;K����J���b���fO^1�H���~$2g��%�9�h��=X]�!��o?��ZĤ
6���馾���{�곃�����#Q�m�7쁖�Μ�)���f, �GZm����y���v[��b�]�b�P���K�KccbYci;��UX�jq�l<��M��E^݋3q��@Ĥ���\R_�%�I酃��Q�c(h}�l���z!��-3T 	D�M63S��a��Ń��ɯ+~��I۔v��St�������m2$�7}R�p&Vw�@d��ԇ�!�cO��BԳ"��v1����c��q���)cx�,}@�HJc�B|�'�������{�ihf�w�G�Z�p붥�|-b�{�}�x/6$-$����6A�U1���x��Q+��c�R�p�K}��c,o:L���x}�������{�u,p��>���ǝ���v/�ځΗ�R��dG� ��p}͛�3�����& �1[a��%|RE���Y�W��Z���a�L�y��J��Ã�G"r�6���~ћb�=v]���ݝX���G�{�=�g�!a�tV�YM���Y���x�p�#|�� ���^��K<�yS�/c�B�Z��W�O7�3�;��[�i�S`���oe$�\�[|s�c9!k�r�ZU����K���tw6le���0�ט�Ac��ڰ����`��h�x�ǓD1����8���l{�b��Z�C�k������">�;��v2���=j���@�f|��|�:{�P�H!���d�M1�z�� �<��|-���7�K�~�u�G��N�^S�\�G"�=��/ ��ͽ���� �I�b_ ⣷�9�`}�l�*VAKQ�3�k��k���'��k�<����$M����� 6dv��ON��h��F�7M�I�V�����v-��'b�.�����C=;JS�/�&}pd�j>J�G'�DLy����>�ҴV�KQ�2n�W}�Q�<�U��� ��__$�7;f������ ;�����">�1Ɍ1����P�̙\j6���S^4K'ƿD�%��&�xy�e�X�޶�]s9dP^ �-ӥ�DK�ӳ1�~��7�Y���C�����^+
PlP���Q��i��D~��ɇ����e�F�%��O�`�<����y�X���k1����:�@4���"��s6�n��V�{	�����Z�=���Y�F_�v���Â�*5��K�;��7|��b�qA���[�ᖶp��2`ό_���g�>f�Ŏ��ę~��k��D������x�_�X_�W�FÒl���8������Z�楟[b�!l��E����R�e�l�f$��bO{sM���͵�Nztdg�����w)�b?��ם�V#�k�<WKu�z�{")!� ;�3�8�`-*��=��Z�yx�=�����+�6��]�`a���ż'�X����i��Ͱ�9�`|�8v���Po��f�C?�c��}�>e����$$
��j���T�N1;�b[��E�@�׼5�!{���W�Z�Uj�ya�a2A�Df��R��y�n���RkY�螭����gE�nk���R��Vq�)�.<�̑P�'
��]����1���7i�%�@��E|�i}���Ւ�n�C�F���bȝ�9�U	>�yU�)����:�"�=�1�vwvz@��m��.%�����	s���87��J԰�G���]f��,|'�bW�y��O��������V���0X�?�� ��n�_�q��z��hDq��^K�s��9��U���Foͧ%.ҭh�#�!�^���s�;��gL���Q�r.�A<�[nړ+���
�]�HӶ�����#C���g����0.���3��C��+ ̓{ڒ�%�����
�L�o�&r��ك�w�к����y�@����'�x�O��Ͱ�Ǥ�R����e����;L'1N&�\E$��X�����"�5K\�Du�d����F�N���가�)m����D� �n�ڣ�t�;��`Bv�H��j��z$���25}_q�>����Z���3O�{\�/b2��p��OOVk������L�$Mq��#�#QUʀ�]����-��^e�]j�k�>n���ߵn [+���Օe}�c�f|qpڒ�T��;�w������O~�a�X_Ճ��d�.�Va�{j��¨/��D�	��F3���{)�����	��R�733�zP�ھ�����">����m���J��V=Y��h��ih��D�/���Fl�6#�Z�)�?���S1�U��@���>ky�>�/��1ȉ�	8��ڪֻЏD�[����;��9�zPa� 
8�9�@�d&�>A(&-�Tw.�6/��t���x�%��k�H�YH��{q��)�?1ѝ��l/�.�A� o�%T3(�=��<l��yO�j���1G�<<H�9�:}�?Ź��d5����o�}����:��X�ׯJ�[anEs}5[�{n���Þ���24�F��2�y�� �a��r|/�Y p�WC�L���4RqZ��r�Hb��G"S�s�$kMxc��X�:S��=z+[��">3ԁ�p�峂�R8I1IQ�8�T�HDź�L�ط�z�����I�!ش50�@�'3cz�n�qq�U'�� �v&�b:[�;�v%"�){W;�ff�X��qè��ۃ��E|23ݵ�"���&�|��"��x��9E�#S(��733�z@ f����9�@�'3;�����]n4�o]�\z-Al�W�E�Z9�#R��
��n��0(VGin�.�IϿ���G��7�%M��1���\��5h"k�D���P�롿s�fX�J���z͛����O��Շ�F��>�o��[)��`��7�����RO���s��Coff�u?,������g���}f�ӗF^>����Fn9Ԝ�_4����o+�    7,�m %�u��X�JjT(�ߞ�_ ⓙ�F/����Q�.���8r�i��\�lNܿ������������L�WdA��=�+\ ⓙqU;�u�<{fā���Tp��e\���_�R�+fH�q�b�٥)�ð�R�z;��^ ⓙiq��/k��g��q���"%�-�,-��%^�|��c5��7�X_���V��n�y���@�d��u ��C��)~v��fҍ\�`aTYDB'�䔊�/,!�u����i+�)���5�Pւ����T��M��.� ���W��t� ޝG-�����㐙#|Mc42|ڏv��eX�I������x���"�6ͮ��pp�_��%[5�P��M��E�ʭ�jGdJ�3S�vw6-3�����Y�նb�6�ߋ� %f��,��yc�2��j�5��>,<ރ��=Qr�WN���n��|]j�\���3��[	�R����_j0�R��]��%��k�S�[�E�R;�c� =���/v7��jL�ڨZ��q�^�\ bjR�_ZL�ֵ3��:xmr��m��Hᖂ�#Qtnd��H�1:Ev3����ݹhW�ߋ�챺S+�J����j���<y`��:���,#�~$�1|M�9�Uo����A1��-�!j���L̓%�Pn�ϼ����t+������d�&���;�iN��_�hP2ܭ�]��"&�T���kmʾ1Y�p���soc)Mk���=��ܴ�B�<S=���":<p<�a] �W�V����K��Mg̠6�H)#,��i����}q.T��p��X/�Hm��;�GW��E���ٿ��S\����F��[+b��ՅlFsjDŹ�a���,�f8Lq��-��9���ۊ}/�����c��	>i�d{�pRj�n�(���V^��r^�m����+&��v�|������vӷ���9��O�L��\ﰆ&8����Ev�H$�E��jr����B3��*®-@E��7����s�����<�(Fр~w�~WK%��+�p]d$����^�b�@�ګ��sO`�q?*4JS������� j��J�	�B�t�Z��� 	��%s$��z �hا%��a�X_m��e8��j��5��{���ц�m���n=z��i��r\R�q�G"v6DS&}h|�"t���zc��9l��E��">ɼ3�����g�=xJ�ZFM�s��f_�#�.�B=���U���ܿZ����@v՝����]ŏ�C1���}9���;��ѫj��1,��Fil\���3�4��2(�'����0���ELF�^�E�Z����jh�/To�ݳ����B,�|G"(�U�9W�~ZOh���̕4ϒL ��DL�������Ck��n��`=L8H�C[`-K�R�D�	0B[nЛ���àX�ۙ��5���zp������G�H��ů+avi���#Q(0Y�z)���)�àD��c�6�D|�_|�����g���CE~(�\|�Ys��D�u���klp��L�N���f�8��%�_ brfv��R���~�T,U��t�	N��%[rY�6{"_��k���M��)փ�MkI�Ӷ����vou�(���Ӯ����R���m�ȏ>�Ѽ�~�b<��ڍ������^� �J��yƁp�׾_�zO� �T��(;�z���d������B�7����[`�[	$ɇ�6I��$"�nN��{1HY4��EuО������6���ZnS��' �q�t�´U��@�\�Oo��1���#�D\N7����%`;��ё(�*=�B�0��Q�b}�Wd��gqR���@�ܖI�Xx�l�������=�s��C�\0A=ij��S0�J�!�9۫YN﫧8�Z3����-�W�����NJ�y�6�5��'DX3	F�F�%[7���;��\ͭ�i�b��˨����w q�5.�@��a�j��2�|_]��D��`�4�FK��#�8#�TH_".|v}2���ޢ� Θ�OYc�ߋ��R��O�lTW9� �,V��J�d|8)����by�fs�����A�a�b���
�=�I4aU?�L���(E
�h����ǮF�C�p�'q �rVh�u��k����[���!�]�}cƨެ�}&g�[��R�vԳ�U���'RC��M9�)�?��t�f�">)���M��k0\�i��X�3���/�[��D<H4e~�\O1��QNx�l�=S�^�O���k�=��n���&���7>}�'2%ر6Gp捎�b�3(����uP��(�3��zy�M[r�>`Li��b"����Q)F-��:/�2���s��[���D!gR/�U����
\�jC)�-
�j�~$rv�7�s|S�n��0�u��x�J|/�Bw��HX��tER�7-z�S�sf�F?���G"�Q����m�?��<�z0(k�;~��:M\ b��ۅ<l���%�޽u��AAyi�j܆�?	�����o����a��v�u��w��K�����Ĉw؍�ȷ���2�&��&��.�#@g���9M�>�J��j�*���g�sS��y �Ԓ�����J��M8��{�u�PvZ��恇��:Z���zŲ�Ӥ�)�����s����\ b��NڹT#��n�K�5�w���"�?D&��P�+u�
x��O\�{���ݯ~/a��{l]N�����/�w`��M!�T��w���ghђ��!���O��)�W��<�z�-3������/�fȾ�R�`���rh
�௴��V��yG��Z��|�Lq�vmfn����{	l�12vnHr��Jl�E���ݐ���(b[u-��k{��e��`R�B���w�������|^��#])�
苩1ۆ�]*o�{��]��l��5U���ϟ���`}W�Y�p��Bq�2���I'r�d'�d�-�5ܴ�k�I;�k+ ����뿸<b�r�&-YӖtv�4Ź�����i�޷���F�)1� ��N"G	�d�pS�e�
%�H,�߀ L��ep�΢1S��F�V�R���Cz�)\ b�$��*��j]��"S`�J�"���X�+��q �%�@�;'���g���D����Zr���^��#����ƭQ��-�Ե?P qՏ.���^� �q�߯�%O{1Lq�M�'�D�<oUQ�1�V��.�X����!J�aG�%�$�--v��쉄3S.ƾAuS���Z���<w~�~+�#-V;�����ԇ׷�,�S��u���D�y(��
��2ù����=�	��}-�y!W����o����-65��y!���-�4IP�mvx}�zv�4��:*��0����y\ b�q<��`8ͬEG��r,1ܬ�gSN�j$��+Fߞȱ����#-��FO���K�r��h�Vp������QmC�����\�C��
@c�}q���D2*|ڡ}㚶�=��)��q���v}��Hs�@Ĝ��?�mp�X4�~�?�6��3�Kh1
�/��!�@D@;�K�h����)������M�S�u��^�d�����s���]'�y�J;�N��h�=����I�DεG4��m�y��)֗�n�7�����m�.195�]cF�]�����@ks����H����n�Б�-��7}���,�0����^���Yա���"&��cu`�]c� z0�z��M���K̮�L���$����&T���ϋ���3�����J8)[r��tbCi&&�֖Zk��o��'5i	&𧂳�����K�!6���(:��pM�D-ќ�#�a��Z�/XM�I"iJ^ b.D�or�˭�'�o�
fu{�v�j�Z:�a��iMt��`�����n�O��d���/1yɻ]��U��t�\դ=�p��nɔ���"�X5��8s���}=���!�~K��^Ĝ�1ǘT�v���>TU�'�l�����F���#��Ggʨ1`nN��O��Z��/���'}ضeV}/b�`�lz��w�Ϣ5�%������uZ=�7�;��Hd)SvX�TO��j
������u\��D�e��g�[�ؙni��D����Z4�    �m�C�����E_ܺx�A��^�ew/a��G�W��y���9���퍜�'�[���-h��ȸ�)�\>�Mq��*)V������"&�y{�e�y}�~kca�Ұ�P;�����z$��'��PR��'�S�����ꚵ���B����ɾ����k�p��/1�>��Y$I���#Q�W^��n�O'f�sos���|'+B�m��">�����EC0����6�0Po�S�;I�6��)ڜ��4źם���d��b���2U�����x�Ik�%�H�0��R)7�?<O�X��y���۴�Zg�V
�{��%￉I��b󫛯�EmG���C����V	6�H��dWBЀ֜	�`�3,��5{t���E��h�[��H�yw�F��Xب�&�yY7�Uˇ�|id{J.�]NK�ͱ[�
����K�/w��n�{1�5���7��w�C�k9����؏D��S���R�L�$��S���{2��n{�����&��ᖩE�Md
�Zʞ|]�`������7g��^X��D/"oގN����\�	��[a��EL>N?�q��:���t�:~����W4�V�y9Œ<���o����a �_b�n��0r��O��w���נ��W���>z�-�y��>lOԡ�sY[����M��!{�҆F���QT�j�]~YѸku5�-[^=+>a�{�D*񍦙d�-8k�11�Q��iW|HQA�j���Y�Y��B�0�`L�?R <}�6��gXp�����"&����6�݂�ځ�
��ݗ��Jq�Hw\����F��{�a�ˮ}�M�f]����	��B��Ѽ�qVl"k�3	(�g ���H�)�DXMߌ�Z�y���X��q�] ���~/�#��M=��8=.�E�w������u�����\��d�v���b<�7��E��/����b���_?��+ ,�f�K�#�����J���
BOc�S��1�>�f���f�{����w�
*�U�=[��&d2�I
�>��M�H$��a�xs��X�â�ن6XIi{{��m�]�z���])I�]�
�Az���f������o�oL�$�q\�<і�z���L��.uk��QB7C@���f$��}��C�G"?��i�7/�f��0�5�.�l���kB3n�NM�^��9��` ��b�u��q�m�ͮ�d=��ӝ �M�/�ɮ�*EK����D�nfdq �b�� -��H��d($��&@3��g\ V_ToK~��4d��M}�lJ�oi�s�ڕՓM�T��<[i�w[����aT�m��K�Vs�{�������)�^lՠ�~�:�^�Pf�ʑ��Ϫ�{u>1S��Q9�9S�I���D|21>���#y�g�:V��@��6�W�����D�{���%o#Ws��aE�,��ZS\ �#5���Q|}ݪ6`�d�gjMbNĮ4s$�a��q�o���0�Yo��yܪ\ �n��S���H�&�K9x�#c;l�ڣ|G�]��r~��X�����p�z4_ �#��b�$�gI��9دMrjV�G�)�?DRֶ��%�o��)�øX�GCa��r��O��5����b5��},��-1�QG�G��ɀ=y-8y�e�X��`n���N�{�Xl�\�L��{5�&"�dxr�4K�^����=���(��A?5LS��Q���#g���@�'�I�xv����y��X�RV�IZ_�GYS��Dnz$'�5��0M�>��g�W��}r��1�@�G�)EJ�B3��8���#����3z�+�Qq�Zx�͐�ڞF�fX�����j��/1�S$�Ѧ�f��)>:-Uc���9aԵ�N����}[��fX�.y�O���<}-�#�B%�G}��v��Y&x�Յ
G6���a�'�%�Rr���yx|��0��-���A�=�O��I�����W��p�q�0��a�A�z$j���4C�7F{��������@�'F��ֽ_�[y�_�7���� �8,��>��U�#n�j1n���Ͱ��k�&�b�,�"�����h�UY���Y
��6J%�q�T�'_X���v��t�lKv�	w�̹��a}V�Y�@�9��^�] bn��]{��EQ����p��,�����^U��#� �Vｽɭ�b}������-��{	e�;��A~��㴗�s�/ö@٘#N{���	,��w����#s�[��D|��k�_w̳�M��R��G�����=�����I�ݰ�%���I�@�g�3ZE�j[{,�3$�E��!�p��_��#�G�V��9�aL�{f��uXk�YM"���z��O��XM'���Dю��q��@�q�5��Iڞ(aN���.���9�fX����9�����k�:f~[:P&?S�ԯ�j�������F�3�D�~��q�Ǚ�b}����pЦ����SZ�"��ҡ��蒴��wk��B�Ql�U^�}ve�D�;�鋹s�`�u�U��|۸.�_0R����廥��.J����yI���Z��~&
���̰�W���|Eq��Ϧ��P��}7����х���>L� 4Rh�f��ϸ�
:k�VW��]jk��K��}>����Ĕ4(Ҋt�T��b�%?�N���)�øx-� z+�s�����}���[����M�o��G ��i��\��яD��m�Ytj���̰��%�l}�.175a?5Z�j|����j��K،�È~�=�!�*�~��"#-�j��uX�G����dn)��K���}��w�%m-!�	%}G�Fj�&	@s�>9ص�س��f"9�@Xa|v���3�=��:,Y���{�N[f��"�,�VF�_�@�	^6V$��3v&M��`��$��\:�� ;����b}�j�0)�H0�q['��E|��Kpg�8�'��yǹq�ܢ����J�/Q��7p��ş���b�����41��*�"����� �Z��L�ݚ0o4"pD��;��gm;AG�%Z	)�]�i��)�W�����w�.m������b���k�x�WU���7�4�T��[s�"9��_�"����5ź�}�E��9�֐���\�p �$�<���nکG-�T�bs�(�ϰ��&ț��S�/��n��d��G��D|�X��H]�"���-���	ӫ'���5Cc\{"�C�/������a�ӎhhkB{���6�E0����o��fo�6��[<9���vF}�"c��0.O� E���] � V�I�BKy��^�^��H�����,8��H4
;�jީ�)��q���3AkJ�V��k�=n��A��8=#���0�eȹ�:C����H�l-�R�ʼ�1���	w9ZNa������vL�=i��Ow8�����p�--�ׄ��G"��g,�������+�m��.�I�S;X�Q_���`n����jT�ٞ�h9��������i���?*B�g���~-`2��`&�ZX��_�u�dՃ�u4��h�y�a�Wxn蛹7�UfX� ��������@�'{�\ ��jk��gc�R�9���D�j�k�����|�9�㰴����.1Y�i�n;�y~vw} _��ܺw&��Y����G�K�մ��֤S�����b���"��К4�.$*�j��EmR�U��V�v=Yg�-R�k����h3��������&��ңh�"�^ކ���U�1�B�������&x_��)-��.N#9{"l� (�k�p���X_�0(�"X!�x����������G��[�cI�H��`�0;E��/�{���D�܀�R-N�vV�a}�5�z���y� ^ b��>�wo�h��~f^�hʯ׶����DiP�z�[��p
�gX_cOk�l��DZtf�ߋ��|u��J=ӃYԳ1��B�՚��h���H���|$�d�D��xڮi�u�%$i-�Ǜ�D�M�~jJg�y�!����Z��В	6iZ~����#�×R<��������i�?f-^��Ͼ1*߫af�Z��%�H�0�ڙ�і���W�'ʎ]�j}Wx� ,  SN��Ii�{z��/��9v��3��A�:���b��,1��F�D��F��V��ne��u�y�-�w�^������v*޵�������;�q�`ڲ�އJ�C�\e�C F����Mq��jk������ZĜ�th�_���b=gn\�͆"6�>+�k�C����` �é��b}����H�.Q՘.1yp�3Ք�z��+�U�[�6��,��PS�7��3c�UE�I辄`�p~�?�zX��I�֮p�sSs��ϥ�U�a�H����ع-1u�0;-[�=��{��4��}����؎G�i���䮉����-�U��^�\V�>�7�?:]��>�%� 8#�hX	VK��G?17�}b߾e�a����h�G���E_��,Y�-�"�鏚�U]d
m�VK�����5{"M�/,p|]_Ȟ�9���QV+��g�ߋ�x�w�m�Qˣ��,1R��>F9e-��妛��dn��3���m�M�&w���x_������Q��ss��oܔ�F}Wӳ����p �V��mw%z�;Q�-ηᨴ���N��L�����֚���M�^ b���!N�q��
�~� ���{�p|Ѡ�{=8��W�f�cZ3���x���EY�&�DN~�+�@Ĝ�y����r1ڦ���g�iZ�H*=��Q���k��H�M^J���o���.�Z�@��`�ne�.1w�#�=R����ז�G9��5�F������u[�����|�O�յ�=��M庤���S���r�<Fb�{�&���\ b*���S�����������      �   #  x���;O1�9�)���l���R*�ЇZ�.�P����/�:�PXN��'��Ԗ�x�Y�X�N�Fm�����&��vo�����ջ��\uiRoW��Y�1��`%��4���=0���tuB�9ڙ ��U
yB���B�����I̱N����05��%�c�����~=������p1�&W���5�5#i�7Ƀ�>Qj���٪��|"�W��cW�=2x�{Կ�� Qv�d-b��-��Tj-yV��~�Ϧhn�;����g�v�X���]�} c�6�      �      x���Y�d��&����~q$�����T�n�7���p_�*S�J	���͎�{��/�H
�RVxė�I[H[�X��-��6�zٸ����b%F{q��p������O���%������G� �/��?!��1�ӵ�������~�Xˍ������o�-��0F�+����n�o�����|ኘ�����o a���[���8�V�H%b�Q8'G��?�_�$�����3F='{�)�?�9k��;HWm�8K�a��J�Gҭ+�D��R*���t���O���t��%A�)Xpx������]ī���d��$9Ģ[ۍ)E��0+�����pc�������/���� (k�����c|��nh�.��"�n�>�m�'��Q׶�7�(`��^��c����?��Yn��_�vJ6	�,�����������o���y�~��[����I%�t%O�'ȿ�0c̲I��7�r~�&�S�YN�x#���˧�����K�Ï����NI���G׷����;��z9o���'c�%��B�����ov��c�������)61��r��n��;a\�sb�ӖJ	%�a���l�BH`s�0X�
;{d�(
��j��]Ɔ������l����At`C��M���S�a��W�6��v�08JΨ��&[[W����B6t�Vm�� ��}��kù��0�8t�9�K�P����+��J��vd��m�K����l�����WK���N{�0�K���;��Q�1b�6��|Z�&�+9��N{�6�oG6���)q��iH@����rc�0�)0@V6�mml^`SqF�%Z@E	�y9�l��|�g#�=�x�iolzۼ�|������Ul̯�TGE�l89Q
�=�TZg���������?�������������M�5`�(��ϟ>����+<:���"�覴�3���9��Dx�K@�`������߂�p���f�O��@�$����?��c��÷`D����\�Jd	���g#�
��+s#̢'�a-K\ؠ�����ދ���ya$���P����R�֓_`���	�!�D8�
�d'n�����e�ȶ��!_� �D{�y���!LI�J8AǵC�>q��C��5l��pM${~BQ��0=�jӑ�����×s��ظ�l�<L�9C��k����4���⑰.eY��	S�
�H��k�ʦ���p����z\�6��U��k�~����m��������bqQM�B6x��҄�ya���p#����;����wQ\�� �d&�_}��R��3@��(!��ϻ$�b��ך's�0�������t;�
J
@���l�����<�'�]�(���z�k�쳒)��c�k��� ͸�� ��.q>�!lQNMa_Z�ί��7Q��sv�؜!���E���ڄ �J)����/�0��Bz�!��?7g�[|�9���m�N����v�_rM��N�3���I؎k�%`�`�*�z��-d���[�l��h�������@b��ڀ����
G�d}��oV��N˪�s8UZ�D��Gܴ8C h6����%Զ�Īz�e� il)L]��0P����(��� /�i�A�0�b�'aSSv��Ӹ8ڠ@M�b���	W.�����ȯ~T{���+m�D}	�=�[��UΧ���l�
E��n��N�s��'Xp	��,�>�ӎ¦����gt��S�,������Q���{s�0�
'z��T��C���kB�v�����6�z���Zq�%��u��ekLGg}n(�����s Rr\k^t�y��6������P�����x6�5�Xܴ��&�k`K���a@bZ�;-��Flh��j�B?MDa�n��;�pIF�����D��`c���Bkp�����#���ճ?����B�-��n�vQ�J���a�o��x�kr��u��8z[�6|��-O����6��[��W6��.&T�ڂ���(�^���'p�6яv��KOj;Y����k��ȖO�;�!l���N��m��r�0xЂ���(����`k�j=�h��m'��bY��!D�d¦p�t�;�8�c��/^L�R6�|r��&�J��|�:D���uu���~��`iz��!Lg�td#^����Fŀc���Aa���g�#�z�z�[E皥H��� ֫#���k�&e_�kt���Ѡǁ�kw��g�.zqJ��;igaSs���t��4�m��ĉ�yY��Z�	���I�D������h\�: ��+��#d&��X�1-D�I��l��.<5����y��>;@��K��>�����H�[bߗݧkr�$����<C�4����-�F�	�/��Uq��«ly��z�0$�4�;�熚��lk)��U/�"
�+���N{a(����ӽ`��G�",�}����(M[�w��s��N���Ah�hM�p�?�%�K�w��p�1�t��݊�N���UQ���X��4諒�6\[�ۚA��J��u\v�$�h���4�L��TC8E��-�)�i�I��?k;�AM����[AY�6��6����(���G�� arE�y��b��ƶc���g��^� Δ�6�����ENM�!�5ZxjB�z�?�ӎ&w���^�zE��FN��g���I�Aӷ�� LI��N'��7�M�	[Xۈ(�b!��fo��A���֦غՁ�AD�vٹ��b�4�����ٻs�P�s#ZO���f!�puA�>�� a��� �s�okcQ�hF���MЄ?�L�_��A�#a>�a�J�A\�����x���L9�+�C�Þ���R��K�����D���l�L��+C>��{�ey+Mg?�և+�'�Zߪ��������������^�����_��}���xv�!�w3��%�;Ӽ��oKY�^�e��o!�k�*I"��R����-{aħ��ܒ$��ʺ�P<!7p`ʲ��,���?���o��.L0 !]~޿�_������I����iK�����;�����=�=%	7�$˺��C+�J��T�??�O�����B�wU���{���C��k���g�xxYVݻ���.�H����p!�%JUz�7���T]�+#a�|k6T��ʠ���X��Vo��5OsEL���6���@B���&��WqHݜ��a0Dh�"�;�=j
f��I�[⌼����N��y!�<5[��Mҵ))W�R[�(�(q/m֎=�� ��qx:p)�e1�EzHe,y�{�$]A��.��!Lq� �2NT���W|�Xce�����q��2Z�{�O�w69jm����i�e�v��z��ǙF� L�L�U`�`�h��EO���$�7Q�5	��l��)^s��;B�o�R.�k�ؽu)�[r-����=�)�\��3�) �e�t`C8���)T��%	�o��k�y����aAΉW6��L�N�W"W�5�SD�{��g;�� xK�V:�iⴍR��֠��6"JR[�%l�s��	B��:��+��'��'���,�M���O6�� ��>�tdC�o�B�0��eZ i �Dbs^��	#�pZ�\���%�H���7���a
0Y��a�!$ؔ���ˮ���r�M�xu����3�	b���d9Ubo�(�lK\� �8���)�9�im�Ŷ5�2�I�x��1���ya���s;��Η-[�M���R�M�͵hx�0^k��&�$��$���]���4�b�]\�ա�8���A���P���&��7�G��`�*�aoF���=Q<C���S���DC_ w�3[���v0���a�q��?��>���b���%�*J�y��r�!�j��B���.�ű5-�	ޮik�΂�kZ����X�WF�2����z�)]pZ�1��`���Md��۴W��ޛ�?���K}�쑫�nE��]qK��i������^e�צ��%蹷�������C7S��
�p��2��a/;��{��:6`����7� ��h�q��!>4    �E�%X�D� <S\�
�p�����܀�C��
汤��Cͣ�S��+a32���}]�"AQi���� J����!6�sl�k��F���c�7�LK5t�+�K�}�6�%?�;-ut `��,�����:_A���qh[��N�e��a��|�.HP�g�O��6�ךNZ~ZT��]��n���A�)�$���0�F���Jנca�|,�,��z��{l�9@�ʾ�D8ǵ)�mX��E����!J�ZLq�A���5�˳��	\emF���Q�ٻ(ZW��Lw�Ɩ���3��[�h4+n@��)�hux�d	<L�3���6Z�lJ��!�±WVt�>��d��~>C;��P��69����%�����µ	��a�K;C�\��?�M�d��
h��5>g�V�6\��4��	B��h�ͯ�ﴄu��$��Y�T.d5��I�	�6R�6�խ@���b�����]�l�z�z���§�����"-<Eq���K�`���l���4�k��K�h�ĵ'����.��+B� �� 5_>�����8��/��|B�,2�\��a����ڙ�؊�;��ȯh�{%�k"��l���.q9�=&q�R������;ۇ(NUk���O�B�ζF�S{��^��5Q�M�p��0O?/<���g�S����Kծ�g��x��`���a$l�Ol���Dq��E��xSDq���>M�˾�6-�h](At�%��U�.�v)%K3/P� L����?���beZd��ݲ��v�#��>��6��Ol�:A,1��,�u���W�=0y��a4
���l�"�d����ק=N��B;C��b��|n�贘���&�(��a^=�!�H���kSbԖ���<���8��G���5�¦prp<7�l3ɡi���01�d���0֗���߼�s��� t�!�m[�:/�uZ��!����4�=k8x!�ql�y�Qt$�L[�WzS���M��^�1C����k���A�����a\!ÁM�W���^���͞V��o�l���q���qg#�!:-r9�Z��;�@U�R�@{xϲ9C��s<�I���n��xAF�A��& L�3�Qp������nI��(:�U[�|�����٨�#�|�_�5|�w��7\�es�6�<�=i��F��R��;��0���o�ft�t�M���sЩ�eZ��+6xF��7gcm`[ݾ6o�\D/㖆ޢ��A_�x��8����q�x	�Á��n�Z!�ĩ����$��EAM�>A!ѭ�~`�[�[(�9A�U�h�i�<���p�)f��\4۶k3���ҫ���$�`��״'#�>Ը����~��wq�GZuf�{{
35� D8�S>j b9���dE���]X�!������_.����K���D�ȗ����=	ҷ+?�tf�_A�NIlj����hKظ`�!�h�~[���2#���� �M��M��E�u,�T���+�T漂0ⲹnٸ�=Y�(vގ�~U� ��t9�1�;3l��8G��k��Չ�D^1,�!
�6	�#ks�6�T�G]NM�M���ež���.��W��9B��5o����@ҝ!��ꊱ�wQ@�pLvf�+c�X�x�-�)�o*{��E��L⛻�����������e����Zqj���t�۟���t�)�o��&9j��w�gڏ��0=��[�۽s��C�c\�	�2HZS�������!�ZᴔI~`ݓ6հ��!
]Q�$?�� a@�ԾY=�fh���l�Dn٣��yb}m��r|�3bF�\�lr�g��Xe�rm�^�N�h�A�а ������}�k+�E��/�3��^A�D����܀��6����ǚ;�M3sp_A�2�6:�M��\�:�5�#��ZKEqZ�=Ӭ���V�d\���m���G'���{�P@�ɔ�'��Q�i��j7��@�ӈ��atnک{a|�֝�Ǽ�hET_Ӳ�VD�q�b633����>�vE��t/�z��YM��l�ǀN�� ��������y��r�
�df���3"�tB�;aӡ�pdC-�-�nG	pE���(~7|6�Z�wƲ��n��|��IK�Z�M��-�M�2�:��3>��0b�a�=�^��jZ�Vp�M�߬�k��x�Mmf��;����S8������Yb�}'���4��g�\>�^~���r���D�������}���N��_Q◙.M� ǒ%`=.`�71�Z����{�� Sm�_A�M�鸀5���B���⪼�[�Epy6hxar����G6A+����c��l�K>�L�W¦���imз-��	�C+�hI���;��|�o�����7��Rm��*�AD��Ə����
��[�}mtRNșJ-��>D�k�6M_���0E"k���&���irv��(%���K3]3^A�bn���v����h��lmvQ0:���y@�{�֞t�/~�้��ʊђwQ�헓���
��-��G�+��m �e�3ij��즯�A����ڏ�C�rn\G�Ǻb��M�V1D�$�^R��68���5��glb9�`�U�u*���}����M�\j���f���8�+��>�H�3M_��0�Č�]����*c��U��ڪ�8mhN�%�:���[H<���aQ��M�ڐ�Cd�U/,O&/�E�fu8R_�J���~w�/u�A�b��Y3k�P�[ϔײA8����f^�x�U��H�u�BZf5�VD>��!L��t�3n�6md�E���b��C����t��;����I`���>�f�-��0�Nޙ��ya:���=[�@�wU�u�Ҋ��Qҕyj"��C�;�9���[�vE���$x���C���`#��g�K,��H�/�f<_����9�� ��� �ѧ)�FZ�����kx<%�p�0�Cɾ���P5@�G���p������Bؐ� G�C
�Z� G5��i"�D��?`9�f�)����T';jD'!t��t �1��O?��6A|�������@�ؙT�y5"��:'QӴ8Ck[�n�ʦ�}�d7}rk�����1�(.^B���
¸�s��ٰuZ��B!����4��<�Cȧ��B���Ok�Y'��7^�kX1��!�DYL4���G����K���#�-K&��";>��{a����-񍍄m -���2��-�xt;C�T$��7�y��n�r����*-�m�@�E
�:��?�w�ӁMn�o��$:��;��`��iZC��0� �qmrF�<����T]W������観��A�PF��-<&t�D9�&g�DZu�~Ż���/�㎵�Υ�c�'�I�X���=�*[�&��<A�]M㦟�l�hV���8j���mV]����'����G6�0�~�(�sJ�b>�A���!6�I�I���M��(V_���&����r�9N�b>A�Zr�ݞ�M�C<h����"k#�������a�D��Z׆�_]��b}���l(�9�����&����.� �M�f��i�n�	BW'~�;����`;�q]�ЎF�CȮ�EoOwQ�0���	Bg�B�lr�Q Z�x�\YuC"�/��X�	¸L�՛�9�g�˟����K�^��Y�\��6�?��/j�S��}���p�x�/�T/�o�X�L�~ah���9�1�%�a��n�J�=C��,�W��h�ޚݗ�������Ƣ �.
!��p�	�pt0J�G6��[�T%�^�F��� �d�'a��7e�8b�ݹ!�i�᝸lmvQ��i]~F0: z���!�z�J������
��:� �M��6��F�{+
9O>-��(��fk� L��J���n����M�w���5_����f������_�-[��_�����G����[����5��i��0���)i���
#f\�z,�����̺�� �MAN�Ȇ{��lMNش��.
z&�J� L����z��^�L[��]�*۾ʁ�V��>��*�w�F��� 6������TaM��]���NV�<A����    :�4��6
q�Z��s�D�k�:n�l�&i�wd����CL�E�פP�E}��#;� a�(�a��BwO��XC�bC���OD-���A3�gٜ!t� ���6,wk�zԸ�*?�&
�Ҝ�g�h�:G6�Em[S僔bY�ǉ(���|�L�~�0�P�fo�ݓ�yȘ\�׭���s�EZ��.ya�Py�rg�#��b�C�-;7^���"ǹG�'aS���q��c�bG� ����bPQ��#�d*����ż샕lr[��GǚG��(pu)NVS�G0�\���+Cl�K�G[i�5�wI�p�M��	�{����T�Li0$Ƣ�V��{���B���� �+Ŗ�7�G_�[0�ڌ�W�.Z��C�����������k��|p�q�`I����]'�ӗ� �|;�����{�$�Ig��)���/���?��?}���������_���[��・�k^�?�U��V�{q��d�����΄����V��B����8I��\���U;>A���v=yg�u�se��Լ�<�D	WQr8��a�5ݟֆ��N̶�S[�1"�^��k���O�&4q�Ol�xR��N�Ꚑ�.������ �l'jÞ�M�[��i��\<�{�ݤ��a���ޏ�ΦY�XK�,�i{q���uO:���[�Ctdq�I�m��kB�]�& ēW\O��f��G6Ĝ�ܔs*�l���?���n�O&�#�/g���m�W8:����jm�����''��'aI����׏�z�0��77QP���y�O&S%d�V��I/�:s����B�sӟ tR�g�l�۳�G���	:vQ �u��ul��2�=��Υ4�M��I���V�Λ$���12��`?�~jU�$��-K4�[Ys1,��?W�X����'�z/�֗�Ά�hj��\B[4y�&
I,g'��G0�Y��>��L�n�%b,��K����Ξ $�/W��Y17/��5u"��%\L���OF~���~�B�+{��(�����5k�5���U�F'-��)A<��Gw6��*lZ�tR��|E��O^�=A��JJ��lHT� �������\=j��^iP���O�fX�{C�;�!n�P�k�Z_�6a��O�{�05mrt�i��NcO錋�6vQh�Mf�=A�:�؝Џ���1��G�5��.�wZϓ-� �M���M&q��YႼ��]��맵���ߚ>�F��͏���CO.�Si��������w���������"���V�R��\���?�?9�o�(R뫖Ni�Moz���7�1�7��4�R��ơ���I~M�G�aF������M.n���8Ң�!7Q�j�76�x�a�jm��~���k�t�*�vn�-���E	�=f�<A��]�n=� �-X�s~����(|u�vҥ{�0�9l��>�ِ��x �>p����D�Ė�ks�6��G�?�f�	� ��󢲈�(H>LFBO�F�~d�Z'��@�u�vԤ�A��� �M�����R$��-Q�m�-�x�ޅ����¥����)nl8��]�?���\����!s�0%���^�O�<M9[�2��@?tj�R�ݞ��cQ�a!FF���D�b���� �ɞ�ǝ�E����8��޼���`r��{c9�D�G@Z���ؠ�W�3��~�m��!lȉ���Pߊl�D-�aW� ��Ю���'#:��O]�B�V�Q�*6{zx�b��9C�������|�p%e��0ߓ*���~��/��|��/}O*ٓ*b��2~�ȵ���/���$���$�
?pt�0)��|=)tﵗW�����f�A#m�.N�Z|� \(v�G.�mGP}���K�P�δ<C�rd�Ǭd[G��!d�U�tު?8��m�;aSZH�d���g/m�(z0/S�7Q؆09�	j�腓��dm�@p�9�E)�7Q�w�ST� ����Rރ�	�chC�=R�o*��������q����7�xё$F��s�C���>�?���{. _S�_��� O%��o���km�H�Go��+�|���.��_>�����HA��r����*�i����m���P,l�/(�����0�Q"��Ly ���fG!�G0�l���=��зrZCD��ƌ�%ki�/��Aq���|`��l����m��M�W����'a3ȡ:����b�C�N�S_�Qc��+�!�,yy�0�ݖ⎧F����h�ԁ�J��(��Q���9@ʢ\:�%Ї�Ɋ���s#���������ҽ{q����/Na��{��B6� ���;C�C���r���j��K[��&Jқ�ٞGOڎa�~�бtY�.!=5iM��.���\���z�0�j���aN�UlA�TtNu����O�x�0����'-�>�A�1�&/h��Z���O¦X��kS�m8j���c��QB �,��0,���XOl
mW���B���8����O�^��B'��#J\8�ʚ��(ɉ���N;B�Z���M)l�_�C��VU=�D����W�� L��=�bo�!//˥	��������w�����Ӭ��C��|e��K�.�X���>nO[�:�R��g�����hݨ��u��&m)�hJ��Ϟ v���	��F��m�<�&��h4�]��d��'�5�s����rO��(A���͎����6�O�����b�1Ap�/?�>Y9V^[�5�0;P�	B"�ZKߛg�=ׁ��<��؊�t��B;j83�����ϕ�h�ΦĀ�2(�Xݚ�oo���{Ksuy��z	��6��-�n�2�5M �Df�����!L��=�}6���^�9r�®y|Qt氘��\��3�i����?��@<;m�${M��ul��Lnr.�3�i��E��M�:���셊Ĳ�F�I�d�*ٞ!LC}ޟ�;-T�?��(�?�&��kA���!lb���M���ҋ���Z�(��5�	�4�i��>�[.y@�u�5�Л {����'�R�=>?�8�m�;s��xAIt��ܽ�3��� �{�c/ �Uupƒ;�7Q�U�2O݈<C�&�;i3l�5ө�ч+OL�Rk?��a"%QX�Ss��m�,�O>,�EMMT� V\\�8�9�B�pb���3��c�pB��Mԧ�i}v�0�I��{].�������eg�-��m\Dԧ`Ja�K��pir��[�;�L<�4J,}rk���I�W���?C��[��#�&�*R�>הV� ������xaBq��"�;��I,'�'p�⚛(ť�^�3�	-��l�xj��A�R����*?@E!	����{�gS�(��}gS\�w+�l�0��o������˿�Z�ᖆ Φx���/uɽ�SL�M�'�v�A���I8�^)�cܬlG����'p������.�)��=��9{��˸���K����>��������qTǰ���������&�;�9��]=i"��v��q�l��ֿ��^�VB�0b�k<��(zM
~���x;���+��$z��l�ñf*�M�௑,�e�=C���~`���m��'��W����5��lF���yϽx�I�蠈�!!��K
T���`L�dN&�J�w�\�`Ǝ�D"IԖJ��/a�F�o�B=�7J�q{#�����DqW��q���3��3RM�SSb�-��!��FY�6���\d�a�5�|��;����p�W~�~~di�"���w���9k=[l�`G󋢥]�{G�,��}�����.�66F���g&ƫ��.�y�O�t�
F{���m\ 7�:�x�O��"��+ù����&�!�sd3�̈k�ŉ�iM��(����X�0գ"G�3j?ƚ#j��ul\�K8ס��TֆF{��C���r�>�=`����	b'�-����J�z\~���և(����C�Dv���Ҩ{$[�����ي� �c�p������Iú/��5����v�J�d��K�}��|�\����_���=ݞ!L�u$    �7�����7��!�l�5�UN��k`��z��=A��2Y����lćh��� qQ��7Q�*�����g9s�H}G��)-iݛ��&C��5g�&�����Q� ���i���N#�V����,�ꚗ�]�(a���y6G�j衵������P�se,�-��b�d\�a�;*��l�X���Q�c����	�����.�z�ڷc����!4p�Ȇ�"��maŘ��(�>�t�~a<�];��g�BA� �!�μ@����:B�3y¯ �'+�ZkylJǱ%�h�8��G,87Q䯍3Z^A��46z�!,U�3�Z�do>D��x��G� LNr�����W��Es�&1�Kؤ�g���Sl� �D�B���*�Fb�V�iz���&J���A .e����4��8���ž �ïM�s8�A����c��@B����^��`��4�.
�3nlѝ�l�A���x�Ȧ іG׹�x67Q���G�fw�;j)���~�lB�� �M�..�n��^p����;���:H\�~`��6E	P�����.J�G��v��$sF0"x��+C�jV{oːs��Ԅ��#j�;����x�ڞu9��26������Y1�~E\,pW���Lg�WƩ=�~D��ݯ�q�v������D�>kQ��4�A��0�[v6w/m����l1�\\�큖�+X�g.�_A��h7�G6�P\5�9�0��a�E�$#O%/��0����lH'��u���+2dvQ$l�xe�˞�Ҟ L���+��5�$`�2���wQ \-�4�	<A�!���4�~�����UM���i"�X=��$l�3�� �.{�%��y����a�Q��97���:�κ�iI� {���#n��X8j#�����.J�b���c�S,Z��ie�3��J�F��e+�?�F��^�{�R|��_�H���q��v�l]���YQF3wO� L�5��{Ϗ����8�櫳�VL|������D�S��^A�*Ѵ@�&3���'v�+�>�E��� n��!L��`�6������X�X��Jڅj��|�6)WҜ����E'�M$�J]�����>x��$�
��Z���wQ��xZr9��sE{N]�L�*�a�Z���&�߫L����q_�Зx5N,���~���a�a�g�#����_B��3W���D�K=v0g:�!�,Vk�qm�o[a$߬�;]��i���n&9��)����no��%�uI�X�][�����Ҡ��$;���A�a��E;#=�pf M����,c��n�&!�8k��n8|}��C�Q���	�(^�D�6.��i��>�P?�)b�t.E��",�;U��߃yL3ǯ �N��W�#�n�&��k!p�n�]�M�ۼ�4�T������ag3���J���}����4`M{:���i�.m5s���#L����ª�P�ŕ�%�d�Z%��."�ݴ�8;�LΥ Zz�/��V�(nI��s�a"�n������I�=�܂*��(�+$�{�~�0ed��u���m�A��-I샴bn"jJ�ӗ�lI3�� �hݦ��>���[-�e� �z����0S}�
���E��p�
��(4�\7QXۓ ؈s~����Io�l�uj��K���>D�gg�A_A�@�p�#��B�`/y��TN��k�Y6� �M/�`=�T$"�#a�i��yE���q������6�6eD��v���^��wQ���5�
�4��_���>G�bnU����V	��5�`g�^A�/��:��>�G����$~���7QPSe1a�:���M��pdSoR��+f�D!��`G3My_ D_�z�R|��S�h����$1��Ka�/�+C��k�ЁM��{#heb�ނ�؈���b9�Ks�0C����>C��R�8k9�U���9�7����U�����k­��!eX��$!\�l�ad;E��q�e�&t`hٯɱSQԛ��^~Z;����a���%*��-:W��3U��Д�x�fr�_A86�t`C����]m��� {��hf��+a������&�6��*���2�yE*̽D=CG������p[,�bIUز��^��a���9C�(���B��"l8�����5o7*J��Hf&(��Ю�|�s�l~�dm4�Y�F[�'oԟ �Ӊ�m�;��J8<o8b��,�Q����L��+�]����15��Z]��N�QX�p����� Lk���6��z���9��^�u���?]~wI����Pg�������Y�rF�=���ܛW�"����	1��׵u,�։{�d��w6h��K�3m�^A��X{`�K�}'�j=��E���̬�W&����m�^�%�Р&Ȝ]D}��^�@0�X���Rދ�l��wG�Zk��(�]ЎӉf����0苨�=�Ά|K�D���$�D�s��\Z�3��(��� ��i(B�#:[$�[cZo�H��	���a*QkZ�um8��X��.rl��4�v���1z�0-��#����ma�.+4���l$��&�c���t��
��<��H:�(k������	'���1�#����/A[i:�&T�^mZs	�����m�.�� �:�q�l�C"�M[���⻮���EM�〳iOƣw������c5��䌥��CY�T(��w�JSS^ ��=��\Jmkj	-w����A��n�{�	!��\X{eZkK�0x�.SI����3��$-a�����˜���Q�~�X�P-�����f��;�8��[a�c�Q)b��cA��5�7Q��G��
�!L�X9�vZNvk0���hWy�*
_�,��=C����6�qԲN`�VYN��KD?� ��I�f��zd��ne����yE���(|����¨_��� �͖&����-J+�"�=�$���gS$0���uZEm�!�$�sŸ�(xub ���w���c��p>n�eL'�x���\�}L��|E.����+�A߬J��N��V��d����Ҹ����=E�ؠ��Fl��������ڹn�� ��Ic/���616�j���U�FD��
�h��	�0k��vd�[�?���h��|�����M5S{a���N�I�Q\/e��G����^O#a�n29�	��$�q�Ȇ|В�Q]ʄk
�U�@/'�\[�gC}���7�O�q�%�i��h��5"��r�g����u{d�F�,�3u� �贴��8���N{�0{�n/g���Zh\����z&�ԓ#Ȇ��̯ D�n��鞆[��*@'�]�	�.��:���x�	�D�<��0�Φhn/TA��C\s'�:�r��hi2��	 �Tm���$q��Ұ5پ�܈(�>���v~m�f����8��˥0�@xd�ъd"��a��^����
�X[C�{�Z}��*�pp�b��]���_�G�!����;�~�nl�\�V6��j�.���I���ç�:-�r{k.�s�|�?��p��ן�O߾��.?��`���,{aj�wǻ���j�M�`�a�n�A������ SC^ ׊�pP���=1G}���h���i>�6N���d�1vM#8�)vh�/q�h�
v��}���) M�ݯ L��Rٟ�lv���'��m�����6}Z��$!�$�w�E�J����7�Y!%{?��_�p��5 X���
�Bs���� �m!�p�n���ɭ�W;ap_AH��絁-���(�\��[E�M��g&���0I�Ek�=��1�.����N�(z�Wqc���W�F��[n؝M������0`���(��
3�W^A����}�k�c�ݑ0�aŜһ(�^��L��+������6)�$�:���z��(�C͢�����~!l"`r�sS�`aC!��2��WQ�����y@�1B����,�g����+���k@��w��`�G��vT(]��0Z����H��i�LW@K~nm� j��!у�6�)�
�\[co����L��+�T�(k{`�k��(#�E�ʊ^wQ�    og滼�0�wKvOfk�����&L	H��V<��x��l�w�g:��0���z��߮
�$Vm9��SK��[��� ���y�3�}�'���L��ɼo]�e$O��MpZTD��Ծ��0�mž�%w��=�u2W��V^G�(Q37�^�ͮ�;��G�Y�6���l��i,������N���2I?A��B�c�`C�I:|�5 ձƇ���@���{�2d��N͝��9E"O*6�b�xi7I�զ�4gm� L^��Ol��J+���q��=
� !̤L����C]�I��Zmk��P�n��.ꘆ�o?���t�����������E�k�(�[���zm_?]r�x�c�1μ��3�����{�l�f�VM�Y|�����v��Lm�g㸇�7�~�!7�x�����F_����Cd�"��<W������ޜ����Zp����i���f�e��	�+�_��B�\��Â�ޛ(�CB�8U��
�@6�}m��s[C�煈T!�'���'ܡW�R�7w��&�Ĺ���8�!�C�ʗ�L��+��n1i�"��E��&���	��*�r�����S�C^Aߠǡ�d��F���R�i�А�%����ӯ�����?��/�'d&	/?��r���['�{��&VY����ar	q��݂��[��-�ְ �m]1�OD��i��H3�^AD����Ŧy�#��҂ �!
_��3}�^ �ܬ����yC��6,,�7I@�]b�yX}!l|��9�6�6q#@�AQ�k�=D�-O6�i�g�{	m�U�׵q)o��tf��PQ�l��L��+a���é�M����Kj.�Z6��4za���3m���J8%��]�W����	��`�l�Fc�p�h��� 		)��x�)��|�0E�;�M��Te��y��qA�~%��Zŏ���� ���n;��"u��IM��㰢��M��/"��ŉ8������ݞ؈����k7Ɗjڇ(p��S�w^A�lk�p`�sжFt}�%�C�pu1�'�RK�t\M�Վ��!W�5\�%�ȹi��a|����vdcG߸�"���逨!��i�
´�ʐ6x���?[�-�T��~s6`�IN���.ؙA]/!LC��~d�)nb?)gql����(ы��߿�y	a��m�6��vb�:��$}��������M����6=r'6�Y�q��-yA?�����?���x	aZ��xn��o�X�X�H��N{����a��%�֎\u��W6ڔ����>;T�>D�zq�q���K�1�ᴊ&�#q�u�da"H��En��4'�}�턆~	a2G*9�:�����<(�Ռ�5kC�=�ǫ�~&V{	!l��-l�F����3kw�oo=�������K�#�|[=��vlV���/ha�&�׆%`���x	!lj� ��|ț�ب6�(��R6�|��^B�k".�q��N4��s���؛]�)��3�+3f�����u��Ds����!��^�~%s~���i�R�&�6�C�j�����(
����	��|?�g1�[�S�X��E�(x���`s�6;���d}\Ƞ�@K(�`!1�q&w���)���̽Vī��
۞���]~�S��S����_�[��ߞ�A�~^��ӟ���/��U�M�UK��3Ӻ�aB�-�i%�E�}�m�
�7�x����?]��k���,��r�!���E{\�?Y�?�5��d�� ��;�|f��C�A��-�v�&��1��@4�3�!��o���q5Sm�f��9��n����C�h`���ﵺ_�8���6�����k�u������'a9TdC�4i��T,a����GQX�A���3��T8::i̖�J�Av�F�p����W�El��ǕɄm��02������WI�j�����9B궀��26l8r��yY��+���C�� \����ˎ��h�`��WI��ݝ&��^B�ko:q��&�� ��ׂ��7QpOp�m�_B���D|���'�F�<\���������쐗&#ˑ���������(�XiYD��@@�G�VhgS��}��M�(Q �S(�|��7QHE�2O$��6�m��r��=��X�}�}�]1 3�;/!L�lã�M-h�e*��A�i��C�	yZA�!�H�2�l;Ł���U�|X���&
k[a���/!�@��IC�Q�4B��k�t��*J��3EP/!̠(���	��di���߾��(x��4ѿ�%������p��z�F� .(�8�B�?`=�FL>�'��w�,���	�wZ�W��}�%�Ka��w{d�Q��&�(ӈ�<|%]%N��N���ON���.o	|�\u>�Z6��&_� �M�T��I;,��D�Ű�^�d����!lJ)y��,�0���EѬ��V��>��¦��t���q���,��u����]����^�K��Ա�P�,�i��#��ۧ3��)J=�iLՋ虣lGj���vQR����?q�#[�c	>}E��6�F����~j�1��j�t��Ό�BD�4����fgo3����2'��e.�D�/�:����������������҂1�WQ��D�~b�Ka��:�6(���Ʋ�ǫ(�]�^�c�����N<i�V����s{m6%�ͬz�06���(��6������W�E��-��ӎ�f�CW>��s�CEU��FGQ���Dk��ƶ!��5��֙��vŝ�(������%i��;�a��݈�k�}��sk�5c^�6^MF����8+6�O�6Q�N��j�A��l��]��j�9�;�� $�Ю�s���NSQ��t���at�)�td�Y>j�R�!A^��D�p�\�%�q�t�S:�7Q[?��]��UY"���0y7ku>@��p�sĿ���J�W�\Ea/���ss�0���t�p΢�G��V���LC��E�h�4|	ak�5���6C��-{�-�r�`�����ٗ&4}�J'[ ����s�	ݲ��t���A�.FN	'@ߣ�p�)�*��I���p L�Ѳa}# �[L��2�ih�z�N�Y���}8��Q��1��˺e��.J�<3�%���Y(��m�Y6d�I*��#���ݞ���!�i�� L0��G&$�lk�����e'kɇq:�qF0�`��B�m����V�����XX'�\us6���$�p=�L��Y; v^�Ǯ��KD˓q�'û?v�俭M((��FsjӬ\��=�D�ė�ŗ.ᚑrcQ���8�7/�j!P�q�:�	�p�NݔO�,��������D�vQ���o�&#O�������}$���_ynBC^��Z�a�/��~��m���XS��z�E�J��01_�%��K�z��#�V�c���5��U�paK�a�`s�0535�4�c'��6��5�3�����4�~	!l
�X�lrN�F(B�r����WQ��:7�_��ɹ��v�1��L�{�i��|�D�)k��7� �3NJ��F�n�!j:�lv��|ES���
>A�<b����p����kѦ�i�>�ڑ��x����
�t�[G�lF��E�ti;�7� Lq�U���椢�۰�M�ꂖ�?EI���d~"���=ޜъ�);̋����k����&Ǔ/O�4��G4��F��t��4�k���}ap��6�´����Fˣ�-�f�@��.�AMy-f�h��B،D���8���bc�-��k*a���%��5Y��a:X�S9ݝ��-`cN��3.�hA�_�'[������j�7��6����5�WQt�M��z	a:s������o=�L:i���;�QH~������V��)&0�i�P9��Y^�x1JdϿ�6GcCk�^}��qw������m�g�k	���
>A��)xG6N���p+r-d�.Z37ё�%��(;l�im�,U���5�pm�dy
��OFP-�6��u8\b�.����"=;9�o�9@/Od�6�F؂r�F��l���\Ք�̴}�6��J�ǵ�Y+�� �Ζ�2;4䪗�dn��vb����6���X�m��t    �=���y���l�`�6%z�s�(WL�Tv�E	�{ks�0��$�Z�4��>ŧFlv%��Ó����gn�q��{����\���K�%y�_B��Q$�ZD�ѐ#e���(��d6����)�;�<�֊\�r�4���&
ɕ6���!lz���� ��:l��R�Ə��]��9Zo�9@_B��5E6(��K�E�]7Q�4<C߻��%@!���nu.�9�rmpO�Q�3��ù�N6gNdm|�<4Թ�u ��Q��;Z� a�mMt��!�G��P-y����Y��C^B��"W�N:-Y�n��~��k��9�Ɋ�'�|_�{�צ���%CQ�"�y7��:M��aBb�j76���Q,�Ěo��M�����6`4�����Z��A	{���O��P�7�#�	ɷ8�ɻ6l9�QvZ^0��.�>W:��9)g��d�I�Hbu��o��������q>�q�6�9�ST �w7��c#,� �	��l�'a� �?ݞ�B�N�~������D�ߦ{�N;B(�yٔQy�.�x�W�/�E�, zD0!����<�3D����U���ԇ��95a��-p���XYL�����D5��95Z�mؓ?P!�>+0��X�D�(��wm�71��%�	A;�y�#ێI�-���-�3�	ll�h�e!��R�>u1��K���S�¦���)2�R��f���h�B6��y�|�0QlO�pz툣��T������U�M?���	BؔR?r��������#8��t�.��Mi��������|:EmC������/\.>����!l|�t�ղ�<�Dqc�yY.�.�[&�:� ����y�n*�>�E�n�0s���!lFɝ�A��C+��u��{�PJ6�s�!L��m<��Ŗ��1xpѱ4�<Ϥ%&>9����Ksg��eԈM�L�y�<��(t+�w� �M"g��ܰ�jC�$���rm��b:�;;� abc��M֦��X.ѶP�]��}��<B1�2�;��YwZ��]�~���N�R�1��zs�6��LG��k��L3�J�=.�.tE��$��a�!�G÷s�Cȅ!�i��Lmh��hf�K�-w؞rlJ��������LZl��dG�'�Rw��im��ل6GVuQP���>��	���g��𺯍kr{���z[g�\��"�|\�a!��-�F�` ��shqYL�,	��=ƞ L*�ٓ]��M\8�l	M��ul��Xm����!L����zz!H�Ć����L�El���KbK�7g��G�*=����Ӓ9֒[_�Ӵ���ꍝv�0�'��N/��G3w�c]f٠&�7_�u0X2���I�� g�B�x�[�Ob)M[5g�5��� �[�۬N),{����iL4oq�!�a�5@Ѯ��ɏ�F_��۷��)�l��'��SL���� 8�8�{���KDxC�!t�E�Şn�8�f�k�YἮ���g��?AN��?�5��1t'��cY�c����o�gC���sŭ�ء�jk_vnH�����!��\�.��N��U97�|!�Y5�($����ig��Em���ys��>ô�R��ɑ����¦E��9'%i����ci�� M+���~�<C�����Z`hͪ��dm�L��^���l�'Sl/��S,�ĤS�4;
�ek���a��=���F����)?�"k.��C�����갪����))Eq��I?��,{�Yg�/��s>�Q}�0E�pr<g@��U��U��.�;y/gRI�u�Ju�v��qŉ��Spz��΂�_\�����ga3j��^���+B0�Y�_�}%�`s�0�ϩ�sRn�6���^Dֲs��t�0ex��tn2�H��T]
��Y�(�V����z;YiI���Ұ��n�~��O�i��<!�
��)ble��A�uW����B�S;C��D��K}z��I�Б�sZ���i���v��T
.���d�msE�7��� q�d'���3����^O9ݢ�6��m��V�t8���O@4��<@1�s��'�x��{Y��e�Bno���ϲ�v��������#	b����,;%^�q۴7� aD�ƣ�ci~l�.̕���J?�(p;��_� L��-ӹZm�Ɓ�W�m�-��(�c̳9B���'��N��r�}��DI��KSQ��l�Y����驅S�C��9=��lyY��s��TS��_ ��Y��t��+�&��Am�˺�:!�Ok�3�	~�b?���b�Q[�,�)��է�?���a ��8總vh=qIT4�3�e���@$���� L�������?��6���u��%h�%Gӑ��=;�~�i����#��:Z��YܒO��� LCkS�_oŐ��_MԜ�b󈻶*���R��l �Mp|�qqc����-��N���&�(|q���+U L#۸�~����B�b���U���E�s� �M(��q����-�#��Ӣ	Q7Q��0y��´�s�{&םM%����,����NE!mbӬ� aj��>e��M��EL��z�}��F��a���xkS�+��l���w�`��jmD���9q~r����ݶx�H���՛�<.�:b�U�@���(MG���X���߹�1�w*�+�k�b�*�����97O|�������d�`��W�W#��
P�ıv۟es�6�w�ǵ���a8��t��lP��t��T�v���_@����B^4��*��#���� D�8];� mk�%�Jiޭ��Um�F��\��y\���D�޹��4���}�#�N��(ch-�h=�[E���8���3H L�@�?i�n.}�؇ -�@�v�n�xF.z����K*ⳉPG!ں���� ��G�a�#謑�mI�"�Շ��VE�B�[��i�|�6�_���K�!�Z��qWQ�E6��~x�0X]�8l��������9�^�|��o��Y�lh0o���6��2����Qd�>7gC6��'6���r6�1�U�]"��I�鍵9BǦƓ%��ː�TG��L?��L�;���a�l�=���Ʊ�A��t�jn��������y�0��(�Z�Bk�%��}�w����B��]z ��*�x�i�k.��5�9�W�Ү��(���y�0	B��ۓA��<li�ڼ*2�/�-�|w�a�\�'[@��@�Rm�.�9Q�T8/
vzm��&��������4F�z
�LC_E��?�a�]⒎kS��ST���2��{{�4��� a5Ky��������l�:��eo����4_�� ab�#h(P����9l׹^�G��~$���������������ʧ���?~�����kN��?������]���-�!�k�����a��(������拦P�x���@�@���q����d�J�W?�6C�z(=`���x��/�����+�t��ۋ�ܲP�ζ�c��K��dK�����?���˯��g�[��6%���ؿz���W���������F���?�g�j�
�>Ź�-��{����������#�h�7��6}��~�QKm�_S3�"-+~��Nx�x���A�[�cM���/�;�ǿ�������s��.)cJQ,d�?�����;Ռ��5!D;����g���ab����F��9a�&�QD	�=��S�\��3��I��^2sc� Ƽx�֍��R6b���a�H=�5@QnOb�E`�����^�:�6>C1F`O`�����[,���P�rm�x��J�!�
��'b��Ɠ��}���뗸�WQ��Q��0�6%ʍtd��-֖�0�J��wQt�����3��6|���F�n5p-�^��➃��ssN�3���\�I���Ն�,�Qƪ�����f<!���{����tuQ��z�BK��I�����y�6#�p�#����NMT��R�(��Lh>C��r<�3׵G�@�4��ֱ�)ha��3��)UT�����`A��:���K�h��\��3    �A�NK�M�u8Z��I�����t��l�Ɖ��%�B�z�P"-3	:�ǵ�n�����������ￊA�G��忢E��}�ҥ||)|��A�09��z�0	
�O��&�V�k]C���"����FmB�XD�8�+a3F����Φ�(@�Up������cL3ف� L��c����M��v��G,ޮd？ysza��i���P
�в�V_ʆ �����q�zj:צ�[���c� ͺ<��߽��	� �8ř\�W¦ՠ���)��-���t��R6������0|e�zn�-�^k� ��6��4 �h_S�`�K�+a#����;N�#�f�X���(��Kv&���	$f�-����ܠu��/).ޜ�_�����35� ���ۑ�ܶ^\J����"k�.
]<G��s�!l��x��6u��Ӷ�nE�� 
�\S;��ҏk���w���n�d�v�4�3��!�Yg��\�U,���8�����&
XXm�869Ɔ�~N���)>�#-(�񽄋�`��#����^A�ZR�Ys���x�,,k$z�"�
�4�����Z�����4�ChŽ8C��$���Z���j�'Q�}�+���6r�8�Wa�B��C�o�;D�K�_��B+��F�3��Q"!��Bx%]���kA��!Ls9C�o��\c��6eo'����Y�/)Y�7���'�i��am���-@J(V�*6��$�&����)�p�:��h�ζ��]�E�M����!�ݧaO�,[�)%��2Z�Vo�,��l�,�7��aF.ҁy��"��X��~k��(��V��9���,h�t�@��0,'w�[��D��p�_˧�B؈���{�'�%:ϕ�@]v��p��5��s3r�=��~qC�CK��jq�E	�=���a s�u��Ώ|��|�2F�!���!r��]F�_��)���F�>�dW� �ѓ�𺅫Ï�V���^~��k�O�69����_5��"�G�A�j:c��|ڽ_.R�,���0���-47z���53�Z�sk&�W&U���c��J�G�d���+N�]w�:��t�0C4�N��Ɇ��s1����/��n��$�f6���C�x���8�N�*U[�o�S?HB������?�0�-�=eą���Rש_�Y���_ˊ�B��@�>�O6��͍�#Gad�5�� 
\"czgm�Z�rǵ�6j��;c�A���Z��!��tʽD+�S'������(��6qƟ{a��R;�vZk��0�D�����M�ڈ�}?���
�>��[+�Zj���p�A������~a(�R@��?-���u�a�\������k݅-�s��¦{�tw�t�G���C� wQ�&C�����$zx�n�S�Uv��F=�P��&�>�"#ô8C�wr�����D7 q-q������{�ZR���r�|=���iۃ �ڞ�7q�,�>&��	A�t�6NV苵 d�!�X��_P~�<m	�!5A̓�FacY.���� FuEGZ'���@.H1��.C��ԩ�"j`����\5��j�?�0��c������I<�S���(���=�ג?�0�G}Vt�K�V�����A�p�z���6G�m�'o�Ԛ�����\�q�	��ěG;!������2�>ɦ����$
��Ŋ��!�-�����C�I��tJ��v�z%\$���)�C�<d�o���v�@�ٕ�&D=���N;@��NZ�e�m��TSF\��x.zpg�_A��(G69�S0������gH�42����f���F�M4A�Q������E�;��}s�0�Q��54�p��d�\H�[��$
Ez�9 ��QN�Ѯ�tP�mb�=�^��\�,It����<�#��d��x��%�1Z	�V�g��-��ax�6J:���)hw����e��Ӆlp_�M��h�\|˓]��R�	��e: �<ʂ���U� �a�������	seB�y�׹�B.įM����b8�A��1`����@��kӼ>�6$t���$L�(.��rJ��=�D�KD��ԋ�!L��>����n8�h�������8�#��	��	��"���X����v�<K�M��F��!t2Y�`Oo�N�X�8���ul_�\_+��:�̍�oS ֭b���b^�&Z�ƣ�ZF���f���H�<5���Ė��e��F	j��w� L�)0�,��m���b�����N�y�_���ڬ��!�ib)���>���c�n}]�	�	)9Oo��|�'��fu��Ceݫ\�����s#�X좫��v��R{��@l��l���k9�C�J��)K�Q߂�=�a�s�U�b9��6Ss't'�S{*�~V�9�m���J��k�c?�0�@�܎'jZ�_eՀ*-˭�E!}����g���1��88آ>L��ei/��3�� �M�5��K���͖XHS����ց���1�3�i�z�p�;3��,Vo9Xv�$M�C�}5ms�!L+!$Z�R�m}4��c�,f������:��!L����/'�A�v�D����]�Ϣ��h���o�9B��>6��hO������Q�{g�!L߳��Yi�^[+�ذ���S�΢�Y"*'|�����f���|k�r4̑z�ׁe�]&7os����;�=��d�yw{���7t�!}�l�s����w�����10� f����yE\`֩5o�9@��}_�)ZS�P(�%ڸ��Y�n$��5��aF�������S��q��ņ^v����|��a���u@���P8�Bz�,�@��X��F;C�0��ؔ&Ύ����������d>'�at��u�͝Mf��@� h�xY����0ůM���D���y?w���u��־w��(�����g�h5M�;�Q��`dnuaF7kYz��fJ�"�b��v<5��xM�4�i}�����r�M�3��oՙ�G6�۶E}�u�#/�yj�(�Szki�1{�ǵ�-mutp�}i�%���F��,�3��I"OMa6}����D�µQ�B�/:C��S��� �fG��V�e�؇�s�0�k� ad����VŠ�������s�D�ha���<@��&7O��a��kamp�*2��h�I�v����t\�F�x�qp���%�ůun��8�N��Ӏd�h�_U�յI����z�}a:j	�6��O-!��)�-������[ WM&p<"��6yϴ�1�ױ���rk.�%+��v�VfF�`�<�g�b!��lra�̽���]�D�N㜋�?CQk������e-w�x��
�6ZОN�yX�85� �8� M�dw�u�s��RY��uχ��8�D3q�W�q�eҼԟl�H�l�}�q��(q�) ~����&ʺ�)f��mE��J�m�\߸�������ϯ �M����M	,�@��7Ʋ�-�.J�_l�b/��!L����6N!t�K ���v��2F�>7ga�S!����i�E_աP�|��(��e��ӎj��6eh�3�1�6�LbOWQH�����8�OF�?�LL��GJ�՜c]�2��]$��?��0<J���i�(96�Ԃ��GQX��4~&��
�d+�-��ڔ��*������(�"r��7�
��D�ѣ=��؜���:������E����bc�_��9��:��wF�@Yb4o>���-�\E�j� ��8� �M�݇|`CY�:�x71���*K@E�K
a"��
�8f�؏k���9�	�(��Dl��N�\3��� ����j��;��SN�E]���"F	�V����!�M˵�x\�2���Sf�K_e��(������+�s#��F�ܦ�?je�Wݞ�HD!+�h���􎐸ِXg[-�9�.�������������
BؔP��q,��5gP���OwQ�EgSL_7'3|�F=
��}��e��q��h�8�f[��6K��|�$?�9��{�#�0k�=@�������F.��g    �x�_�.���cq��<Cq\��n�7o��Q.�=0{¶�Ĩ����~�x�0�8�����R1:	JMٗE��]1٥�P�#����������d�H<Q ��]������I�!l"G���u���l�Í� J���E�
�4_R�Vl�*����kJ����0�Fў L';Z����1A��9F���k4�.J�=i�k>�6�G�G6���ҩ�T3�E��&
8���� L�o����DqA}-�[��Qn�@�D�Si�� ��5�o�?�M�nK�ۚ
�Xd	�(~o	��ħٜ!�M�{>�!�Scl�(�Uw�U4�2�a|�F�W-0n�f)[Bq�[L��o�WQ���O�L��p��s<p)bl4�u�ڊ��$i��|�Щ^}\c�}�`���n���j�iBiQ�Lc��[+�,�P�:Bw�<Z�����Βh�	��y�d�F~���l���%��b��M��3��^A�����?�3Y�j:�a-�犞�WQHm����~a B�^\6����c8�������N<��fZſ�0@cԠUP?w����#$�m�ڰ�%���|a��\��N#�[ѹ�ntvu�F�=8����Z�
�@����imB���Xfq�(�3Nu�}a�>qd\����Ƶ��l�5�Z�FA��R�0�#���)�k��}�iv]-�Z\�gM�QkqVC?@���w;�=��U3�F
���\�+�Nk��!;hl�omˣ41E](v�o#��z�#ܬ�~�0��Cw�=ok�S�2���Ƕl�����m���?Alв�|�l4�&�(��ӊ�q7Q�!M��3[�w/�Φ���
8��а��u:d�ܜ!��x���N��Q;�`���9�H�1��,��4������PG�C|�5YO�(u����W�'�*;�W�����QL���"cXD�_��6Z��O�L�&'�T7?�uVؔ�&ʹK��Œ�;s��	�tgk����hx�ԭ|�&O�*
�Y3S:^A�aE��z�8�*Z���Yл(ڂ2���~a��gn�YQqO��z�Ul�^(������a�"�@t`S*&��BC�6��&�A�x{���(���]V��o�w6r�jK�aWE٭ɬQ�//��I��a�S���&�C;�(5�X�M�.
]�aZ�!Lhi^��m�d��$j|�&�!��&`q�~f��+F��l�sZӑ�[ݹ5ލ�Wv��N �:���8�#�";�����ͱ_e	�(�"��C�9؈�+[���δj��(�^�-OFӞ Ld���#�6q�G���\Eaq�"�\T�	��<���ǝ�-�Hn�T�I]u{�(:>م�~O� L�aش�ץ�vd��(��ܨ��,�˯y�0	�x)t\�>���k��V��馷6�ɸ���V�6�i��I�!BNQ�s~���_���՘�,�3�ɍt�SK?s���틥ao�쾹�Ct<����Iy�l8��ޔ��`���v���Lo�WƹRz�+hh}�@H-7�i���c6�|m��+=4�%����"6^>�R;{�]�k�N��9,�S��t�
�$�I{l�Ʀ���{�v�Z�F�z�ē�O���{�m�i��C�@�ȡ׆���������������5����`N�&���~�R���ӟ����������~�(���VB��Z��S*���0����Vޞ�^"g���֤˵�6�ڬ�]�� \Ħ��E����&�h�$�%a�LA�\`hڴ��FT'n���%k�q>D��j;���!l��r��8�[�d��u��p����w6��������t�h�9q���T;8�%e`�����h) �)�ga��������`�f�h#�&M��WQ�b�����3�	9p���ȍM�
t��'��i�C�$^�h�w�� !lR�{��k�|���sS�i��lD#��6O¦T����;���VK@AՆ�kt�U�x�4�t?C-_�"w6�����@M.�5��M�`?3�������q��:@f��8���}�"�?A���!�3r\⌛�����K�Y����&T.)�t\�̴��{��_5.y����3F|�������]��}C9���: z�yI��]��pf��+��:��C�.���R�Q�C�s��&�����q{S�2X7x�c�!J�8�Rzgm&��8_m��ڰ؟��:�(��o"]Ĉwo���������QӡX��RCkG���v�6�u��qm��؞"/�lDL��t�{!lJ�Ԏ�[��N�1*k
�>D�����aE� �Moͻ��$Vg-�}F�ƚ�WwQ��f�a�+��T�ɲQa�1*��ڸ&,zE�;ͥ�?C�H�Z�wg��na��_�5I�wQ�ązò9B�	�w6ah�Q"�Iv�]�\dsęf�� ��F��QC�Z�f��<ĕkb��43b�����)ʑQ�4ܰ�q�8��(�b�\��3���۴�]9��P�9!�P��L+5t��0�w<�#������`E@1�����s��R��G��O�F�n�BV�t!�8���9@��NVg�Dx.6[�B�s�`�i2�a"�PF<����7�|P<�I���B:�����C��vǵ!��%mN,�6�]Ȇ�O2���}!lpԽo�O6����b�5��Mb�oY�979�x���- nv$H��b���V@����l �ϩ6���{IX�r�ۇ�"�5l����6���r� �����ӁMf6�8[v�h��:6��"w��� ��A�����ơ��>�������4����Y��#��x�L�@cM�ի(��6q�*��$�0���p�A��D�*��y�d���g�J��0	k۟�: 54t[�͌m�ʈr�߫�.L�3�I�uP^=�i{�Q�FG2�)=��i�5�¤�]��F� �?�����ּ����E�~�y�0r�#����Hj�a���X�z������+����/��`�^�#���h���O��j�3n�%��y�0#��;�ɱ�- E�i��6WQ�fm���=�F�f�Ӊ�F�<8���y��θ�� 0�x�0Ժ���SsK��5ɩ�Ys=��)qu���y'kV=��VR����r�@�R�⪕�&�y�D{;X��r>A��k��ܛ�_���u(8�����y..�aX���|:��#�����1u\1V�.J��4W��a C纷V�7����d���k�V`Qtd�V�Yg�d��	�@��F��)���&�Y�˚��WQB���vs:�A�r����v!iZnƁk��.I���"��K{�0)���yi?W&��������Ѯ��>V2��5Oe!B���6�f����v�>#UG^���6$�Gprr�:��ƖF���2��Ӯ���՚�9_�	¸*�X����RƤۍc�-9ʫ΍�X�U4׌�B���ճ�`�-��� �X�kn��(�&L�k� a�(X0��ڄđ�E�5WQ�"v�����q6c��6��)�
D�%K.�����՝'Ʃ�߯ �M�u��܈�l�T�a���<�(�1��\�'�=��WK��M�P7
4RI���iF�!
\ě����B�T�R9��n%t�,^�X1��.J��<�M�3�I>�~-Ի����1��|�b��]M��3<{{>@�ec磆.�����qb���nO�.�,ε�~�6���H�k�oq��=֖W��>��(��i}�0�ښ]?���b��sBX1��*
hW��̕�>C��t�qm�Ƿ1l�r�f����.
:;kC?@�4�A�'[���i�|�޶����C�}>����gaC��p��v���za�u��i���w`���3���cKt�i�9l��`��fWQ|ڻ�M_�'�R�v����k�os�<ϫ$����[d�3��b������Xo�u�:6/$��!pB.�c�[��-Nd�m�7�\3�C����c���e}�Ǜ�u8^+�`����B�䆞gs�6�j���&!� KV=���wQ��{�gS{�|�;    o�c�-������U��ڏ�t����� a��P*��M���H.��9URQ�D=!�>
�>��΅�6�EoY��]��>�\�J�9I���y0�(�!��ʽ9(z�EYO��TI��\c�ga�*��lː?��6��+�*���']�G]ͽ�M��\r�F��i�J�k�wI��#Z��wx�6��~`�N�6�ĵq�Җ���>{�0$j�y�E���m�j��85��l�(�y��+#�r���6b4��'�Y.Vb��"��W3�� �&�������hfMAm�Cr#����&J�K�OX5� L��o���B΋�����W�
^E͍�3���[�9��^��Ӧ�D�����JB�.�=�?��0��}rdC��-'D�#Z1�*
_M�T���IIߣ�k#���3�#�W��.�Z ���{�F�ln�1��%Z��f�ꂻsE���3��<�WF8���l�؞=䎽B�+��wQ`���3�B� �(Ze����F�:]Ҏ/hW4�����p�h��<@�h�X�q�m���Ptږ�숮Њ��WQ�������$�Pr�.�s:���%;c���U��ڳ���ɜ!L�:��>��L"�QbD�"�v�N�4Ղ��q���5�GmJ�l0��V+�]���+퍕9CQ[��pdCr�l9�R�Z=�FD�����9Bhݍ>�lh<�X�^������SC���3s��	��n1���lrἥ1"�t�knN����lg9�9��	�t�Y~P����90���,��=m�NK����:���
�Ȯ*�m~�)�ㆥd�5a(k��U1��\��+S�z��*�� 	Qj�OnhO81��}��cJ����ٯǜ�M��B�s�z�U;Mgtik��:�	B<5Ҿ��N��È�ݽ8#�t��*6��G ���ڜ!&�+k��Ά]J���ı���r�*
iI�05����:�KCχ������`���5uj���`&��A,�:(�]�G�$ ��hj\d=�ңkk��+㩶Ҿ��f	T���򔯖EQAԮ�@G3y�� ��^�L�<�Ģ���/�!p�iHe�g��_Ah���(G6-���v�/�8����x�~ft�+㢆��؆OgƷ �[9Krfƚ�&~��;qEf^l^A��C<�Ѩ�6�_�ŉ��������t�*B@�se�����w�-u�=s�$^B��7� LJ%��O+3�mb˄���X1Z�&
��8�]�
�$��|:5.��,t{��Vi4o5��z�Y2gS;'�򑋸i�P�k���B�*��"��μ@��0<Z�;�[=v��w�},�j���/�/Z�;���at�:C��ܲ�
�f
�wX��U�,�npv��°�]<�����S�仺ƫQ�Wu+����/Lj�yr޵�-8����ɥ�р����fF��0i$�Б��Y_8���,d�֓O�^�}��ٰ�}����f�?��\H�9@ڕ�jo��Ԉ��<$�h�9}�� ��Lw�W�cK����(���g�`�2�o�Ĥ���soiO���Q��׵ю�~�,j�3�5��_[�eϺ��8 �,��?�q��e+
د��*
��4���
�8=4!쑍v�he��`�EܸE�t��?�e�͚c�!�@8*�p�v�b�Ps-��i"
i�E�3��� �~����l@-��Cl57�ܞ�I�p	nf�3�i|��=B��e]6�� FukaQކM܋}b����
�tM����F��R
cNa��OWQ��1姬�gc]���f|�5X�첌5�vE%�M���l���aR�C����u�c� ��|�5�T��E�!L��1y����ύ�Je�Xj^EӁ�Q<q��$���!�K�]�l�$�v�b���\���F �uJ�=C���똡��N��**���`��h�	1��8�l��Xɼ��ؐl�mo��j�E��U/V0���a�ٜ��?�X�7�Q��ɮ�E���E~�<�]�aFN	�`>h?���Q�f�bn�.J�'B��`.��a�,���h�6swu�$l/+�lvQ�ç��(� ��r�=�;�<�ǭQ>_���U�@t���yza+��Vlr�~��Yq0����*�8�΂�˫y�0X����N��D��ֵJ�(.�B��i�@��́ղ�1"{h�k��Qtb�s�6���x@����hѺ���Y���mI�����g#�g���xn��0T�k_�����Œ�a��y�0��buZ�Z�>�m[ ���uŇ�3��� ǂ-\�{N�촎��Pa:�\~��ǿ���������C ������o�||ɹ����o��9���%m��\�޽� L��S���t�!��^l�r}iXt�*�/~�:�.��uOF��e�lD{����$WmX��v�E�V�s���)�K���p�I|�Q��Ŋ9�wQ�T�SC�_A�dG�{�����_jD��)�6�]`5$M���B�S/	� L*X��!�w6���.b9h�Ʈc�MD}�3�WƵ��F�f�&��Ko�j���ۂ�n��ߓhd;�8��^A�Y���#��^�NZ`]E	j\Z�3E9/̈IT����Va��бұX��D�K�6ٱ)��}�!l8��6d[�F�R�B��Q��L��+3����9�{g��e`�b��������%%7�}a�|���ks�1��5ۃ����[ױu��䞞gs�0�7�:ِ�wk�b�@��^�F��Q��^A������_-��g�[i)��<Ug�
�X����?�8��oX��\�[��wEq�\�o�#��iBG{B�d#��B ~y�q�N��&;���
�����ey6�N�����d��D���%� !v��c�NkSDW�!��@CqSW�U���gRq^ �r�Y�w.El �mB�6��W̍:H��a·ya<���WF�C�*s��v\���!?3������񨟋�nb��*�@����.
��_A��#�����ъ�^j��٨�eV�ߴ�aZ�!��j�im���ccmt#��2�������dH��0A���6%6�h�R�4�>JWQ�&�Xn&��� ���I���6_�o����*���xq�l����I�y���űu��k��*��*��dӬ� aF�%c9YiVp�Fh�Ѫ����($���~aJҖ�c�on�xԢ�jd��0r��~8�R�������~����?�S�� ���w�2k)�bęF�� L�����Z���W�@��u+Q�^^	�L��+-��b�	��T7�l7�Ԇm�M�wQ�i�˔�B����$>w����[Cnދ:��%��_���������iN�C�������ȿ�������^������_���߳'U�QT���Oºq��`�a�C�q̱�$�ҵ�~.�bY��230����E)�z`#:�7[B�M���%��Up���as�6�r�Nk#W�r�b��\���G���W�
�W`C%�Z`��+ʗvQ4I�.�Ѩ)��B�`�ڦ�'N��abK�{o�S�C�X�@aN�?A��BmǝFv���9U���M��M�������>��eP��/������UfH��qN�?A���H�.ro[���Q�%��4iT\���
�؎���"��ve��6=F�1�.�c���r�y����)Q�Q�pϰ�!JC��(�~)�f�N_Ahǃ��6�
`�iX�'t=`r��9��'�v��;b}Ne2��0=�+ه=��nK�Wᡔ3�wQ�
X���TW�W�f`s�ϖ�z�����D�������u0�o�
��h �׮�n�B�����@%5�kܐ���ր���,�3�I^+R�?��>l80{+�έy-�/H�f�U_A���E�6\R�H��ږD����*
i�gj"_A���#��|�ͣՙ����?^�yQ�t� �	��,�T�{��8���p�O7I�$]<!;�<@��^��{Na*�z��j�2wJE��Kⱽ�� a��r�6d�    ���|��_Q�z%폔ц8�<@�^�Kǵ!�	����D��p;Y���d��{!�4�~g�@�P�f�sh�C0"�в[�y/�t����	��7g�ll�M;��C_Q�t%�E.�{y�0�P��76%�,�zǞK�� 
�w��¸$�y��q���[�:��>������?[�m�ͽ�>C�i[=2֎�~�����j�1��� ��J���8�f�
�T֊��yr�ެ�+�r��0�[�C��Bkm��i�g�$��0�)g���7ƀ��{�rG�/Z��ux�~Z?=@����v�L���qp�Etw������F���˸{�0�X���~�oݢP~ C"�����~��kBzb9kZ�E_�'�O�P�����m�n��l��xw8�hQ_AW�c�s���&q#��[���G�Jl�������;�I��	B�t.|�D��g��@冀J^6������bs�0���HG6eXQ@·[��5���(ڝH�8g$<A�F��td�J��p�� �ؖ� �EA&�|�|�0$��S�G6^�T�.�D�K�_E�#X�ګt��B؀�Z�y87�[���TۚDѻ(���X�
°�͂�69@�B��Z)���h%ڋ��L���~�ϐ�ee����l� 	Rc�-2w�JO��:��6��بxMC���p�_�?ެ@<�Y�&���|�W���]y��q�Z_L.�F���5+��cV�m䖿`T�f���aKb>��7��;���m�Y���+�i�]��94S��_A�~� �#�AQ=̭x�oWt���B���bL�W���}>��\@���u|o�n��u�/ɞ�_�
Bؠ��+��ڤԶ���H˂��(A���w��K�H�xj���2zL��p�~fV�+���z�g�C�pt���������.Q��;:�aX�U����'��XNMw8���B� �=a��@0E~�V��Y����6���,�Π��ុ]� L�l��;������)�!�.�]c͹�<�W��\����𠠙ڹv/��b��M�7F7U�
�ZU����H`���Lѭ��&��t��"�t���{�Ħľ��#v��̇�(I���is�	�j�k�7g�נU�ݠ�k��k� �㜋Z�L3	�� ��r�������,Kq�����n����PK���!L�o�ڛO��*��zn���mE k%���N4��� ��Yd����^�����}�.J�h�����+SY/jZ���kW��#݆�{qչ�^�+3¤]�a�|g�=�Uo�h�:��Z�EM�b�P��pf"�+�ŷ�:��n���� z�h���.�m4%�k3&�<5���Ѿ��HuZ������� Yº��hCJ�7��>�����p�ؔ!t���ζVt輋����g C.�4��.7�����pH�a��Ī�t�Ē8���� ap�ĮT6�^N���?o�,ٍc	>~E��v#	� �kz̪��e�kl��ה:3UeRf�����r�v�~zp$Y(t��%� �A�O�IZ�˜Ω�b�e�ϑyF0\���G6.��!Kmy�$��$>\ DM�^!�̢���M�saք�vEߓ�(t��\r���|��^@L���C�z�͘܊��t��r�ffw��/�Ҟ4�lJne�k"�v�K⴫(ދ�3<o�wyذ�̸?,��"���Q]�Uô7��X���v�B�� |�M�VbN
��o�;s%�3o?�A�9T=��q�>U5�o�8	���^����Q��0Ց������6e�w��-����$�vE<%7����f��@؄�~.��B��L�b��.���. �ofR�;ayx�6<j�A�AӟK"��(vf����y3��rG�ST���-����_���E�$�uB=��09t�K"�7�]��С�1��Eq�� ;O1L�w&G'�g��l{��`Gt�H}-��L��B� Z�����)em�4�PJC� ���S�h"\�	��B�t���=�$�U�D:��V�t|�"��T1��0#&h|=776%%97�2�'�o:��K"g���6݃*��gx¥�����(xA8�}~aF�1�/վwZ��ӛ �}�_��E��~���7�pAHl�:���[Y�4����$(^�L�
�t\��mD������^�U��xA�\M��� �MB�7���gM��@�mT*�.;5�(�uB�Glft�{�|�6��G���\V�$~�/Q7Lܧ��0Z�f�ΆoAvqh~Ӆ����{]=�׿��Z����ǯ����/'Bb$�����4��}�u����i�a�;l���.��}j���(%��8���p���?���w����䘾�k���U��v�
����O�����+�9w�}�6h��Խk ���ֺ�pq1��w�h��m��ٌ�r���C#,�&WQtp<���-oL��t ˉ�|��:bXq�{�$i�	��L��W3;�����t�mi@W�_+�\�E�-�6@�_�AǾ���S���A�hHL�XL׊�]��Q��̳�wƵ2Z�{����6�y�YGO��m|���������	�x��ȷ�d׵kgkb�Svc����_��nf��;�F�wZ�ْ3Wv~�Y��((���	�̍�;�B!���^��m�`Ɋ��V�	j*|
3�`oLJ���ǖ.E������h�v��%�$q�<�#�)�"Q;� +�l�2z�Q���H*J�r�z�A0M�ؒ�tf,�V����K*@���')nd�����Xu{�fe�Ib�#ZN��^0��.� L5a����Qū�q�*��wwQ ]"�0sc�g)!�?���b"𰾐_p�u�u<�Yf���A�I��j�S9����(����x�V^G.��W� �:z�3�w6���z�js�F;m8!��0�x��A��^[+�T7�P ���]c7í}�����ڜ!L�>�L�ͦ�M���9�bW��E������\��!�餫��ܫ@<J,P,B����J��(�w�f.��AGb�%�>�)�߄shlYun �����Ҝ�Kz�U��(�z�"`Z	��&q�p�&��D�"��qeR�x&q��]���/�<\�;�Y��a��.&�ǵq�D�iF��RŜ�c�@�`γ9C�lK�@ǵa�Рr�u�CY�	�4MA��n���4J��3�6�&�Y}f�hd�����Ek�&���*Y����ܒݪ&=�e�}�-�U�1�03a����YgD*��-#�k�.6�b�m�6�u<������%�#���"8�m����*J�D��)�Y��a��kv��&נ]y|�M����7wQK�%6`�ܜ!L�)�X���muX�V�vI뙫(Q�_�G?����a�5����w:p�k}�b~�U�v�>٩W�� ̈إ�a!"F'��!��9���n)b��7O&�I����~V�n�K���M������������_��	H4��?�o�������b��y�߾���Q��N2~�0\F����,\�,�
�a���JD�^eh��Y2'cc�ǉ��{]b"L�ëw�p����ٽ���!$N�#��0]Tkڙ���m-nHJO�	�}Q�)Yg/�NM�za�wy!=Y����oگ k~���PQ@U�+����[#�N܉|��N�R�OjaEa�b����C��$�[��+����{�(d� 8b�� ��ɢ�yq���M(���&jo�~`#'E{���ՙ_??f8�#ۉ�o!LD�3+�{�P�B����w���k�����_��_�����߾�������w���>�7,����.\�sa�!�[3zt�5s#C�U4L��@w��A��s���MTξ�6��ju&|�q�4\����>Y�M��c�����;�¥o�2��}k�����xa�"Oh�wƢ�ud{d����.]*2�ߢ�E��Lv�-��"4��o6K���D�۴ {�E��8��#���#0��B6}��ZL�/��EA���< �Ϙ�����@��Nm����/`������    �.����Ȇ�?k)�	s���g��D8QS�,D��6��krM۟�N�[�p����6�$G�s=�)��z�ֱ�]�Mڇ@����;�!ljO#�vٺy	V�/�a��z�m����a��CȜtZD�)�ݥ
��Ͽ�z�"!�0���-�V*�A��6�[�zK����4ҋ]�4s���u�؟���[Ԉ5IL�dF��cX<�~aB�H�G-�#i�0jM�k^���(J��&�쿅0�	P騡�&:B��v�l��D��[�"���M����y�=��u�}�����]_U�xk61�~܄@Q�H�]�����ZQ��k�T��Y�~�'Z{��69��G6T�Z9�5�LcA3�(�kW���< LhS_��;�@v�#玁1/���{9�:�v��B�d��V�}�M(�H4�-6���oY��p��#���Z.�����ޱ;��W\<D�9��k}!li����|N��(�G��5~�U�`&O�¨����qm�*��2�Hd���%^��ٜ���iVC���"�G�j��kk,�]��E�t��P(�{<7E�E��������z��?�^Ԋ/0�B�g�F��}Ů�d[Y��E	f�G�Bj��v^4� ȩ{���hJ6�`'����6  g6�i�20!�ї�]o��Bf�*��AA��em#�&׶��#���:��a��_a�4hbo\��@�b~��ˑ&�b�B�N���Oֳ����-�~����6��a�[��ۛ���D�[�<ܰ��c4^����׿�ο������֒N� �����������ۧ.%�ɑ8M�	5'fd��0�y��ؽ�{-m�u l���ZM�{�� 3?�7� L��5"ٔf����cKKZ���B��O�Ҿ�0����5��Wj���b�7�J�c�����a��e�k|w�o��M/9��aAO�(��!���é����N�q�&�1H�ح�w�v���b\�\D�!
�X�l8^��u��hM�.Jdo'����6�C��� �6��d�N+:^~��E|�6a3
$���66���S�h�����M
�G;�=�@��r�ǝV��-B���%f]�&]�;���I��7�|����GCN�b[0�!
m_23�-�ɾ���qm�(V""j�r�2��Zӻ�u��i+o!�O�D����&.��:�]vnvQ��V8w��!�3Z��ĦV�{Gߨt}�z�SY;�������~�"Xwl��H�|����#��r��ב��Ϫ����Ԓ�Y�gSK}�xd�VH�}Q�k���(pIl�dF�B�d'���Q ���
S�qA��C���32�B�:(�n��/���Xj�.�bZ�_�!
�����w¥�6N�I �V�hK�����WI���H�2�bp�����X&�#��Jc-�	�>�GӲv�'��nyؖ���+��%9��{�aCp�s+ l�uن�2�$����Dm9�B��Z��6Q��Nȱ愭���E	xI�N���u�G8逌�n��C���Rr	.s�h����4RG8ښⓗ�a�n���.��M�����az�#���̉�j��Z����vQĈ
s��Ӈ��=�M����Q詉J[q�0����@��6l9h��\�����]���~��B،:�)r�9���Bc�e�.
�u��3��Nِ,ge�T�O�ױ����+u~q>:C�ŵ�N�I��K��8�˼4%^0h+�� ���K�]ܫI�8mt�Qmծ�"&�d����!_J�6Y�������`:˷(�	M�h�#�O�g�V"��97}$�jƊ+��=D��vךxY���QC<�)A�A�V�T-u���'^����>B��|ʧ�a�w�e�c�\�(�j��!MVa�@�o�b��X�	���F�e;ME��QB��Ɇo!�8��^��x'S��ʰ��{�}U<��s!�ib��[�5���Ň�I�B&��ï��"
0��d�����T;��7,����N�7Q@�8�8�i��	����A�C�ߏ��S'G#mZn��D�v؟���������kɿiK��(���g�v��g\������.7k�
�������Pj�d��C��ֈGqj�k.���/��|��ad�am�2��F����	nK�=�m�W�gö����*�o�@��!D�*PUQ$�A����Ag5�]e���*�b�����gZ�l�*�6��tr�g�<A�@�-�sc�JH:J܍�%YX��E�k\�C�'�I�(@<�)�a�Ѣ��U\0|�&
�V? O>�{�6rl򈧵���ѩbJ�p����(��|�2��;����~jb�M'�������8{�����}�0<������c��-��Υ�J�@���E�0��l� ����7��f�5��k��_��n����C��]�%��~$^��6�p�W�I{����,�3����4��Dh�(AE1������($�d'�_ ���B��&i{_
5�Ӻ�E��"��OƓch�6>�J	E��!��i��M��q�T��xY��0��Qi#˩ۺ�KQ�^�EG�����ق�����}mQ���88K�P ;���-��U�ʵe��Nkm4l�����%��������z���p�a�%���{[��*	_(���3�����l�,�Z&��`,�U�f/`i�z� \��1���D��2�K��U��*IB��~�B ��}d���n���V�h�μ�f˫_ �M-���Ƌ�L��<{À�lH|�O��ap�����MF;6 כK^��*����%F������`6��F���c뉛(�U����r�S���� L���ɫi�uhԐ|�eW	*J�;N�O&�(G-�bd��*ֆ=m�������	�����{m��9L�X�e�8"���`�=�'a�)�Mna(!6�v9_�FD!"	�?b�0�p�Z'6��^]ko��l��1Og9� L���#5��K��<�A,ߢ�K$��[� L2��O��I`P�R���i�*�Dw�<�x��	]�JW�Vs�� P��/��-k�L�7y�6�?���j��hP!,�7U�t�(n���?C�h����m�˼y���ݰ����8�d�t���������?+��� R,5-<3:�	'U�@��S/�NVS�OY˾��j[����k��l��a4o�-�m�Gt�KZ0��[1^��l�Hg� G휓����L�g^v/�������'����Vf-�Ȕ�8�k���a���	�Ę}��O ��h\��g(��g���Q���3���r�N�F��E�M�T�_h;=�re7�8C��`X���N+yÒk���+�&^�T��w¦;���H9o��[(+�O�d1�~����p��y�6ŧ͑s���?}����iř�o!i{'-P)��9S^ո�^<a����p �q���krntp��1��r^�ݺ�`������X���Nk�:�b���n�ڈ(t�=����,��im��[ߪ�=��2���*,Z?o�!l�:g�Dik�V�����s�zta�ܜ!�6��Nw��E��ШTZv3����w:�t�0y�"w��Z:8��$Qҍ��4�A��l~��!L��
"�"���Em�D��{��9!�0j�tj�O�u;��0�z0���ʟ%L��gS�>W;�F�y����,[+����_s�6\p����i�]��#��L��Ο�������4�-��F��_��:n#.<5�'f�l��!l�%>�5��C��hVBm��n�:Sպ�z�'3X<N�����-������>�Y�}b������9C�Q<U�U'��x��|�����|ΰo}b��#���;��{�6�� Ӑ��R\���e���n%�a�/!��͝��Di.�\�Ʈd�_�Z�6�gc#Wm��`�l��A>[�����(L�y�0�Jx�뼳A1?��@���e�M�w��O?7|�0��T�5���@�J��7��s��kw�y6g���    V�qm���m!���kY���(1 O6s�0`p�ǵ�y"[�Rw�.��'	&��@��5w{�i�^G�B�ĝ[�H�FG~f�[�1�dl�xjtE��~Q�(t�(�t��a��^�q<7�I�ON�".�EL�f��+����9�/�i��Ѷ��r�.�i�_$��y_�a�cQ\���0�6"Y|���2?���"�&۟�@�V����C��Xdmho��B]vE�6�Y��#�	,z���;M\R�� ��u�lm����Gga�����4���Hа��eY�����N;CQ�Z�u�l��y�	��Ͳ&"�O��ɴ8!�����\�A(�j���1-k
�{�:ki�����e ��Ol���7��B6h/�n�w��Ī6�hk�@���ζ��21{��8m9�&v�p�g��C<��Ұ��D�((a}�4a����y�u�}�r�ʲ��*J�����o��l���I��ⶦ9��d#�ڧ�/"���i?�!l����/l�8W��0Ǯz�׾�������?���h@{nbh��Ņk�m*'�&�@�Gh��6�{��D8\��,���<b�o�� o�����\e�>��B�^C�(���I��������n;�l�e>R
�۰����h)��e��ל!����8�5�¢��]��Ҳ���OKE�k���$���q64_�����z&���;�L�v�!��r��G��"��j[�L:�Z��� �M�źSlècԓ@X*����(:&b�:�a��}-� �[)� vrn�{uE"�����aX�}�Eg�d�A�H^8-\Et�|�	��h��z���b! 6DcY�6�3o�`�����&G�Ƴ~uc��sL�n��݃F�k��!� LC3�S>=j�ȩ��j���a%qJfu��i���t�<eQ6�=���1�|��"�9������)�$=��	4������*ks%F�O�<A�.�r����JՑ������Y�&�E���{	<A��+�r�����t+qtYU�p%rH��OO�#ɦ����^/.�� ^��x x5��F��
<A�B՝��FL�I�d��������X�	��-�һ�<l))A̋��xq���jOf��{��_�@���Y�Ş�*/MD�,e�o<� ���>����P�:��{�y,{E`��E�&�q�@�}Ol��k�D<:u�l����cdq�>`s�6�J�dSj��A[��ەV�@�k���������X��k��;��!D+��U[��S���e���x�0,v��q�� "i}ȇ�*�q��-���!���W�Φg��Qt�uiYeZ��f-�胵9BΡf��&험]i⩵�l��Ks@0	�SO��
o�4�K�˚��$�0ZKv6��!lj�%WF0�4S@�>cY(��b�3�I݉>;����y�2 e��˺V��Y�R���aJͶ�k���Duk�,�@�qY���Z.�ϴ�m�����R<�4gA=�X���E����Ǯ<A`1)e��ᦟmB��CMù����Z.O`�d�����-����;ԃƞ;��D��`�ȗfm��Ѷ�h���nm�U��������5�_�G���߾��?�����I�b�_e��_�˂�S�֋Ġ�CD�NE~�0Y�F�7Y,aK,��ڂ����HDA��⺸8�!���Eo�x`#ʢmM,P�1K�(���N���/�hn=��F�!-��:��&JkZv�
��&+Gc~m��b��tT})�}b��t�ƾ&M��⵺���gm/��Цڎl
���a�9վ���U�t!Y��T��������M���AT\r�,��Eѡ����9C�.�ƇrZ�����a��D��϶$~�0�XQ��ĩo���,��3���5�<�(��(�~����-�~b�(:�0��� ]E�K��O�Rx�0����&�v-��r�Vb���z�}ZJ��/���A#_�TxOV+$����I��R��T?#h�����K`� d��X�u\���4�>A�ȶz`���H�Nҵ�!�����8Q�� _ S��JǵI݋�����r��(�-Kn���B����q� �,k�Ku���ċ���ɱ9B��8G�k؋Xł����s��;'�@�X��
���*�S�z�3=f��������እ�ӹ�����hd3�U�E���Q"��Ǔ/Uy��Mie�E>	`G[���*��=QG�%�/&E��OA�l�F�hP����.���)M6X~�0��FV<�I!�Jӗ���]����.$�dӻ��l,����L�>-�軯k�WQ��A��~�� aDs%�q����ȏ"�g������|�>}�� !lZ�NlPp�X�1H�0V�	����5���X�@<�iI|�;;"�S��;%�?�Ot���GOZ �jm��f��x������U�	�v��
W�\$�x��h�3�em�WgS�|��`J���'�f�t>��)�u^�H�.Q#�i}v�6�h�����)�P�M�-d#f�b�m�aJ�l��WC۠� �'�2�s�Eo'�O�@��|�6&�{��i+z�0��E�T��>�hSj�����h�ۍJ��;�VVr�b�'�ݽ@�h��: �J�po��g�wQtL���v�0Պ�R��p��l��e��D�ᢲ�]p�K�i/�a�>�fO:ટK�X�l�E��(�C�ّ�/fth�v�q_�$Q��VlA-;7�u,���z>!�G�x}2n+��n\�#p�����ۯ�'�Z~����?�_�޿	�t�������)��^�%D��//��8A��xv�ĵ�uR�)a��ο�h���K�����At	 ������?.u��Ϧl5�N��8}�U�&&�ֹM�O'��3/ӎ���e��0�!D�'(1���Dq�4j��.��q�Y�:�c�r�!�͈�6��Ɔ���Q�-c�y����(Q_�����T��qm�V_v������^wQD�l�aįk���a���#g�[]�^�*
_��4�������!�6A��4�\�2�"�m��1Y�a��,�+��ч���B^5fw5, ����&C��6ex��h��X�]�@�.J�a���´$fŕ#&���"����ה��D�倣8��� �M����Ƞ#O��c�	[[uC%hެ�~�0]\;���G-�ek��u�@R�c��`�"�	�t�X��H���W��Ǣf�WQ�b)�t-���i��lJ�W��J���e�?bs�0]'��k��׉�-��kuȹZ�6���)��� L�[���F{K}�k�`Ѩ�]Q����{�'aӹ8�i������)x��A����3O�������F��į1VQ�ݮ�oSQ�N����� �ّ�q���GM=�f�ݚ�(qO�N{6Of `:Z���D��.��Ve�ӗ����a�}V�A�
�R��nD^vn�����?OF��oM�ﾀ�5�+�4��²s�_J��+�� ��`�O٬��P�հ87�F�,хv����U���xc��[�V_�օk�}�'ks�0�:&�>lJ���^�#N"�U5n*
]���N��x�0�So �pɚ�qb�������E��h�	XG{k<{g��φ+�:|�/g]�������/�������W"��������/_ƿ�k�{����ܨ��]����3����[ݎ�mЊ�]�Y�����C�NW�<A�5r>�2���x��&�%+kɘ}�����-������o���%�޿$���~��_�����ap?{5Q��~>����8������=Y���{K'��iLT�i��������D5^+�����)��h�s_�/��Z�C����kp�d�Ľ���1Q_=��pоZ�y@͔p�fR�l"4�:�Ge9�J6p�N��dmZ�t�ȑ�8K����[�
�}d�9=�!��}�U�GO#��x̃���,���N���?A�Lj�c<��ƛ+;��쥃��m�j��v�0So%uZ�Q���$������    ��N��[�y6GaSŌ��sHc�N�Zg��s��|��"�'SpK�h=�����bnhQ[��(tII>��7��Fg��&�� ��H�r���8G4]�uF0��^õ讟G��N�:%��&X$�0N49L�Bش�s�' �rf��U���"ۙ&��@��Pɇ�~n��^��kZӐg%���a7/ƍD�ֲ�nl���<2²�Y�N�Kǃ%;����c�tdSئ��M=�1`٫g�/v�D�j�'a�=��n��F�\)��hbmV��;H1L�y|�01�B>�aWtHy�č�h���vѐY�����a�2��v��$�Q�JJqYv�*
s�y�ab���?�Mn~l�Ucfo���؋(�.��l<�aX����lz)Z���ɹ�hH����� ���D7QL�;鴘������lm�:��x:)pF.��]�Q�ר#Ԃ-�e�`/Q�N/�? s�0e���٤XxӚ�6*��Y�@����t�!ljN|���kS5+JڍgP�Z(_Ea-X����O�ځâ=�Mj��# ��xٻ�{������4OF]˦��sS�agVtuY�PQ��䞿Ky�0�s*�mg��6/ڡ� ��U�b*
Hh';�>#���өi{�~���u���E�;a6R{���6�N��6��к7�-�l��.�4�����)��z<5�!�`�LkӮ��Dq��O��<A��O '�g�RBr�+��r�(,�hl����r~�/'������>ّ�$��0�?��TJ���C���8g���׺��H��%��hrl�����_'��%-���:j4��7
�L�!���\JOV�F���볐����^.O&�h��ߴ3�����(R��yϬOXH�$O�3�aЧ	��076e�$��C���z^������#?�6�	B�d�|}���S��wTS��g�e1g��N{�N+�3���u��Ȋlcx95�Dڷ�q����{n������$�7~��B���'W�խd��ĳ��'��$�����׭Ca�M���~�����1���M�@���/v��}
_����U���&�w��rl&�ν@�n��=Y��A�G�-]�t�hʄ�'Ue�	��c�!l�p}�~c�-�M|#WGZ������3�'�]ϵ �tW�\��B+��|�(xѐm:�a�����ĦT-��c��*�PQ�Ņ��!��騳1�xn
j���d]�e��S[!��'a#�C�N������Ol��-#�J�_E��0���O�G1^%�v�v�T�K�H�RY:k�]8�g��N;B�@��t;�[1���eUq,~����V��o�l���aP��}_�0]E���&ӕ�g���F��B͎d���5.+��k�Zp�R� L�yk{<5�I�Ԋ�/k��7m���}F.�'w�5)����m�:ao)�����9@�>|x���EY�`*x�uU�TD���.Lm~F0�;��'-�����li�6CQ�$f�2G3 ,u�Og&h�u���8J]��Pt����<B��tp�q��7$B:�ۅ>��B����������TY�(�s�6��k�����A���V�X�:ԣ�T2㲦�WIH���'Of���ϒwn�as��:��+��FO��mO¦�^F<� q��g�1Sk�j4%b�@�}9�մ��|;��B��lct6-+ovu�u3�.���Iֺk�ѝM!Mb9�_r���v!*��^�γ.��H<	��x��s��-9�a�e�_��/.E�>1O�f�'w\�\���5�Ͱ�Y�U�� �O�� a��A�G6����oصs�:6�^����a$���ļXNB-RH����*
R����!�M�^�@�lZ�Vщ��Ͷ������L_ =A�n�v98��i���%܁�We7U��!1լ�y�06X/GÞt������|IqUa��b�$^��� ��,���8 ��QD?D�Hu��@ޥ��'cc���v�:u�0���ҝ�f<��(�	Bش�o��lt�Z��MGH��V�4q}-$?��|�0�|�ڶ�s���upF�kU�FE�����>A��)�O�3�^Z���u���E�Z�ٲ�'a��a=��Nb��#d�l��U�:��#6cK,Þ�MJboza͡���fO_E�����|���I�݊(:��-�����eU��U}���� ���E*G-PJH[PߧP��s!�x	���,�a�C��������H�^�ݗ�a9���#���R8��l���e������<���(.��`,�HTV�kq����WIı������KSNl\�-^�l���h"��%t�6Gc�����x@�W"e�i��э�%�A}�!�M����(ɷ�-2���+ٸK����A�t�<O�'�b>�:_05}4����'HOF6���t�5��>>�r����@���?�m�S������:n��(��kɫ�u���8MRβ9C�N�F>�)�=��_�rSEI�����??A����#->�#Ȭ �V��(n��a�A�1��*u��l/U���좰k��<CU�"3l��>��g!�t���K��&؀6\� �#�n��.�В-���yI�4u|�0�Y(��Sj=lH��>x����}��`�O� �M"'����߉Ǚcʸ��{}OJ0�I;C� 1f��@�l�:0O~�:6 �<��ݚ3���I�����ylc��˞T�(xq���v@0��4�s�qX�(<kY�B}�Z����|B.�w:q)��M|�eDZ�."IJa>QsB0��n�^�{�5502��h�a/*	^�K��gF������m��$�^6�XE	�G(}�2�&b�4�3�6�l�ŭ�k�/@����&ȱ�c�&��1tmòl���.6r�~��a� �x�8m��K��6��bO}��;�3�)�%vw\Q$>��7E&��sZy!�L�o>A�[�Nu5�9	mX[�8���jvQX��9!hC?�֞����|��9VoWr�<��+�3�)A����+R����2�y%�����O�D,��cTS�l\r�>:mκ��sK�Nzy�65I�|������Qq�;,�ϻ(�z��F;C�R��O�̆o
1b�Du�]��aT��Nw�x�00�s�����X�M(�`�V{[�o���H`�U�B�h.�$�}ӆ((8�, ������	�o���|`�gк�_�����,]����g�����X'0�
Ro��J.x�1M?�:#��F�� ��3 ��D����%]'�`���=C�b�G\�УX�!Q��-d����[�aPTr��W��ɩ�Y�V*�u×U��u�;}�� aCi�V��).��\��$}��Ԥ���-=� ��R��#���챭�O.'o��j����U�|��!>��l�P�Mk��Za5j�S�s��S��p�@~@�M�dǰ���^E�J��*�#nK+�Z��o�f0��M�0���6s*Z����/&��=vb��!wj��H5"�4�X�?~����_���f�D+�Bg��G�?���?�/�+�������[�}DK�$�&ݠgci���9���0�X��4g�>}\��̽3~��N�%r`��-b��M�}�5A��B{g��x�7�+��?{�p��y�M���C��%	ޛ(��ONz�����}>�cm�&D����qК	*
�4n�����Zܰ�C�B͌��zq�V�Mpz�,V=���x�6:Q��l����Q@��5N�C�([a�M�+�*x���X�Z��uŸf��M���e|�� !l���яZ |�2yM0�,K��M�����X~�0]�jʡ�u���+�X\�57Q��\�+��IY���aF�Zi�Cx�|]eo��`�lVC?AW3�M��<�nq�h`��zNv�Nۯ�)���,�3�q�_���d��b�j��-����.AK�B�W�:�����;�"���QLl�k���D!P`璼���S�ێ<�ؠ�x*��jHK��Da���+�y�0SsvO���$δ%H�{�nI�}�e��ѹ9    Bl˞�Q��p}����Y�]ƀ��#��4F8�M��m�T�	b%�i�r%�E�s���
a<�o��N͏�&��
���h�K.�o��`�ˑW�sv9�֦�B����k���Dዷ�s-_!�/����ڀ�KK���b=�$G�$�+>��!8���ȑ��=���\)�(��M���B�q`��zj7�<��.�v��}i/��u~�0����?j�lS�F�����2�{�����F.�yvG.�D��X��d�C�������چ�d9V1�d��
-�"�5b��9�3�A�b���Hݶm=���ր_�xnP�+�	���L��6�`�Ħîi������<q���+�Ѧ����?�O�e �h�yMI���͓���;��lЦ|���mnR&.�e;�*��7mk��&�x�;	��MːF�֗i�(��
�^!�M�p�jx���yJ��k�}�Ŀ�����F\{�pXk5�~WR]uۡ�x-��@� \JO�� 6;J�P��5s��"�=�z�0LV�Gké��F)�%�k�2�A�n� ��p�6B%�Sd�/(`��*dqYd��B�&[��Ba%d��ID䄝ښ��WQP{�y���
ab���4�>&�V�*��$��nM)�Ӣ �#��d~��ph95�9lR6r�G��<�UQ�.�ٹ�y/rj�o{k�o.�������&Z`��J��y3N6/&i����p�:g{�������8X!LZ��Zb���� ��	��-�)�QQ�VK����i�B�Z,��)	�Ma��+-�����s��cs�0ث˹���ގ����"�lh��5O���Ţ����#�Zl�Hc+ed�L�]�xт��A��&�����&i�+G�Q��5��*J�	���Ej/&����[�o6>�w�};6�;˚�.��t!;9Y���Z�����V/���7.�*-�^�qE87��B؈܀|`S��ѐ��0��<���`��������n=��Kӑ�l��?��ZT������r�?paM�����k��^%�t�@8��^ ��6�;�v?5V�YW�>Nx�_#�8}* �<N��/F�~�����?9k�tOXP�#��6�C�����$�'�2氿�z�I����},�xi�(A���ɚ�3|�����D}��<'�,.�*6�HI�b��@�@vAvV��f���[�k+��x"����D@;ݼ@�;s�G6z��1e�KE��"6g~�o����[�h����$N��թ��eQ�0�@I+���vn>�+�٧]��~��G���6Ƒr-k�h����k'�)2���
�*[t�6�Uy[��b���g�G�-���/����{��u�$q$Z �}�ܗů�����Kַ�K�J�C�q��o�_��g��T�I/��xȓ�����aWC�p0F�y���ut)�ʊ���_!��	K6�+���N!�]gi��B����Ɋ�#�.���M�$����57p�}�E	�1O�'�+:���f�VG�j!¢v87Q��u��d����a��}p������2@Xc]Q1����f��B��+g����۩�Dth:fnQ�~�� B}h2�4/&�8��l���M"]mlk���((��H2wj^ �M����� y��j[da����]��Z{�0Q\��?�a��6��]B��&�sE���&���Q����m�JV���W����l���
�M�(�?�aˢ�Fq���˚��7Q��} ����=Y�)����X�J�b&+����aE�� 禺�B
xأ��j#�� .ں���.J:W�}����ո?��f�A���-�)��/{��i��$�'����&f�����ծ^E�>���ɽB���:���2��Y䇻��E��vQ/���N{�0�
K'6�T���c,[��"�f���/��k#�G�
X|6����6��O� L�`}���HxPD�j��5>t��fq�������i���g�p�-��>���e;��.�r���@��Ix��q�s��v�������G���؆��v�0��>_6e��n)��59�]�4b�}��a�)�&n����:p��_5i���ss�0bV0��k�[n7��&��P������8������x`#�3J���Mh/���E�kg�i��	��(6�4�}mH�*�	z,�F`�Mh���`A�^G~��"lz���_SWE� �pK�&k�^ ��b�5����\��a�#۶��{E��ټ��	b;3g`����C��;\��������d�]��@	nz������IR��J�)��:����e E��e�/F��������X��G�ކ_��FD�������es�0{�Jx`�U� ��iكa͹�E�b���i/&���Ƨ�!�=i@rcquMD ��4���d��W#� �jo���@oF�HdK�ې5�[�;���"1p�|��!lBd�Gk6��еRj��"�v.^k~���I�b�����&����8hV~ź������Z��yN��@�F��M�[�T֗�ږ}p�b>�Dk����L�^ �Mk99>�IE~ǥ� �rX����=M��<#��E���\B��4�s%�E�گ��1�d�����A{����݂R��V�ta7�}v�0�[�)���u	ش�Z�U:@D	:_M7�<�#���Ol8��)D#�Z��(�m�v���~�q<7\k�\0�(�-�q����xqz�4��a�X���:I�U�qF޴'L툜׼��מ�\�ǹ"�WaS\���TE���<�Q����Q"hK���< �M>Ǥ����@��K� B�#.�i7QT����Jy�6�MN�o��ϓ�r�-��p�x*�y�0∱/{�cm�غ(  ��%��UOk!�͞}�6w%��&�o���54rn1�D��o_!�c�س���7K.	���(�.~�=�+�)M�����"�m���7�ܠy.q����A��B��D�Ą�~a��ܼ�̃M���rb�CJ���I�(��s��0�J�\�ڇ�<�y[S��?`���.J@���ژd�a��A���l��Ӗ5�bT{�����E	x	���'��-	��XԖ����AB��7WQ�K�I�L'�wznJv�+��N��[�,�u����.�����;�a��,�΍����E�(k�����d�A���� �P�����&'Ԑ�9�k̂���B
3i�7�C���2)�=�Dz�~�M�U���Ć�g&較0�U�5�l��cN��[,!K� -��"�NW�~�]�;a�km��4
��Jk���W��>��!��N�� LB����8�=��$�fQ�I/���(z����\J�k�a|b)�k�ol�`��D��Xtn�^�(�D���[�w&C���QO��j#�b��	��5�3����p��dv���\\���ݹ�@$~ ������K���Sg^[������ǮL,ۍ�5�$�JD�o�����~j� �D˽��Olhli��S�����λ(>^����;S�Z�V	�G/%����_R��YK��x���i`vv����%6)B�����9wQ�����ya�)�^]�X� 4��
\z�k� %��'���h��#����rX+GK+��wQ�L�a���zaFl�Y{�i�"6�e��b6�]	=y��iOfPt��f��=W\�Z�U�C�J�ib?"ř��;c������~:7��� J�	yϻ(��V��k���#�t�6�~=Q�9��r���f�$X}�0{j� ��G�cϢ�ٔ1t�vM~ȷqZ�m^E	�c��6_ �K���-kS�o�˵��J��\_tλY��a\��5�G6���`Ĕ]��� �F�{37j� L�!#�:�1�1�T���b��v������K��;�	�Tv���<P+��x��W:��B��I\x7�����-��=���Jsv�c\�K�E�X�4S��´H�H̯l��׭��A�����u�s�"�	�n��A�^n�|�    iA��	�G�p������.Nf�^ L#���=���$�a��i��5;�*����v���;aâ�ܑM�#m���@Ɉe��yE�҄��< L��Y��6yl�����5WQ�^R8$��^ ��������=�-Rf_}Z��X�d\���H�w�FBtx`#���<�@����.JY&3�/��ˑMa76�HPʑ��"
iY���;�aZ"�y�)�X���q��K�����.���H��8���A�H�Y�j(� @��4�2��JBU���{��>���>i�`"����� ��6e6�ǭNRF�h��B�H�?�m���6�gWBq�*ϧ)�L�f��nN���Ol���@, � 6��>M����~-��� \Jw�x}5�C��-�Li���eI���{�#?���&G�-H-U��s�4E/�,������5W#����{
= _M��m�����Y�����������_���Zp}����������������׿����_����d��i��iO�#����� p�|�{]��I\J�Jȅm9���I��e6��ѣ��K{@�3d��"�e������6ҭ�d�A���y�Sܗ�`�6%qI��� ��%-��sI-�2C�먆�����U)m��OSt�%�����cMl8��"�G��J����NX#�Z���09V���)��Q�ż��V���/�l�!�,Kp�ε��K�_�jI���NS���=����~@�R���Ŧ�;#��N�N;��M�����;3������b�كl7U���㎹9/S@��R����-�5\l�W8@h�a[ȼ+z>MI�H��a�쳜�=�ʁZ;r��C��4%ZMK��d�L�� ��ľ�<_��'$A�1y�2ŧ�����? �M�y��]l�1�c���5\λNC��P�K�� L&*����+����J�vLkS���.�!��.��~@�"_�yw�aL�K�j�/@^������5/�a�Nh��̌��!���j'6����=M�Xe����? �-�A�O�+z�|�0P���=�j��Xܫ��k^������bg6V�� �YI9ܞ��ӔhN~�vum~@��ϓ��x4UU����tK?MqR8��)�!l�|�fǋ���\�I��T�]�D	qէ��06{[��kC� A�%3��=}_OSH�8iE���@V�f6�xh��ŋ�qO}ç���O��b��a���R���&K�9���l:GT��spd�+"~7&��Bw���[m�.іQ%�Ņ�I�	!�U7&��&,s�����[r%a����� Z�`.��w�{���W��J&�S,��\weib
���u�;}75���ņ��8}C-uZ��=�)`UH�E���"�9�O5�.6�%�n%�1Q��X2���"@ra�)�G�殮������l�����:�
���;�E[b�a� ��T�h�=Oa<�p<�u��-'�:+
�Y���f���I�=_O��TG�Wv#�S�^�h����;���Z�mm,�\�F�1���rb�4E���8��~Bl��6�$��Ҽ�D�	v���|K��'���jm�앋MF�A��q ���-������e,/��pQ���i�%vz���;fPO�Hx�k]Ɵ����t�7�\�w����"_[���x�[l^�@0���B�=@��Hy�I��ӗ.K�
���C�#���o\�js%D�{���=�Kko�>!̨�t������?YrP[N�����#0�7lfc�~n��/��]�U f)�����%xeP���@)��mN{iC�]�hS���-��Z���r�E=�O����S�T������J!n9ESt6�>�uqe����5Tȧ��M%8l	�`/u�P�2%I�s�t$��`Rbr�W��YI��e!�C�i�:�G�f���O�m�aU}(ګ���I>SIDuy�<P1�u��8#��5�B���A��J]�\�m�C�rj��mb��1.��2��B���̦�tx����j���eJpH�>��T�����7�:H�T�ܧ�)�SA�@ֲ��`8ad�͗�EA�J��$}μ�~�?��3N��dEa�´��ibC��#"}.���ip>����=�'�Q���'6���)Z��-�-��j��Fg�k=i��7�������F��ai�q����������̰�[��}3�C>�1|�$x}��k�П��l�se��,A
�}&� �X��p�)g�Ki�0��x���)Ml$��>v5���b����/M���0�:O�韯�)V��x�.%A��&��>ה�>!L��y�;�[���=}Ŕ�6�vJ���#��=@��b���mm�@չ��6R����x����œ��*�V��F�Ɂe�8y��Ce�iJҡ�(�����OS���>�4���GT]lWd��bC��`e��ΡW�/l��NkR��bM�r�q�t�%/����B�4���Ԏ:�$ֹRH{ِv`-x�;#�����X	��׼�1��eJ|��[�0�zk=LL(�(x�VR���:rLa���Ha#6̻�:�Crj�wI�6䛓)�%�+�!lh��y�eL툃��ݕ�7�/S�!�:�d�w&X���ymJn:קՑ�|�}C�y�"��v+�wFNp��kSȦPU�P��1_��(�����Bؔ(���A�}��K��7��L�������{ͪۥ��_'i�K��Ȳe��Y���M���X�56&a< �l�G��N��c��ݜ��� n�D���������~N�]�v��6�֜�8���HVjۅ��;S}nVE'6>V��Y@*cSV㿆�{���WټC�ʭJ�V'69Kj��*��m.S@�E��d-���0�!r�4�Im��%��G��Ӽ����s+zJw�'�#}�i�H�V�c���6Tj�)^��Ҭ�;�Q��i���M)����b�9�=O/S�a����t��-?��Ŧ5wH@r���{r���`!���y���=G87�Q�OP��=�˔�#T���aF�\�����B^	�Q�#�����i�S��d����T�������ɪ��C�]\��9�v�$�/u�g}�)|\��}�m����)����y�{��������5_�W���#&�g��	��0�c쮥�M�C���������=#��m�!L+RRG{~7x�rr;2h�$�1��4��X���G�a�ӆ�8�!���ڔ��^���GD+/:� Lϥ:�~b��1��Q(K��?�)*!�Ľ�f? �p1�|�C�vT=OO���u�wQ/���aE���[�8�顯�)�a%��:����S�A�	�{�&tv���l���ٰ��=�]Y�*$K��WS� L���⤉��;��IV��	R/S��[z�~aR���yn{��+��
�m@d���yJ��$��*�7�S�<5�K촐A��Z�l��!y�[�~@rRH�>�y���,)ta�;�)��t�y�`�1*��+��7]UŬ$-m#�k�6��XxOK3�� k���^Y��r�ud�1O�CV������}�a���s��d�� ��\m:�8M��1p�v�������t��:qţ8�[�u�NS�
4 ����IN�>w�U��Goֳ�=��D �h��=s@����q�J8�\��2}��-w'_Ξ*Z'���}�V��� ��n���mzU0�5CHu�{��gIB��w����zg��Ŧ4��~�N0r�=��iJp`'��:��@��۷�ɥ�#�),���8�1c��Z��"�´,��h��\���emĥy��Ҧ�3��^�'���}a�QWY&�8���DVukjq(�ݡa�@��&�.��@)����L �//P�;����l�3�Vy@ˋk�a2���y}��t�aV�1I�9�Z	z���.ƛ�����n.�[_�Tj�cG�T`O.�g�?�6Y��w����!��K�����.��D{������;cI�v������8Pb'[j�l����0<����;a#�2���7    ��dh ���n�˔����O�+_��e�����%ؤ�ޡ\5Y�d�~"g]cz�׺T�l�����1�`��Y��U�B�@w���yɞ{�-r�LmO��4E�9��a3A�����ɔ���}8�i�|XL��h�qN�c�y�e/����ݍ���_�{�ݾ��g�q��*�����t��t,A�-SK/S$�BdZy�u!uZL�;zcӒ�?'X�D��Ԕ�������ɞ�X��5x�.o��d
eO�I�H��Ё�+��w&GI^��Ćhh7J�Q{n�9{:��U��+� �tN�ʼ.�����z�~��)��BZ�佃0m�M�<�y���K�l�O���D�������? Lݩ#�ˊ��g%u�P�]�g�b��x��alO졜�暈G��J�|��g�`�x2io�Z���0�ee����l�;��i���A�]l@��(R\<��6ѵg�]7�@�>����>NV�s=ГB0�UiFG�J1�'69{�QF���y�/S���4���H���nf�@�tD�m-�����X��b5�al���t���-B�wqǖx���L�`I����S��ņ�����YC�[N�ՔS�(��Wԟ� `i�g���&�����-�Sٓ�}�B��D�2��¨�0�S��bS��]ܹHvO�)*�x�M�'��y������~�a�9T��od�C-	q-���0�\T������?e��P�r3���SRX
�U6�F�\rK�ڔ���z��#��n�)t��?�;��`/yT�=t��yTDm�q>���H�HJ�e��a��&��C�ה���O������w��r���k>!�M�T4���p	^2���6��e���+6/a�Z;g�}��w��E�%e{n�_�� ��j�	a��P����PptL��μ���˔��`��� L�*���;�tn��+9	�������n:>!L�ncϳ���A�c�\��3�eJzH.bWt�� L�=֌��P��D�Rl�iS}��8S��_��K?�JO>MgE�.~{����VUS�T]X�|��0#���s�i�e��F�6Gy�O;Gx+��Z�!l����&��w%��=��tگؼ ��ai����Sa�lC�ݖ3�/S��z���Y�	B���
��3#�v�����i�l��<�B��t*�+M��~=��iO�:�@RF'{~�7��t|�	���y-Eg�$��66^��U�`-M��`j]�&.lg�p>��םjIT) ����}5��Yt��,���ɪ$_ۢ��e
=b �k_�����?��#�Օ� ��^�/SX���5m�O�E$*����-��;la���	��磎��lye���	�6�0�)�J��T�ڡ�>�$0�B켃0�ʇ~������Bu�ı��|����q�S�B��ľ�kC���H,�Bk}C=�����wsa���zNW��i\��qR����П�2�SX9㸃0m�P�(}��1T�PB�;�����ұ��p:��ͣ�gtx):!�aC�9Y�$Yy}a�6@cgW�ɲPJ�X{	u��D}ʤb��\=��;�rl��Ć=�T�T����i�~�B���V�(�A��=�P�
tW50�YE#��1���:� �����A�F��ԁ���l��Xt
}���dJJ��}!l��`�Ʀ��Y�6����k�)xX9���6�iw��N���T�aG��d
'\I�A0Rt<�v��H��,̐��w�^�x�p���L�;�6�^L+�H����Q��nΗ)���5�������F
4���a�҆��e
>lHa����t��l����hb	��u ��U�dJt�~��a:�J.�7��� �٘�i����q��fa��8�g��.���m�� �q!弃0=5���z��@�mk�di�)���ԝwFgڲ�eo��#�Tאj��1��1z+�� L�~�8{hn���#���&����f�6E*3���L�[1�4�� ���eJzp�+�(7��`	o�F_�W]��zG��˒��q�R��0#4��r4`�`%��}�L��4IE����fD�9G;��:�P�3U��7��ȏ-��0���xz�������Qv�v��D��V�� �M�ё��HMS���1
�-*v�)d�]��|a�kG��>��z�Z�$P|hV|w�[�8{���ii�}B&�g�ذu�H�X|t�C��2ū�&q\�i���DG�i^(:ݢU�[;�d�iE���d����+�J�fA�[j�%:�!�
���.���}���ԅ��1��e
>�|�k�'�d5��J<�_J<�:Y���3츷��xRS,1�(��A�� g6���6X"v�n��|��*<����;�;��&��;ͧ���z��T�"�x��9�
!�̹��0�9竾��ao���	����x�9�,�ƚ��0%��$%���zz��5���i�����K��'�Qh�i^��-H��ss.���L���_R{��0�X��u|�]g(4/x<��N���z�K{G0R/�q����*
]�� �XҴ�\X��O���8�J��ɉ�z��%�IRU�gNi�o�D�]U�z�n�[�������k�>0xJ�����)���dU}z��;�=5�)��XH^�K��NS�&X�+�wF*�=��4����������C�܊���	V���絡jY�oe枛ۡ�v��!�h���ɭV_9�kS{=*�Z�
�lb#�/��J�EK�����0bk}^�����AR򞓴�)�?����7��uD��P&_o�	�z ���frn�}�{�JG���{�;���C �G�A)����2E9���A��Q��3������٢�T��Q�S���ͼC�"~�����bSj�G.������)������aJ9��Ǿ���T�מ*��6���CuWf+�A��(���̆�̱S*>��{�NS�}�ðx��aFM������xԣc�a�\#�ɞ�q[�A8����;c����q^��G�F-�������.�	}B�Fj-��d}�-�NIѧZ��)������;#	Z��l8u=���6#� {���Q;*=#��n�OSZo���&7�H�NT�k����iJ��)��L����&��޾�L�uNGv5�i�N�ڮ����N�O�*i9���K�7������H:Ga��7I��ټC�^b��,OlJ�� K��Zݗ��5�r�nE'��8W��A�<�D��9ϻ2�g��N���	��<�% ��g�G��m.S�}He�/v�a\	-��M	6Ib'�N��-=ij
�� 祎_;M��0�2��f�՚�F����l��2&"�2��¤.����dqG-�6�ַSoOS���
Q��B��Ws;{h�7*I�Ӆ�./ �H�(��O�a�=j�Ӽ�GI=�3�/T.S$X�X���;#�C�~f|�ږн���v��l��-�
}B����vZ�$A'�Тd=��41%�C�_�|.��d
����x#��(�v��:O~�w���3㊲��ɥ���=s�CvZ�5�xiޕـ?GSH���)ra���0�M�R�E�� o�7p���)���).y.�m������r(y�}l�N�܊6��iu����89��c�����l��Z��'�	bm��\��Ŧ"AI�6������=òx�0!S����M��������g�t��(IɊ���I�;���_��|FT(�L\�J��uhm�^��U6�FR��y���2Ijs�1�u�ڠT�Oչe/�a���Ҽ69b}*����w�C��6���%�;��E{j�{�SSR���쾬����`�W��a)�#=�΋M�&;�WW�6�7����1�����0{�}�!I���=8���nd����r��ar��R������y�U�nOw�iJ�28��@HE�s�:�a��xh��Յ���S�&���%�g��F�q4����ݦ�J%��lw�׼L��wl�7l&�o�vm��4�    �a�u����9}B�6���Bz���|ݰ�_Rq-y��چ:����N�����;�7����F�)H��:��1���eJ|D}�����AH����ٷ/6T�M.�K��m�iOS�M/_�ʣ��6�:oo^\�KG��!��+n�/K���J���	�Z���x�ju��|-v�퍘�M6��8���s�A��*)ub�]I��sM�v��/9�J�yaz��VP0��a�z�鲗���ؙ�J�tp@ZZ�3\�>[;q!kA?�\{9۠7r��cZQH��0@~p=�S�5�6&�[��36Ly�PS�y5n�WΠ� T�ǳ;}����`(��=�������LV�9� L*Tl׾A��T5�܎V�3r�c���Ӕ`5���1�(s�A�&�%��A��0�p ��#x����OS��)UcZ�8� L���Pϵq_lF
G-W����4�k��J���I�*��LlJ�t8�Y�oi�������VΠ� 
1�ٚvZ��T�2���P��#9��������������_�L^�<���o���_������}�������JjJ뗺
o� �"Mvކ(I�>0��ܴp�Ut�m\�qaSG4o�&]+�IF��ǆ/S�N]�yaF'߇�C~��% �����'�9M��E3ڥ���T�������.�I�[�g�)��F�o-[�G���~@��K�0�̆�N6��3me�7�H+��w&�<|��N���pR�D��h�I$a��A:���I�.�'.�,��
�[8m�.�H��A�X�����9�4J%Y�~�ʀδ���;��|
\Qy���v�"�[�U��@����z�)����>�͒�4��aA���8*H4���i�|�	�ۅ��;cG(����&6T ����ˆ��2%�(�gv�`bK��Ʌ��ZE�qXN����&.pf�D�W�p� L# ��abS�|�z�ѝ�w4��J@ ���0���~*���)+�,߿l7gk(���4%z�x�կ���A���y��)�sV�	�T߻؀��[�W���)#W��h��Zx��ڎ���P���"�����B�Fm x�)���E�p�-츤~�rN�ėW=� ��`U��ņ���PZ"��fw4�=M=�	�������vD���k�k�xx�n�&}���)�߰�!�Pz�K����=kN	��簍M<�d%C_y�s�b�����.I����݆�����^lX���6�%M�׆��r�t�;��)��Ǵ�L�¤VG}�5���ɶ:R�q��4%�99�k�����E;��Aj�1A̼'�z_�g`�\�l> Lצa��fb��� ��&6���$X,�n�A�O�B̟;��t�0���ð�t�7��@W}�A�<��7�P�Q�mq}`ܔC��x'��"���az.��|(�� 5�E,!ia�׳!��aAoe�7���w�D[��<��uER��F��8�A�XL����REp!lbv;��a�<�j�n�):y��´�h�<�)���rFG���|���A�ޕV�;a�%��T������A��3�Q�L!������J&�Y'�ׅ[`��	3���8�i�9U�QX�#��0q8v�olX�U�����X˶��4-���� ��*�'��Ķ
��7ȡoy�+����j+�w+'�wZ���\��.�c������)�<nAm<_e�aB�ڡ��g����"�������DU�˰2B���%��F�Ȗ�PϨ���|�"�V�����A�ҷib���<�	�x�C �iʩ�'?�����r��=4�/�i��õ�m�p&@�$fHa������O�F�:�xfc���;�Q��[����i�g��x`g����ؔ l�g�!I�����e����q�;�c����7))w³e�m�e��򒭯�p�AO�dc3��ڍRUm98�[��/S�z����f�0�s%���/64�� �d-���4%�#�Z���������X?R��GmC{�iH��gѮ���A�F��kk�G��T ��������2��)�e��S+v^F��b�����N��&q)���0���c�= �Ve��oR���1��2EUi�_��~@����α�|�zbk��#x���N �U���4��o��r;w qm�m�i���#��������[��ڑ�O\
n�0̗)�G��Ʈ�A���@h-�wOO�bm9�*=�#= U��:�n!G����8�F}���T�o�����}�􈞖���촨�/^ټ�`
��)�p���i�N�w�+R0w&�^��4���ǁ:����n�_�$I~)���Al2hƙ��$�8$Iɩ�I��߬�F�S��\8��0�
�DolG}\�Fl�펛��*"���> ��5�F����G+Լ�#ƺ!z>M	�k&����X_��u(���W^�Υ��E���L�M��J�va��\	��&�<T
�4�Q��m�MT� �R��y�#����m�_]vl-���#�����4E5��A1ŕ��;$vZ���&3�����)t;�`]�Dz@tq�.��q�U�Qe���m�z�L�����a��Rs�y��k>x`%��i��ŧ)*L󀥧C� F�MH����Xl��*�<6��\�~���RE�AqY�$řץ$<:BrB9�؞��qGR>-�y�0���Dib�OGqR���!��2�u�Ȓ���ɤ�n^������C�~�H�˔�
h�/�f�P�A7�}�n�T�j[qml��_���q\𾃐��B8��K���V>�+�;F{��L>����h����l]x�X��(e8)��qO��?C�R�X�v�ҽ���k_=iAGI�-֌�e�=��!>\H�2���`jQ�q��D����y=}�;�/S4X�ת�O�u@�8�Q��`ӗx����CMIzn�Ċ������P�JP��o�C�Q�2a-��&x�&H
�E6? L+�anab�{����=�2�\�i����u��:�´J�{�yx����H`k�`�p��C�2���A�6���:�	B.C�$�!o�lԔ3ɢ�!.�
�A�l������`�)��%]��F��H��x�	azRe���� �j	V>�-'_���s�ªO��o"�<xƛ�~@����ג6UjjJ�����l�!��.���Ħd!7�pNe�ۖj��~��ڙ�'�����YE�WGJG(���=�OOST�ŪT�:��/��sm��n�@	�ǎ!�-�N�,}�d�k;���b��'6�=�Q tO֩�yuڃ�ӥa�w[����.�;/^��-����k�ʵ�}aȖR�3���[V%�V�d���x�Љ[+��w�x �����b���5q|%��N�V��=�څ��;�jB�6�<X~� PD*uCw������"�|!l���[���$���ۻ�䲤[�H=n�o!LEr1� ��}��Wݐ������7�_�8}�Bt~��;�������ՠxj�8�bo�濾�6EJ�_8O��0uT�f6�'w�H,�Vk�0��eJ����o!L�>u���N�� @���d����ͷ)N'��B��-�ia�f��uЯ�؇�����m�$�:*�����0M����fcu��Ӷ���kp6e_/;�7�jM�>���� ��"�.m��e�9!�,�>��0�I�v��R�hv2�ƒ̦`r+��n!LW����L�d��4/�J��|��|yDtaAY��h���:�5��QKvMnX�+GSSt֨^Q���a��,y����ex[� v�&$I~Ê��-��Ag�{c�N�G�Z����s��D�0��¨�'�wک�KK�����e�y����z��aj���3���բ*�X"���n�/SH����/���8c��wӯێBRE�� ]���[M���
��2zaz�9��yM�^�Wa�T&g����iJ@�kA����o!��a1K~9��a�#�*u4���,�e�s��o!�-U�jεy�"I2h��U�쯿WSS��Tu��dӂH�-�q    �
��>�bSF��Ǡj�Ɔ��/ST�1Y�5/�a}�_'6��[c�J�}�ߦH),����0�Ň=����ȺH����m�7I�0�qV��Q���Uݧ��4zc�7���:��:��E�Bj�Gj4�M:G��s!���d6�)��߼�ku��I9
��T���C�P��.s�����U	�m"�<-�i�F=��^lt0��$���{v��zX�*xm�}@J	ɻ��|jt��"{)�w��s&|p��ya�:����ڰ�Y�&��m���<�M᳥�7d�qN�:T�{e(�l��(������%�><Q\x�~a��]�ٔqN��(t�>�����$1�b���0$�g(�^3� k�i�c*ԓ�M�Gp+��w�[0s����>��8F�m���b
nA+��0��ͱ���X�"e5��F.~���x�zo!�>�I�͟��� A�>T�
n\�$%��ӧ�Tj8��J���iPQ�3���9OgmY��<�9? ��d�=��M���}r!� o�K�M����a|(a���iޟ����V;퉜�)�I�`��-��@��������ب� �N����,��5��a<9�����.�jMc��H���o!L��aU���^/���i)9�8��%V�}��}P�� �vaR�A�x&6�)%m.�m[j��)����jpi�}B�T]hI��^l��������;:��M����� �`�h�����Ϣ�G�P3�:*o��xZ�2�Af�0�I���d�h�*����E�������Rw�����K_��m������Ց')KVn<� ��Y6��T^l�R�#�����Ƞ_�H��ӊR�-�����Y����'i5�m�Ƶѫdt�r�qa�D�z�=���q`��:I�7ԝ/S���Ԧ���;� \?��!��Ned������~pĸ�A�A�5���Y��i\X�hB�φ��˔s�#��P��A�޳����i����尐$���n�NS��P���s{n!�h>:|�v�A���z���G��n!����H_��aQ2ī�9�eJ�q��;���zd����&X��J��҆�=ߦH����X��Ps���>�K>���e�snj�0H��P���&�#�z
	�l�[�u2�]�~@��`C�S�R.�^�Qt,.��� Y��ȥ�!I���h%	���?�ۿ���fȪ��Oo���-�_��a�)��zY5_ul�]�)�s���[���F?k�ru��XA��P����A�'���^�v�����?�2B�ZA6C@ؠ�m�>�w���Bؐ�!�l�58���r��T�/S�C5��E�B��uX�Ć��EI�WB��6܃L�H��+ww�d쒥��M����p�
� {*1E��B\7!l�˒�k�O���7��t�fS�-uy�A���F���fC���9P���l@��@� �Mjlۼ6��x4h���u���dJ�6ಇ~�6��<�4/�P-=T}�6��"��HkU������҂N[_�J��nw2%z��n!LOX�76��؍4
�m����)Q�+�Ki�C�CI2[����I� �K�{�)�!����;��(��c���ZJ���wtxL�p���� ���.ս�ы�&����m���m
>�D��{�;a�b��\����U�7H-��l�i
=\�+�׷F���笓���.�R�s�q�".uE�A��}��޼@�CRO�%��xOS���aѺ���B�Ĩ��ok��׸������)"-Lº�0R��6��z}7U�P=�%S�t���&zX��D�'�p�\���E���durݳ�.K����_�yA��~��V����9{޸2^�_���D�[a3R��3�)OŮ �t�aS^s��#�V^��A��Ѓ�w�;-�p��7�;��'��9�)<0I���? �M�v�$���|�>��'K{�:�f����ν��Ɔ���B	��v�����x�A����&ԋ�*,�D� <�Ě˒�:��Wd^&%�)�y^s�������a��o�hN_9i{���/���BdW�3��%rJ�l�4ۖ3��)�V�;>LMC����_*��u=M�H�-��j�j���hO����|B���RV�o6:�U�&d}G!��F6�` ���}a*Wk1�k��ڃ�zL�{߷�h�U�f)n~B��]�.��4';-���K��Rs~��Ƈ���}1�e��ĥ�<)��#dGf�}[��|�'��a����.6T@��}�%�T붯4�ˇ&y�B��8wg�<ZL�蒛���d4_��LR��f�M����ym��RQ��z)Z���8~`��Q��&cB?��wW/!J��0o9���4:���A{���|@�2U�4���â�6����'8M	t
�/�\�B?P�O�M'^<���V�_��=цN�w')�[z�ya����F��Ě���ߥ��_��3V��5��!lP�~?�)��g4bj�UGm���L��������n%pv^H|��p'��Ӟ���GZ�꺃0�6�S�Z@r�// ��9:&�Y2쿞�� �TFx�z�A2�}Ѝ�⒣��цd;�G�V��l;waE��B2�@�ü2t��p����m&S$Òx�+6/S{��Ol('�
 �fI�B�0&��J�va��<�~V�&�HДh�-:�欨)I���_���t!l�Y���ƥr�J���w(��L�Uo�6�q��z��bCŇÍΒn�0vh�]�8���~���̮UU~���Z�����B�����i
i��0;����E�צ�Q仑J���eCu3� g�b�0�Y D�O�|iu�c�#�A'n��z@)�D�H`%���0�$ЭNlr�xt������سӞ����� �y�#���=���PS_}�j�p��4�5�B+Am!���6�˗�g66�KV[ax�m;�'Sȥ�r�ta��)wՃ�|�?���Z�%ق�v�T���`5�_d�B؄$�3Ol��1�<�C�<�dЗ)�1zum~@���%�:�����:��E�<�D��������;avzc�܎6{��"ӆ:z2�Q\��ؼ L���\����j^'q�Xv�_y�Bx���A�P�4sI�� )t���Ε!����N!b{�K�#	t�d�lw(t��x�}�lX^��s����l�Z�Rڏ�+�<M�),u@�A}��M�6vp���Ӯ,N�gO���f? �1�1��!_PC�rR�>n:�LI�a~��a���E���IzG(����aϩ�Ӕ��q���6R�����;-D�N/U�f6I�y\�~@�J�H����G	�����M�)
q9�!l����!���u�����\�DL�K3!�l;�g��a�TjRg;r��m\H�]bHiE	��d眔�}f�a��T��Owe�OS��A��ؼ La	76�l��>K(mȷC�K��ΐĚG�\cE��B�$����+X�/)w��*�)�k��w��"Y%�Ć�A�M,�k�����}X����	�a�)Y����܎Xz�c2��IJ�Ǖ*w���m|�	\kS��>�PS�4-^���	�7��!l���0��R�(Y����Ɇ�}\�#��0��󘿛�I�i=�����;M�%�+]�w����S����,���9	�lwEO5%>���qwa�5�/��׆z���dar�m�t���Yyy!l��C����I�z���M���)1�����=��?SRE��Y���c���x8�>���¦ �S���(�C{Q�v�6OS���
���}@y��P��Q|j�n]>Y�z�� \:�\��>�����K�;z�'K��n�D��R�yF4������t ����7�m��>�����6������G��2�R)le�:��7m�0CgDD�����8~TJ��u" �x���=�����6�����]><���`�;�'SbPY�_�yA��$��n�8��aX�Ե�λ����� ��_��F. Z  #��o5�>^�b0E�m�W㽤��+Iwf��Q�g�� �K`m��6fh�,����;��m|�j�:�kЊ��n�ڄ��J����ƶ2N6x�
J]�7I��u��@`��Z�~;? �Mb��vbs�ú����*�n�:OSBZ�%}a��c��צ�z�A�5T��2N�a���Wk3C)��t7�4	0YvZ��K�1�h2%!���;Ev�8�9�z�8��7UH�->��?u �$���B��p��>q)9U��U@>nY�/K���[�}�	a������n�E�y�
�w���NO_yD|!l�>{�_k�%�i��T�[r��)%�]���F�'�u^���l�ɺ-�h_�����o|B����l�N�@�iŢԥ[n:���CSi�����$�v7{4�b|����Ƕ���0Bpi����D��!���ŠN�Z-$�cK��2%>$�+6��<l��m���Č����շ�)��9ӊ���9!���ݔ�ڏ�aw���=_���`�ֺ>!L�3�9z���fжqk��ު)�O���ie����i�8H�(Q�F"'���=wj_��'L!��l?!�2��[f3�N~M�md�ǵ+��2j�>gTX�U=E>l[*�/K$��kg�?��G;R�����	qtR���fO���s�7�R�+o;�8}�B�G�.��"nպ����Cd�e��7<Bq���j��r+�4�ۇ�Zϝ�!���Eg���t�`�`�x$���&��+�5wuq�h$�q���o���Iz:<����'����b�7tx��9���▓�/S��E���l�0X=��^AWT6����ƍqƇص�Oa�0�g4�J]#hV��x�OS����LFGe�s�ɪ)��Jf�C�����,8�����������o�_�[��< ���o�/<������������}������+�-\����/�W�g#����o�T��TE2�*u]�[:��UH~��k���¦`����3&�bH}���dJ���n>!L�(�Λ��*~E�2cJ��_�2���y�/�B�ddr�U�#��V������ѹ���O�aHQ睦әU�!�jݎY��)�1�� ��0Y���X��\� Pkb�m�i:�'���'���1?�K�J�ءӋ*��v�4�ڬΗ��l~@�}N���)UU�$"c�>�R�2E>a񮴺�~@+\v=�l���AjT�~�<����L��06���kS(��Kun�>�� �,H��6���p�Ϯ�kml�oB�K����K�������{��������h�(z�\����������������׿����_����.����Z?�'���Bfwk5}ba��E*�'�u�=���k��9�Ņ UM�:xV��=��eI,�ٯȼ L��y�yeH�� ��%�O~�O�}݀�(��i����������=�@ԼC.�e���W֊�a�Gtuf�Ym-N���{�ӌ�e��.�Z�'�>��ݟ��Ӛm� 꾎�[�^��'��b���!������6��D,�8{ڐ�L���G^1��6Ը�rR��ƹ���M	�e���,^	}@����}�=t&W?lc}��ö�v�Fd^hra���-��T,��!�ܞf�/S�!�oi��	y�������8�R�a�5�;T�J�J�=���0����&;")5.��2��)	�Z���0*������8V�������i�l)���>L��3;�lÑ�IT�(������DOf,,^�|@H�d(�@^O�a�.�� �ZmE|������{��C+��6 :�?�����៴�q�@6paE�����c��Sđ      �      x�Խ�e��h���S��A")���F��'8��s�]�@�:IǮZ.[�%jPT�r���O�� GN��g!��BKK�Q�h���CC�	����`�	��_P���G)�����r����__���7�g��X����=��A���Z+r+�'o>_�X�Q~�Q/k��~���4��5�7Ϭ��ʊ1����{��ps��f�����b�\��X������摎]QW[6b83�;�k�cAK�c�c�R3�M��yU�j3�5g���f@������S��Ybzj����;[�B@��������J<�<�c"�����#!Z���9A�M�������ΨGΌ�rjU��۵���i�������᠌�7��{BjYd;^�Q�1(��E	R�b��}SO�;Rfkў�Z�o_��7-ӽ��1�/6&r�K��k|8��֬���t���5��pHm��� �c�Ud c0s����n�{I��6������ۂ� (	��c�'Lm�m���	�T��ܯ!�6�����ĸ�ek#�6F��mځ5m�HLm�B��1�pC佻Fg���(u�����^f40�6Fi��J3*�������(]��@D��@),;!�1�v{�`r��V��{���e�8Y:z������ �6F9m�d�����7����ngT�TZ'\����z!�{����e4��`j�Ǹ	��9T�ȉ1��h�?�A���U�K�AM̀�v� �,�B=�85!r��R��Ri!�����{O��V�Q�k%��$5�9�ǃ��8{i}�AO�`5���l�����#5��D�	�3vǽ�� Jf����&SZ{��� �Ԧ8��h@ҵ:�u�9!�*�����A��v�j�� �]qܖ���-��B�BH-��s����4�k�.A�mq܎�G�0���Z�Zu��B�����A]�Ծ8����|t��,-�7@ja�������:d�h`Lm��N n8��,�e	S�$(n�<&�U�\Z���8����N�/c�)!�1������v�Y�^+8;`jc�:d�����]eNm��7�_�R9��كR�\ .&TExv�6�hLHm�s�;�vv�4�`�q���\d�6��LBHm�
�/�S�Cu����ƨ�~eiJ����8tD��R�ri.&,��ځ�3��Fy�q�؂�j�������p�;=����q�5۠��C@<�����Ck��P>��� �
����'
������ʿ��:~�pgi�b��ӯ&,ԟ&�T��_�
�|��#}*� ����bY��t��ul�)Hn
������hs�IA
=7�c�(𵄢wQR�)�����!*U�Z�#�9����z�7��M�i�;A
��B+4�>)���N����<�X�χ�=�����fT�S5���Wy��G���F�Հk��l��S}=���$�c�ی��0��9�����m��SL�r��f0ֳ����~�jmh1��������~��"������]?��X���t:ƀs3�ڿ7���V��eJ�AK�`��慫Ҋ������5㗘����ju���vq���|[nT�}��H��u�R9�Pڰt����,>(�9s�Fe� �ܦhk��a�����fBH��Z�t�c���P1�2�vś%�DGY8�F{BjYT�b�Y��Z:WBj[|~ϝ%��YKpߨ��ZW�i�����<Ǣ�Cj_|
����;RM�@���¨d��4�S�PF�Z�R���c��GW�q�֌��Q�����t�B�k��v�hu�u�?���g;VE|��+�}�ܣ��Z7%ݍ}�7:�K�T�8q�L�@�g Vgm\��*��{���F�c��:�cPS38�yʑ��n*=c83�U^��U��ԯJ��g�R3@Y���b�1�(�@R3�d��ڔ*��U	�����ya+ߠP������L_�v��b��w'΍PRC/Edn�Hm��e�6�uS���~}�Xpv�Ԫ���G�;-�	���e� �Ԯ��$1�6P�n{ BjY܅}��s����X�BHm����wr�V�B�fЩuq��+p$�L;�=�BCj_�Ҫ�	�ZKߺ5!�0�o���m��Ge)�1���U��̠!`jcܫ77E6�L70��uK< !�1�S}Oht�@@�B�)S�6C7;�r�b�r��S�s�����Եm��v�0�1^C&��	�z�\R��ƸDn�p����A`|�����&Y�����7��J�L�?|�A�3����%�N-"1��?�`6p�Vf7�]ڈ1�[��q���	ys�VW�w����uL�g�̏ߛgR/���>n>b�N)�����L,��¶��1��?͠w����Zb�����sl���g߉��Z���oQ��\'��@���:m@���uB�g����ظT��6�~��δ��:������5O�����Sh�{�D�n\��� �Ԫ�T�i�
���b-��L�?a�pq���RqS�Բ�}OU��x�BHm�R6��̨���^˂R���.0��H�dkP�ޙ�B��R%A6��GG�Cja|�'�����=!�6F�:��m��R�<k�� �ޙ��v�<&@m����;���CPD׾;o�q�QzBjc�����Z�7c�6F9�:O��<�gLm���r��Rʲu����;q�C�br_B������i�7F�gi��؃Y$�6��=��Z�H[M�!�6�ެ�d����z��Rjc�}L_<M&o�V�	�,Qjc�{�p��i��nB�6ƾ�r=��nL�As�ϮC_��;`n�Qo�1�O/�fdp���k[J�d���A��>$:W���`��.�$]���G�AM̀��X�`Rs�pj�s��{-�<����������[��v�gI���fй���9�gϹ�e�~�S3���H��F[=�`�f�j.y�;/속NؑJj[��<�U�nH=
!�)�;18x��
4�4H����� �4m�y�ljBjW�(ͭ���DB��i�GH-��"���{�d{i4&����]O�7kBh�3!���)ݷ��s�eY߈A�}q*n��Z�b<��(���8��Ŕ��b�m`���!�1�5��29ڷY��5cjc���d'��c/RO0}���xC�rkJU��=��	����Ūܨ3��"1�1*�p��ʐQ��Ac��ƨǵu�M���y�,!�1j[���Mjv3j�BHm��E�� �Y������u�r�ф
ڨ��?A��Q����H�U�s�ct8�6Fݣ��A�r��Z�Km�O�s�wj8nXBHm���;���L�	�J�u�.jן�gdp?�rG�h�δc���Y��mm�*u~�J�=J͠U�yᨵ�P6���n ����V��pjC����I����-5�;��:����*�����$5�^�>�=+���=5����E��v�ڌ1��Җ���u��Z��T�8#/�|? 6��тR���r>Ş��@F�!�*n����	�Ctj�Ԯ������r�A�=!�,�~�k�M��y�	cBj[�s�K�dt?����EH��{Ur���Jd�������ꜹ\E(�
�D�RR��R-���w�l�F=!�1�����+�g0����x��AV�1��BڢR�ǟ�>v*�1��(���x�,��Ulu��4FLm��W_Ui��v��_��R��n8�О��	����N��YLi��3:R�٬�}��6��5!�1+���;�P��fLm�Vԯ'ti����
=!�1��׶�]����	��������@j}�Z���R�5 ��&/��}z��޾X��v>g~�s38-y9�V>WÇ��v��f0��0i��:��`?��������h�竮������{GiWX����fp�ti��~��p�gc�3�p�K�fzΝ�f�1���L776)��� ����_[DkwZl��ӊ1�pc����V�ä��� ��j5�n�����M���|�š�sc#�hOȬ��Ly)�(�!Թ˰ �̮����?�D�Td*�)!�,    ���vk)BS�+JR�2�b/����EB����Z��x�����	�}��4�ѹ�s�� �0�9�?ڌ/��%�R#��O�,�sFmGe	S#���U�rǉ�$N���aL��*p�A][Lm���T��2)+i0������H3Y��.J�'�6F8�/����W�قR#��O�墭���U� ��ƈ��ZB�e�e��ј����|��t3����W�1�1"OJgHe}nɫrBjcDa_Z�d �ڧH�6F�7ۻjm��E�R#���ӡF&������*�M�f�j?�S�����)�(��Ec05�;�
��@[k�Pf��t�u����cPS3 |��_W�(|jfpj��81�&���� ���A����#,�9���Nn���f��'���o{܈��=5�	����`7���bFj���#խUo��(�!�����z�3�F �6E��{�0Y��M�1j˩U�B9.y\�l�S�ӂ��]�R�X]=`;$'
!�,Vn�'�g+Zx�ZwBj[���Z�h�2wmFcj]��{U�֩L��ZP� �/V}�3w�ۘ�7lF!�ƺ�yYL��w�f�$R�m���v��tRpE)�12�]�5�Ui�``����4�v�����q��6F�7�A���RjpAS#� _�۞=���BHm�<�{�m�x.?ZBjc�瞛�"��}jBjc�����6��r� ����J�'�'���"��$!�16���v��"���"1�16.�f4j)`�!$*K��[���� ��x�n��[7�u8IEX����"[�����a�W�%?�y59-�i��Otʀ*{`�1����~^�jyj�Ί1���_�����V��%Ơff ��1�_�h�����{����KQ�7}�a�BK̀��ޔ�f?tZ0&Jj,^��߿m�����{=5����_G��Ut�H��H͠�r�ϓ��ق�TRC�×��4˶S��BHm���?����Jp4@jU�3��wd]KmЫ�GH튽��r�C��'��A�e�c�.i�:J;��i���;���fX�P
��1Cj]������2���s6!�/��������ҍ�����7�Aʹ?��V�J�����oAVs=O&�]QJm�7M����C}j��	S�M��z�Z��IS
j3�6�n�'�H�r�4��ڌ��q�8�.1���N����U� d'Eě=H��6�Q�����������G��g���z��De	S������I
�0F{Bjc��T��W���\O���8T�����丰n��#�6Ʊ�_��ϣ�r��BAm���8��n��5��ş�{�C�oM1�r��3��!y�r��;��n\@_�Ϳg��`7�9lUjGf���{��A��WY��Vh556_��.��g� N�@��}��4�V*-Ơ�f0��&ⅳY���f0�����m�g���$�`��e�s�����H����k���:JQ���JfZ
�3�Z�#�ŵ� �Ԧ���B5R[���� �Ԫ���=�$F��RBjWT~H�*�Uk��Z������Y�>O�F ��E��۷�i��:� �Ժ��Z
���Am�h
�}Qu��sQ������Zuw_tq�:��V�k�% !�1��r����ӂ1S�*��A�=4��k�% !�1.�~m�Z/� �,ajc�Bt�1>53��>�=S�B�߿%h�����S��Sd�A��ڂˋ���`����n`���-� ��Ƹ����Z��)�����Z�r��+ԧl��6�u��E�D-{�hOHm���7�a�������o��q�~y:ۤ�V�ˢR��I�mw�L$��s/x��/�Y��׵���'f��7o��}g�����f H��-��p�J���ŗ�a�n��
D�AM�`�K�����U��N�`�_J�z�̋�~%��g�R3��W�_R�o����� I��Ŀ�q[us	0��=3��_�G��F��`?��V���~k��E�#��j����s\M�l��(�6���/#4ݗ���<�R���/ �<���5�� �Ԯx��7�捪Gy�BH-�G�/�����J�(�Զx��>к�J]A[�Ժx��;�,u.�2%!�/Zi���H��=!�0�?�6���ƭp�R�����uP���\QJm��c����M���)BHm�v�oAJ�>PN��1bjc�~��}ܜ��҂��6F���j�bvLp��ٌ ���h��G1���l!��23�6F;�{2�K�L[4FLm�f�'P,q�y�f40f6�Q��F���jU�XBfc�^��6S.�Jpy3�(uo��8T~=��l��^��&���#�e=�2�(��˛Ʉ}/���J��?_�m�ˤ�~��&�ӋE��X���1��t�bs]����3�Pj[|�V����z55C�I[�
0�b83({�r�s��~J�AK� şJ8t
�*GK���fP�͒f�Hy������O�X�W�[g��H��H/��K�]����rđJj�K�ɲJQ#��R�"�m�`��܌���D �VEX���v���Ȇ���]�˵�n����� �Բf~UM���SZ*!�-"L_2�M}�S��}��Ժ�O�@,a�ŭ@�����+����y6���Z���V�PZ��U�� ��ƈ��*�J9հ	fO��qV�	����QgGe	S�	���m��;+�'Lm���/6��e�RI{t�5�1�ݩЭ&�)\.�`�����8SNߕ�ٗ
BHm���B1 ��ʢ���6Fz��p=�٧�1��`����p�)�۔�	���d�k�!=�7ڸ�	�6F�9�ECk���k��I_�Wk���7c�6F�ŷOm"M�(�s֮݃/���ϡ.�6��ޜ��R�q�ڲ9c05�Zx�3����:k�A���z�&����A��!�/o��sx�9�{������d<�OB�A`�)r�҆|y��!HnOq)7;�0��?�� ����O���W�:�1a䆰���v:�N�=�	Aj
{�k�H�u�i����ʣ/��{N��rK#��8e�C`�����J�xSȺ�ɞ�irk#�~U��ՠ;WF�Bno���R��f�C�!�8��8qT�A�G�Bns�1�e�u�q8�&�A
�Ց��L
匂���FA
�ݑ����V��w���Snw�;�4�:/-c�����͟_^{9����+1�;�'
�l
�N�ԑW�Bnwl�KGΠ���tV��������ʮ�G)%����ݱ�KAf�Q�ߌ��E�Bnw|J��<�:�V�7������"l6�'�5������*�_��I%���h��m��W#�u*5攔����W�����&�r��@��5����ӏ;
 ���s�MIA��{H��_d9��@��c07���f�i?�q���	�B�삂��E�9�PsC��}O���{�A����oA]kT�-�A-7�����Zt�A��6�⌢v��3(��p���z��^�����!��`�9e���L��P_Un*Y���s��Ъڿ��软�푥_�����?J���A�ϗ��_>?����=�4>��Kâ��b�y��띿ٞJ����0��~o�!�0^c��`���yL�j1�1����X�ּe�x�-ʊ1�����yC�M�s�R�!����r�nڬ��J�1h��-n^�;1B1hL'�@R3�m�x`���˝�����f�wv�޼�7�^�(87��v[��Ȯ��ų���p��A���<�2�"���L���A�Ǯ_!dVE,��:r�<�<�� �+b!A7*���(��Y���c�g�Z��O����4..&�gK
���BȬ�XD�O�����X������r�/�{Ym���˔�h:�y�:�����ƈE�qS$�9$s�� 1�1bٳ9ժ�.�w.%`nc4�>����f�ѵ���e����#4��HLm���y�G��s�?!�1�4��^x��k�    ���܆�	�6�.�ssLm�Оa߳HmR���4�R#��F�xW�QOHm�0�p�j%�U�������'6v;ֺ��p���ku��NG�����%Jm�p�TZ�Amm�'1z>Ԛ[~�?���I�㋘�Rݢ��޸�m���!�sTɝKj�������F�A?My�%157�z�i�sY�gxD�Кxc4��|�Pp8�����5��Ę�p��0��	,�a�f@���sC��YewR�HanmXp��!�釃Jk�V-m��,����l�]A&������1��t�R�-��\_(7��]��(���H4�7P��R��=Qȭ����������" �7�uD�յ�}V��k�Bnq�>�j]F�9�@]g�Bns�yS)����	f�����[Igw�V=�$-J!�;Ҧ�f�Cu �Z[擘��l?"΍�XL���/`nw���qP�>��i)�v�
7���n�He>��s�c%��C���ƍF	Δ��k5pe�h&��n��s�cmn���2�ݔr� ���Xe�-��bܺc����ݱ��lJ���]���#�v�:��e�R�a���q!�;օ>:V�Z���])���F��]�},�^�ё��������3��2U	�*y	<�}5�}��-Xfr�]�Wlg�!�F+�	R�]w��NWmg�2�C��)�.���fL�Ҍt��tÂ�@��K}��k��{����=H!w�>��Jd�Δ�F���#"w����A����s�%H!w�~�������Z� ��՗�-�l� ��If4:&.�t�5�u�@����f*�����q���]:�1e�	s��/#�:ձdq0.`nw�eD,�z�mE�Bnw����٧�)�� ���8f7Sv�UDd�E)�v�'}|ɬ��iC&i�b%�vǱٿ�TVٴ���r����� 2)�E�Ղ�,��'�~y�R��N���펓��U�^S�pq���8�nΚ�z��,���g[�_���FU����#f�k�?��%5�|i,#���/�߰��YC�^��=�aN_��,��&n�A��J���#���>t���&ե*��C*��շ5*}�ܣ��(�o���ZP�����Ѡ|Z��"�r����_-xn�Q/k��~�BSu�C�~㞑�B��z�=��&���Âzj���a)�u�hO�!���{�D�yiP b�.e���)��m8��)�P� 5�2_f;��k���\w!�APk���y���p���|%�ʎ1���|o޶f��7w�1���.nj�b��Spc����A�Ս�A�����w�1������������x�R3��� ������b$5�>i �ZFj2A�AO�`3�x@��lv����x,��s
��Y��TC�R�:APYc��((�������dTR��!!�*r����`6xݼ��B��\Le�:�hQp~�̲�E�t�����Yr�93�"_nv�2Amu}{� d�E.Z�Aز;wړ$
!�/rYǯ�ua�mt<�2#�3fq1��/�g?:!�12F��FzdU:\I���X�����sƯ=� ���O}	'K�Ɣ��!(K���[s�A�Q���6F�Ϲ��ön^qfBjc���q�a��Vo��#"!�1µC7��5%>O�� �����ڼs��e�f	BHm����,GO�wP�hOHm�`bBӆ���q�R#>�w��:h��HFt�-�1"u�k�R���jp���sm��Σ	�Z���I��Z�{h�i����5����wQ�A���{׾E{���1-7j�&��N2�@��pJn,获3�닳����sC�^�f7r�qU������x6�'�nm���T�k`!� W z� ��g�u��B��r?T���
����O_B�*�Tr.������mւ�/� ��NX�Fȭ���r>�l�*�؃���qq�J ]�>�'|*�8.y�غr
��ݦEg���FwۯK���6���[��O'o� �U�ht�����Ly��6��r�ws��ʎ�
4Ų`�����{���<���cS�1�;nBus���؃%莘���଩\sƁ�U
fS��[!e��O��SK�y3�q��j���~h�j�_?�$}�Y��:����<_���K#�jAՐ���rZO��:	���o;�?��uvunW��I� JA`���[���bjn��'�m_$���c85������M�q?�{�9DB��ȵo��@ױg���0���]O���]y�/���p���(s��0rC����A��W2TZ���:}F��@�M��� ��ў���3BXu8��P�ѭE|>�M!�K!bk*�ls!A��Y̼��`j[����BuM�1��N��%����X�A��`�<��sh��^�pjF/���F��͙`?h�u1q�.�C�w����`������}�`�����:,�{�;GnK�>5���;?r	:RI8Qܲ�w�jBjS\h��M���x���Z���٪*7%�AH튫bu��z��
g!���U�W|�4G�B�[pr�Զ�����(����39!�..>~�d�M�
�.T%��M����p���hO�-��<��.»[B�m�2���f����jpE)�1��7���U���g�m�}?�3��>�S�S�=�����q4s�C�*:�<:1�1�Ҝ,-�U`�h#�Ҏ��qu=��v���,�������	*<�lZ�� ��ƨ���ҁ�����Ƹ�zKZY��f���w�[te��=�dcr���R1�ה�������jU��q])�	���4��^��2�1���!��?�r��t��̠��ߍj���mVg�ff��3:��0�5�������a�f��.DcPS3��n-��E\��c���v��h�k��L��1h�|����x�_�c��b$5��b��h�a����f�_N�<{�(���#5�ږw@�����:RI���"��qb����7���D�oF5G�V�&/�t��� wv�����ԗ��ss�s�"�E~��TΞ���	r��͒б�M!�!��ž��>%��8�,�>Bn_|\���Ҥ,'�r��k�m�����"3�@Bnc��|��f�����$�6F��<��ZX�
�'�m����"6���[p8`nc\��nP셭v�j3�6�]�d��P�x��!�6Ƨh��	��	�Si�m��ń)��M{Fg���x�O��@�~r��Knc|���m��,3S�y6X���Ҿ��� ���xn�����әVp8Pjc<P����)8T{G
.�Pjc<W��y-#"kw�܅<`�o����m|J�����)h�I� <�o5�`j�����1o?�Ud�Pn�}j����<�bPS3��O��
�͝j�1���xO:z��bZn�_p ��J1��A#u�����ӡ��������Jk̊��V��H�@�;�T���?a��`�w�=yh�}!!�)��!�����f�'�VŁ~U�uö�z���r��X~A�h��n�� �ܲ8������g�(�ܶ�/W<X�٫r+%�9An]��k���v:��(uBn_\�}q[-*e׫�A��q��ڧ�������6�;��E��4�t�S$�6�}�k�(�u�``���x:�22r�}3+����,m������m��{B��(�vBjc�R��	�n���N�\N���he��	���E��(���h��>,�8GF�,ajc4���T��Xx EW�0�1�;�A�������|�{R�4m���[jc�
�KP���q��	����)��	3�N��	V�~9�(��h6?�pb�R�������W���3���K�M�U�8�5ƀr3Pq�vJ���r������d�ul{��!887+�Ț�햛`��z�/�BFgW�z���$5��R��L��cb��@��e�0�ܶcFj��:�YKm��u:%�H%7�㯂��As\C�����U�?�Ip�un}r�    ��.��������E��K�I�~�oD`=AG�ܲ�[���4�.<4�<��m~o`x�<Emr����Bѹ�<iUT!�/Z���#����%:;�F��A(�f���!d6�ZJ[.{Z���pi��+J���(×���r?x�hBfc��r�p�:�_7�2c-�R_�_ @��B�l���J�X��}.A����;������ƕ����k��%T�2j]ח�2�0�A(Bru�Yd.�`fc��+��@��M�� d6���	HMj�v���z�6�&~���8�^���)�r���،��`юe�r�?E�����ӟ
��C:������s�|^MNˠ����uE	�S�5� S3�w��*H�mN���`������c?155��,����­i� ��`�Z���IVg�T�0h��K�n (R�Y\�1���*䖔����ڧ��X�JI��.Z��jt��H�`��`|N�� %7��]G��V�
��Q��ܦx�����r�K�F���[��e�>��-�`H�ܮh��7��jouCBjY�2<U�댭;!�-���R��ў�Z���*�a�3?��F ��E��WA�>��N��ѵ���T�APE^�TΉ����/����w��������_���J��!�6Ƨ�o���95��fLm���ߑJK�m	�Lm��@�jB#��b��� �����1.��P��z�6F���X�� ��$
!�1�~)�(cFآ�Cnc��w߆�޽�rztv�m�пx%��V�����l/�V������6�Y}A!�;-�7$��r���㐫	��P8>=��
�;}��*珧>qb�^�֯��I�1���"����
����Pn�/0n�}H/`�155���e}��m��=��s30}ɝ�9�o��A-5�3|A��a��T�w���f`�_j��NO��`?�,�u���r�_'3~�`df����6ಗ<�MAG*�! �}XA�~�zBjSD��$��46�ebВ �*"����YS#���@H튈��JT�,կe� �Բ�$����@yJpr�Զ���
���W�Y_\A�u��z˒�y0!�/"��O��eC{/ў�Z��__=Rz-�6p�h�m�M�ft�i�߱p����Rnc��k��x���	��e��G���VyD{Bnc��߇��[��������طߑ��������G�T�����+r�0_A�)p- ;�͘���.&���
�FBncT���ەf�ZsP�1�1���;m���?qp�s���V�����׀O݌��[nc���E;��:aYp��r�>�ߍ��c���N��^�>4u�����<���ep�e�E+<9Ԁb1������dR+W��1����;/t���٨>cP33�R�)s3:q��pn[|������Ϣ������a蝊ؗ!����f��W#�ӻ<���1��f0�t��#�k��0R3 \nn�6����_uC�TrCX~r܏6nC*'GHm�T�W�f*}�CG�R�"q�b.�4QxC�BH���2f�&B387@nYl�eq�����#!�-�S\L��(,Z��OA�uQ��(sy��g�`
�}���z�"`^�v�rc�>qXv�A��F!�6�A~�]���������8�ߑ/7��ǞGn�K���g��û��/�`����q�ߌV[g��]OBnc��P���kAY��ƸПܳg����1�1.՗��(tT�hO�m����oט��d9�2���qrϤ��)Lɢ=!�1񥥶���ؤCBnc��/}��y(�m�6�˘]�>���5SiJm��4_��6�VE���s|��ꍪH�l�?FbP��`"]k+2��1��������)������f�䳧&e�G�׊������x`�&cc��P����uk��1-5�
��d7E)�Z�x ��܈��6���^/�=����I�}� {?������h7qZs�t��B�~R�U9��%	r��@�{.2߀�K$!�*��].�@��5	r�b�͟XS�T;�� �ܲx��ńe�7+�2� �ܶ8D�GbsoY���r����z�~z�</�@P�!�/���z��n��Y$Gg��¨2^�WoG�ld=!�1.^K�-�2��+J��q�_:��O٭]4�����q_N����c��tp���Ƹ�r�d�w �%����x��g3h�z�h;�Icnc�2��v��m�s����'���"��7MR#�>&Hi�0$:R#��r�U���CAc����ЊK�ٞ��x��0�12�Ki)B��.�E!Pjc��N��-hw�lFQ������p�m����B+��ɶ����4x��C���Jh�UI�k`�Pe�W�hw�2�5������*��2�`159��_Ƽ�C��K�:��{�Bc_�������� ��^<a�U��ך_YArC�Ohf���F%8zn�A֮�ʩ��#9m/O��6��W��,��F�9}���A
ɝq���H��[��xD�Bri���
m��d�y$4H!�5*����xE�)_�u�/@!�6�|)�n���tgH�翺�AE�� ���^�`�e�ʌ���q�rsĶ;���V����_��(��Y���9"�;�9��%ZLϱ�`���������&����FGL}A�bRhw�v�ݱ��N!ͺ�a�+1�;6(�(ܾ SX{0:bnwl0�_�"{�&A������c�bj�� ��6���� 	�v����-)�펍�_�b����cip;s�c��/Eu=8O��1�G`nwlU�Q�-<6v\]������m��TW=m���펍�R��˹�A>�x�E��Y���+� �!�v\b]Uʲmо��� \|qF骠W��A���^j�U��j���PsCxVQ�7���M�v�A���d��f�F_�{�%����"B��Z;_ǹ~ArC��_+T7��R�.1=9{yH�z4�*��{#7���q�Jx��g�>3��O;'��n-{)$wƥ���"�h��\7�WTQ�9�[�=($��}�3�뉊uu��FH���W/J����h_H��
���ɝ �D�crq��2,��u�)u�Bns��$�[=R���U�2@!�:J����P���z�~)�v������)�_��_�kL��Qع#*���uF�	s���� �oҶ� ���(�1n�\�q�\��..`nw������d����6�WcX�-�䈹�Q��ۓw�0 �ё�r���N���f�֢9%&w��w�ljh�O��3��c[�X�Oĥs�����n�i��yכ'(�;��R�Ǟ��Z��J�}�9Gc>�NWꟅx�/Wn�
�">���h�손�k�]&�L�� �!C��@�!ܤ�o���P��U����� ��<\ޯ!pr/�`���6=}� ����~�0�Y`c�$�`�)�e�u,9XZB�a�����sϽ Fn�w��8��W�o\h;(K%9���@��� ��x���h�?9ܤ6B|N4� ���hǗ~g�ô���"}�Bnk�E��&Lm������u}�\�>�fQ��;Lx9���W��A�Bnq�H���i��3�I�Bns�����e�}�����[;���~�"�K�(���������yYS�>�9s�c�ӏ�z�O�~��`B��ݱ3�G�P���_yr�c痷�;�8� �(�������,mY�O�cFGL�}��,�st�	����Ϧ:�C��4�Sbrw�Z��i����\_���������ƺ��������A�c���1�;N����*@�@=�5����{�f[Iq��3��c��c7:�j�i`?M)ϲ���isz�6[����?�Wc�à�A�R���bP���?1����ǇϿ�hP>�Z���z��(?Ũ�����?�à��5��6��٣�>��L͠���ڼ��O�ˤ(J�`߼%�6S�cPS3�i��r���j1���n�Ń-���M    u�c�R30���	ݰ(KV��df@e=�u����Ibzj(�7�P��y�!�`�fPq�x 6v]\�S�:�H%5��r����>o� �ԦH��oI����� �ԪH��	*U�x��C!�vE��/���a����Zi}n
~� M�7{�+R�"��Q�'*3i�'���g�%uڛף��)2�/V�醃Q��<�w��=!�0֛"���7R����w�AHm���8c$�1����k[�}wr��E�`
����v9~]����#�6�:������b�b����6ƪ���@v��!G�A����_�ǘkO.�`jc�F~Me��rN�'�6F.�b���g�@�hBjcd\�<���՞
D�A���� �@��=�LnAbjc�V���\8��@0�����r��g��OJ�R��q�R#��øAa���ى�1�}������ώ|K�@GuqQ��)��~�>���f��t�4�T��,�c@�n���M�j�55��A�̠~fP�źy�c��`�n,�2���9Ơ�fP�o���j�c$5^�v�Q��k�cbO�@Ĝ$�4�R�N
ƃ�����g��^g�;�H%5�y|� v�x�DuHBjSl�������
<�	�� �U��Z�&�̫�8+6BH���v����Ԡ!��E��\�t9�A�����ͭ-���;�<��$J=��?�����H7`π�J*I�Ǯh�D-�
&N�����;�FUKBj]�j�T��5ҳkBj_�~��K���qO�`� ���N�/�(GJ����Hw Bjc�U��1�!}w
�(�6F%7E�y�p���y��â]KGL��ULm�lX\���Fc~*�!�6���o<Y�2�\mEcBjc��v�C�L�4�`���qT�S��1�P�ј���&�@1U�ħ��#�6Ƨ>��f��B�ڢ=!�1����~���mz�!�6Ʊ���fۥ
u,=��H��q��q�����M���xm���A����ş�u�51�4X�h���f����uH�W ։1���^֕���k�Pj��Q^��ס�Z�AM͠UG��j��vlc�R3����nވx]�N	1=5������D�~��0��85���Ɍ���Wvc0R3��RC���>���X��l�*(������vБJj�_��0$��)!�). �Ք�v�ôKBjU\����3n�X��hBjW\�_N�1�����A�equ���^�J�s,! !�-.��,�n'`��GBj]\s��h� �R�=!�/.!_(�0M!�v#FBja\z��"'uO�d5*K��q��|�5��M-ق+	�����-�&��JuBjc0��9�6ˆ�$1�1
�K�`�MF]��=!�1Jc�Y$�=o"���1bjcF_vPl���
��R{jc�������=���X1�1>��n�yq��A�=!�1�����`ʨ��5Lm�r�k�����R��'�������=�R�ba��"�ʱam��ƨd�'�δA��W`T��k�P���cQ�Fb�e'��͡���:|� S3���I;�Ck%|πR3��'dҲYg_A55������|VJg�������uh��O�x�S38�\�T6�v6����853v1�Ȱ�h������勐>�Ѹ����=���5�w䅵����AБJj7Q~9�qHx������w�岁�MyPD��Z��t�Z�In��	�]q��^�3Ӯt#@4oJ-�[��AP� �
BHm�{/=��jrcc	Z���m��<�����{��&@j_< ���7��دIEcja<��f�;�K����Oe�U�W=���`�����Y9�5Hi��O�N�����
z��4��De	S�K�����`C�����x���q�5�|^�
@Hm�g��"K��]�./bjc<���+���Rj������c5��t�R�a�n8�Z�|�J� ���h���zj��l�
S�5�/��=
m��@��Ѹ��{ǀ��
������m֗�_B��\0?���}� �^M@YO�fb˪kޢ��i�c05=�5O�w��h�gb�g@��ŵ��L��cP3襼�/k���a�AK��z�ϝ��n�>ˋ�3��r^^3am��	2����~@4����Ic0R3`��.[�a_��#�`�f0|�H+W,�c�G*�!��wl�PP������{Q�� ^,�CBfU��Pq6�R����]�۾}&ꪅ�� ��E��o7t�%�2G�Hm�@u�܇Ey��)�9���Z��/�l����crBH�����X��wtvH-�0�:̦��6�0����e�p�T�֠,ajc���G���HwX!�6F�싇0o�y��%Lm�`�͵k�p�Q��'`jc�r����.j�~s�����㖽!=ѥ��ƈ�|9�p��G �R#��=]0�5.0bjcD�˵o��A�`Bjc�Y��å�i��!�1�z9��\��3bmAc��ƈ�����3�q���6F<,� ��/m��u������7���#%/*���P�c�)���!��σ�G�Ԇ;�(7��ҚP�_�T�qB����;��Ҟ� 1-7�n��*�m�ڬb1=7�1}	ʛ@݀�K�%�87�uSE?E�\x�������3���Y�B��!��/�w��*�����yS>/�	�;�bV��U4: �3�b�����R�Ag���Xq�:���Zϝ'V�Bnk���y��;�E�8)���z?�Rs�N[@�p4.�������5��@�Bnq��}�Bx��)s�c�G:����Q{0����Xu�G�n� @�M�)�vǯS�/�&�+�\Y����
n��%�H�����ݱ�����}�Z�ք�ݱ��';'�;��S��s�ck�w���ӌ���v���[y�ӏ<�⢙5�v�6�rq�1Z�Q��ږ�P��mUAR�qE��RE)�v�&�~��n�q��F(�vǶ�_+<O���⯒�
�ݱ���/ls�m�����/Kx��/�����o`��D"g������p�S�BR5�Jz�{HaPsB���h�����!�#�}*[�D�v� S�p@����"l157��m_�� '��#��`��i��d��I��!������Ϙ{m���=�sC@:ݮ�k�0rC�诇)�Ӻ69{� �����W���.ڠ{����}ϧ��� j02Bng�����W�e��(A
������/}�Mk�� ���Ⱥ����D��[x���[�_��q����C#H!�7����TS��A�`��q���T����%����M_њ���A��ȭ��U��­Wѡԣ֔�G7=��kMm�R��ǘ�B_��aH�V�ք��q�Q��b���%V�r��3�����������ql�W���=���W�����8l��&��J4����'4_ٺ�D�qs� ���8������R���
��qV�5���h�tF��Bnw�}��0�������h��=�=��
����|�ꎼ�F\����enw��}�>��+4,Ǿf�)�O$Mn*c6:�ٰ����Emoh\[l�~�	@�����0���Oo��� ������*l�wق�PsC@�ݞ "p��s��{-7������W�"�l����sC���UWn7R�#���0�W�4k�=��0rC�{y["^7�zLh� ��d� ���+[�q��TrS��+]���`�A
��q���y0����P04Bni�">���Q{��דY
��Q��_t��nM�S�Bnm���7c���s�3@!�7J3_���#�)2ktD��瘊�@T�$��5hϐ�evKj�j�{�Ѹ�[��.:��`s	�Bnw����kK p����r���-{�Ѷ��� ���f���XS+vp�s���Q�a�f�\
�R�#"�;*M{9�0��>d��5anw��^��T����vG������`�,�A
��Q��y�&�s���U�펺�_k��u�	&-����Q���P̆t��#0�;�    >��¡������@��Qm��(�����
���hR>���~h╨%�����b��>ʿ?��/�7b�g��ˀ�O��)�Nl���\�;��P�]���?�*�9g���~�����7��v�:ہ ��@�c |���Z�#ƀR3�M9�nH����yA�A��@>�7Oy �VYvp,�����n,@�~������:�y����7�1���|<鿛w'L�w4 [p,��zs�°g�
��c0s3���A3�u�7PБJf�q�h|EY'�� @jS��m73�U�}
"�	BH���(���m⑃�cBjW� ���JT�P��Ѽ)�,N�˵���V\�3
!�-N�Ͼ�?b���=
!�.N,��)ҵ�����R��Ď/�D�
�~�)!�0N���<�2�g=m!�6�I����φ,�e	s#��b��U7 q0����HZ\LP�Zw��JB�m��c�!�H��	�����Vք簅uI�.bnc�/���:�r��	���K*�����(����:9mF�Ж��"!�169.&��Ȉ��@�Tsc��PXXϹ��� ��������q<)$VР'Pnc�b~=�&�vD;c�6Ƨ��ך�Y���������X�9����`��%4���t|&��`j�,�C.�M6����͠�B���$��k�������Ɍq�yPϐcZj�T's[]��c�s3h����������`m7/�y��!�M g��H�`����:�gpn��4������ҧXБJn�/�x����A�MQnc\� �6���38;BnU����PEd,�6!�vEY۵���6"
�E�-�
�eQ�ǣ�A-!�-jW��ް��1�.�ѥN|G��o�}��v�`�;:;����'��p?�A���6ƭ�7��[���1�������x��o��Bpv���x�q�["vh`�փr�Qpá��ɀ�0�������k��!�.������vþ�C�8�g���m��{�����y$!�1�����%��l�Eg��Ƹ���o�d����\a��Ƹ ���m�����0�1.��oF���؂=�R���'����Qc��Ƹn\|�	��H�[?W����1��{��K1�#E��˅P��ku@�OԘ�ET|� �M���*�� �D��߄�|L@k�v��4�'*L�&����z�(RE�5�'
L�"�Z����+�ܖ����~���oB��_���q� �����~��Ӽ�����J�OT��E�t��b�sR�Yp�O��Mm��6�>e�� �)j����������	RH������T�8dT58I�HQ�_�Л?�>��jukЗ~���oR�u�ҟ���Y4.$�FƗ�O�`���y�Bro��_��� �{A�A
�ő���ca<���qTp�8��WM��~���oR����
���;M`�Brw�j��g��s�!�Ɣ�����ʭ�͵���)j���?�p�7�s�-H!�;N���4kgo
��?R��)��O:���A����/7"�z�fS'�����:��L����A�}���(C�Li� �ն4���#E���G�Ӻ��Ϫ�����ˬ�ljS�iep��G���&��/�IXN������{��!\��nPfvG��L������J�E@�^����܇�J������CE���ܠ<�WZ�"w�z���}Q@X���~E�2�W|1P������S`߉�)fa�3u�~����yU�M����);�[6��Ӡ~]
�38~��ԯ1��5O�!5zn���):�[P�w�A3�j?�a�35�~��7�N|z?Q���a�3%�~����5Oz��𔗉0���S���jq����U�J1?Sp����⁲�s=I�sq:�H?Sp�� v���Xṕ�kBjS쥖�M6P��`Q�U����b�_�kב��cP�����A�⇃p{2�9)8?�PQ�߂ ��j?�$����&��m����#�1qY?+
!�.v8���-�I�1j4������i��mZ$}��~����A����Q�'*!�6Ǝg;O(�Eˍ,���CE�Up1a���N�?T��� ��rH`���zCBnc��n8 �Z��X�B�m����"��E��3���CE������W�:� ����	B�m�}`�R���&H40�6�����cc7�uYXBnclۯ��h�x:CoQ���z��"�վn�,$��!�1v�nv�֊�\k�����A��%�w���=!�1���y?I6�;ֿ>D��1=ur��̙ܙ�	�L�О��c�3u�~�� ��<eC�x?2 ��g�N��N�l)���d����:�k��xW�Q��B�?St��2]L.�Bk[��Lͩ_c��M�Bֲ�煟)9�k�]<(&m����1?Sq���]���|�j���3�~��?_D��Aףg�.��g
N��J�k�XBnS��!���:�rA�UQ���F������*j�k���*��|[����oA�����P�5!�-jg����HU��1!�.��C��Vߋi�����-��	bg�k���q����������J{ Bnc�⳧)u�����*j�[n���ٞsT�����O���D�_�cA� ���xğ�2�Ɗc�MA����#U]Mx��'�PQ�_���A�RJY2	?��r����pgH�
�`pM凊��.��B3�j�JS�h`Lm�|?�z"7��D4��?T��� �����'PA��|N� �6Fh�H�)���B���������=�nV�9���CE���)��Q��>�������nk��v�y
��%f�u�� ���3�n#� s3�~�l�;��b(7��#�������{55��l�ˁ5Q��6�������㐃:Ψ��=������՚-��#��v��fP�psc�rӦ�{��X�L�$ڰ��T�1q�fp�ϛ�)�C�kF���Ъ�<�J(��`@�ܦ�&��Z$xMY��>�r�b/�Ɠ�v����{;n~�&�yN���S BnY�.&�� Z[G�r�"�g�xHe����[��F�p�'Sh��,�Fj���Ӣ�1�0�������M/�r����7X[�=E�s���R�m��v�c{�6�Y��n-w~h�-8;`nc�˷�Jų�Q��q��+������9,!�1��cBe;7bΪ�Z:��q����-�Z�Dp�s�����+�[f�����9��V��ZW�!�6FQ_s�Й�xڈ�,ancT��Y�m"Ia
N����}�nL�:�������|EV��(��'wЍN+UV?f���n�e����0�ٕE�O��f0�����dB��f`�ߑ'�c�����X����O�R�U+4-1-7�yܾK��W��X���{��E)4�a�1������ý�x*7������e�>���-�`ff0�#����*��t��B[/� �2�V6�6�Q�/��e\4�XBjU��T�s�l��	���� ��}]M��mF!����'�fN+�1F�Cj[`>{��U������uq`}9��ԏl������1h�Rm(�hOH-����0����s����Bnc$V?;ݜ�vn��	s#��_����#'���������T�.n������l�X7+�Kf�.��6�j�+��X`��SNP�0�1�*�8���2�Rt8�6�6_�H{vg�v��z�6�f�t?Yo�!]AY����+�7b�J9t{Ƅ���g��hi��~qGe)�1���f<O��E���r#���8��2�B�m��}���8u�-f_�/�_�6��y�NuZ��B�"	�,�1������M!��Zׁ��@}��y���K)cPS3�`��[���s�{-7�u
U#���rbzn�ߵi\&�y�E�1���R��t`�3O�#7�����g�����V�m\�zʴ��%5�����WG�}G!�6Ea�L��uZBnU���2IA��Ճr����l��$�O]� �ܲ����^=    ����3:rۢ_jOH�v��-Bn]��4��2J80���=�珼o8@��Q��q����޴�emF�Cnc<��~4m����쀹���~��������r�9륌�n%�5���������5ڲk�J%�Ȍ��Ѧߑ�<��橲�r������(��� ���8�
*�`<�PT�0�1�2��	hsh}�� �����q�-�'���2(
!�1��p@g������q����7�5�U
�5Sjc�p���)9������D���
�#�Y�����O��&�n����?_�&�e �.���E��Ј1����cPi⾡�7S��fЎ�d�+��cjn��U�{�:�bZj�+� �i�A�͠7_������h|��}πs3��Vg�&�ڰ��0R3h�c�6"Q�fnͿ�p���T���p����*s����H�B�m�7��
�r���:�f!�V���W�~���Q>g3r�b��o<�5�RT$<r�"�?�7���[�
B�m�<�-H���<wBn]d� �X��$<�B��㥦Ra�
�uL�����8|q-�&��F!�6�Y�K�=�q���%���Rnc�m��7���tF!�6ƹ�'1e:������q���V����Jt�5�1���y��>W�:����ת�',ތZEj.'`nc\����b��q��p�m���5��8�y�rIT�0�1��U�� ����0�1����"�m���f�m�7Kp�C3�����	����u�c���O��%�m�|�����4���f})a��'�C��Ùto��g������1���E�h����y��{���~9�Lg�N������A_�b;��,��`<h����UR�rG�1��y���0��Bc87���+�9O��`<�(�ĩ����U��`ff�
���Q</�!^�8R�a�
Փ��s#������ڷIt�6a!�V���/�*<�!�v���jU��kH�� �,.�Y�Jg������j��V���Znq�S��D�GH틋�8du��P�,A��q��WX�Y���"s#m_AEy�-F>'�=anc�8|�Q����Rp Bnc����o9ZKk��Z������i���d����{�����f]u�!]i�����l�M&�M$h����./���?�8oJ���;�E��S�bU��Knc쳺�	�Q�h�Þ�����NY�x1F�Cnc���k$��f���[nc�U�����ZU��6�/�ț�П��?_�̗��&HU9G���t���6�������f ~qmIX�&+�~@��r^L�4�V|����A�͠��؛D�N	5Ƞ�f�>���m��8Ơ�f���$��*|`��fp�w7�߄jVTX-8Fn�k�<5yIykx^�����X΢bMzБJnݯ�Lz����(�6E���4��>�g���[�T23�X����u���!]Ǧ+�t�-���=�Vi�A�=!�-n�Ƒ Xw�lBȭ���=����)���� �ܾ�_�a�!��\kBna</���� ��)s�a_��ni�(�0�1���.���e|�\r���z{7X�S������m������>w4����h�oAY�DUN�������t��@gSiLm�Rx�!M4�m������bB�B�A�JQ��Q��H�sc��A��Q����`����y%"!�1
l��H��Ӻ� )�1
bw��n4.�N	BHm����)z^D�ZT���兗�QC*E��y��38�i� ���
@A�����j������w!�g@��7z����y�{55�
���O;S������A�͠�����jb�s>���zn�SP��9���)H�=N͠U�q��Cd�`<�,_��
���h� ���A/���2ٕiQ)t��B�G3����I�}
 �6ž�o�5(��1?�7r�b7���~�S�	B��\}� �Tq�=�!�E^~�}Q[�)�(�ܶ��W���mz��4%ȭ�W�YY���������K�D�l\�uE!��Y��6�~�niu� ���8���w�2:�������-���L0�1N��]@E��%`nc\�g^֟m��B�(��Ƹ�/�����	\a��Ƹ�_���A���"1�1J�{J&��նJ����x��[hZ\�>"Q��Q̿s�He�_dW�r�6p:M4�2��k��um��b�?7�(�=H�m���B݃��8��RP�)�1��ݢ��s�~���>;p��A0�}��*��|� K�|O�W������=��4p1�p	Mie� Pr�\�@T�?�s��{57+~G������1-9����� 1=9�n��I��W�{^�[���_4�N�#9�~��4��R���N�LA�[*-�{�j������}.ĸ���vF��N��*2�n�+8IBniT��G��2�P�A
��Q���#}(�
��ȭ���/4�4ל����F��W��Ƴ����r��N�� ֱɵ���#�/T��;�	���Ց�^2ZM���T�Brw��/K?o_I�}��W0�;V�ˍ���ͦ1�Җ�����N��3H!�;6D7S.�-�Fo+|O!�;6n/�|0?w���PA
���N>��U�8R{�/$w��_�!R�;C�	��c��͔G
<��>�}!�;v���Dd��Q�Brw�7���*m�-�=��ݑY_ʫ̳�ͥ���Qrwd��,w��+́�<����~���w����:��!S�e��]�k�2C�^����|�	� `rǛ�yJIX��1��l�X�g��{� ���L��;�?E����rCX�W42�U��h�'����2�y����_���!,e�2�q����濇0�C0���6ua1N�37i�O��"t��p������b7�F�9��/J!�3jy)���q�>J�Bri�ӡ|�Y��P�Brk�����{�u%:"�k��_n����XM%�{�~���s�^p+����^�"uemWf�5��㶗L�<��罃 ���x�_X(�U��9 J!�;�=�@3͹�^g�\cJ�r�؊��|*r($wG���UJҘ%H!�;���dmަ�����w�����<���w�5Ph���s�8H!�;�b�~���6y؂�Acnw�Іv�N�7�:�q!�;n_�{�����gtO*�;n��8Q��Ρ�Z0�����#H����AК(�;nT�m�#�sjp������J�*�֛t�FlB�lJ�c|p�~���e���r�࠹��1��m�a/g[����@�!�j�����sc�F���P�CX��S_"�n�Ah�!Xs��������b��zn��Q�HA]P�'��'�p��Cط�hlTbFrW�]�ng�� fz������ڥB�u�]��T�S���������A
ɝ�K���� �4r����h��qVP!�5��K��R��ْ
PH���0���"7:�h\H���*]ka��8H!�8���6�����M&!�9�r\_(�Z0k��\g/����:V��A
��q�TpRim_�^�5��/�\��x�������qutq�`M��RH��fL~�����h������3`w���L��L����~�����P[�؂s&wG��9��R� �`���QI_�R=a�`f���Q�?��&S�̦0�;����؁�p�}�>@!�;޿����(L]�W�)�;n�/�=��"�{s���B����dX}um]������X����etn��}�~6���Z��R����a�~m�����st�����7(������Y�5nQo��`�LL���ݸv���H�� e& ��#�7��Q��ybj^����w�:�Q ��1-3��h��-�zb�Ϛ��Q�w�4�S)�81,����z����G#02����q|?�w+C�q`f&���s�mbЈJb�(b�	����*XP� �21��}-�l�"H��L    ڜܮ�'C
"H�\�{�g�m��Ƃ�b��k�m��`C��G����~F`�uJ�Q�հ�p�[���K�
"��m���n��ښ�D�Y�!��MLa�h/�l���y����sKp�(��!�5S�S��$	3�a?�V�H&n}�p�D���!�X��T�.���y�F��n�}@������t���D�j}�� cf;$n (O��S��`f;��~����� :)f��q�k]7@�Y�h8�l���/��<�Ɛ�½ ����@���@��� �l���H&\�٢D��טnF(�ƞ&��y��,I[���>U��\�o�ۙ��܁���G� && �\������6J� e&0�b�s��+F�f&����~`t�f;�ZbJ��@%���ڳs�@�L�%G�Ll*l����rs=���tc���������� U[���cffӟ��T�M>wQɌ�L7*��l4,A���Tv�3�J���� ��Zx�qRdW��ј�!�[.��n�:fAf1�f>9�˅�v�D��o����s���4� ��R��i��L
"H솣4u^`t?�OC��Cb9E�W#^c-�ٓ��� �nFh�O�W;38#`b;��-,ZJ��y�0� �Pv���:�h/Hl�Aܤ���"�)�\���p`�G������}g� ��v8P��<�����y� ������gpH�9������E���;+,Ҡbf;�p\�&�Һ���d����O��h��s�'��vXu�։)��@��e�Æ��aa�]�l��H���-ʊyH����s/m��o�v�l��8�A;JK�
��55�!F 3����&Ǭ���M�� e& �d�މ@�-(g�����[&�P){[k1-3���$2����E1=3��
Ȗ�P�X� '&0`�3,��y��	ty����$1�:#03P�v�tV�pQI�`"�@�YOW��A��p��独�qʵ�E�Y�F%��f=ƃJP�!�.�'+����lz!d�5�!��n�v�D��׮��U��T�Dg��j(/N�4n��2$� ���n8�:L��}Nd�C���d��˞�-2ۡRq�S�psD�>�3ۡ�����&I��u����{�yj0K��v����X2	�3YpAf;��{���������_���S�l��T0M��vx��P�C��IA/��vx^J|6Z
Ĩf�^����U��s[-������׵3�5ev;Q�����S�s�)(���g�י��AA��v8�bC`����V>��@<����k���S�y	�/YQ�����`b���ԗ��z�V F�2IX�S�o�zbjbX���)�j%X�J�@�L�o7,��N*gj|O�g&�~������F�>��	� ��`����1�#02�����:X�~wG��L@�?W�и�%�> %1�
݅�cT��f�A���vU_�SwJ,A#��ZXu91^t��J#� �6�5��qkZyB"�,�7��,�13�a��sd�6hJ�+�!Bf5��/fN�ܫ��2�a9sk2vݻ�1�f�尫���$�����a��ucU��1����+ld5j������"��^�-� ��v8:��m����h�d��q��I�Pj�RkpF��v8�W.�v��U�m�4	3��d_�����F�j-� ����6���)D��z;D�fO���^���R�*�u�s���2�����@�f���D@��P���Z�g.���e�+��Q>w�gO�f���6	We�;����sRZ|(X,��Q1��@�g62:\��i1�����A �#��(�>P��_A��Oa�1-3��a��@=����	��8�LV6-���o	pb���������� ���@�5����~��Mbff2|�o����$F`�3,���e��75�Af+�۲��9}(��h$��Zx;�B�<kk�[�9� ��R��r���q��D�XW�~O�HM��	j$6�U�? <���BZ��!���-׺m� ��},"H���+da��fH��+%��p�����3X��������F�&I������~�(�.d+�		��s�`,��v�𥄏X��hM�j���p��O��Bk��I3�!�_;?��*wff���i������ݣ!�V���5�}Ł�d3�aeu�����>fQ�����Zwhr3C�=�������vM�Ϛ�w�zAf;l��X0�7�� �������&G��R��C��#�l���.��]眯X�z��C��N����<�g%�>��?��C�O� &&�H���=��4��X_�&��m��cjf��j	3��}H�h�	�χ�I�XJS���}�g&0�����V���pf�W�W�e�:uRp��&g�D JY�}`f&0��h��ɴB�wЈJf�/Rr���fA��p�_;����77�BȬ�78p�i7njA��P�o����k�A��P�?wN,�7N��2��h��Q���h,Ȭ���"
Q�i����n��Ws��X�	�`���Pm�7a�&NB�"�^��w�u��y�lrdW�2��^��y�vV�S�����������E�� ��vx����:���� �l�g���Ϫ![��f0S��vhſ��w�^[���l��^J^�>{����M� ��vh�߇j׍�Bڝ�K�������纓��0�Ji�p��+���X �����,�x˳����ۡ��W~��U����i Ab;`%��6(Om{�B �w�����4���S����3�ﱨî;F @G h��A�#@�	�<�wl[����%��	��^ތ��)�E�0F�%&@��[�$�)�z�f�H�3`��$�X��	c83���=���Sw-3Fbɟ�$�5�NƁ����Eh��h���]��Jf���`4��N# ���/��5}�@Z� ��Zئ/|�����և ��^��>��0�YC��d�^��@��Z�#� ��V��n��|o� ��j��"R��u�O]� ��n�͟��b������r���S7�E$r��E��pI��S�r\5h�3��h�B�?� k4I��v���_-yN"���f��Y^� �M�����3���~ͬX��Z�S�9f��)~��Ά8D���D���˫�JT5�]�� ���>��:��f�3��z)�slO�V�>Q��P���2��L:g� ��v(\�}��>ҹ� ��������z�)(X�	�Rf;��k>�V���X>��~��ǋ�Z���K`�_1��a�1f� f&`����E�.��}����&����n#P3��ZC��,:�^"1-3�{i�g���������i�/&�s��ti+83��O#ه�����	���x�R+��O�����5��6o�ԕN������@�dC�3�hd�B3⸐��
l9��k����zJ�qä��@H�z���x0�S�.+� �*�?_3Y��)b5�����H�ֲm���@�X�o")um���L� �*���79(s�	����6��t�y��E=�T��PQ�;���e��+0�*a��%<iCa��CLl�J�}�{���30��.��I����d�l���pI�R'���@�l���?t�ϓ��N��bf;�:�M�D�ظ�BAf;l/U�:�C����vظ�����B��lW1��]^A���\>��v�q��5r��~ݶ��2�a�5�!s�gKz0G��v������j�T�v��o_���#��~��̴����@���L�1�������C�ƈ�V� %&0��%#n,L<P5F�f&�>Q�~�q~&��	��f󧎇�ֹ�i�N�@�L��#fj�
�����jn��>�so�1#3����e��0cfbR�侀�sFY�����fs�kb&�Ԫ- ���f���
A#��Z�տ  ���r>�K2{�N_闩OY���OE�     ��bx�ܗ�5e�u*w(d6�]�͉O�w�N@}EcAf5���`�8���n0E��n��׳c+uj�A�2��>Ab��Z�fE Af;<s�8%-D�f��s��[�-\O�,� �Z�nF(T�:u7-;� ���9�S��f	}�3��M�ܤxs��"h�[$��]n�w�n��"G�1��"/Od��ť���� �n(^���͔�.���v��yAn���"W�0�n�|�`Fٻm�4	��F���4�Wm����79�2˱�
#�F��7]
>G�s%�W��	��lc���1��R�x֐�"���b���#� S#�/����>ve�!��*N7)
��똭�CPS#�T��2�{0��v�� �-#��?u��G�3#h8ܤ�Ա�3!Pp pj쯫�rÀ��C0R#���3���]P��`fFЩ�<��x�i��Z@�Jj��,�R���� ��~�E}x.Vƴu,8'@jA�^���	�nԭ#"�6�;)�U�g�P�\=� �"�2�~��M�ʭ��XH툣��h<��C�A�AjI�:I�6�ڎ2Hm��˻�|�w�I3������ĺ+p�:RjO���ܸ�p9��
~֏R{�*~%����)ot�� S{�����a�;&.&Θ��̗Z�d���P�1S{� �y�����R{�t_���jVH?e/R{����BR���]�R{��N�ij�:c0o�Ԟx����KV�`΄�=Q�׼�n�ݙa=S{�m�}���A?�Ԟ���nn�g;_��뉔������5�i`��[���7ۻ����ϖ;�E�4r)�3I�͍1���/kV{�m��A��Pj�eQ��M��m�������]����\#���F0��*��S\?���G�S#��R��T+7y�N���7������.1#5���ԑLG{�9�X0S#�/�Iw���<�jT23 � 7c/�d��s[�RM���v��d�Yl�v����%L:�d6ă(n��H���Q�w�AfE<8Ѝ�����U��dvă�_��E=�wht^�,��ȗ���X����@0Hm�4Կ)w���l�'��g�Zi���E�~Z	�2���J���٭#�׏R{b�^����G��� �ԞX��Z)<ǘg�Z�눩=��_< �BS��z"��Ķ���C�`�y�����f������O)��S{bo/�>����Q�`ވ�=�y]ԭ�0�={gAG�Ԟx��rd�u�2wp�S{"���]Ixn�Z-�/`jOd��d���xZ�)�'8ޕ�3Y�%� �'�����i�A����7`����)-ϊbZ��^A*붞�~J�}� 3#�/�r�] ې	���R#xI���m�i#��fF�h���DP����bZj�o����T=rbzj�~˝e�m�s�Ό@���d��U���ϩ�������YhW�-C�+�`fF���;�6��6��QI͠�#H���¼�#R��
������cF9� ��O�L�Z�Z?�RR�n���CkN	N��Z��j�bmXo�A��������yU1� �$�v���\����\�%1q:v�;���&��/��M�������.���2�c>G|�Wo��]S[�Q��Uۺa��� �&�k�l���5R{�K��R_Vj����Ԟh��ڨc����2��v�#�t�m�v^&�d��oCĭ����
���2{��f�g��Sp��X��՗%��ڻ��z�AfO4��cp�v]q�%2� �'�?[����vֱ�~*f�D��O�������&bfO4��*�b�Tht,d�DC�/W�h�R�>��2{�Q�����#�_]�g�����?�G�C&���KL`��~p?��G�χ،F�.o2���tp���L(�~[�dH��t����W��T۱�e����C@���ٸ5����zyC#03��] Z^o�$@�	h�#��G�˴�^����������q�:�0m�h�	,��e��U��}!�3X�F�� -�F��k'&���?�k��"�˗!02��f��5P�ׂ���پ��:�Kηs2����õ�EZ}��� 2[��Vz�)�T�A�����0�̻ج܂2{���eE§�J/XAf1����@(��`}������Ƃ.B\�N��s�h/H��T*�^ �{bo���\�����`N*c�`| ����^��F���z"Hl�􏳤���^?iB�E��@���/��fAb;$��$2�S�F�#8bb;�$��`��\��P�[��fQ�с��	����N�\T[��B�!э��:��Qw��bf;$a7v2m<�����~���M����vX���Mz�?�%�2�a���m$����]#�l��<�y�9^�� ��v؆����r�0�Z3���.*��Ͽ��%��?E�2��_1��@~S��f91����������gQ�@ML��߭�|�Q�,h�	��l\%<�Ev�#�3��5��5o�
΄�������(@�S��`�	��g�@�l
���L��kY�
��l;hD%1��g������薶ld��9ĭ��s-�2�Fd�¹ח3�m��T��Bf/4�M�:�]GA��P����qGH�S�2����.��Qi쁆A��P�� �N�8Ζ�#��*Ź!=7܇Vt d�C5r+���K�3��ݭ]�{�Vw��-�l�k.�eH4[(�� 3��2�r�4�]�d�����ˣ�ic�҃�"f������ޏ1�"�l�ۦS#c��j���AAf;<��nN�v�YA;��vx����V�� zJ�0�����j0:Fd�Ck�?�5P��TzAf;4Y����9�VN���k)>LZ����:%��Z�_��^�Y���IR-;p��
r�5�E;�K`�k�{��� �3c01@O��=�+�1b(3�B���]�������	�/�
x�uޓ,���� ��"!j�czf,�L�*�5��� g&�����^k��cFb�~۴��ơ�i�>03`�����/rЈJfk|�}��F}�l���;��j�ҝ'WAf-�|���r^���!���_n����sc�,��w��h:[Af3l�\/8���ƻGW��j���I�H;.�n���vy�K�/��`���sw7+L�7T���2�a�����ѠN
zf�CF$�`�;D7�2�!�`�� ��'�g Af;�3�\ ��@����\���p��=��ۺ(�W�l�c�a1�����N����=��A`K)Тv���p�Y�F���	F������
�n����<G��v89F*���fp�3ۡ4�b���;%D�(��6'�z跅*�A/��v��oV,��F�m�Ap��R�A�hr�w�^��~Y���~��N 3����btT���O�Pb�FI��i��S�A�@�L`z�Tڐ�8(F�e&�%H\zcdӆ�bzb���|�}x�õgB�L`xM�Un8*������AF}�18��N��-������iA#*����X�YWl�C�l�Ņ�����0q� ��Zh�GG��L(�k�hh��M�zPl�f����^�X[)>[�E�(�E��[����Z�EW��j؊�3u�2�����a�n.P%�M@7E��rؠ��sM�A��0�6���pZ��[��w��aC�/�6_cZc�;H��aC��̘G��(	�a��Ż�:�4_�� ��v��?M5}�b��h@����_@W��o��W�l���O��h�?�؃2�a������S��\��+�����4+g2�d�ú�\=�6Tl;+� �6�&ɜ��%&Qf;l|��a�ƥ�BA5��v��p^�A#�yj�A����z���l>������
���0H 3�/�^�����	�~'@�	p�/穲��Z-F�f&��+m2�(H*�-3��k��k�s�A0J�@OL`��>�Vd��}R>�N�3�6�4a$i�k��L`�k� C  ��-�"F`&&0�2�\��5hD%3��H���Q��)#@��
�:.F^��JG�2k�����\�h�=�2{��?D��-d9uCAf1��3� �9}^d6CE_g�;D�
ѹ �*���[ko:/��&���%��螶��`| ��p�����(�0 @f;\ß��V�����l�k;G3z��6������py���L�}4� �������2��"f����jhU�yc�):2��A�`�,��.�`3���Vئ���:E�l�V��@���%�(f���߯�tp?�S��vh��3^?��׉���v���۰2�0z%��^:��3���*F��{9>F [L7V���n��"NkP�Ң�ީ������j��}�#��	LqWK��������w���m�}|��V��R-F�&&��������	����`5t�q���#�3��e㔏��pձc81��K5q�}�,{������~-�C��A�����L�6�_�-�TUX5��A���7Y'&e�S�2[a�H{Z��"Ȭ�ռW��jѵ?'(���U� ��{l��Y��	N'W�R�秘x Af3l���u�ے\!��� �m�XpwAf7��߽g��� с�Y����l��UK[�2�!ׯQ"49�f�Cp��殻a��HA�퐍�d�yH�Y�2���篱��@��t���pL˪p�t^I�d�l��|��ŭM[M�sAf;��'l@����( �H3������,�u�G��0�N��/�����S��v(_�e�>�:�DBf;��/�kgOl�O�2ۡ�o�k���N�����P��t��U��6A?�@�G�T����`�q^��! m��z��LL`�'p{��<���k��	Pf�h��A²z���	_Q�(o�@��1-1�M�X��7�������t;�N��4���� g&��<�x.���hj1#1����)����h��	H��T���VQɌ��˻bW�u�Q�����X$�P�꿂� 2k��/����aձ�2{��x�o���m�7F�Ab1�����������!�r�d2N��)� �2�:f{ϴ�Q�A�ݐ���5�#7LlM���X}jK��O�Ǝ�����ߵ㹹�r�|�%�C���tX��:Т(��vȨ^��M�l� ��v�""7n�8D��\��!S�׏��kɽd�CR���J]{�6��f��k�a�3
�fA5��vX[�IN��n<ךNAf;�b.R�7|�q�(gO0�6�"����h�2���\/V����(�����o�?'L�ppQ��v؛�n�<�I��]%�;�t��S�6=�Z4�5���+g��C[�e������/7�F%Y�*�N�2h��uKT4�0!H�f&��-δ^qԲ�s��w-1�>u͍�u��5�>�3����34ݝ(�83�	������<����HL`�
ׅ��A�#03h>�wQV���x��dF ��m(00� �
�;>Pb���Ђ� 2k���W��[�\D��e{Ei+N��@�Y�%���.]Z=Q��P��:��ΰ(� �����)Pz�1��bf7\X�eZ����3��u ��L��0>%�2��Z~���jEy�cw�2��F�^��4�m�Q��p�	��&�j�3��^��C�]k���<� ��o��h�]Ă+f���L�mR��u����,�r�d�Y���D��<���'V����m��K�C�����C�l���o����"A��p�_���+Ú��DJl��y7*üa��H���C��M�t��s�2��_Jo�����_3-�~����ˀJ�	~'��	��t�����V� e&`ݧ-y�@������ V�ĉ�t��$�1-3��� �mb�����/R��7�1[p������jc�;A��cFf�Ki�m�*�Zp���(w�)��|��5QI����:AӪ0���Q)�l�UƷDfJ7�-�2ka��-�*�-k	� ��^�v�5�mȾKe1� ��b�ɿS�6�b�ٱd6�>|'z%�:,-5�ƐY�n. >ݴ�6%�2�!7�k�ʥ�<�jAf9d񻦛��E���bf;d��� M�"��v8��\r�V9�rd�����p5*g,��3��D�g�����d���ӵN����}�#d�ù��e�g�n�:�d�C��Ԉ��Vla���d�C�/���t��O��m3�l��|/�a��pq�2ۡ��:��R�QAf;�_����H?����v���w�4@xN�E��W&�Hy�.��>����F�;_N�t9��CN�`�Gʇ�,���-� S#8�&��ҫ��m�ʌ`W��1�Q~�[cjj_Jg=��	�
�����'r�4�\/�K]1=3�S}Q��et�P��F �L��r?�Gj����q
������w33��/�\�6��WL~W�����/q���Z��H��~h��$A�՟lgU�̂8K=_nY�1P���E�l����m�q	XA�q���EFng넿�\�� �#N�ǝ&������%q�����Ӎq� �̖8���n�kY�:d�Y'��_�٪����)�=q���B��R���Np]�̞8	�6���j��2�쉓x�"��ƌ�� �ԞH�g�a5Tl��r�AjO��o�,�7���+��ŴV-3<��ĺ���"�N����Ćޑ��1ޏpБ0�'^+vs�Y��5ftNL�m��v"�Z*�蜘�;|{��R��]3(zȖ�;���2[]��<\�Ԟ��'�v'�>J����2�7qVn{Y����"`��B3(vZ�DC����,(ښ|�����R#8�S`��W��#���� _A��m��܅18Zjӿc^��R��1=5��K�"�ވisp pfo���Oo޽;�^0R#��Bfy��f���bfj�_��(��J�ըdf �s`n�=Y� ��~(�+0!���,�ȩQN�R=�����h#� �!j󆨶�^/�ى��Ԋ���3��H��H툫�[��]u��H-����M[���DHm�K����w�bK�c!�&n(�y�`����+� �'n�eF_�\�1Kp]�Ԟ���T>k����$L�|.D1")Te��>bjO<��\;���am\1�'��؍�N���{0n�Ԟh0���/O�HtNL���[�i��)�+cgL퉶|�M�w�W�<�.d�D)���O+�w�SΉ�=QJ�57�:[c��^f�D)�
!O�>+�]�2{���j*�&�j���1� �'
L����������:����
��̓�����7����aS�1���M\tV?���`/���r�3�oWY�������F���� �4�u����G`:�2��,���F0�e<Un,M�pj�^ :�Ö2cFf�6/.�V+�1����p����;%9�w䞘��/���k�z�R�a��B�C׎�˜��Rb��ܵ���;|^��6�^���MwY �vt>H��7.v���8j��O2H�]�k^ц�'sm�~�Z���f�37.!���D��f���mL	�2��DV�l�v��~!� �'��ӈ�G��hVO0l�Ԟ8��S����0�e����\�S7o��d'�H��'�I�X{�{��?�Ԟ8'��I�)�4����/I�v��2Z�1�'
u��M�B�a?�Ԟ(��R�vX5� �'��YpȬڔuID��Ԟ��3�	-�{.A�=Q�/=�Y�!1M��^��D=��P�K)�698(�'������?���      �   �   x��O9!���##�%������RD)��3�Cl��V@]�|���C]�y���3`B��"=�� 	8�7��k�̥���#�lm8̥~�t�Td�nE���L_{��]x|Ο�U6BjK��u��͌����b�/zY�      �   �   x���K
�0��ur
�2e���Y����
�B)�_p�����O9�V�R4 ��X�*�=��M���>�M���1�a�m�O� k�"�S�U�cdB`�`�F�.FNBW�?,|	fą�!��L"5�[�֞/�O�È�c�zV����{���[�      �      x������ � �      �      x��]��6����+������x�o��o����f�.W.�cIԒ�8�W��_7(�)Yr{�xj�r�E�@��FwSK�}r|�dY����$FJ0��V���̵]l���x���ڻ��ǅ���|9��+7]FR͉���ٜ���pD��z�ؒyݍ򽾞�]�yw�R��q��ع9�$t.RrV+/½�yp!�Э(�*#!"c&RnS��)g#�F�jO8��cʥ�OJ����,̀�R=JeH.�乓w�E>�(�@&�@y�[�I��G�ȉ@�̨T�=&�	cc�Aa���s�
�<�(�k�L�^pn��ˣ�0ޛ�,�HG���*4*�x�'�s&���
���&ʕ�F�F���9�\�坛H�O�+k$�Lr�t��ջ�L�(GZ(%�S)�lȤo"��z��_�,�Vs�
��bّ�z޹_I��]/")�K��1:f�>�Wp]J��Hj�׃���M10�ؽ��ߣ��3�"�����K7���0��h*��/s7��G����!�/�#/\�l������՝��~�И��j�`����tݢ=��ͻzܺɵM�\3k�mW7��bYޟ�P���dZ_�_4uX���}E)r������M��z�m���RG3a��n��d�Z��������L�tђ&B��<{���0�.?��D�������o^�տ� ���W��:��E������޷���t����+e��6���5q�� 7$3�����a�S�E��`8��{�I����g/<#N�vvJ��'���ŏg����x��y�\�����-^Ȥ7�&~�<�]��������p3v"$����BE�XF�
7clēb�k��M�)�jL��4�.> ۚ�'��0Ɨ���[�/"����s i4U-���	����p�.���Ѕ*v��F��͘�jj�6��7�n���חU�W�M���B���	�%��������ɏ�C���+�b ��v������lj���n �e*ʑN̙P0ϵ�M�f���/�~��C�?u3���ܑ�M5��3u��pR�>�_�Ecc(�O��
 ;�̶�8T�K��eյY���%H}	 ���4���ʪ2s���$,6�1y[7o��~�О���e� Zu��Y���� ��{�Ưo��O�|L^&�&��JH��Crg.D�l�ƽ���˺_�(�|٠r��&dZ�؁����n�X��j�'ȇ_Ϊ�q9�%��X��uӎ|��7�g�YvK`�ܓw�ڡ8���̡�tET;Bڞ��[���|gW�K@RO��Y�T��	z��5�
��Ø��d$W5�Z���R=�p����,N�v��<S�,��z����T��WЬ��Q�B��|�R_竓c1� �l�����M��0�(�M�AUu�1���=}�9=}N^��xqJ�����ի� ����t� Iq�how����^%a�ԯ���"�`"l=����-�� �FLU�Os���7�ہ�S�;'o����^��j��+{�u�{����o9�8k=��$�pUʴ������`hK�MX�14����JZ�qh<�)C�&�ծ�y6
�JF�t6��Du�P�[h�%��++�K�k�a-�Fu�[]P�o���Q���sn��k��3� ��K��2��`�|*t�CB���e���^^NV6��.5q�n �w �p�,@��Ё��}��Y5k<9���C���K�@��k�W ���cNb��dk!�SB�Ct\����������U�1yQ�%-��@:���&n�
�g��!��¶�L����z~��ǵ V���p� ��Ȣn�
���BvXs����5��@��l� ���S�<���%ꮛ�mHD9����Ŀ>?}��%��la���p���q�	���I��,!p�����y�04L��}}L5��v��ОjPw�A��~����w%Ɯj�}�Q�����{iF���'f��ꖽqB��{Q<YǷ���VJe��i��H�j�9Voa����ڋ[�S,`�'�#����[N7�큃�lN�粂�K;���I5��G�s�(�o�Юvx�{ ���:!���4�x�0j]�k�����7yoַd6�^7_�W6�+8�0��~�-io�8��.@�6~C��~g�)�������]�����&:������o�"���q�f�����ӟ<:;����Y|�z��Q�'T�z̴���*��$�M�"�TɥL�_� F+���6zBT;_F*�aA>,ȟ� [4�����~�]8۟���!���Q���7��8�v!����$/���>��Z`�%X�� ���?�ڏ<�S,���51ƀ�P�*�Ҋd���G�u����E�X��vL���g��=��!Q�� *)���v�f�!�&JZ&���6�'��~��	�$�f��"6�WN�T*�Ǆ`�2�����G���(�v��܁:�,�����?��~{�.A`㊁Oz���Fe�*�XB)K��$�P�(�w�J���Bf
��+��Jq�=@���u���2c�$��ե�g����YG�!�d�%O�*���M0(i�(t�v*�U�W��bR���B1���f���@|�z�����%�+#��VMK56��f����m��� �[f�	[�l(��g>t-}g�"��#�<@O��i�8}�NF����������"��fp����Ƴ�n=��Կ%3t��C-�0`G����i���n�џ�Av� BC�� rE0�\�{��\w0���r��?G�
�H�(�= � ���la2�(È*.`W�h���cs�ʷ9⋴.E��v�.(�l!U%�V뮲�������M��d��h��}���W�y��s������Y�݈�{�(����qaf��R�Ƿ��'OɃ��������xD?=;���ڇpj@h�>a�D鱱��Y��5)2�V�:2 ��I�@-/Ur�6����� )
����'6�4'2���_���K�6�zk�(�F��|$�qko l�)�����5�N�`���k,��5h�(�׏c-���I#��xT�#VDi%~�듢'���t#=����'��Ny_��ʮ����5E1�R���J�J�H�u؆��c�).v�rq֒��[�G̄��=�FEY*E߱&sAqB�XqƳw�E_���,/�H%P�,Meqw8c|,mYV5� =���I+��d
��6�;Ěsa��>��>���!kE��Y�;�خ(���5{t�h6tK-$a(��%�͝t�0
�|k\����9��m�9+�S��c���;w�8�c0Y�U�,,-�k�Tf�WZ4�v������9V�2�fD�2T�Rp�D���w�53E[%;r�h�
YS�0�Rj6J	���������QX�P �֔�>��Ɉa�7�Y�dҔ����ÚPc*
��e�ac�����&�K��<Z��0�$�UK��S �Yג+<�X��:�����&b"�]aM�SZ^���o]!J�j�ģc�W�՟b�|kR�E!M޶Ѡ�b�83�E0��v�k�4}w8Sl��)�Wl ���^�����(\���?��{G���U���[`k�
<�w��|�H5X��~�T-�.%�R�M��&n�)=���
��ʹ���f���0�����N�B�BR@D�!��
�x����%-qo�*[=$V��e�Ȱ�6z>%7T�p4i�G9�1}��\"g��b�����4�������V��/zڶu������->�ʿ��_��&�`�zFI�m>�H���*	�NK���G�7Kt��8�3 !�ۮ(k��	��V����j�0}��l��6ߝ���g9�%o�t��gW]�<Ƅ�8�B��1�>���0����h���=�����ӽ�:�ZB?���#@��fu��ɮ�繨�
��y;&q�Kt��xU㰌�)RF@ ��j��Z��!�́_��Ͳk��� ��(�I���pC�jL`���y�����矛����~�S���o���k��rZ-2��N�.��^���?;���cAO��_�]<z �
  H?{�ӣ�s<6z��S���S�Fp|�.6�J\J�����/۞W��`����R��U�1 +S�1����3��N�9���q�i��]+��ht@�}>�b��bEvvZ�}Q03@#��+�+-�B�N��׆F�(����3����r�z��#Nu�&v��}(���h��`� !d��_π�Ob=r����L�	�� �A5�!}6�t:�Y|��� ��ށ��1�g�<p�+*�b�H˧��|s?���S�!���))~闳U�[2[�	��ߐ1
˚��n�8��
�a��|T��xy�Ch/�x���qW YT��X�Y|�b��*��n�`�e��q$��֟�!�w��ӿ~4R�@텊�O�A���ɣ������?<���]�H�>��C�x�+8�ڃ��H���ce9t�]He	�t���`;��gA?�E�v�4?9�D���G�Ri!0re�[[���2��u�?`��a���c��6�����@�/��Y�́Yӂo[kk�r�筻F�V��o����EG��
��'h��� ������13��4s��1͐�A+ ��|S���O��t"NV���X�Q���Ơ�O6&"�ص�[LQ�OB��k-<^�u �겏Gq�d��_1�o���\�u�ދ5c���	��X�R5h��bBh!�x�F��� ?�vU�@�L��k�:�8l�(�&^��w�����J�Q�]v!�J�_�'ˠ����|yF�>#���=߀���lTbt3On�-�,|Q|)���=x���И�L��AL�Hc�s��E��ĥ�1�N����S�d�q�;��nYY���"���� /x�[�"9&�*���]&h�=/��F<yS��*w�}6������[ݖ�e�e�m��9��^����cc�U}�g��5�a�����(K��Q�
��dx)ƌ���;�݂��Ë؂�s̥9Qw�>���w��l�}N�Gs�l��
O �k7cN��j����~ڔ�qﯸ�k�p��l��>n�W�wI9�a$�Mg�T����뾹(�����gȬ���Y����j9;&0`�|�,����o}� �H����=�k�sO뼟�z	t�m��,_�q9��s����������G�jWM�/y�M�l�v�gU�E�.ɲ�E�~o,�����鋇ߟ���@^����f�]YF�/WR[@b-N��Q�T�>G?R΋��`�z}@$)�	@��(}�q��Ǉ��Y�7(,��;�+���/�n1���0kVJ��x�ȨDc�)����刖N��*z��2i��0���
�A�>�I���;&-p���2�����b2ڈM��Gh�F�HR9[zjo�\�\}�i�����6��07�6�[z�]�f�Q��s�����9 �M~ ���N����RU�6W��5 e���4l��L�̼8o�+,Ȃ2��a�j4{�1��m[�+�~?h`>���+��U��6Z�H��H\/9��s^g�q����{�Fk0���i�y�o�{�>��*��u��"2�����u��:�&�S�E_F�O@ˋdX[��iN��5)���<��Z.Р�z��ioW>>���t�u�R�7k�(�r�S�8�g\R�V#��$�[�5s���^����>����MMx�U����)��n���]����)�|�u[�N���ZN��n�U�0�J���}ZY��Y�� �L�j�E(�M6��M*��O�8���u����q��/rž����1�cc�{A����F��] ��R\��8��a�hݾ����f����1�3c���r&��
��i���Oڻ"���8`��w���������B0ou��¢�l�F��4��o�UI���)�c�~df�q+��%����1�_y��JZ���z��yX_�gk󵡰w�5`����Fq^�=��Ś
��j#�������+O��C�me-PY%ÞKە�J�,�~�FY�+�($�eZ������e�ӔUjۻ���,H����s��F�t֗2���W�|�S�U�/.x8�w=��>�����	pY+F�k�C;s���w�s�b�1��`��>�D���C4�Ժ��q#^j�l�o&@ߕ׶iɍυ�n ܢS�[+���oMq��	�I���*'�����b-�H�6q�
^���p�iC4ܤ8��`Ǖ�{.<S<��!�\b�$è*re!����y�>�4)����"X����gT��
LR�J�i�Zb��e���6I��뎤�X��}2��$1�~㍻R��U��,z����{Ѹ�.��捺���!'��I�AY��L��|]��/��C�0&���m�n+����(��UX�k��H��ٕוU �1i+�w̫�]�����N�Ѫm����N�3X��t@{��*w�]��,�֜ױ��?�_Ŋ�-��q�o��:`�'4տ^ø�9�)֥�o�/KX<��,�cL��_���w
tw=���r�ʔӌ��nc�7ÝG�[`�<�8H�̵-���kj�A[Iw�͚�k�\���u�?�'�?zD^�=z���烽�n�?[]��(l�1�ֳܽQ��7
�w
�g�p�'�8��C�b���O�Ch��	:n@h�F�t��*�0�j��Bz����q�c��#���[[>��Ym�H���2�(n��o���r��-_�ے��Ӿ��\�~��/��&4�      �      x������ � �      �   j   x�����0 ki��>"Mz7z'��H�@��w4]N7��@�:t�!B�xu'OTӓ�8^��i	�Jv|8bL��`n]�R@�VAE�na:d�'�����>)�      �   �  x�͛Mn�:�ǩUԼ�)��Zz�?�����M�5*���5����Auh�Ξ����'�q���n� ɒI{{#��f�9�A���t�ZJa���o�yK�� <�F�@�`z��%����y�_�����:��j�����TS�~f*J�N�R!-��>P�(ͅ��j�|@��&��6��1�k�Aɿ�M� j����Z�O�,��$�ҳ��^DZ��(Q�0�it_Բ�e����f�]�&�i�}�
���<ެ�����FD͆��
5室�}MKއ�J.�LԼ�!��s[�"��v�Q�D*�yq�t#�������l�]��5-�Q�!7�;�&�1��~T6!�	7;*~mÝ�`�T̬��{��cE�<h��5(;��E�wm�����@���#�G�w%�=�%h)��CS������ 5�D�Li������Y�~*0�Q[�H�Lo=MJ	��+?{j��LVu�߭P������3K�%h)��C���g�3xL����Ȕvb���L��S��$�vb�<�<3i3�i��ވ�R�0�Ǌ2���kb�NLb�����J����uM���T�R��zCHYf�kbt'�Av�{�9��<E��ۈ)z�����d��*�51e'&��̔('�ZJ]�sa'(E̗�+T��R������I�*�����������}�� �0��~#u�����;��o\�S~}��ߠ��sO�J/���P>(px���Z
��/��Q��D
Q�{�E��S���3S���z��pQ��4�_���3ū��Hiq�x'&���L�:|�J�b�FL��e�4`��5�����NLX'�3���7����ѝ���v�T#Z��e(������X/uT�bL�&��Ĕ	�%��l�o:���{Jr-��"��vbq�p''�jU/�Rl����P�X��Å�}�[�����s���A��~F���۴ףE��ۤ�����wD)��v)��C��D?;��L���`VbM�NL�#�3�6�e]s{��S�/�תL�W����{>�d1'&��4�H������SL%q�3�F1��mM����cL=f䲞�J�����~>�Tկ�Z�̽�������SL-��`�L��qB�H�&�� �1�����#~齑/T��"щaDO(W��r�R�̔D5���@�.B�c%��H�q�%�Dͬ�T��w�n��kQ��z�#�op�CL�6��7M�r�HJ�2fɋwY�S�	$�I�+TVE����B��쭒W�,�p�٢��9,���װ�w(�ҳ��^D��_�ܹD=sQ�>D��L�[iF�ҍ״���5�~!r����/�tO倹��4h��c,i��1�"�ߺ�O��a4���8G7�cDM�D� )��}M�M��
ٵ2D�9�E���妻x�Ƞ��:�:g�i�i��-#�\��:��������=�T��e�e��T@wT]D��5T�o��S��؆�#�E�]l3���9���6n�(1���9�s����^ ,-���(��ڥ�nE>�k/��y�S�x��L���Q�MŚ����jOg&!��u��y��wO1Ͱ�|f"*m2�51��!�������7��Y�HL�E1��)�\�_�)�DBKs࢘[��S=�g&#�XK��&���=�ԩ���^�!DRl�kbn��SL��{��ްk������=�$ir���$F���yQ̽�{
J��e�JĞqd�\���IHi�.�(�h�J�ew�������_��9E[�      �   �  x��Y]o9|�E��f��&��S���p�H��ܽ-�3�ڒI�"��_q$9��J�cŁL�؜���j����4�SeP���� ij
�;+�o�⧲Z�E�ǗX�?c����6^�e���JLï�6�1ks�����!��e�*4�!���R�A�A�+%dR��)c�&��2�Fi��5�m���Z�fS.���0���2ް2:d����b���Z��o���-��]/K#�T�����?���f���>4!��S}>�-6����X�	"Z�����*��Y[=$��|�����l8��b#_�m�R��J���#9X���*r����Z�Rg�k�fU�����r���F�=���}�������3P�k]��;�T�T������F��G��a>Y���"{��gECmdb�\�]q1>���5Ӆ	�� %v��ݽ�������u����o��\��q0%��4��M��+��	�}%�Bڅ��s�X7��ǹ�y-4_rg'y ,D=�Vgg}�t�^��	x*�����|̻�ݺ����9Du*ē0�a[�$��8*�+���LJ-��z;��=�"���&�Y⢓[J�:J9��M��41NXŔz�*���%e��B�?`� r�� #� '6.�0�-L�e��>�cl򁅓�啧t�W�D��Q������g�8ȒKh����#bjj�G$m� ~���oOM�j�:�7��LK���t�3�q�� ��Ӌd�l���m�_ja��A(A)���\���Z����$CL�:�' 4凮>7ʥگA@אY���8 �t㪓��s$oH(=�ǒk����2�j\}Y+�׳㺄}����x��GB��D�#I��'4O�\XԲvYӋZ:�*[4X�۬xW��u�`�>���ģ����$k^X���#�ת �B�:2��R�ɱyT��B����uz�����8ֵ��+>u�HtWw��
�8�G�}������o�x9�U��C�b��x�/��A���VkX�/�H١F�9���|�7���z��m����. �@|�t�C2%	V{,_��@zo�Sp��Ǻ�P'F�˻����8rHꠋ/�_u�ԈH�$e��pSb�o�d'*���>�#=W�(�&��Ib{����zJ&��&�Ic�0�h��s!h1�R���bU��7Jls��M�VG���w��M}�����m�{Y����G23p_����N:[�I���8�,�C����M��28�w�C��3����Z�Fd���Q��s&J�#{�w����D�G��gJ�AӧL}/�Q���Ǚ>qVܾ�}C����U��s6~��t�m�O�P3����@���c7��v�p_�_�ib�~aM��q�ftO� rєt߯>T�֐]P����U��羴���.�}�k�V#�,�UU��(��Q�Ҍ�5|�|���8�z'�F�kW�CN��u� # ���r�O�J�x�!ޭo�F���֣ ��fǓ�3��_�G8�)ųD5�8s>Υ�.�h��'0�7ǣ��LQ�����7�\�'@8wZ�ы8͌������Q�F��ҍh5h&�y6̅��"��v���xx�jW8<	��?�9nQ�~��>vV���(��e��r&���j��A*�I�[}V���]NM�*�.o���◸����C�a]�,���x��9áwqs���$�G��1�az�BB}/*���n�m�P+�惨������}Ϡ����Aw]�'��Fy�����i��|KRq��t,���~���,J��b�������Y���<���c3-a~����l�K�-�da֓��L��J���������<���nWo��-��i��!�|�q�۞I��'���~W��6�Ľ�w4�Ĺ��I�Ly ���ۮn<�K�y��(�W@tR�ҋ9׾��J��B�ޢH̔�g�|��Q���vl�r:Ŧj����>^]]����      �      x��kr�F�.��w��ӧW� $��ԣT��������GH��H�����0���7��a�Gr�#A��Xʨ�����"	$�k�\�o�����4���}�RQ?p̸o�A�^�"���cڽ�"��|�-�0�Ґ3C%Y4Q�M��̘O�2��Q���(�7�H�4��w�T�D��$�SE6�1�J&0Lb�����JV0������FU����p��Wռ��ݝ�ȳ*�r|/�"Ke1-e�jw��v�0/�K5�ٝy�����_w��.�x�Ͳ�i�}k�����ӹ��Z��[�q<�/T�xm�Ե�J������q�6m�o�}+4Lwϱ�Loھe��7̶�!`*��on�A��Q��*��v�N�,�LU��GÞ9��ޕ^�-.��A��]\��F�K�2.z�i�^����V�^s�3x��+nI;f�@S�H%˿�
9���E"ݔUӗ�`#���J��F�z��K����J��YUq���l��r`��ᒱ������)3^T�]6��YD93�ai��1�nL��!K�`a�R�dI�0�����j��HIV����$�
��{�����៻,��$NN���i^V�lQY��se(���N��X���T�BIX�,�yj��b^���,����Q�.������f�ٚ5\�)�C�;����������-��K������G�1ʣ�qd
^�)��E��wY56��T�v��(��.*���0F��Ib����/^^��D�?)/��Ճ���������xtttn\^��DbM��ixN���V��/W�Eq#g r�e\M���d�h�OI*�(�*�9ɪ{��QI�]��(b��*�,��c�G%*0d\� �Nf@@8�iv@9.��+^��Bsr�����]��$��kR�<�A��n�;^�ްg���	Ʋ{W痗���1<��6����ɝq2�wY���3���fLtT2��h&'�[ULa����M��T�ċ�L�c��/�����1W�X�`�sr9<]u23����ąk��,�����8�i�I��1�aX��N�4΋)�.�����g%�0�8��0��.h,�F����f�g�w�	*0���l^|�W�_�����<���B�t��$K���G>�@[�]��؎���v<��bS?���yFg����o���'�=E��= ��5
T�%�8H�]�K�����`F�q%j���1��Gظ,Χs�-��U1��>���V�����&�;�~G���L�w���hѦ�� ��n�a�7*~O4	��<O�s��W��|���`ޅq�hU�wJN�1l���ўq�&�?�=�4H��4x��	������gyZT���Tɒ�HvV�s��#(K��I�ͬTl���i�Ê�;�<�q�t�.�%�i��^���/���sI��g����q���ȸ�O������,]��k�,�z�.p8:v;Y�ƞoz���%zj���Ha^�Y>�O
��|�|٣�r;;�.��ݳ�A����s���x�9_�1e$�llI ���t�9�+^��Ѯܴs�,|0�Ҥ�˫&�Uȅ����KhR��]Ǐ�t6�-���w"?��c�`��~�mv���_��lX�o�xQ~�'\��ՎQ�)�Z����<A�E�Di�QV��y��<5�)�Mp���*A���o�+|w��?�x\Ӏ��Z�����_�;�IU��H����vC�뀼X�4��:�iG��p7�#���Ħ�$�)���'iz��y��/�ɶ�ٳĞ�,��|���>�����9���ߡ��#a�(�e����N3�z{rl\�???�6��{�=��zgFw����v�f�H�d�E�	�b�>Kt!A��T��5[L#U ����rnA͍!hͥ��h8�h T�0��
���b���'�P��j�V�p_��g�cq���d���iǠ*��'e>Q������&�.��U>��Dϳ��>�ݨj���m�d�k�N�/��Ӌ�#c4<>!�3·��GG����/С���lG��ik:���f1m��|���.���f"<7S I�vQ�Wk�p|V$b�Eh�]�)���`��L������h�M�Kߢ�����4���S��	Ř+��z������&@��MS��t%Z?�l�(| ���z��Wī�: l���12pm(�f�w}�r<iy^b�I(wO�=�~���w0��!+v�o>�p	�K?��"��������#ї��ő��Ad`�kv�5��L�D���6eؕIl��)'�qBJ�iN:`�2�@Z���^[�q��3�������y~hǁ�ؒ0�ҾJ���(	�B]R��~���m�8^0(۪S�'�@)�︦���38�M[%�����탮S�c�I���ճ���Y�	6��M�8�}��izz=f��-/JT������v�C*JC��5�� ��i�	σM�P��؟�e 7n�}y�C��c�ϯ@\�,�s(
z�2 ,��h����Ƿ�������]�:4������������7��������j󮶳�[n+�rA5�����,*���O~	7t����y���,m�e\��L�y3DE��a��W�!��oa����?:9�~xj����:����T DK*hy�[��SB���A��R������Ng����y��>�p�)�a=��B^<����q�D"�p�Qm�GI_���S�Z��^��W;��~�v�o�I�N��#E}6�囱�[rM`Y{������F���+;XiE"h©���H�9��{���m{��A�Z�Ë��jWA�ʌ�WY�*�^eݟE��{��s���q�gɺ�C�d�#dlZ�,�Eڦ��x��?H�G��L��!���	T�G2�zva(��2�$H��p\�w���3�=	�ܻH+5�1�*e�G^��U��F@�d���>�K�2��f1R�g�����>�_��_u��\ �cF���P/��TT!��W���-��S~Yd�=��͔��$�rq�\ͫ�'MP��bܫ�S�)\�Q�05q��f�m�cQ�`*�}�����b�Ss�h�Z�>UB���,��J�̀%��E"�-u��^�U�C6E�>�m,���������0�S�%%�8�bblʎ��o�V�O�ɂ�1��H@ �T��N��|�c��:Q`�e��	S�=��b��c�«L%���ݳ;)T�V�S,�(��(�Q���2Q`4���5����/{�5��>��;Y[S��LR�R֎/�µ� �S'�+�O��%�Kຐ�K��c�H\���EgѲ^����G����p8:97�G�G�`�z=�k�
��X� ����
�~�^ؾ�+����ٝ.�0��H��>����<��s]���=�?@�@#�n�tr�������yD̆�/u5��?��e 4 <�*�$�A��%֥�X���G8�ʱ�c�=]����݌�f�%����$xfI,��5� ��0O�l&cP�� 2=��ȳ�H39U;�zx`s5`
�dl�EN���n��O,�p�0kibDL�k���9W]����̌�LQz��.3�����NZ��7��Oxr��ꜦX8��;�C��e*`�4���`���4�p�.h�������Yt�S�����	ڊ�\��dV��B�T�X��Bg�U���8K�
/+��oc��t�yܐ�J��8�/P����UI B���H��H-�;8O��N���0&�#/�B���+v�n���cSmՋ�@�кn���O�Nί��N��8��9<շ��\&V�x��w���3)<�D�"��N�@}s_��X���m�9��I�m��l���Gus�)2+�ؒd\R�2�P q��)�fZ�^c$�lB⨋����x��3�8�M��$i"���jkd
��}儎�X� ��7�'M���l�g��p�3⷏ !ok�q`�؃(������䥡i��J0="
� � a>�	��͏O��ij�P����;���ʗ+]!�mm�D    I�wS��$����=�$����R��YL��d�߭Y�NQ�|���Ν�s�[FE�tyVh�K0�sq�9t �I�O�x��'>|U��e��̲�N�(����P>J�>�B���
~,+�&�쀊hP/�t8��Qd7hKk=��X�88y�3��ԅo�����\�u�,�%�M���r��~yj�Ј�3tV�4@�;z���)�d��#	�����`� ��}?��ocX�9.c�1�WA������D�ܸʦ�l��'���8-JN��i���[8&f	os�=ܛ�|	� �Xxu�%x6x�u~�xs���=�5�{�?}��cB7��6>/(�����1�5�вΚӽ#:���A�C%ߢ�R_����n�4�����HMS����G ����"��9�{�x`.�t0A��^�
3I=��:\���I���g)m�ۻ�����$���ya\!K���q�#��x5<�~wt���������N������~��K�qG�[i>�6� ���y�*�1�;K�!4�n��Fs���3C��5�D9�$�`8&����Ɖ�Z�f��`Jk��[�S�o����ńZ;/��G��D?f^�3��6ؐ��ى*�,8I�L�e���^ ���!Qj�
���foHx+���>P���E�#�˪]+q>���eO��$P��@s��DC�0�{�Q��ww:{IPy�G*��~r-�
a"�X�d8r����^�=IF�	�s5�����9í�t�����%��%\ZT�t�h�-�X���`\���A�-7��RI�<�-qN�*�̤��%9W`LN#�L�`F��\P�֔�2Po?+�4i�q|����Z�y�"l]�����_�k�C�!2F�x������ָ��~z�I�[PW��{(࿿�O��#�6qpHl��w;C�E'#h@�ς� �A��T���l�-o�����;<[uAȤ�D�A|�,�SJ
�20JpsoDy�\� �8aUp�h��0�P����	�^'S
� �ߠ�D9t��� J0;y>���E�ן.�H@}���f ��OC�����h��M��	C�B�U��⡀�RseiҔ�"��,n0��b9FQ�	����݁�er���V�O%U�e���X��UH�=x�H��@�R�UV�rΖtN�^(�N�|�\�N����U"��������e�ל�j�׳~8&�Z�$#x/�MZݺv��k��}��v��b�x׎��v\��{^=Z���?���� �R۔��~z �!PSFp�8y{���T�Յ��y7�kXN�ނ�,�����E;�E:x�$�.�Z��06�Hj�ٯ:lF��R�8��(�.I�d_c���R����`�Yɾr8�xr%�i�ڟQ��?ρ�K�)o(J�����-j�|�Z��Tf�%R��UnW1h��;��c��[��������k�p�c]l/k��s�\+�д�Ĕ�D�Sm�T�c��|V�Ƙj���77����*�:Ǥ��ۢ�M�Ø� EN�;����Hx��Q_�͔h��M����T@'AG'�om�7�#��㇎U�''iܷ#�w��U�������Y����V����d��u�0�c21�@N{�c�Uո�������+X��<>�z����GH�F��_�7p��=^to��-hG!��{Wo�+���0I�[@r��k�8V���%ڠ�t��ƅ�p8��Y���u�>�3JP�K@�T�X@G�@��?���]�9��`�^avW���賗�]}p%O�܆�n�b<~1����b��9Պ�?p�k}��J}"�{��9���H+���V-�a:.��1Ţ�/�:�6�Zp���~'1˴7V�ѹ�m��M�6>*���=l��_)���pB�o���r ���6dG�	��e�*�q�Id�qb%X����������/�Ӗ�GV1��Ft��� ٓ�7�����8V�gv��8�5��N�V��ur�Y>��x��sN����;�������#l�4&�T��7����y�y4nItH�\{Mr8g��dU�N����3�i�y2sk��<0�c4_q*� 	�V�[��3�
���Ǽ\�f�>�?�Vh����
,�Q*	j�/]���}U��4�yc�j��J�a-0��R�p�0�m�h�5��|8A3M\K���D�9��`�u��` ����g)я�h(��c���$=8����i�*�|��"�����:ݒ�_�^�^
cm�V���O0W-�(1{S(LJ��2i_-��sz��hh\!Wd�|��,������
�[@�,�A���f�*�GIr��d@³L��(ck+���6R0t�(Z>I�0I9Y��E	ډ�W2�(�K��܉'�=�;���� �Q'� cp:��U`�P�w�U��]�����:�Dw��/Fо�%Io��]Xw<^]DG�[p9a]PjȦ��M�P5����cAa�ry�5cL�{9{@sN��c�#��3�b+H���A��>\f�
�'	��i/1c�s=2e�{i $D�Vm=nDK�
^)�
��#m�+���|��0�͕�c�0U9�O��'<�1ok��Ӹ�1�Da����׳��+-�y
��-��p����l���U�f7�K��7x�*
i�em8Ɲe������r~�!Y{����� ��|]3��>�8;l�a��I侘�w�����7����ǡ�(�c��7g�AQ�u˴��2o�3��g���@����U�F��#��P!���}t}}39!�!e$T�������jf8j�A��!�M��2��#�!nL�9�RD�4�}1��{��=��:��N+"��B��=��N���v�y3�Z������lX��ܚM��r$��؁_'d�	�v�-�~>�lk��b��2�����FX��xq�������������k�2�LؒZj�A�c�o8��D���\@������/��9m��� ʋeY7Tb��m��b2����9AG��/��z,'����k�Y��������VM��4X��a/h�\)c=��'N�v�l;H�$q�5x��ֽҌ���� �VWI9��ǭ �q�C��� 4C��:�D)�'-�1#�2�'��@��-?m��o��c�z��l�f�����Tv>�Ki�����ҌtE2# /�d��)�{D0�[����2��%���N�����}��ә��s$wI0<���a�i��Ғ^�x�	vS��&�(x�4f���X]���y�xa�^Zj1���i���4�ohFQ��Ff$e��j`�kWoKD��g:{�;��3����C�T.�M�Ѝ\J�u;�Dx`�E0�lO���ю�E(W�����]ld[N*�ĉ�W��j�g������I�Xџ��0I)բ��F�T�(IE�&�������8�sr��ش�~�Z�o�0v8/���-*�`�҇1�j��2� �>F(6��ʮ�`��rRJ�a0�G~ۛ�����b[��ٺ�XLt9�c�*�N]�iu�����QW�|��#�q��pe�2�*���9x�9�RTVY��t��L�iHY����͸�:�腮9������if%5ɏ�4V��(���e5�w��+�U����W+�����{f0pl���p����WP|/M�&�F��O�$^�H�Z���γb�UYM�%}�b,r�y9::;yƮ4��hxm�\�?��{{2��椦 ���b:��2;\r�M����c��0���؋:Dm�+��k���e+���N/����l`l���ىߵ[v�1?�F!F}ܶm�L?�}��u>qh��y´�$�[�<lq	T��t����Μl��&"v�0FG�k-����9"p���� �'l�o�;nh����0����&�+0��4k\c �4
"���
���О�m�z�ͻ�K��v;7[[��-�	������_�����)7�4�c+7��+cx~h\\��d@��C�-�����5��1����l,�Y ��b��hxr�ф@�+�e�H�9�    �xQ�24RP�0�"��y�k����F�g�$}��hkr��@�BDHl������!н�>n;��i� ��\�/QyNL�ҥ{�M�������c����[��MX҂#F�(��k��U* ��HK ��r/�0�`������}@x�ǸV臁C���hm�*i�(S:�m�i�qJ+P�Sg��
��wS�ZM/�$��MX�؉WZ�k���/�^^h��gH*�ܳ܁g���\a�p��Vݬl+,4��
�~�qb[v�h��~�/�ĝ���hg�	(pd�=�XÉ`����|�c��RM@���z����4wwWM��Q�/�u�wo,�t�~o��L����T��D��#��Uu���e��S+�̸�z@��Odn�SЋw�/"6n>�X��J���&��Xw��J�����f����[���6�|b�z�ޞ^�g�O�O�8�֑ `Y�ܷ��������J��X�y%���:ݯ_u�zY�P�po�Hc�\r��2�fY��c|�X���$+�;�0����Db�*�g�t"�B��~Gg��YW��u�ڎq��Eyw��]%�tE���1���lO��v	'�ԫv�nx��cW�sʣya��l��z�'R3B��[m�4���i��qE@��ٻ�Sl�����H����DV����r�Ū�`rq��%u��4���
;��d��҂�΢�u=�y.-<�er�P~�9�Z��71�4��$�|7^%Wm��j����gؼ�и�p�V�����U�-���l�4/�~I�����}��CDu�e8�D����Ai�<�ܭEBU�8�?��*�N8�޳� �BS����C�T�]]�V�vsI%��Y�0CaJs�Pl���%�,�$C��8ܰ�{V��.w���(ꋡ��[��W�����J�䑫��[��O|\�@�pP �y���`����DGHO�gS��"�g[{���eyϓ���@�o�����(U��X�@�I?J�H�v*��\��ǉ��ҏ�����j��m�M�r�?��iB�����������3,<Xo��ف�h٭݌l+���{il�}Y�X�T�|M^
x۔������Z��o���!VZJxI���^�!�f�h�#W����/��@g�E�j\�|�A�cb�V%��������~ E��ϥ�C�T<M��Tc��a�9��LB;��6��K?sB��!(:�'y�0�a����F���YܠH)t}�O��G!�L�b���Ȉ&�Ԕ�q8b��\a1t'�{�8��Q�~19h�v9h�����f3:4::4�O/����PM>�Bju|��{0�$�N�7#7���Ď)��z�3�(Ͷ30� �gʙ�C���D:�I�y��`��i�i�[��~z��ǎrR<�}Uk\A��0�7v�T �XO>Cu_�F�3�����T�
�����������8p"�Cgm��=�ڳ���6G�;�:]H%�'|�9V�J<Q�D�����I�=M/ ^�N�˷q�xa�\Z�ⴢ���k�5�"#�/F���J�}���/]0\����aj��T��A�n zKҬ3������J��A�����qnp�Cƾ�E1[��]	w�� G>nH�d�R�,f�?�b �$��q��pg02�1�}��kb��n
���n�Cψd\������G���dj"�?���G�C���R�.̣�{��o�l�79A����G5�΀Lp���܆�0������4��Ԫ��^��ojAo��2�u�VJy���J�"�v����76���#(rD�{ع����S��!�G�e�#-��T��L���b�1�)+uւ�>��jݖ�Zg0�\{v����
a/�NK�<�t�#�>eb���"|џ��H�	�/��,xV�أظ�����O��a���i�J����n�����0�����#�zͷ߾��WȷO��w3�u���@�8Q��"�@k	���PĞ��þ��>y����$��,��W�C���g�|�C�};R�ri ��Hy1D��j;���Y �h��}	��A^�z'�?�K%���tA��� �<��o����2{gZQ+^������o=�~��ÿ���t���qp1:7�\�~��^KS,K�.O@�ٗ3LD|����F
�	uG����s�B���40�;�F����PF�=nt�:�� *K�esq��x��'}�6/��w�V��|�t<�����������n��H��ה�.��O�;Q��M*����?h��[t�,�m�!��R�_�ԳWt�b�Ɠ��S���(�7��e�\�
��֋zwq�"ql��1�#��O� y�?��eW��nta������d~:�lKjp����VT�vj�����Ц�CxC�
<+�],����.
4	�3*��f���Br��
,���Ĩ"}���\;��fD��+^�����bu����`p��GC�z�7��Ό1�Z@ֵ����Lv~R���cdD4��R��ٞ͘�5�.�Eest���&��-�%TVES+֊�W�.�O�S�6hA���Ȥ\>fQ.��)	�^����o�.��ˉ����=����,V�dS/��� ��ҭ��9��ʱ�@Z��|��qP�W��$fy����㘠�b&�l�!k�P��RI�k�F���X��~�#�j�.r|t&@�����Z�Qw϶��i(���v0�5���HIP_dc0��nߏ�HH'��8Z�H�C>�<)ʘ����)G���� ���b4<?>2��RDj=G
V9�mN��*���];f�I�H\������!���u��Lo����3rI��eg]lU�%�mC��Q1�)�7n
7-=_=f׎`���C�T)� &��MЕG5p;J
���_v+��7$�-n�Cn�;^āv[&az�����R�����oE*�=�b)��=����,Aʼ�&���h��l�W� )���ٰ�$\��%)������|��$w?\�n��EZ��v���O@��z#���`D�װ�퓮Dx�Fr�B-��r��b�lV}GB����[<��~]�J	��C�8�~Zܓ���
8���aׄ�Q��q6��&YI�7��yT�x����(.rc�Y����~�Z��㙑���q��Ӫ�y���.ޟ"���ɩ?^�=^��.d�Ǥ�2�\v2���G�mSt���[_�ҷS�L�=�`���5�'�@��Q� ��7(= ����
��=7��&��)*�nܤ��L��R� �W)t_��W3�h&2'��v=�v��2�!Vf�m)���l0O*�� rd�Ʀ�h��R�D�q���Ѹ�u~{��GR)U
+��W5��z��b�Aצ�p���Xn�g[�ʊ,'�(�?F�0���[ŉ+��I�ǁ��
'd�W5�OK��Z�M�ϕ��XQ:(G~�f��Bސi`
+*U_�ҥ%,WȦLl�퇩�J����J�VJw�@qC۲��R��!V�z��]k���8aj�@������I�-����bV��*{���W0��8r�V]W�J6��3�@���M$����C���Ӱ}�XM�B
3�1%��H̊���!i���27ng�hJ!�-�zJ�M�E�����`�L)p\?X�[S���:靾#���hkM�4]�)a��`P�:��}���	|�e�Y���˗�	g��M	T�`.S����09u���$�b>n$L�h.n��30ajAjy�����1x�!��+����^׿v��,�����V���x2�酙��S�ヸ���n?��ej�ضz���K~ۼ{�4��o��#�?u��C1�3�ߴ~D/��S��:��F4�4�sh��X@L��� z9,�M>3ޢ{i��:�����+�P��bF��t��r��kG(��j��䕲��C�d�����e��Rar�Q�R��R�{z���a�ج�U0L��p�����D�J���Չc�Ј%���Y9�2PT�ȣ�~G�G��J��EJ.��AS�_�s��|1!�E�t�±�i�)}���s�����,�Q'�ed��M�=�0\�tRI�����,��VG    �<8y:�Ak���?|�rĳx��0��dײ׎�d90t��`㥱�u\�!�<��|���0�ڑ'ؑ�KG?�p4<�87ގ��������1����ã���F�[1���5��IMǘ�H�jLT�|2�xR39�����X +瘑���L/]��w�g���5��LY��`�|A��`k
z�!��8�~���DMB�S?��h82N�./F׈1:::��������dA�S9�{���b�$$��$�%{j�jYZ�!D�ro�����Q�U��dwBI��s�_�p��V��=����"�G�G?����يl4�xK��\}�m�R�2R�ݘwh�q�I���J=l��(��?7�w��Lbz8�OKD��O|�M��8�A���0�2tM_-uɯ�("R7�p3�.��<\HƄEHWbR`�k��-�d�%��_�d�B:U|,g�_?pl�ě'�����N=��\�&l�0c���x�mfn0>\J6{l�����K�l����J~�Xjn\�E��iF�yvA4��^
�،	�Հ��tRkX����fy�j���*vb!�D�$7雑�8A%f#�xţyţyţ��&�:�z�޲)f�*�����L9�U��SX*F�����lgϴ��x�@�o�J~��4#��E���+�Xq�x��T��f	�o��\<ƣ!؀u<���C�3�(	�b%��w<8<�4��ǁeF �|�7Z�㬐�c��nk u��ԭ�L�cG��Wu|XdrV���
r�26lS��#J_7��M��)Bd�w�A N�Dw�v�a��鑣�F���B���	����,�, ����fE	R��䳁q$��|��G����",q=H��\C�D��A�h�aJ�`Ey
�Aeh$�0�Ɋ�z�O��f;!k�
��.��aQK�Q���ع��PV���Ew)��($�៷���0���[1D�@��B���V0��1�
�/�W��[���dK���hl��6v�o`Z�c9ϔ�����J�PZ���O�nt@���Dt�x�5�5���X��k�$#x/��[��;�cI��R���"�Ȧ(NbКS��P�P��W�'���[��=����i�ag4����LϷ��6��@��~[Kٞ���R)��TVb	7Ti]���� ��!��5�����"2^8bZ�(I[$�	dsB
�
|_�4uz��~��h'��"n�@�ȸ�$W�s�vdaDY9��X�&/<V��RY�X����QT�ɬ⼝ ̠F �����t��'}�t���b`��e�ϥ�C�T���ݏ7Hc�صȇ���%������k)ʫ�uC���`�ٌ
syz�}���4v�_�2�k'#�H �Zz���t<).��Y��qj)�L\x����
8�)�$��[���,ey��Ek�"<X�"�\����>L��(�)�rhSfc��Nb�Q�'A�l���_&��\���&��N��O0C'q� ���?#����n�3 ���GȔ��M���SM)Q�������D�Ԡ�^�܎^��^ϗ�7�Η8��Nu�'U�m<�^��nE0�.���p}�xa8եS�y�~u�:_"����v�e�w_��T���J��v��`��42������|�����a��m=��ՓC��L�H3�OMZ��y&,?����� \ub{A)�(�5��k��1��|�W$㗈d�R��5�p�<����q<lڄEw��*[���A�-�I�/�r���j�!��p��\�x8�OX����HB[y�E"�����~h�^�;A�����!#1����/��ّO�Ɇ{���
������i��KG���̎�g�B�D�a�Hwլ��fGk������S�"����I���H�|b�xq�p��q9�r��$���d�<�p-�JІ�i���<��I��������]<1�a>�l�SW!E��@S�Q���n���`�*b`�%*INnqL��܆��?�Pi�$ ���b��E��Y�U"��\Nܠ�����<+|�O��(�x�#_q�7�\����Q�2NM%Z�c��G ҶM����� ��>itqppqz���##�v˶���ۉ�#�=2�}�G������!���Q������`����C�T#�Ĳ���Q��";NT�V�j8�;!�$�?�z�R�Vo�!�����(��7�Đ� S�P�:��/����'0g'�� a|A=��FOIw�ݔ'��&��y֮���V�����F�(?�ޞ��<0��D� �c{��|Vѥ��GZ˃�$��E��5P�tB�@?���{�+V�٨<8WA8�?A	9Qw��3���:]��1��RU�8�?�\�55�|�ؾ�JÅNZ;�bW��n�^�8��Ն���l�{�?�V�e{u0�!��)���f�A�>�
�K@	�X,��6iaKXY���>�8|����n�3n��#��ѐ��L�o��~���{o��pD�bJ<��2(�X��5��HA�Ȱ}��>��Q%�bWK�s�G��,ٓ`L9�5#Y�%,Pٍ'��~w(1y�ø�����+���d�����"���Wؒ��$׫�QDlt]���|s��\�����<�1�GWё���<��8X�j��ӒnM�G��h�]��"�} �*���y1G"�TΧ.�[<��?��MD��Q�	w��8��?�뱬(��p�+F�E���a	ޖB���"�D˕�;F����{�ҎhR���_CTD�nHUv��š=J�dX�!�B`ܙ�Z#PwW�m���m�y�R�@C�u���P�vK�+����	-�nK[�r�L,$��6�����;�/��8#f�zJe|
� �H���ES?臓':���GW����l��5��b�pt;�s]g��N���r�Z���2�L�Lh�P1�.�]�[����ؤ���ڭh�1X�TQn;�W�xwr}d����
L�h�l���H�?߬���&&�H��E��m�y^���,�CL�խ|0KNq`y_�7MDbu� ��wZD7A1����18�'�{J �ɽ������J�)a'O@������?y������Q8��I�M��'��β��p�X���P�ss�f��<�~{�5@1�'�O���ɇݾU}�,�e����3r:EU���kO�Hj^���x!����+M��Q�o�.�E,M��s+l�ݾ��S# ��Id�$
�d�֟
��D	�w�P2'�<U&���AJ����ѻ��8�o��?A������!��IԎ�P�?ˮ=����ps�����f�9źa�Y�U�+�ɪ��V�ǥ����Ln��z/�C�o��4�nh�i�hA���@''If�L����k%{�c�%�"�`!PS�չ�1�ͨ�)�� ⟁��ȍ ��iD��t��pt#*�Sy+�#4_T-j��$~��F �khj0�H��]/&e�c�񝼁��`��%>�&�=꾘%��ԻC�������2U@����N�YV���^���ˊ�e����=��S�t�O��q��R�சu�3����L,l��\#[��58�t��7�^,֎L/��$�T��FК���
��up��;�������gx�������q}44�OO������'�?�W����`-\Kb^&�#��
�5Z"��6�PEqt.���~������r.�R�loRw-;��c��7��Z�f?V�n��R��-,�2�=;x�cyH��}����q "�B6�
�4��P�/L76�Z׵�8��iKK��v�����Qk�p�ϣe�cZ�c���Uw��A�������-��N�}0zJtV�ޯ Ӧ#?�%6�kz�O�q��6\:QFqx�Rb�;�0�=�Ŗfh�mOC��<�f"�!h�[�	�F�
��Q� ����˃���y;::?x�ĉ��5�6 �@^��jK=!jeA���I��-��� f��)�A�\�S�'�v%��6��"'Li�F)��ae�0U�%��v.d�:��q������v��<ˌ��^�°R    �6d�p�r���fײƻ�����&B��@�c��ge�n�}�PNg[�a�#�a��O�\Q�$5	ꦠN���ۊ���D�$��1�1�q̃LO��Ykׅj%��&�~��n�VA��
���S�no9���*��.Ǒ	��d��h�(�|~�#��D`�c�.�&��fᚡR���`~5����ke��H�^��*�W�@o���t�vU�jC�/���gp��;ϊ)(�5����Roԥ������gp�^���G�kc��� �{���}{2�"G'��t+�au�<v!�г^��2ڟ��6�#��0�������%��1�a�[�4�����.Xz!��k��"��^�Ԏ`\��%��f�8�����?�{Lډ����E�2+�D����П��j~��'��WU~��̈�,������HUwRE��@~�۬Q:��F[V��&8�%�������V���lQ 8���a$y�B7D�X:
.3��=��Ñݹ����)��B�M���ڊ���c��U����!}��vu�'V�U�T��*l~�(����M�49��5Rj�Q�Iú�
��b��j1�핸=�. #ű���|�8hn͎c�F���JUĦ=��}�|�h`W�V�F,ŗ"�md��F{y:aw8:9��ϰ6�z�٩!l�r����8^�xu�h���xES|ES�M��*h�/D�W�J!0��bK޷�����=�^Fy'̱���Cj_�e��c�����g b^�8��P7v�4�,���d|sU'}ݍ��qH5�� gb_٥mb{��/����M�Hw�c ��^�>�i��G��~4����W5���g��x-0��m�E�'V$�w�'��1���8I������ ��eK���� ��G"p��sU�$�-��v�"�D����>��q��{���"?���W�
?D��c�[���!��P6�:�^���If��;�o�H��8��=� O�"��	d��T9\��æ���[Ҏ���jmK2O>t��/K0Vg:��Q���$�c���!7�/�K;����^�����x�(��ξ,�t�՗�.v�EYN�nJ�� �x~�$�j1��y�j�f�j[�fu�I7h�ݎ\x3�Vf�$iF=!l_�?��k����CY�����6E��t�j$"�y����l���5�z�A66=��^��966�fhag*Vj BN�+̽9}%6�)kH 2����=�4О
��W�5��S�/)I�>r���V��澧����l��qр�eQ�!_�{�`��t��bvC�l���:���S�,�7c�4�k�=�|�z[6=��?-���TY�J�&a:f�W�㦁m���ʿ������҅���g05�>F05_ԏb��ëw'����F���j�k�q���[�s�JN#Y3 ��Q3;�~\ƭ�c6�`.�l��%�s�֒��c�u��D��'<2'Rsη@eZ�cV:���\��Ԙ��C�V��u#{n�[.n�KT�讼z<͘	���
_�j��em�|-���
gȣ��KE�>���"c�f�.��� N��!L%�٭精2T�A^�}�u�>f�c�a&�Н<��Xמ�w���:���l�7��~yd���T�[s�cCu2�v^X?�jx�?�'�rt����/��-�[�q��rz�1�V��<R��Y~b$�Fv&y�	e��بJ!AF���D�S}��#��}p$
�Մ����/���m)hcA�:�[3Gr�=rO/���G�
qMh+�Y�"B:8��%�M�r@S�~�Y����3�B�5�du�q�T�M����r4�b�>����3�b�(�{�:�I�b���� �vZ�"��)��	[S|N]�CsA������7�Á���c�UF3�`{s��(ri�"��]г�����t��ރ��K�HoGK���gJ��k�
C%3��#yj�[�D��V��N��EA���l���"��Rv���g�� D��@C�R?��&�z�����9)�\�}�(�}Su�e�ѐ/��q�������1��,p��uA@�� ��x�|�����1S5��Z	�.Yc3����e��7�ް�B#}d�8/���/���1bE��(�Xd(��5�8Ɛ(V�Z6�[��0��.<Ec؏/_���O���H����I<�U�PS��ܝLЩ���kU�&gH�3C׶2
�޼j�B��Q�%?��P��C��B�%�꩜���^�2�Atw��C�
7�i^��\���Oe�S=]=���PT8e����k�BL����[+<�w�}�;��A��J����J��ֿ����B�L$�c�*i^��M"P.�Ab���5/�2,�c�K� �<��7��Ճ2a�O�t&�#��3@�^�A����g@I��ϛB/�8�mh�3�ƹ�"�k�iP��+�?ք���p���wI���������i�bYS̻UR�h�>�z�;�1f*�Gy1�L���t���6]��D�v�����s��`?%fE*�:�ar&-���LI6矲D�*��w#$� $��G��aX�^_�2ra�>��-��ء�%�S
܀Ȟ�&,���h��a-9CZ��� d^U'�PY?{Q~5��2�f��I.'���?��:���+�3@/���Y,օ��E��~T��\�O�;P&��X�3�JFRZ� �%�4��s���R�HkYspȨ�'�_`~&��t�~��䒁�M����(:����[�m�r�&��d]*cm�ն�U[�顗yt�+�+�%_�)�}�r�`QP*�$E�來m����_8_��y�%�3�=d �Ւ.�q��~؛�$Ͽ�?�so��Io�vK���A���&�7'�f��ٌt�x�X<�\�͘[7�<��L�ܮts�g�����ȅ����~Bw0ћ綌����װ�k��ű���l�[�kإ����}/���Q��_�9]A.�)
i���"�G��^�u���E�U"���K����o�	O�>�Y�s�4I8l��;%��r��1�X������	-Q��U�ձ��Q�2AG$������H��з2A��]��y�����)j�����dB���_l�����)���ȝ�M���]�gZ���04�V�v+|tD�{���9�4`���g���.;6�gSM���ߨ$h~����-��FWU!����Oi�c��=��܍3���^�q�%�nO�,ѿ"�6��ɵd��*\t�am�7Tg������8,���
c�
sŸ��/F��z�TqR����Uvṑ͍]�TՅ�֙��T+ʋGL�Y��4�)w��մ~F�~�ǂ��T؎��Y����h�a�h4�qM�D�]��k�s�	5a�KP�z��Ekxx�����ѕei#��uJ�<e��x���R�#����f|���Z6~�3 0���������ڤ�q�<�
��(�0jYxɲ-&zk��I�Q��wZ��N�	.f����I�-�;+ G���9�}b�:���m��N�pc�؋��ڒW6�)�z0$�&T����	�"H�]���U #D@��٧/ܼ���noc��!o+�ڪy�����������]���[�3��স^Db�p,xv��G�<���)i�r
�����
\#�c �n���y9�D�6uD�mHɸ_���Aώ�ߝ� �t�,
wv��̶��{r2%h��ă�IE<U���Rr`��``�Hd�  <�3`9Qwu�������A����
�����X������|��U��|��q!�d����Ox��`tc&8�{%(�T�['q0�g�'t����t�I=ކ.��Li��C�q]��Y�	%U�nj�|���7�Rn,�1ܠ_�-;<	׹\�&X����#�`xz� ����������
��:��ی2>���҉q�&��_�.�9GנO�=�C���vV^����&Ɩ��٪�}]3�g��M4���f
^���H��cAg:1��}3��O��:����/�#�͐��B��Xm�߳mWa��dڡZ�{/���    ���`ߔ��M�za�yzP�����NO�?�|u*,��MҲ��O\��b(��N���~-E��z9"�����;YH�pO���H\�oIW�@����,uCA;��V�Ġ�"��+/u0����[bX��15jh��D��"���I;�&ٲ*C��9�:������n4__��[�)���T@�FI9�������xs�nx~~��R�����A�����	+~�r�І2A��;��$.J!��K<�&��G!<@�}���I�JƓ�(� �#��4����������m,$���A1��#An�����98�;H��r�o�[7#0)�K��n�bHD��V4�u���k�������*M~^��<[�ҿG���2��m~������l9��vB�k5�i��Yv�����8�7�g������x\�0w��X-� �:M�=�����[U`���PӋ��j�������c+�r��e#σ�:���p5�K<g��:�&��{'��"�b��R��kS�|�Ŕf��~�g����[�ig��Z�X���AEi%�L|ghlÚ�I��W�_����j\6[�����.
�X�E�=������;x���T�����rN������a�5
�D�Z5L�!'�Rá���FDM4d,<�#?��e�K�e����,�����G;~�(��&�;�~G���L�w���h�9=&x�F�&Y��'��s��W�� �G4��H�1�q~q}�GN=���Dz�ǿ��Ų�I���M��\��-䬜��2_�O����M����18�ػ��#���:�FP�?���/����%��Rzn=������ёq1:�� ����!ة� �8�`!����I�ꡅ �b� ��kDsj��[��$��k3a��"u���b�Z�"�t.A��IQ��x�/+�f�W#o$J��TI�[�Yb�2܂��0�+kv�+)��a�bz����[9�o�r7�g;�����ŧ˩������=pN���g�<ǌ65%�N�ѽ�X/����nA���5(�2N����#�.ޟ"<��ɩ?^�=^�2hپ�m��_7�������P�~�����ڱ�k�ށ\�6A�{s9��q�G����+}�y�N]{�j�d��XR����͛F��-���@(�F,�I I1w��р���/�KI�02Z�1(#J�� ߎ����1e��
�(�4�T�bv�� �Q��'��
�fsf�ˡ[kk����}��o$�Q�t��[����g a��=��p42�N�u`�b$1\3,ii�!�R}S���!G3u�i朕Xw�Ѹs1�]�+����?�_���?�6��.��_���v�`�R�q�s�Q_=�`"� 6��������99�����e���*&��at8�1�S�D=���ӫ����я��������鑁��S�./�ͶΟ����z~���t~��߾pjbGtx/��۪��Ujb�(5qm�xa85���Û��x��Vg�����N~�|<�`{tb�����x���r�6n/��f/�ؓ��DIH�e�U��V��c����C i���쌤��7�87(a���g��5��N��f��~�)�nXr��<��¥�4GuO��Kb�������7UX�X��do*��JP[���ƺ)��F��M�(��?S��!.��s�n��t>�|K�s��I���>�z���I�Ɏ�,�$�9N�����n���իƙ���ӓ!���htrx|�-š�����������ǫ������^�{�!`�J��j�(��[�e#H,��gkZ�LB���KY_O������S���pPd�	�L�7�0�mK�滊Y��)�����7��S/���G��l8�_�{�$5���-�M�~4�)�-��D�+����z4�ޥ�����L��q;:�o�U�'6q�Lt�y���M]���<X�Y9��nP��Ov��?߅�aB?gz�?c��3�vg϶�\k�x��YϤ��C��$���������v"��q"V=f��
4�t�6j ���M�0�Z�]G��H�k�0���B[����Զ��w�������	�s�W�mF���XILN�1�G����r"{�G�,��T�(�����`#�;��;)g3��@��x�F��Rj T�C#6�� �d.���~� 5
����7��)سz�6�����-��]��H^�e��rLD�U�f���O�y�$�T+��2�p�4���Y�"k������ �r!cJ��@�����X�����d7�w���ehw׭�-\�0������q<<�a�����|�L'����;��j�-�ݏ��I����Ǫ�"ʀ��W�,1y��dy���M3��3)f�L��})Kw���3�=��Dyr̆��{�an>�1�ɀw!V���‚��T*�)H˂TF3#���N��=c�¸�7�˪������B�O'ˣ&�apD_�	�o8#���H�y�xl�f��1�|�nd:swO�'�l����!������7�(�~�{B�f��t���8��+̐���|rO�f.h�<�p�b�9�8�8^]��ڿ�~Tz��m3���iE��.���M�|,)F��'��j0��Ym%^���A����ʚI#����_]5�F��C.����|�n�sL=��{Pd��U`E�$���|K�noOH��W��Xe�����fҪ���Yd��e_xn�Y�5�����F��{�T�nJ�Ϝ�/�T{KRو˵�A�\=����5��&T�� >�V�<8�IT��x����eٷ|�~ Őw�&�^H
���3ހ��F��MH��$:m������.=�gU�dn�s^yl-H��lF�Kk\�U�Kh�ۧ�cF�Ó+D�?�>b	ckm˱(��K�����q�B�7L���T[��^�0s�^��@�	Զ�q�y�5��������uG��ң���P3��js��p�L �S%�,FK��q�)�������i����U*6���SeS���0@�\���U\������Y�8��/�'�� ���
>E7D&T8��GKH�n��io�Ǽ��#nm���$o�l�= �����h���k�G��R�Ʃ��i�S����m�m$[��[�.��v�(H�;(Y����#���ё �$��V���!��=3};w�=o�O2�	���]�����D���Z+���L	F�b�'q�FQ$|���A�si��'��D<|�r����m��lq�[\��wJ�g&������i�]L��^(n]C��VT��vϪ.Ws�4[����۝�w�6s+��TP"7���1��Q/�b$u"������˅먤�˟���D�����O_��]G���C���K�p0�1�:�v�]"������ܚYm�ר�W�_X��1Z]Ä[�W�7�؄�%Nؑ��}��Ϭ�>\��oV���P�ba<?K7O��$�����`Mƫ�����U�ׂc���~B��G�������A���7����Ԏ~����y$�֚�7��8`���=�h��Q
��#�Ĭ5I9�y��b܈L0�*��1�?�q��
�tqnM޳紏#��t�Ŝ�v0��/z$^�e&���F�~�]����W2��k�� ������a����	^��Nv7u����8������o�����D���[��=�on�:�����z��kF�M�:�7�}��|��͸/��fC4�ʬbi��a���gU��+t]0���m3�ц!�?�.�99�Un�|?Zv���3D菈RH��=+_�����xj��+�_�A&�x�L:F���,�n�@!��T;PX�A�rӸ
�������1à������y3�+�ff�}�	~���V��茲�@�a���x=b��FB��o����}W�=2��q��5I���b��h�y��]{@BߌIF&��U�s��_~��"�E6X����JO�f<fǠF6��&�7K�,���VP*x����f
?�3�<O    ��l��V@S!F�����b>7����-�c���ޓ�e�0�69P$*Ii-lOnkD�!���x��l��Ҧ�95�ѵ1p;�@C��_^,�wo�U��8��M�j�X؆��CW��}�q���|"W�=���.��xG������kv����#}L��2|���-����fw��o��|�ئ����68�mp~'�w���������D��ah7���V��HG�D15:�����ĠGO��1��q� C3�P:D�Nu��0U�L��^�s2/9�b���.+o�Е�˙j�u���w8��GI��ə�VZJ�rǹ!iJ�)�:����{9���C��b�
�N�������hR:"�5�[W%2��e_�._	ǟ|,(��!i����jQ2!�kJ��p�DG.�[A�y�l��N��u�xxDn�ʥ��5oa�]�G�ǽ�G���et��������%0q�ނ-� ��%���F�4�<���)��)�&a#��ˋBhjc3�*��_U+Udz�+�
�?{�?|�tT۔�qcqĒ��bƄ�R�²p.���J�v�x(����De�5�"��|���@��]���0������/lY�k,�e�A�=j/�h�j\��;k����0�z�س�^���B�������{,Mw⡚�b�<Zt�.dAY�^��#�(.��t��*���rn(�1ף���[�	�����|,�E�`�N���x�|���#b���çP@�0P[�a�!��Ŭ&N�i����P�^"W���oFl7D��R�M�P�hR�c��z��i_��$*G�wF�&|���9p�b(ɯu�U������0�s�
DH�a���(	�(4J=�4VN�S�v �H�3q8��jd]c��g���?��:x���܏�Fb�� ��fU��#	�[YM�G�nA��s�9ej�I+�qv��b�J��l.��򙴩�ޭt\L�c}65�Q����(NK�EUŨ��zɡ�,j+�D��S;����sn�C<xC��M8��jh7�T�I��D.�l���lo?p}�uQ�zX.��7�y}?C�ݵ;!�X!��El!�NCn����'�_[$G�of��x��S1]��;6?�`�B�V����g���M1���ּ6�9xHQ��/�!�P�>16�ع��
���13���tF2���rxbc����'�[�'���o��t2�f)|�&�ſ���Y��e��nb�-��-��-���)���o�f��o_=�ו������ř8ݠ7*�>w�/�f��`��?�A��A�Ş���~�'��_�+�3Z@�T_��\n��*��Ӱ��/�+�o���$�����6�fH˷o�W�����77B� ���h��$C��6�.<�
��u�n�|���a:Qc����*)˟��?$�1x%N�-�J�N��E��4�B����;k��ea������p�ӚpM��VD�������⾹�]�ls��ls�H�8�)8�>�l���S��_��]^����ұoN�S��"E��5�A��A"�^�8H�K�q���c�<��]gh�,�E�ȗ��;2ƹG���Q��e�i������}~�
?���,�]��.e�A���Q��S��o�g����g�ү���9��L`�ԋ<���*/��́�~�-���B����_tF��0.�cn��E�F�ǋ�,�|�z��§P(�8i�)��/��� �w���<��h3��@����� �fG��n����a�~E���������KnS�״O�t2%�RS�C�l�(���o�&\2�!�����O�!b��O���U:'���So��ZQ���}���D����s�"-*���D�)���t^�i1�`kBhK)v:kr]9��C^�u]2���LQ�rR��4�	���J3N��?4C���QM�5��������Q�s�z:0��m���S�Dؿ��y�߶���'|�g��6�t~��������5�m�o�!z�s�!ʠ[
���|lP��g������%��b2b1��b:�7�(&���*�Qb��X2�Y���7]���K0��ӌ�'�d������{wd�}F�5 �\-����jd���>`D�h� ���E�ώo�ۊ�f�	{$�� fPo�q^vF��&����$��k����$Q�M䄟�JF��1����*�[r�R��}lo�9�M���`���8;��x�ye9��/�Ӓ�.^�~���6�5��.iN@e���W"V|����)J����n}�����������Zâ�#|����@�('�hLo����� �Z�r�n"�6�,,qA�3@��d�զ�e�#�JV�r�0l�r�������O�!��U��j��/1�1�j��m�
O�q3%�>��QjŁɷ
���{��#$P`A�h�|�1#pH�1!qkN=+qzְ3#6r6,3��T*1t�+oa��L�����J��Z����ޮk�V�4��8�J���T��|>V��돣s�|tqri�a'����˛3b:@-�?t���\�5��U��\c������F]qf7Q�����2���$Ex�a�V:%��=�D�2�����W���2�����71{����{�(,�1b:�`;���ŋ3��L#5T"�r/�$�ƅ؀�c�w��~o��u76������K�o�ak 7�~#�M�ͬsUM	F��`�i������!\�c� �M�yI��=����}~[����ۏ��y���'�@o��Q�(�Sx����̉�i)�O��&m�{
}��#�_�?������i����h{9��$N�D�#E�t.L��"�Bd.D���U!	��kYI���)�gs.�R�{�o������=k���$;	����b��;�o����6�����j��o8�U1A��:��f|h�|���9F�	��P��߈칕�۲�7<b?p;�Z�\�Ԇi[�N�o54�0J�'2�S[8��)�`�ba���G�W�`����g�L|q���vtpO'T��|v�=��Y�A֭gg�^L��
��V�=�|;.l.�.������ C:o�Ƹ�b</��~�[����D�7p{�����i��!�v�����H�T��ΰU�Htr5�tx0����j��$� ��	�ĵ�a�����I�K]�uS����;Y@����%'gsc��K��c�|�-��H/ƹ'r߉����[�X�c�u<����K4�x�C��sy�Eƍ��
��(�e�����c�=�>�?xu�`p���u��o˹���h\���]�����7�R��'y�]��ďf ����2�'��e�^ތn.���2܈O�:b�w|�XW%R��Q���ݜ࢘m������n-ej$�Ѵ۴(R1����^]�_t#��$�c.h�<���L�7��iܾ0�Co#��Έ��[ʓ�?����Gd�Q�L�>sx��rq�g�f̡,~�����a�_G��VJ��(��H~����*�p�����o����|U����Te6`�6Ǘ��y�0��QJ1��y�'�Ng��bZY�V���ht9��������ɩg����!�{�5���S��p�7���%~؎/6Ϡ�~��l5����0O�8	|7V�����W��{
Ϗ˩Lqf������u�<�ﳜ%lo���,fwXL��_3�#�F��)��r�<تе	�	�@�&b摷��ޜ�?���_��:%z@�s~bf��@&��H˹5�^��Ze�(��c�&���	d��P��x�$k�dz��k�yw �N���� ؆�GgT�\U|	N�56T7C$����VݦFOfN�ͬ\�w�sK�Ɵ$'�>   ��ŭ� v���C���5��	�}$�K��F�/uBg����Y��0�L���W�����;�v]��xd�{����G �G�7�˫?���mvu�i���G��h<)���E�/�e�RVL&�K�=��K�Y耬�H�2i�iJ���    ��-�x�=��a�1������Qlk.pi����(��$����o_�|�Ǯ�����h\6����ˋ�FR�#<���A��&���{�cCbž�0�ú���"��Q�;w��_���]'U��.�#�&��+/���>ּ�q���y	L�D���D!� ��g�<P�8�D�&��;����j:��6���~k���Hz��e?)Q=,�c��U&?�<l�<<�i�F"�N�i�n��-��+rĉݭ�hײ�*���
;At
�ʇ�H��w�4TX����%Ө_�[��GU��ߐ��R�`�=7(�|4�4PL1_��C� �o���O�18����0�y�~��
�ȵ��&_�N ��WX���x���n�@"�]A~Q��Hz�� 2��7�3�y�J
DT�%c0��ה��K���\_��aZ��T2u|&H�P�:H���CF<�#�	f)pW��8���C*���c��l��x�ca~�����S�7��Q.=?AMm�wá�,-��+���!��mV���Qةy�ϔ�b_����̝�����H#Xme��;6���fk��k�S]�r�[����֙�����m��E;���5'Y*�~�I���WoW��q0���/.9}�I�[��Sx,���"J*����x�v>��>J#<��9��a�@��Mf�	��M�Jx-8G��gC ˤ	P��Z2O��%_?Q4VT�q��6/Ц6��L��EJ@�{�	!������J��թE�[5;%_h�tQ%:ù �����[�}��n���vs��xѾ��'>g+|b	�#N�x��C2�hF;�e�kgA�e�V[�>m���P��7ë�?�ά�����F�G�l]!$���=�mod}7)��r���'�z��ܗ,�;~�gD+t͢,YoFׯ�O��W(V];��v��k�E7H)[b���0��5l�C�z���q����\�<�BW�,Tѯ����%�m��������� +x��Þx���[�G����7��o@�;	��3a��ٮq�����"�'��c ��W�����ԉ���F�"v|������>.HKOL��9ot&2��<oJ�c"�н���脰�`?c[�ZK�Z�����/a���b�p�(u�(|�:O�P���N/�Q�"��3nƣ��P��=U|~�%��ӈ�'�id�|�}���v|�v�垷���l��Q�턟p?^b�{3p{�z� _�O�H�{�I����;��0w1��� ���9�㖮�&�n�U��F��+6��������Ds2��ӛ�z�z����Po%��DX�	���u>X\�������Z2�&W�_t�2����z���=c���֏��j���[�~N�4}�������Q���Jc�&��%�t:�pzqq�(���tr���Q��ܕ� tv�������^���T��D��
@,�ٰ����?�ߓ��CD���~9�E1�����Xp��NG�:�NI��!��r�VQ�"����j� Q�/q(���هk��L���xL�p;)�AO)�x���}w�)n�ł�� ��~fO���N�d�O;4;:�ѥ�]QI��N�B�����@�2���Kz�?)��f�d[�8+�OK� ��)�y4fYa�$���j�%k%�l������KYe�������+��b��"�����^��Ld|;^��ր?d�g����X�lP�K̓�C�<�`@J5�K�pyE�Q�)U.!@�6�4�0�S#�LZ4u��)�T�$w��qIs=������^�C��Ō�+[	������&�_ш|��c���v,\>M����9_�~_h/(V������>w��ت���mQ*@s�Q۸�8�F��t��j�83Ԝ� �R�0Hrj��J�X7|rdǒ2[�����W��z�UR2��/3B��|��ٽ����r��	���3��O��f�&Wؔ�����b&���&Ր�f��� s՜�I7�F��<���mg��g@a��1Z��5�)K�t�³�]G��P�Q��J� �.��ւ�q��N��L�����t6P^��u�
��"%�������c���!��8n��9��F"�����6YJ����4�&����l�wS���acG� 
)�𔩲Fn<�Ǖ���;^�tw�R�� �/��!��3���p)�a�)!���nGQ�QJ$�H�̻�_�R� ١C��d�#�$�n;"��<�����	 dM?���C�y�� #E����\Ʋm"׷��H��D��	 _�Hr�x3�;;\��:9�D~�ϐ?8�žp|���~�'�X��$"�"j
)e�~�:����u���U���4���+�R�w_�W���3)�V����8�*��$��D������b���5��W�v^�(H��l��F+�s0�3��W�q5�M�a. � ��<)�Yi�%.n�l_�ɶ����$W�c9f�N�]�xn]l-�`j�o�Z�2+�h�`O2��5�6%�)N��i�C�a9n�$q��{�x�ŧ�nߺ�3ނ���bZ�c�Y"~
��^.Y鲢"�Ŕ��gDO�p�݈x~n�ȸ�F@�s'	dh{Q(���� ��v"��~����J�Ů�ܨ��C����Y�O�8�V�+9{B��V����������m��f�>��[/�n�|�^��Q�p[�ڹ^��Sj1�M����p�4�=8�W��1���:,��К�*�z�EZТ���;�H$�l�k�76U[M���N��:Y�Z����)B���]�	^=�o�W���h��`*�}��@�j���.�J�D�J@Ӥ��W/�z^�&�+3L������[����z"��i&���l]U�Ϫf�O\�o� ��X����&���+OR�<S��<O_WN����ex
{oCゅ~0�C�W�<���&��}_q@��=,�!���4�#8��ZQ�d�{�P!i�A0�(�	8�FTk�ԷN�i��5�F'������"�ūӫkjc�38DZ�N��n���Yɉ�VN��{Y�� [�N�1V2[�_�<p���v�us.v�[j�l&��ˊk��=�"zk٭��[�D���kd<4j�jJ���`�]�i8qy�/��ܕ��	��g:]T�E���LƦSsZR㷅nlHؗ�g�`����kar��x˫�����.#�a��|Q�]�2�5�����g�Au��X5�2�*y�mK�ᙤ
/#Gx���T353����ݷZ.}3"��i���%��b��Ҝ��}�T��˽!T��n����F ��1 �Rv5 gO�aG�dL��:�xc�F���
�*p~f	�zKXG���?�N�f���g�	�4����������p��D)�����o~������L�l�X�E��ңn~�����ї��kkt��:�<��xw����BG����m7�c���m��u�a�9����I�qf��x��{ ��8��gJ�����@�)�V/��l�&q�������j�MV�0\#��uH0�-����k���/��Q�����_��hK��#9�\M� ca�IY��|S�?& �	:���~�<[9Ɩ�.z15�]~B�B��^�n����,1�<.~��`�-�˥�74�����a_F��i��7���R�%�@/t��dte^]������M�4ն#�\7acwMC(����u~��&���=
6�vBH�>��l���k�����9������M�0���P5�v6;Il��+v�i7��p|o�q���~��%~\!'�H6�#5R%C?���9v��;d��L?R��o��J7fJ��C�K"�A��R��]n,"@���n�5��?6]n��}G!�Bc����J�E�HOu�H�2R��Ћ����ʑ���$i�F��ߤ�s�ʋ��(��훎�^b%U�Qq�T�~o���v��ҏe��'UpKv8�?Ǳ�M�a&I�a����T}�T�N�MAv{��}EO/ѲUi��*lKU��0�]a��±?�B�!�7�c,)�}C    ?�˲D�f����n��x��𨧲cl$���l'%7�_q�y�$#;r��e���� �C���p?�C����{XSt�A������+rx/^��{^WG�W������#�5h���.���AI�<͢�MS���;X���VUK���e��?�ghE@R�W�c>�A&�CR�!YZ\�����N�a��&���L�OynHH����u��-oA������3������w 
�G���g�W��L��^ɄC�΁+�}��������Bp��<i/%O��3[E*q}. ޘ�'�h�x20y�?�NN���l�>>;���d=�NΟ�Y KWj�HdJ:\�fTo�2���Nd)&�M~(�d;Y����G��Mq���3�U�g����^�Q�S"3�����yUÀ���-6�������D&�h�@d��Q�*%گ��}`�������\
�+���&��z�I1PJ/���Z��<E���z%f�>��j�$������� �� R)\�g�I>��I���A����G�
��LI��z�Ffw��cf*f9�0)��@sg��
�X���X�g�[$<��̯�^;B��w=�*�"��H�捻6��G����V��'��K��_��^�zv��D>�����4�34���6�ŋKk��Crv<���uC��s�H:"��n�xI��$6W���%�Vʏ�d/
㵝��X�l]#�ӗ�`zj�Z@�IX�3.Q ��/�[��0O.����u�	d�}虛�I�a��N��{���q؃�y0���O+$]+։��J��A�0��a[j�JW���c�������o��n��� #�x�=�m3&�ycbd�K/K�����EI[� �*S��ML�!�:容O�pfZA�
D��l~�~��xp`����KɁ���:�ֻ����an�����i�~��:I�8Y�Wg��8
�d�\%��x�~;G��t.���&�ݨ�'�hb![��rӨ�F�Cp|�8L}G��j{��5�L9��J�g��������2�W��l��	��s�='ۍ�~b�&#��*�E�^I�d�0ͽ<�Ӥa�4�32�Ȓ,qg��tv��C�Ύ�.�La$�N��i�ZԈ�e�%����//�E]��~&珽a��q}�d���'q�Y_��n^�X]O���1Y�� 3���Y���R��(5]�y$�8�P������N���%��¶a�[*�~�U�ڼ*g� jj��Q?�j���P0z��"�,f���0Y1��h�CDB��ƻ"�!6��vY\����P3�r����>��R���+���fB����f�It���^oZ�K5��,�);�d ��$�nM7�A�=k�g5�e���������K�KհcN���u1	I�4�O� ?��Ido��ǲH�Q֖>��Kp�G5������Xq�R���<���̭���(x�����(�4�����hO0�<.>(�R��7+�^,���3\������T�8�8��s�OM��2�9l!�[�ix�H������l��GM#;\�tW�����4�`�D���d������Xx�!������Z^Wo�h�&��A��9���S!�Fdq�2G�Kj���@��K�:�d�a	4t���a���+I�����Xz�HVmڟ��|���W����^F8pە����0����|�����Rl���&�?T�[�Co+9��C� �lef0O%�u��M�_t�X���B&Ϊ"#�X����"+�aj����:Y���{���+BU�Y�Bq@A0��.��/���r��y?��{�Б�PD���z�|/-���j���Ȯg��X�P��,��;���:S��m�m�=��OM5t"�9ѦӸ�G9^�w�a�?��4����d��"��,="���k���&�+�C�f�]�?\S#�k #@�64�Mw�u�qΘ��E��߿��w��$-Ƭ��^d*����g;/<�!l�|*��͒�x��}��q'U.�H����.�GQ;:J�8,!��
A`_Uj�ޭ�� �=A���*��l���<�o�q���DO.�/��� L�=77���������2���m�my����ŵ������u��uu��N�vE��+ݘ:�c���{Y���A�8�bp%i#}OPC���r\<�����bP�Q��6�!ԡz$��/Te���.�Z2�^þ��WJ����:�_*���&f�mXK��M�n���I�5���K��w9���)���F�}�I����B�p��G����s��0�A�g}H�x����k��k�ӣH��ѱ��TKG�N2#��V�
^=��2�����3��8Y�0� ��ӣ4� ��0!4��*�{�]ʣ�ch��X�r����(����z���㛫����z;:z3�G���k�Ѿ���*)XVL�Pc>^2����X�F]r���$�o"Wc7CƦ)�`N�\N$4rqV�� �dŘm�N�c2&b-ߘ��kӸ�\D( |�zE�o|/�5y�S����z�W`!m����ci�c���V��������	P QyY�NK��/��Չ�o����@>�r�$�pYo�񲵡2����������ht}}:zn��7[k�n���+\aG���B|:��~��Έy���{�;
uN�|z6�T��9{����%Ҩ�-��k)Ǝ��=�8)��	/o�� 1�~����U�%e�J��8�1�b\X����u
_ ��N�tL���$ؔz���I�P�����\��緜 �b2YLA���)U�A)8Rg���7iw�=
;#��m+���l��k�~�n����qih��>.<���?�����=�O�mO�g7�^R����a[T�,�61h�+�?`t1��71��w�Y�%j�� �P�F -*[�Pbu�����}��m+M���iQ`}� 
�r�ѠD�ޏn��Ώ�./��h=��t웓�~l�Dѳ]���%㬞dN1\�s�N�ye,!�X-��m^��I��3�=��"8�?��?G0V��-n���f�б+�*b!'�EXn|�d�1�ju;�L!��Tn���R�!s��Ƕ������a���#���Z{�T���4=�!�6�Y�dc����4Xs�	� 9<�q�+�������d?�Cz�jF�`2*�s��<�]Yp��q��%��=�ƋZ;Z��}�iYd5c�e�'\�F4��\L��^ BҼ�sI\L�}���p���e̹��'�C����{�G�py�!!4g��]�[磋���Ӌ����/]�S:�|;8t�eW }'�2Q!4�q��#H�b��ʐ�n�J8b"#\�-�B�D��L�DS�A�I#1CGc��K'�a?$�_�-	�޼��T���=���ں:~i��][o�]\�4�8<!�������x�g��#��|��������Ń�����*B�\��[%b��/0��E�3�[?F�y̘L�L!p[�!��>��D���� �Kllz22���B����Θ�4缁E�ۀ�ϰ���?iv��aO����rg�=�*��<)�z�����:z����r�_�]�p:�7D���D�>QU���m�y��(��w%{>�[�'��<V򩐟����1h���՚��f���2�mB�������#�ӄ��&VT(u��=z2��=B�E E��u]2x.ઘY�p.�r�y΍��] NB}������<����L���Ə|�M��X��yXb/E�lᏣs�v����8'ǞX"�N��������k�{b'.V�^�������xpr���T���0o�X��8�K"�x�c�A�ϰ	֤
臃Ճ�|�`�l�ޘn����Q�{2G��(5�p��Ķs;�R/m�T�F�w|� �����R�4�/�������:�8wU�x"u[�J��X�P�ZϬu�зW.!��������vSxT(]�A_��HFf�f�&���m�^�Qa���+�a�_@�1�P�n�г3*��\�x�    h��{t��2ç� �=VU�	�R��;C�K4d����<Ņ=UD����<�(L�����֟�Z�:����ݝ4Y8J�aъ�V� �z����6T��h6�iZa�!e��Ξ`�:+�^�,g1EC��ה�[��Q/�(���`���[�|7c�'�K_y^�L`�4����~ۡ�.���K	H\{���ҍ�%i���S���̉��^n�Wv\�����a�q>�ys
�����~.�qW�n:�ye�h�fC�L�%���>����"SZ8!�WiJ'"HJ@ʰ}AUEM�HxB��[G�rw�u����v�g��%6���9�A�!ڟW��f(g𤦦eQ����?\�m�LU9#;ה.0
Hg|2�� Foy�AB���&��9Pg�4��5�;�{�&�,0L��4#����x_Vc��P�ɰ��}��|~��0�3
����?Qx�zT/��=�E:���l�'�
����gzۘ
��{��I~��m�	�YI�e2����1��FWW#��������9�0 �r�0˭���Xc����v8��
v�i!��g����E r������o�8��"s�L��2)(�F��y��t��b���{kS7���M`ǎx;�&Ơ^��9Ts*�ߩqn��*���Ԗ�͌e[���I�����}!l�n/�O.�)���!C��l$z���0M���}��?��.�i�ө�#�7�8���'6z�"p.!���g������\+<a�Ǉ)�"X<������7�/`��8̳�k)4��R����F��vE`�#���%�`S��o=�TyU��)�sÉI�2E"y�[1m�� ��@}5ڔ���٪��9��
g����Z���!����=ʝP��I��}:k�8Y���pֽP�m���������(L��<�����\"�k�^�|t��ʺ~{vzc�]�>~�d��	�^�OM�?���0�������������4qp �ƄI,>C���<���'�zVbRA_`��r���w��Yf��:�Ot�	����(A��*!�	��Qս.0׍)��L��F8�0���}Z��x4t��XK	zb�w?������,��a�d��u��P(�D��c�;!�O��?eHj:��F��7�O��2c�]����K�t`ҍO�����c|lF���]�g�	
|�d�"�_���[�����#:S�Ĝ����}d�Yax�q29htS����]�X+���������*"����v!�ͳ�-�ش����a�?��`��n���=��;~������3�k���ۄ��y�}D��1��Z�C�m_o�:��Mn.O��Ÿ.��ݺQ��\�l�Êjʈٝ��z5K�	���U9C��^_c�|�aƱ�C�a��	&�D߷N�0)�i	��p@	~���;^����+"���[q��Me�wV����B`Pc�;���S.+��j!8�'��`n�[�,�,���6�ݢ�����&_�Ǥ�b-4� �܁��U�#�~G*�{��p6ҹ�^���q�	�x���I��֫�w�����p��������x�x�ဟvyw��t-T
*T�#5��K�ƴ\��b�b{ӽK�ң�s��TGV��+���Z*d
����$0��Y�*(f�U�I1�C�%)3I_���t�������N9���#�D'����J���Q5$�|�X��TV���v����GO�*[�p��xi(��YYN���R�D,�>8C���TE~lu+Ϳ\L&K|��}uC��B���(=��,s�*�oW 嵱@z>�8��TT����Ɣ�+��_�){g4)ت��wa��ɱ�RN2����o��/�O�O0��U��9��܉�����5�Q���M�����7�'��LQ���$�&�D�P�8Ta8�sB��b�؍��ᯎ7�!���0t�+6��?����G�;[�?�\�� -�T��)i:��z��#'���DM2dS�5��^����⏣3������uls�-B6�~_nzO�F�e5�_��r#�_�W:��~ъ�IV�+�{5�Aؼ��1�����3ة3�\U}%�����+�F�~=��<��I��u<�:���y
��1an���ԉ$rS�AV��������0uD�eQ��X�0{|S�ՋQu'���J�?���x��B�y�S��/7�B*����# (`OD�~����x/�T��j�wB,Nt��!�AE��7��x�kp�U� �z97kM!ܟC$��A1�l�I%�JJ�P7�>�5��k��T�������<C�M-裙�<��awQc���L-�n��V[�$`��	7F[S���.��0��x+�O,�i:����W��-־�N�4+��rEg��1ln&	�j(˗�W֋���ѕ�����͛Ѫ2��v�Q��jG�[�	1P���2^?jf␨��K�%�-Y=�B3V���ݙ*QL��%�t[o0��F����j��O����=��5ؚ��!MLR��HR�?P�1ԁ�F����t��tB�X�Ab�PS0?�Zغ�v�d���W�3:� �D�������H�DQ�0.c_�'Q�%xH�w �4�v�E�_�{T�_Ҡ�8G�E4\3ɣ�����3Y� l���ƾ���I��K'�Y��|//NH�j��&�# aW5+5��O)ڟ=�>B1�%m�2aq,�K]��YzD��T�������+�ڥR-����DeMs�z>G���3��VS��὿�)�ͼ_^d�'M��M���1�Wm���E��3.�����ቆL��[&��Gi�x
d^0Ƞo��)>Xo�c��)�Awf|hWR�D�0teʺ���ZC��I�M�|)�5�%AB���n3)����]��ؠ;�!%��BX.�|R$�3�Ӆ�<j�Za"_M�1b�Np�_i��w
p���2��z����S
ݣ@�2�t�3��d�~lDn��2�Wj#��e��+a!�d�G���.��&�(�M��4m5Ӧ�f���:��=����IYb�$���N!8�<�'��w�(�[�T�x�8U���x�@�8�^}�p\��˒���y�����^p�{�q�:�������:�te{-]����$�#f�T~��+�^Tl
�� z���8_��#&������)5�A*�Q�*'�}�f
;v�;�^��䠁
{��n�E���,'7#�UrHU�&_?-�C�t����X�?\غ@�$�d�͙@�-�¢���$� ��j`v�1�t�����f�G<O����fch+lEf:V#2����E]���M�$"�q�X�^��4����skA���v�� |����~���x���\�-ɋ%��BO�i��ڞ�vg���߽=�jFWhh��%Ҍ�����I��H�E&�zj��0��HP�X*���O��N1����z"�ǲ}�h�}�3�~D����m$��w曜Z"�̒$��t�k�	���%2�(j{�e�h�?�]\��za�n���H�+:5v��)��E�M�:�:8�x���1xAy�j�Q`��'�3�/�y��`;h{�����ⅹ����n�Qٙamϱ����d�fZ[KO���q3��%B���zwt����$kM%@� #���Wp��6ɖ��AT�?u�R#��1k�D��G%�aM��B�ig^��B���X�ʩ�������M��0~!�*���2�ݰSW t`��;����|�F�3R(���pT�
�=FZ��6�K��5�H��8��%����ul󐾈����Nl�l��\(/�f�.�=�}bo܎��FR'?:�>r:	g{^�'��K�V��ΈW׉�b��(��a���a����}�#9���l�&�3�����8}�S~��eg����[���u���zf�?�<<7���~��;}ڣ���ӣw�� �W�=0n��nb����*Ӵ�T��Z�XS.�7��T&�j���(D�`�}\���!3�)�8;g�h��ߋ�y�L7r�패}��㍌�oCz��x�~K��T�W�GG�gS���	��#LAW�r�����4    �����Y� XS/�/	��ы��H�x5ItK������{vXaq9����9'�pOk5��Lc��8�=���Sr��XTcU-�)3���qY�K&`]�0N�s��{,h��C�(��'���l�A��}�l�8�ۻj�~�񂶟A�~�F� �������c���fQ� ��kY�}���dnf�
��:~��"uL����E�E�BLr(��YJ��&ƾ���𸔵��x��3 ��M��#=oA��N���P � �sQK�=�}ׅ(����^�,�8b:]j�u�!��="���ܔ��Ҿ�S�6�5�T]��E4�-3V6D>+��{S���U;�B��!�jo����{B���F��t}�q���8(�*K �zi�;?�H�CG$~�z���
\ �#���iYQ����2�=�O����S���j�i���������ۤ`��}��b�3�Tѥ�)��f -'���e�����eZ�%��uYa��2N	=_��^���&��E��������|G~{Ozb������mӒ��5�>��l~b	��ɏ��0�h˛�j�+!|_*7�E	)�cp�G���sq�������j�Y��1[�}�������	z��\������	�����t�`%t��$�n��T�2󱚙*��*��l/w���>I��Ӑ��4��3O[#�9�C{�	��g��=^%�o6��8r��z'q�aF~.�\��jL��@+
[����6k~zN��9�%&t�o��/V�vD����o�1��z�q���^|
��5�=]�n�6F\��F����te�|6�#J��(��NmA�>�ŇL���u�2�Fvݟ�����7Y2����V%�r��&%_�U�C�T� ��X/�u�<kN�-��+�kO�$�-�M�{֕�	�~t'��x>��P�įa���T���]n��2�Q��kz��!�& 0ɣ������=i�;W�1+�1��������q�΢3N��{w���cB�#����אP��m�i��,�g�����~�9�������Y�L�2�Z��
�n�ڙ��\�4t�h�So޽y9ڨ�4Nmw�I���!�L���"{(D���#&q��^�x�.�j��;)'�X�W�_����>S�9�_����������<�#��?����� ��fF��2��N��	tj���!G�ȸ(^�>N)y=�Zo#'�ւR�an"
���d����)3��HI�P�rی�:�<k/rS7��x>��������ˋ�?#�����)8��|��΃)��E��k4��2H@�D(�LH;��<�G/�w\w���z�)7�Xy�N�N��47�Ly��<Q�������I�7����c�Rz��ܮz��=�X�0�o�d`��\�J%��J=fB�)��N�	c9f����A�+j�G O��X��K�-j�E-��7�J�E&���/"K�� ���	�<3��L�7�
�*��� ���-j�C|}Gh Xn�n5���m�B���bF��7�K/h<`��9�t^�6%�)�=Ѭ���-�-{F
��^���V �����ex���,�Q&��ݶ��I0TI�$�3�x�F�nNG��[�DW�P�W�$%Hx[�2�(� �"�lێ��y���d�v�~L��K���\�^di�\��N�S�g���y#�$�7�o�|)��DW����Hn�L��Hd&:��(IU��t��������;�Y��HS�r��Q������h�}�3�ه���Ĝ��]�i;L|�V:�v%6��UlR.�wC���2+K�ѯg�-K+�+?�W�U>^�iC��{��׳�um���LSY��J� 5^R9ERY���a����X����E�?���'����*�S��ܶX@,7��<� O"V���$ ~a��R���rȈ����$5���Z�i�E |d�����^�e�z��@8{;|@�wE��I26�l��qYNj��P���`�~X��"_Z?-�b�=��3�fd��.�o�iQ��;Ss"�C�	���8�2�U�|?U�hn 	�>p`�;k&��L�����$�����N�S�
7� ,���4h�ў�W� �S���q�ק�C�@^v�� �u������	;m'%�V!� ��qp�� ���i���4�T"�.Rd@��W��w���h�xV[��ﰹ�1v��8ύ�U�
fp��K�k|�D�z� AL8�	k�<�D!���B���:m_�=��}Y}мLp�� h�����|wƢ�|�]M
S\���_ ��Y��킰�Yר��\���+������������s���gg��q������:|wq�z����?:e��I�{p�ҠDn2tsa�Q%a���!�~�������g�t�\�G���'�V(?R��{��DzI�n��͖��!��˷h�+��٭$�G��$�[4���~A��dW����h7
�oV�+Qo��v���}�h7��fE�����m���ŮZQ���'��_$�� j(��dB�LOY�a�;��y�Rj�i*��|��/K=x��	կ��h#���Ȋ���l�]b��F�+r������⥁h0]��X/Q� !�J�d_ɏ�:�����p��S+Xl�t���׮��ߺ�����#T�^q���pQwj�Nڷ�ȗ7.�V��O^$��,���ŠJ�q��#/�}���mq��޴p��h�xr��G�a�iK�c��n��kK���y�n�ͣ�7�返^���^|}�>��,J��1�l3��$q"�8v�"�7��7�	�@x���}'�?�j��+�Y&s'uے���MBO����+W�ڡ�g1�D��片p�a��"O�t�7`�`���\��������ݟ\��f��I7K#��d�?s� 2%�&��`��J���
�+|AQsc�����VP�+��@�z�ˡL!"��E��b�;�������R�����wN=j04����
�4�Ԧ�]N�ݏ9.��}��YI	���c���-���V�|�~��b���?)���pȵ�#�l�RՋL�r1^�l#-w���@��̚���q� Ie���J�<�p?r'��RK��� ��(�J2D�o�/OJ�ZnR�� ح5O�琰fi�ˋ��BX�8�!�2��QW*�n�8��*�C��bl]P^{�3X�����b#�A#'m�LI<$�*+k��r-ne�ƇՆ	��k5[��c�L�Ď<�qT�<ߦWV��t$y��W�a.�Ғ�VOJ�lge1����|������4�6������4̫%��to�&ܲ���(񼍙��z�ٮR�V�oI�c�ͫA`V:��|w���ݍuyzf�o���0@Н�O˺;<�a���y��5��;t�\c/L\;��7��?��-,�������B ׼��;Yͥu�ɇ�!X�[� �Cn��_rJ�#�!b��H͋J�^h��[����|��rL�@�E�M�}��K���3��(+�M��#�=����dQ����"vMmF���<>'�H��3��[��utC¾��G�^y{�-���GW7#��lt�f��F�q�#'�^�vnp��^[)F"���!�l����Rؾ���3p�1G6��mp�|;Pa��w�� Hz�0I�!NS�ĪD�Zvp����Ŏ j�߾�oB{�N+;�n�%as!R�aI�ϛ��	���q�x����ŵ������uc��HO�|�2ȃ�I|'��L������d��Rʁ�|*9���*&u9���� r�lr��Q*#�-~���������^@~a�F�����)ePVV8��	<77��Vq�CC�^p �}ؠ�h����%0��G%��\��N��?��i��$Nu[c}���o�������kp�uO�����NֽH�'`�|ϔp�$���-;
�W��A�>yq(39��Gr\�#:��c0�s#DhL E)f�h�f�I�����z����y�0�c�^�{8�A�°��8��@'���LRK�8��&�C�o~o�s�g��;?��]��� ���s��@��    s�6N�	������K�F���u̸RN�y� ������B�Z����4�a���8�4Q��ZҔ���6p7�������#~��z~Rp ����Dpi�[���9�=��;�Bs�E��:�[|����e,~>���M�4�S��U²��;@��0}B��a	���� ԡ�&�n!�l���je�)�K�ySL���?�<B�O4�#P7�lX�\�3Fz�Ffw������=�M� )�@��*J�9u^@C��f`�ûEҤux�R��D��Y�0���"�8 ��r���4��C'��<��\$ί����K	����K����КG����x�'0���M��b��k�<_�G~�����Ӄ�� Pqn�B�ʓ���Ҹ"(�j}��#��9��E��g59����P�X�+T�hz�Ar'�z�TSB0ew4��I���BT,��DR`���p�SW_���#�m�dZ���K��#�4��x�0���%�)܁�U�]Lok�*�����Ջ�R�!#@�T�e6T�n�N��J���hv�R4��M�Q9�\��D�	�N�0��<�����Ӌ�t����Oߝ����ّA�3�1��x��:��F�W�n����i�uso��)5xkp'�w1��^kr���&�.�t����#���8�9Z.*p:`噪��考�6��Q�S�5�"�.�-�A������On�����)6`+!o�owe5��+�?q+B��D�n�=y�a��z�s��GIWŊ��Yb��)��<�~҇�[���߁=W)�`WO���X�0�(��.c'���?��LU���xE�4�m����btR�����[���Gt�=��U�B��5��?ڼ �'�����g,���X� D5�Y�٢���W�o&�����T�g����C#Vm�	)��5�������С���z�������<Q�T�{�.�������vX�2���q�?2�<�G�\Y/r%�5l>�geE���\}�H>����	��-�Cі�~��ץ~��fPw3n��$���n�����
G�׬qt��:y}|l]^��.N�����?B|xyF�ur�Fh��݈�٢�9N�U��
{�	�s:��VN�-�/}�-zY<g�� �C�U��,�`��p@6����zv9�{���[���TbkTB��	�,ǨiN�b�z1���ӌ.<�@�E��I5a��e[ ŏz7^KBo[{,|R}$R�X�6�;A 	Zz
��b��<��D���d��U`����#9�Ł��Ob�x��+M2w��;�(�Lϴ}a���H_�y�?A7������^������
������=�2z=:�g�_��H�WV��4T��Zc&C��]!��6H `[/����I��M�!��U|��#��|p�Db�Pg�������t��T�f�?^��IM��l���	Y����f{��s�L��R�w��yYM
�^������k[H��|(��5� 
7Z������r�/�#�
�0�f��)�����(��щ5��DI88���qR�
$!�ӎ�,ʭN��Ө���V�+@�]̬I�3���
PD�߯�$��4�S,�
����=LB����^�������ۿ��EQ���Y���N��X0�XM��u�k�����04�Oq4������DS������aq;h��y?L�{�=T�[��W��HkYPJ\�q��I)�)�j��c)"�έ��4�SR�br �L#FM�[��`�;.��%f(��ɧ��2��ʳi`d[�J�#FZe-�Řx��H��Ј�n��� ��f�xDT�	���k�v��/�h� 8׍y�%Ė�?N���)m����s]�P��V��*���Ȅ��h�K���} ��'{X�G3?��y�:Q�S���0�4�5��X!mO砏^�.F��חg������?`p>ূTx]���4(t��,��
�Q�%&-���<U�i\|ME�X}�]}i�]$}iw_)�AN����=����u'6+�V4wc���������V����n��c�2k���%�¬�#�!&*��xV��RT���E�t���5�Z�� =#�Q���,k<�r�yT\v�[��A0�OQO.T�;�@�ۛ9�^%����z1�z=��^�άW��7�u="b��\ǍH��hg���<|3�����\[(�&�n�f�����?����t&]��O}^� (��b��@Rh�2_�-꾣(��V&�b5S%��4�K��)���N+�4��)Y/�;Yq����$���ŎR>p5��E}���gP��+����2*����֪w煮TJc�-�
�/�A,��V�cF9�U���}��gƄQ`�ywu*j�e��P���=�^@���BA�e7��V֊�e֖z�6�nD"���\:)�b���'��m5i�GL.�\�Lܥ��,�@�A�;YD�����k5%l��,�3D.��~�-��*/��́���liE������Q7%�2
E��� 62q:����b��V��WoJ�&9���6�ʹ5�^«��oWŌ�f��(o�Ix�S�zd�iP�f@b��D�&�\=3�*�Sb���y���L@���o7�3`S5�d����89�-KK��!*tɨ�ip-�0+���[*��$��������U�]��-+�o
N�b��xŉ��'pbWltUvF���o%蛺���*�@7\�]�X/A�uS�A?�ǃSuq���ybp%�+����3ؑ�V�@��cݫ�>��ۂ�?Mg-����S���O���^�@�jvʂ�����/�^�	�R�k׻)I�3��!'ب�;M�-a�2��S�~��i�F/O�_[�_��sw����=��:��	;��552�v@䬱�ĉ�c��;M'��zr8��UoV�$ 4o�}Ĵ}�:����2I�մ��_Tٞv��뤝6;eb�Ŵ��������lm(]낹*��gk])x"�v��n1�S� מ��',��˾4��H��CA�+����P�\���]���[t��I9��+��⣚2U����\}�Ǎ��ߨ�?��'��7_{ܳ�qߚ����N�;~���
�?[�����}�ٛ���ѷ��v�C��m�sU��������:!N��l����H"_�a�8�q��m�jz#L�������������\������	:Vh�)k (�� �SL�;�qp<��\�΋cq`�j������"���:�k�2��cƖ�����ejڦ`�iYM��9ٝn�!��<�@��i��.P�Az�K�WEx,��`��������&�-5�l�_cM�=�\5�i�<�:$h�V����V��9=��:�DG�`|L$LK�yB�Ru��P:�@=��P��젻1���r�m��ҥ\'P/������sz����OVd���4)>��:ƕY&?�S�.i�L?���{�嶑lm�o��wU�(#OH@}���eYm<������@Bb��<إ�ꇘ�=3���(�$���Jb��ln�v�_�%�I ���u��.�	O�²$�9N���]�������ʌ���ǖ�|�H��@ ADY�_��(r�+���+7�?���~���ǐ�J*�:��154��)�;H������?����;�����|ʤŘT��bR������������G5.1Y����j�RwuiyRr�����f0��ٹ�[��#���яX�:=���LY�����ƺ#P�Iߓ���z}[��T�z�u����^��>��&C�)ӲkKQ湴�#���u�U��߿��#���4z���ӟB+�罧l����.�"I-fA�Fum�:�)s:���aHp���<f��c�J!R��
r���I����o
Ѹô���/Ԇ�o'Uҋ~*�L�$7�4V�YΊ�̛{,l��IAFX�hq[��=A8O���v����;A�<�o/�[��*g"@=�h�\��ܯ���f�vP��ޑal�������)@UR&�N���o�.�l���ey&�;P��"%K�<    M�_p�ǲ=�|�bN��-,�YArlu"]i������T��8_8_�]�Km��6Y�K��.+E��,4��]$��'3�N��rܡ�F?��2��ű_��Cl/&)l�Q��S�<u�Wu�g&�I ���s�	&|-05����]�:C�tc��������L� �K3�		w7�潣ܾY!\[e��� ����>H�������ŕ�6o���>�u(����c�U����7q��\�������O�T� a;!���n2U��y��s������QV8K]�LS/� #E�p���ܒz��Hj��Q�߿����L)����+�H�"�:�uHȲ;.z��Տ�q��7t���D'��ó.;�D;����BPu ���"�Y����9��-JL�eQm���Od�w~ދ.�h���G����<����i������4�!H�[�i@v�#�1�#��AA������b3�3c�ԟCm �����]�,��0��?��FԵˠ�+\���ξ�9��`z`YKAf*Vb0Zp���`�R^1Qp.�B3��"��)^�?8���i
�;�0��%��K�Qj+U��_� �~de,$K2D��u�JW�?_�䈩��c7r��:
�z
���+5�W��V��Z� �Ej�|Jny�0��B�\f%*�{���c������J(�Ϗ�D.3�·���%(W��*��F9א\0�iW�6�q��IݷH.���F����G�lO�"C	����g�X�+�>:�~���1uAb 8��\4���䴇�������4�j(~o��r,�T�@b9�9ċ1ʩ7I�p@P���S�8=0��Fs05`�b�7��x�#k�"!��*9�\������T[���������"����%	;���P�~��B8�KY��n��M*Jp~ů��Tn���_�W���y$�
4	�<�u�ד�'��?ƥwd
��`J��ͤɹR���.��ڡ_We��C��}��wE��)�6(�D��Z��>����/���В�}��z�V�s>��hb�d��ę�k�:W��`)�F���L���	�%�y���4df1�G�J�����M11ج G�;8�W[���.��-'�uk�~|�������.82�胀�{3�|u�NhI��??]97y~�~Fq	���
�H���c�y�t��;47��V�]��+�����M6rw=�_\	[�Z��_�6B؍N��.!Ě���!V?~��
+��>���[:��[͋��m�����@��YE�P�b � UL|��}���	�C*_T}�Q�n���Kl�wn+p�)gޑ������D��jp�u/�@54b�P}g_#��Lհ�v?)��2}�'�����(���	p�9�9�o��Dek�A�ÿ�IC����z�����Qs
!Â���y<KDlJt���ꔱ�2�mG�q�S/����l{�I@E��*��P�w	tz|�w*Y�5�fm������0vQ7�&��k
{,;o�_�a�9����@38���|=��ίC�����C��;�/������$� A����>ƌ:^hgv�X@�,��ك���Q>�m��6���n)ߎ�xOс�X��&4u�	�tןā��[�Qo��M� �3����7�=��{�g�Ed�P��n_���c��s>�~����1\�~�B����>�@T��Wr��*I7W�;%{���!�����I���Eo�>��up:	����{��kNk��lO}��݇(2c�}Wg��Ec��e����L�!M-,�1�!n$�߬q=�KE\��& yL}�UM�QNKUM�cZ��8K㶕��Ɗ�`�Pq��la�����B��q���C��y �@���~oC���x�/��=�
�d8��S��P��'˰F_i�47F�� ���q>�|�~�O��������،����q�%{&S����n�]nE)�ǘq��#��bq��&�P����F=�ͼ����xl�!��p���}��s	N:��ɱ__U�=PF5�d�4�up�1#y��6I�a�|n~?&zoZ�A����a�,��N� �˺�� C�(wH�'�>	�!8�/AU��_����[f�@H��ݠ'*�$�uc�O>��Ҽ�R���J�g�"�zB�S;�����D�� C�8����`���@;������S.r#
e�*�����y�<߄��-X9�3�{�&\�[�G��>�*�z�>�^ciϽYH'R��F1��[z�b�ж��Fq��|�O'���'k�����7 dpg0g���s�����w��38���|��'yW$$�ANC�	���i��{8����K��.����~��k1�[L�W ���i�����t(=Z�(tQ�H��q��β�o��K<,yu,���H��X�zG��l^��1F$��N�n�C�;4�iX�r�����h@:�:���+Q'��K�V�l�N(o �Չ�8��C�r/ϏN�D��{�a@|r	�����A�oB����J��T*�Y&e�T��T�Z�i��R0���߿�"��Q���$Rcg�*cTE�pӮ)u��ejT� �p��&���t8�948^r[��l%�7�0��/�Jl&���ϬV����b��$�s�2��������h'8��X,��/S���e���ת�.c<�^�W���,q�æ��='�@s
F�)S�I7�%w.��%!a����f8R�4q�Y��J��r��/�6�Zn$<j���LȨV��$.�elSyƳ
��;�HC�U��+�7Ƚq����-e�rE�Fe�g�ညѩ�������=�'c���d�%{2S�Y�d��.�0w)�TJ�b�A1Ƃ)�0V&E��̝-un0j�;��u���1�k :J�0P�S0P�j�8֬M�{�0!�����
���Q-�,媩)ǔ���9�g.a���%�S��޵_�?�kO��/<�	C�����V��Yג�)�('��(�<�P��45`uzwj���B�|��:�!��rHK3ہ3�K�K�b����XD�a���?������?�VN(�"2�$�������H��V���X(�;��T�<[��^˓�9iR�K�L�`��������l�_VԷ��_6b������_��;j)��jm.%!�S��Ԟ�g
�Dd�	Wr�$q���n�$��"wk���1����[+�삑���n�̙���i���a]e%�}\lPA�f��h��]7���= "7�������� �&e�������)ݥ��0
��Qc�O7�l�ntA�D�x�:˫o�q�c�aQbȋ�:_�S#)�ɪF��n�E��Ypg����x>s��rh��Ci�&�KO{B�6��t<��w�kN��?r̶F���lܴ��=��$��JՃ*v�,���覻�Ii��gT&��N�*Ke�.s�Q�T�V�yGfU���ۃ�h�wq�{w��8��_T{H�?���.-���~��Ne�U�2,���J@'b��շ���>{�Zu��J�j��)��
$�^������.��-�$�ަc_�zae�N��ƃ��Ƙ��W�j�d`��*Wb���
�[u�í��$?�WTgG(c�k)AL�E
�pj�~����y�g!⦞��T`Ib����DT�n�O(Y9L�{����a�Y�,�E/�6s.ST䨅�,LWk+�Mra�o�������~o�IT�xݚ�.ubռ��Jx�n"lbbi�I����q���gK�'��G���)��%�'�r��:���ɳL�]V&�C�MQ��}����L�zx�\��b-���*2]<�[��:���dO��D�4҉�K,tˡW#��	%��a�1V�7҉�PI��eZ#�ep��3��,w��T���~c�ա���W���3�	}8#��e��j�(��a�)!��V#�/j=���t5��4�W�m��t�t�aU_�ka���lDo��]�K\l�\��wK�]\$�L���*T�E�Q�l�};?x��    ,A����ok��'>�D�f�������=����g"��cn����#�+���ȧW1	�f�<�I@�����ц����U�c{��e������|�Xk�t�����H(M=4���ب�o#5Q��p�
X@!��O�=�Vt��|'�Op���[�2��;w`n�cW-�d��M�L��PM1ЇV�����|4�!aKd����j'�M��W�vuXe�w���G����A-[כ_Ö́d�}����}>0��G֑�LE�8]y�n��5;��"1d�5�ϏN�����qo��A���g��-[��r}�g�/����UM�?��g]Z�=�~�a��Xs���~J�cf�ήk�É��C̭kQ}՝Υ�3YϞ�^�5�*6૗�3i�R�n�%t,J���E�g�,�y��xv~J�Z��!���p�Q��r�-�����?�B�~����)D\R�UlP 0��U�T��"����m����r�̬L�1�uxQFHl�k��ĝ�WfPFF���EU���w�7���0�^,��������A�����U�8v��%<j{�«%W�9�-^Xփ�ɹ+�$,�J�-ӥH�RH��$_� ��yore|����>��cw��Jxjс��]/ч�,�!���Z�p����� Щ�p*�A2�|7E/��w;b��?���/�0��@c؇���@-<�{�T`c4�n�+cꎣ�1A���.H6�\x��ߵ��F0@��s��~��(ꠥ�E%�@J@5RR�VUtC�L[�fI֦e{B�*Ŕ�ՠ[K��$��3��<�ӆ���Ȯ�93Z�T��7���j(��<����U�ݛ^3������Ѭ�FIF��'cL	P���B�{R��E�}w���D%����c�>{���{�IR2���`��fT�Dh��93� ��C}j����E�]�
ؘ���LED�J�H��c�_�t���.'f�q-)CR/��g}�1a��£7�F̧s�&�Y��l~rs�'	���*��&OD�x�����G�ż4�̢�&���޸���F�Oȷ9Dg���E)Wj��!rQ-�zqvvzH��@��+ք�_S�\RC�a�9�0f�}Ɏ���x�}�}9�հeߩ֏g�D"D�A9�J��5���?aڈ�����B�oT<��^�]_f��K��(Н��7������#�u��)�NxZԪ���V"��k�o�od�g�i�$`,:j�8��&���£6�KY�_�V~����s��i��J��h���oC��j�%�{����MoI�$��zz��L,iޗ�*�Z͸S�'����S�t\�a��t 6�Py�@�Pt��6����1��4���޳���b.3͓�E��:�N]�5&Xv� �Y^މ>�y�~� �k�Į)>I�	������u��'�CTƐ�@�
q�����ɠq.�«a�B3Aa�0,hL*��fS,��6�/�	Ё�y�`pK�S����ZE��37lϏD`#�b2���g.�����0,2������a�G�������紘*vԄ3�f;ݤ�� ��Y8N���jT �	-A��#�5�a�#ս�U��f�ê�LE���Ux����ӎv��O�f���V&�	p����z`r�f�&�W��`�w�@L�F߳�ԝ��N��-kD2���E��.�f����R_
b1�#Lki|Zp���Y!a,cVJ�������ˉ���ߓ5��q����x2" �-q>N�BتpMH�#5C� D�F��Ϣ��E���)6���Y $�kR�#�yepS��tC�W��7
S������A������n��h�$��b-�=�ysP���~�&�.\2���C�6��t�s�d��Y`#�2��]���b0P�������������B#���W��'�Kp�����X���[�g0�#�y�� n/�:IU6m��u)ײ�r�M4�U��0ݩ����m���(�1
��n����wxv8�j�Ӛǃa�a�Z�z�&�w��{Qlt�!����P��Fy6y�D/�@��.@RM�Oi�ِP־�F�U����w�C�J�^��JM`�E�����H��E*��>y�x�Xj�������n6^0>�U4R|�D����������p���:�_���<�AO4�'9��h>���o��vn໬�0��507ȔWQ`W���R��t���+!!g�Jfi;�NU��㣨"W�ƺx7�(�:`���A�Ԇ�Gj��r�c
�u&f�H�T��\T���w�R+͕cª�٭͆H�(�{Bj�b�\��V�XOn	Q�p}�xgi�p%e&��H���i�&��.�w�ز᪸�@�V����8s�}��x��x���.p3�0�{`��8U�=��]�c���3Y$e�dPl^vK�J�D-���M_7c=s������p3SG��n���
9C%�J*C����eq��2Sy,di��|�l��׸���~��R����I({������������Y�WB�J��^Q|v���~��Fi+,�Bvm���q#��2�#m�=��r����-,��U�Xf2�}7�
t�U�,�F6�jI8B�+�:>{��=`����!�%�[�nsqj���7�6-��K�lVJ��哧��>y�ߑ���q��f��=�WX���Œ��4�I�\�-K!Ml�vv����T0ʶ4&����61I��UV���ܚ1�"��Rؤ+Ӳjn��uK��</��9��Z�=J��&�=�ha��՘L�1SXX��ZYic��9���{�1��^���)n�W}��q�
���O�3A���#��K��*�_��"o+C�P3��k��K��-W��o�P�-QsѢ��N_ޑ��]�̲��?MM}�SS[�2a�i#��©���,�Uuh�_���D��-��7 g(�����M��O7�zl {!o����Z���u'c��"r��D�8=C��H⨛�Jv�Hk�nE2�o�s�"�:�����,W�����'�.j��"�-l���{[���q��]�����&��������_�������ދ7�p�;�� ��[Oj�-��*0[#R���B<6��(Ҍ)��sI��.�Z���ĉۚ��k�O@�eY����ucpv�������ab/V���*I����D8!�-v�92L��n��$�MZ���~��a͗��)~���(Np�6Ҝ����+���E{qeF����"�H������F��=�P�0(���������]qt�� �)��rۅ�`�4w��*+�t_w1��䆆���Ʒ�R�)Bz����pγ_V���WC�]�'�J�pԄN^�n��%[��5z��u]5X]:	}x}B�<��VNa��l]��rg
�Je W�-E�J���J��9Y��<����7�S��O����`���g��?����K�5���
����7���I;����qT��S��aŮ�c��P��8�I�Y�i����h�ia��!���w��n�%�偃 U�P�Rd[�ƅǞ��+�Ό-�E.��\�kYJ�Ǿݏ�n��91��$��%O�#GNKFT��sҞ��4[�):G��#�I89���΄�-٩4Y� �%��t]ɨ*�cQ(�.�+�~q~[�b]�B��Fv�`Y՛Pخ*��Ea�F��4���`>�.�f��"��F��lʦ��X�'F�X'���@[�6ɔ���^J�D	oD' �\4���%>橖\���������D��Eb�����ص�v3[�<��R��&��̟��O��A�'?A���
���ζ@T�Q��-��i�#}�h>�����?�ւh|y~����oș^�:o��D�SޕiMsx���L���_�^qF��jW�J)�+na	�+dV\l�N��[�R�@���,�m�up�0�܂��K�-�!�F=�*��k�{/�.^{�y�g�!�&N���'��)d�[W!$���6v����E�-Cj�����D'�_�̴fe�v��k(��ٞ���Do>�q�p+�Y-Ks����+1�ݴ,Kt��QX�\�kc�_��<�֤�^ϋ��[��     3���q��?���3Z$B�(\el-	�I��x��O�p�78�Ii!��$z���q~i�C���U_:�6�I@�@p�r����j@c��������?Dw��"ͨqj҇7����ݠ��Fw��#���ӕU�Pu��������/�	�� h���8�F�������%��ނla>�t�Fa7Ǒ��(F���l5v�^����O�1�����'7���c��t(�ߖ{�<�0~�`d�rihQg��^���d��<:�<�]P�$z�{��w�'kvά�Ʒ����w�m��=���["G�I7�6X�}"�O���[����xϱ�����l��$���v::�"��~���Ne$��2��VDii=��ܓ�h�8�-^Z�e.���Ҥq%.�p9<�L
�9����w��eL8�:�����k�ތK�q�7^��ցg�U��)2_�w]����{�F`�ö'0�C�f�BH�U1��ԦIW��ƆŖs����`S��$�KU�2���i,xYH)��80��N���.��@��c���"�|e���Jޕ�d��.��j�֔9��{���jN�ٌ_���M;�1�� �u/Ses��������y�q��,�
Y-ѻ�+��$��+=2����m"�����f�~h�j�<6�n����2'�'�f�?^.u��)���g��0�)�|� P؟�~��-+{K�F[x?��(�[�Ժ��e]ystzzv~[G��D�5]��e��.ƛ�N��"!
��̖3��9�h	�`{�ܕ`\2�9�ϽK,�q���J�迪p��
���&*__�_W\��Hak&<l{��BQ0)8�Qd�H!ˊ�*m^2�b1L`��&7S3�N̿R�a��� h�� h�錺-1[���� �u36*�b���j����
d�Q��t����/G��d��	�g��x��� �8�<[�[^Ӵ�����&jx�
H4��C�;D5���C��@��"pwq�v���Ttu��Ɲ}�������:���:p#Lc춞7n�!_8�\�n<	8��q蚚��|��k��j�Ō"7��&���>���W�0+7�JR�X���D�M���czտ��Gp{�Wc؅/W��
��nY�ǟ���k�E�Uz���o�衺��_����義g��6n��ٗ�������o��.R���ی�L�T{R��$��ȅ�]nEy��\�)���ܰ�+�Ԛ\�ئ�[~����$z7��ɱ�$�@���}%�&�����z�;}�����I�׃��X{�xwp��?}��ʣ�u@I;� �VJ�����ab%8NE#R�3�)ȇ��Z��`;5��	��5�8q�H :ai�^��lmf�,Mr�Ģ -��#N
�v3�N��@��
[��"�y��7cTҕ����F1a���4FӼyc��/��;��^����'
|���+�k:��g�ʰ"�� bUt���1�08A�ҪC��}²^	�-�@��+
f�OC321=z庋<��+0�`��Ǫ�&|�#e��{X�r>�����<I@�Y���A����;��dH��%��x���C�G��Rj��QQK��V��g*n�zH�u��<������:Do�X�]#�����f|���K±;g]��:̦ �ĸ��%�zK3��d��+x]яo�lf.����S�K�!�O��k86Cr�w�C�}��<(�&��/仑W�)o��L�y��ϟ�/���x%lj���f`*��DXIi���"����:��tpe�H V����K�7LQxZ$E#�FQ�e!�OP �Θ��J�����t����}�f�q�����%©5�(��'��'���޶Fk�î����m=$�D���ܟ<տ�}�ah��=��ù��Q���ѧe��6 ���n�}K�#|�OU��o�c��g��B^����>40E1�`��z�cg0wS����,к+���ϧ1�.���z�6�R}!\4ob
�4�
�ܗ��1�)����t@�ă��\�i=����M��U��tZ��<��_�)�ü�'�#^���� �aET��If���!^L@=�Ct}�9�̂/5|��ʳ�� u["Y�"���n�o��M�X�S����Q�솫�E��T���pFk����R�5�.�]z,3�3��
-��+<�en�~(o���cD�f?��JB�f�j�#Q�"�=��ԃ�����N���x��	�'f:*�!<��ߨ�DTS��f��*+B��C�! A���8���-,�"����%��ٵ)����]*Uٯ�tK@�~�%A��ގ��]�~��r<���",},���X~��tM�L���zq= CָE�����#"�H_�A�	on���d���� �̙#��4j~ۋ��q�1���*<�b?�a�?5���C�$PIF�/`��S�⌺��*OzA�D���x}0��U�$Ȅ���e� �Z��oO��L�A�������9���-��]8Q��[}Xw8�Eq�=�f�_��vE[5�V��o����;��q^X���\�1R���^�@�dJC�!S���>�E�{�	���*+���X�B@�IM��K����e�!z�Yє��; ���`�#x(��n��b�5fW�1T���)��A����l=�-�o�����q��N��|���ZDl��V����~��{݋F����za�*�8��|�&��`�<���y��Ukї�d��W ���T��}��+�����U\qh�ج�C7�=	qT�C�Sj#�҅c:u�����Ҽ����`a�6�>:�H�A��&0��	_��������o�o#����H��Bz��;����R,_uv�;=< �~�����(��d�"�zj�3�d�\OO���G�b��ۨ�����ߘ�K����{�(�tT��
���;�KpU�ȄM��J�k�Y���ſ����ZV�̿�%wס��%�/�s��Y�C�L|�֊n�z���� ���o�^"���R�e�"t{��Ո_�2βT6_Q"�n\�;J��`J}�L�H �!�����8U(%�#�&��z���jT6ӫa�]��mA�j�Dkk�)D�ӯ6�v�4K�ECgo����ѭC��jM����J��z�:� ���΋�gW���G�Z��ok%#.�c�h��=�~747�U���)8�n��z��J��s�SB}�� �K�0�U���H�gZ�1$�6#k%����xe������:o�?�Ts���ײ�"�i︷�h�i�-��i�uy"
LO���L��[�ĥ笐�i���.)SlV�M`5L���rp~Ulm�hV�5R��x���,��� ��K|�g���bƅi,�fNw���if��I��eCU.���LW�c13�R��DY`�'�sӟb��V�!�`���j����ޠ�|=�O6��AXj��	�R�B�������� ��`��l��H!�h�R�^`xR�����i�U�U+K^��k�f�t��Y�6�w	��̷crN�l�_�]6%-�s��i^K�R�'[O<�����E }���B`g�mJkI\"��/���z14�A���__������5�bn4D��I�`!�P�Q�&�#/!�ѡz���<���m�3O Q��j �C׈ã��?�o-��$�|� �h<�{�����垊�ןMa�s��&�>�H�O���9���ˇ���'�Q�A�����M"r,$����VW����,���+6ֹ/}���>"��{+��FoBD���9\�&�H�$��߿Dt�ntq�;>��{C�����Ц��4���4j���jN��ݿ�*Ө�%e���!@���ѵՖi#�\�4U��.�Wk�!L���*K�$��4�$���t7�ZƄe��QK��In�沮�%q��"�7���J�)sO���a���kf-��Z`6ъ*��l��8i�b�p���0o,'���b}��(j��X�Z��9R94ޚ��BZI���2j_�0�'s�4[+s�tER�%�����C��\vG�;2�V2��Y=��l��%u�Dz;�V��    ��)p'l5�UĢ����)c�$wx��2_�OK�b�d-a�i$!`�ӻ:��]n��v�h����8u�)���"�4KT�Lɲ͑�`����V�U-�B��uY1�Ӡo�
ɾ
+����oc�H��+�z�#Dܹ/|z
�~P&:<m�pe���(G�7��l���ײK�
y-���[8���eK��I�H#zkgr]b3�6셕H kW�2���X�΋1Nh���������oLD�?���������ϟ�;�⣁� D�z7��Pd�~Z��?��܎G�"2^�,�dnA*�X;1:'�UЯ���+^.��N�i[�5����z�հ�x�lOƻ� �m�Ys�p+T�3֔sH�(u�U�좒�%	+��6�w����,������w���<�	�N�~�1ZX0�R�X!\��_OE�u(V�z�"�`�_TF���L\��	��_�0*�c4�#���4�O|�����	�$8G����t5��H�Xj����GO0��~Ea��O�N_V'}ݞ�&���tͬ�z��8�����\0?�OL���Ϋ��	_ɭ�	�"K��6��p�A�>���a�t�iq��Oy]}�F��8������\��'_�"�7�'y>�q�`g�K�'��& ���+�{o�ȇ�}��nFcjW���q�e-AQ��W��53�D,裸8��n���i.�5�ߐ�������b����g�顒1UI-\E&.E&$�O�3q����'�ͫ�Jg���&1*�36�߷��y	�(���B68�I71��sR�n�U�ӵ'��
�w|�-,Q�8]0�,�
��6�!�41椿���i��)HT���p��Xi�2e�}�
�-�"_ځ\�ni3�o�T2�l�=DXNw9K��<���^��ҥ`Gn-U�&�y�$�A�uEE�2S�ħ,��L9��LX�+�d��S��;�;n����:&�Np ds(�{�X��$��7#�<oaa�T;��d���My�u5詊�?�k%����(_��os�kcsd��e<�����+Q,��$M��,ܗ��C�~�q���?j��Y�����o���y���K�+�3F9�r�7�$MK��Jk�J�"_�U{"݃��z��sma	z�D0V(�`��B`ϭ�&��,�N���՞;0����v(�BMZgŶ�|��DX�b�׍��=3��y42�Kf?ݒV�g[����`�(��7��Gl�h(�!!���` "j{$�/fRAqYA�\�k0P�/�zT9}�@�>�g����&��U}'8l0��aZ f�O�/�1�.��Ƣ3=�Of ��Us����`_���]��Cp�h�"�v��Lv�ř�e��f8�d�a��dHw}� �q��ojz7`�o3�+���A��p�	���C�$�2���#����(x@pW��ί���ap/��;b��@�V�d��n��u�%�P�����y�l�h!���!jk'�v�ڶ�yL�h��J������h���G�o�^�$z�;=�!X��q$x�v���q��wq������m��D�������>Ꝝ�Gh�`�h;o+$��Մh�I�,��dX�T@�.��n��;jz7��g��'���h8P�b�F��1�_,n�pl�w���H�� �����E�>��OW�ɐ�?��C�M}�#B#i.��Lh���y0�L�S�����p�Ė�G���.ۍ��jv5m��}Ā�*׀|E�O���ܟ04p�'�x��	1LD�..zGA��x���U$�h06�s��5�=�+cPK	�~E{��7^���?�D��Ų�Q��ሌ�v7��L��7�ѳ����ַG���D��9�
xS�*�Vc�as/���)�3v�1����D�g����`��JUú�m�<�܁?
�wϢ�%�7�1FSD������d�!ҝ����E� �c�_�=�u	D�- ζ�䅇����D
����ū5j�޳�����h�������s�y#��[��\��i�u@�fѱ3��?�Ź��
�j�7������U�!.�@����j)q/Wm��/�n���EJ���������烋fy��N:~{<f[��r��!�������r��_�ϳa	i>����VBm���M���j��� �>O�[�yC�M�ܚb���M@Z$ h�(�x�t�M����b��
�.Ă��:9\�q\0��k�<�?np���Q�CV��˚5����]��3�a!t�	��#�¾O���Ht0�u����\Q�����:"��nwa�U��G�y�)J�LnV��岈e��똕�|c��~h!��fGC5�OD�|��/0���������>� !� m�m��`{�X�r���N|'�@�aøҚ/ޟ����q�<�1hW�6\Or$��s�������d<����d9����Op����
�x<����Z8�Z6�}U������9}����#Ęm�.��2rj q�Tl��?E�Gxyt�:����]`>�!)#sӦ̤�s찍�#�Fw��zD#��2�1�?ް*���� �ߐ�O��\�<�F[�X���5��6%˹���W*��T�o8>89;Eg���S�սe�Kh`��]�)-Bw�W�G`_̧Op&���-x��5Q���`�"���I\��ܧ1# ���?P��\���`v�y���޿���?ʨjs����(��5z�X��B�n��sR�l���S[+}7w�����\�UE���g秷,��~Zp�֣�I�Pug!lY�v�Hx��R��撴��Gw�ʋ��}n�����1�h}�f�.�Oi���`Nf��{�F�@Zz�G����|8�4S����%~)�6%H�1�˳��y���F£j��
�zKL���ƅu12��<�PM\p��R�������w���[����kL&r1�gb2�e+�C�[&�"oʴb����z*�w�T�ʤ�\���k�2�O�L�ˤ�`p �������ٛ�_Q��I�A�9�L�-�k����8���߿�U��G:6L�5U��IW6ԕ���lu}ktE����-�����-M!�������E�48[�yt���8������1K�>��<�V<��ww��a��)+�HL��T@t�M.c�j�D�l�l=1L�켸��L�;�C�����-67AUP��ؑ�M4Dt��� ̧���n&J3�e M�Ѵ���.I��
'����xBx�y�6���g0�`�<\�B�0\���>|��W���p"	n�2���O�ڌj�5O��x`(ӁTo�h�_ԛ�g�r
Qb�ӫڧ��V��1<-���h���)�Z����/�_�ۉ^Q?�o 	G>�V��?�\�\������o%����ZS2�	U���L����pKM��ӂ�
߂����x_�28i�=��U6�jV5k�	8u�ـ�T��,��	�d��=+c;��Il��^p��Y����;�n>�_�� �.fn��&v<��_����^�N߽>8y�~����M?������Y��&CG��DK��ʭ�S�б�i�r�������?�Q��9a�
G��雅 ,&QC}�O���/Z���<����S�L��x�����0D}^|Y��A��AŨe�� �fh�=��Qa����u��߅?aԗ�yD�^��j,(i5tH�T+���/�' ��-��P��D��kW�`?Գ�/ Eo��X�-%b��/i�{q�+��T�@E���Ǌ�^%�rY�M��tE)�B�n���fqX�|��w�ӗ�{���/<���)�&m��^�tk�'<���򤩒I�l��UX�&�U�]��XO�:�s77��kD���L'<y���]�c��(l��=*y9˻�VZ&.r�pS�eTgM%�Z��V��V��l������E��"!� V���ROp��6�./����u��w�+ ��;��@����S�D�5t��|�|f�@�J�f\
���F�W*�]0�    b�
��ZV�Y�dV�Z���	�>�B�J���F�:D��B��G����d�͕R�t=K�IieR�]%\�tS*lsȋ4�9<@���7�h�(�q� A2�[�Y�Ltb�"[��2�"�=.v�	y����5��6 Z�m��	�]�,��\ǒ?
����cV�Fȼ�9V�n�c�������^�j�zLvZ�1��_�״��v!�=�v�Nb�7�	4R>�Nei)]�X�3�K�F9�r��1��^rZ��PU䢫ޝ�O;�f� ��Po�d}R
�-�R�X	�P`��/}50�D8��dƪ��~���T1U*�� '�nl��+x�R؀�]�(����f���������MZ[�((���Q	x�,�<5�	���T��S�W�7�+(*b]�2)�A��<ɫ��$�:mU!�R�"Q�������^��3��iHŉ���4x7ق�gi�;� ��<��D��]��E̡߽�Ǫ�A�4I��4�3MJ�̈́`9�)S����5����jzX�k` �/��hi�]S:�?j�lb	7O��N��͍�MM�nt�DϢ��qG���?�wXF�.DC!�g"˪�U�l�HLi�6dG$��O����^�A��k�9����޴�+�\�&B�;�������}�ڍ)T�	���- �ߪ�CM��|N�mrf��.�p�ք���xB�	��?�{���(ǜ5Mr9��g�7�O�X��|	��*���`{�>��g髅���Oa�yG��]|�|�i>��Gj�'+hNvJ�GC�:�p������`�`k(��1_5�c@5ޡ��S�I6d��"�P��ƅ=�A��t���o�Pn5l�����IU��dEڅ�A��*qĭ�A*ɱ�"�)oa	t}���t)OQ�ðk
�0�:����I��ʉj1ԋ�����eo�IN#��X3�����~ �:5�I����/�G1A��t@s�wȋcU��in8�g(x��	)�����_c�Ҧ
�t�x)�N�O�
�*/�aC�@����|U�cl� 4*��҄t%6��h��-j�_�ք�ϐ�����qＩ)��m��h=��pJ���'�{�+�/4���쓹yCmS��<�����%n��p�t :����t���8��|�tf�	�`\�ڠx��~�����a��?��P?�E�%aC�?�&K�.��  �7��M�sv=�80c:�}�w-�}����EV��t��1��S��U_#�T��	�KJ������%++q[�Bɦ������J���y��w�T��W�woz�=~I��8[=Z����6vz{����w�y��wߍ.A��)���>%d�� ?|؈����(��Y����R�J�X�H���l�S�ؔ��D�k�n���^U�����qTo҃�4����n~[���jZ����*4,V-D�U]�N�O�7�1]���{����F�)����П�؉���t������he?��葔����$��Y�i�M����5��55��� ږ��=gN����
��6�9�T��<��1`f�¬��L�5JY^t��Y��D%V}�xy�ٞһ�N�|���Z�c��s�hK�qc�j��N*��r�7�йI�ﶢ����,S]�E&Փ���$��R�T�(3���d&Q�Leno������	+�=2��Y��6Lۤy.J&0Z9�f�Q�U8F7�a�^��G&M�0�������V(c��PsT5bs׵�g�
���Ͷq��[�D�9k���8j�d���� �cR�p����J'�A��,�1Rq#�o�`��������<3�����O*i�a*y���q��KO�%�h���CGs��CN�{��NK�K��4e��,s�rmAP`��9-�2�qA��YE]�-Ӆ~���+2̲Rz�b��f:4�>U�����	&��i�	s_*N8E'��rQ(Y>�F�Qq}?�T�Y��EG����z(e�7!t��x�,~U �T�Ӵ���U��[0wQ8�a�3{_��}����U��FXU�)}pJ}��t<��w�kA��!:��m�
���Í"��C�e"�R����~ �U��6��rSB$�f:5�˘᪺'\U��j1��o����.Nz����
�jB�tMtm���o4����b���&ب�%�웫�D��3��|1w�6���-y�I)��i7p�C�T>��/�n:Y������CXq؟���)�h�|�y�z��1ȅ��5j��	qk�V�ȱ�خ�W�i�g	���y�ʜkٴpI����,�M2���6n�A�+��v�媪Y#Ǝ�5�P�)����B�w%�I4�y������k`rn��3j͉���e����ȽK��pʊ%L2[䘦����8gݢL�yY2������r�g�RQs��&e0���j"�KQ�y>yn`����ߦ���o+[V���mf�@x�=g*s���C{������L1���� ����ۼ�b�s-�>m�x� �׉viY��հ���h@t�=l�X���8_�Jb
# m�A耕�*��&#*w�`��'��5@8�~j���X�,-�����
%�@Y�����ߘ\!���#�3��s\�kl��&_�X�K$R���p6&iE�%c��%��ѱL�����I�+�L�(WK���K�9/�U6o*X�UWjgB��>�$��U�\���ʧ��=m�OT����w��{���q�{M.]���Z�R]%�B�"wI�I����؋9��4���[KTI���Lj����B��{���#��"Xg0�J�Uǳ�41�&�3����(3�
q8���Ld1�L,�^���,+]&e3`�ʙ���+�p��n{d�������	��YQ���cʖ&KbL,���"�L��!��L:��o�A_��㩏�L��~-q(6��ؠ�.
�~g1���c¥#��i\5�8$��O��g��?L��?���v��i>!��l���b�ѐ��B,��VO��b5��f4�)�=���]&crs&�{�@9�g̈́��z]��5�8g�U*�ԋQ��!?<�(W>��޺w�/��ã�Ãs�������Ӻ���c�niA�⢋!�>��T;��8�V�m�����HR���;4E3���~{~k0M���Ӭ%2����H�H@���`Miy*�_�aL6��oX�qZ��͡V�ꖢІ)��e!X
�7� .g#�S����w|�4�2�A�{=��`4?z?�ZG��K	��'3h�v�?�S4��$(�&"^�A���&`(o<�%B�a��t~��U͸������.cs`h�����@SM �?D�q�l��!��|1T�$�2`:{���Mu/�;C����;�l�U�/��"vg�C����XR����vi����W�=DE���B��e���$fB�����K��d�U�e��,.2�Y��l����9���	�z����~�<:;=�OW�^���MB�q�&�x\:N�g(��LY��O�3.sO�q�~�W��c:M3��|��%*�V��Rj��^p��[��(8�٢'�����hc�bhҢ+5�IQX���$��-�	��D$�=To-Q���D��4_�3�6dm�c��o/�q��<d��r0��B��7����>�E�;���(+���r�1�9�:m���֗ZJ��-j��i��ҼQk�.u�R���<�2���j�9�s����}g�O>�n���lҥ�!�]*Е��0���d��&M����줫Q�ښj�!6WPjO�ح���!�l�,�a�����I�R�v����+s�AX��d��b��i��0���Et~�2:<>�?�޾?==xW%����)>en
a-��T��R�3Di�PL*�t�mt�mV�ȐT+zWi�R�w���+7�A��1�W��#roE����]Vm��w&�R�")-�]?��㊡DN�&`�*�����0M�'�񂭒�}s�.Ӝ{1\�0}�z��P�l+�^ϗ�����Z��I�(�Z���h�,����O�}#��߃�)�+!���6-,�0�	�u�o\��"�M��]�[���    p�NwiCy�Z&�Nh�c���e|�qj�2! 3�&��A��KT�5��2]䍷����%+T�Z�=�uj�R���w[1�Zu��p8W	��t=jIR�ń���Xx���S�I
�g�7^�)4�%��[#�6�yQ�����Gʻ��eie�D>y�O��-���t�ޓ�n���~�gz��4F��$�����K8S�'�t�Ă��z����S��k
V(ao"X�*}�+l���Z|l����R�<Al3l�ҝ�9���;� �`�i`:����d�?�K73x�Vî�����G�7`T?!�J�nN��I���K��@��f��7�D���e�&d�����/�gdF�&�Q7��?��%����������hEwj�2�r�3�s<Ǧ�CsF4e��lr���������AHAkv��]?�C@�]D����F��s8_M-��G@�q�u�Dl���p�F��ly8Q��kHÙ?e�i�I�`=�������F<VK]nr8�rث���k<�M�	r�o,��Q�l���yLݪ<�r�ZiN!��x�XZl�oݻ܊��*!K�&7SeW�B���\K���V���U�W�j�wؐNo]ڐ5u8�K}����v<5���_��9I[jjNZ�_zDI��Ed�D~�կ�o�4��·��,������/�,0mu�'-u�?��ĭ̝��W�7�L��/=*�!|t��xM��Dm�yIp����w�f�_�����Ul���'������_���D�l�܇0��n�K�8ǟn�5�'# �0�)\���d�qn��K�&�� �B��L�?�5ܝ���ˉ��]�5<��xZ���ȷ����'M���Q M�E�̖���j���dc�qϰ��<� QcN�����bhC����z�������^��{���IYȓ®a�j͡h��R
C�՗J
�r{��� �u�yE>vo��hv5�6����G��p𽋅��hzZ�릺��C��=��,�,����� _G��7.�ub���YKgf�zrl�z�	��D�=�ds�k��,�&7XT\��԰n�A�be]��`[��c��j�^��?�z'������/(��N{�ޟ�N_v�� �����,]Y�ei�YW�&�I"
��S��qB��$�Z������ǐv7�]�����uy����nA_����捻L�D���p [&��-�oO�~JɖH�d{��R{"��������ѳ&ϊBč7b�ݸ�7��F��%Y���qQ"Y&JuR�t��]����O�����C2��{,ٕ��޻ja��l�Y]84I�B�4�x�"16�K�fK��+�b�'�[�J)�TV��I]�=�w�f�GBna�J�-c�m���\���J��I���^U��D�)�B�n�ul�u���~1����W < ���%*1�p�i��*[t�W�f���S��㍻̌S�_e9��IU^�t$B��{���"�T+�7_p�q������-h.O����]�G�hfKg]*��{���B�]-�T<Xo-Q[�<�t�]�#�,�K�3�ʿ�%R!�$,�p(��vU)�,
k4�է�꼅X��Y����/c|-��2��AR�m9*��MLZl�����\]�C@��pHh�	 �n����*�YKI�4^Ɏn	1|麲,+(A㺶�i�r#Jc$�qk���n�DРKK�1n�)c���"r�D	�I�1��j}����� Qu�p��w<�.W^��Z�Mv=��O��y�FM��o�+�r�[�P|bn2.�nnY��$N� F�t��⭙���spo��J�q������g�ٿ!a�i��${"�gWp�Ճ���
p#<��o�s��d�^��,��
�a�e�RKί`���F�z�!G�I�r#���W�i0�?�䨖$�|>^Χ�A˅F����@�WM�Il����5��7�7s�7����-���A�؝�k�*l���23 m'`7��y��[֎�?/�M�mH7��qJ���Y5�{���� ��$�O�G _�XS���^���ֈoh�� l��T/�q�����S��@sB9�S��Ǟ�~\�$G��擾���h������}��x-��LfW�����[�VY��(�W����
��޴H�`���9�3�?P��,Fc}vL�3�҆�2
&�P6U+�(�sĲ����n`K}�g�%��b���g���Q-���������ώ��g/�N߿������w�.�����Y,C�\�s=������=hLּ���=�[k�K���[#C�a7:���9,�+����_KhRgc-�޽BtM�c�ZёR'�}gF��(�a�?�o�N�	����g�k�7j����
%�R����KQ��D���]lr�~��%(��Ϫ\V�$O�kq-���i������{gĖ�庂_t��wz�:?@�������Mg��t����,����j���������c:dʾE�g�� ��z�	�9D��/�	�ښ�Q�،�x�Q�b-b�ԖDk,��k���j�|��~�O�{[w2�����8$���|T�c��J���������E@v�ב�u�"�9c�è>5�1��3"��������Q�
�+�;DS��4����)֭�#p0-�A�x\ ��H���M.ov}��,,m��p�E���h��H�^���{��?Zne:�{+Ky	��n9����-�g专t@ ڑw)�=;�2�i~�ĺ!P�#-v������Kt��-�?�;����@/h�m=AOW��^�/��q� ��$�^9@�%2uS��:%Q���w�7���X�H`9��h�R
w�b�d�E�`B(��E/&s��'����hA�E/̈��Bz@zx�6E��p������$^v2 ��Ǒ{6M�/���2K��.R;��������LA����e�+$� ����-�����v�n����R�;ʫ=�x؃������}'9lڷu{E�t�R�yg��s5�Ͻ�9��-�Ž��s��x����\�:�pb~5����!v;���ޛ,�qmۢm�E�q���ʺ�; ��h��%����ر�"��8H@4�:��^�4ދ8�ۻ�pޟ�/ys̹V"Yy�rJ��y
�+�9���������S��i9��m���AT��4�Օ-�<����ꃱ�t"�6�o���r��!Dӝ��H'�������Y W<hZ@/,v�?�x1�C�r�:�@���k�qhC��������ˏ�@k�$��ȿ0�	����-��?�����47��}���qst�A�Bר��/����b^��E�a+����6����t���դ�Z����������E+������@��`���55�#�ju�s�f3�?�O��.E^GZ� o��ŇT�v��W
�~T@��S�N�62_�F�v�p�Qa�Ր�NAo��_��3�R$��(Y�,ߐd�}lx�F��Ã�<
Djk��֬�S�xz�7zo�O�i�i�ϕc$�0xg�N�A�� �u��k�x�̊����^,��z9���0���Gآf�zw�L�O�75fzWĻH��0ɵm�����j�|�z�f9�r����9|u��g��S��k� ��af��Ŝע� �[�FP�7�q�Yp�=���a�VBf{��h��%�~	%;H�J>RH8��t��h��rE��?�>=�[����w�m/Y_�LKX�".QkA��}��h�%��t�~���UY=��E��T�|I��8��l9���W!o&��M���g�+3���<��@Ϯ�C��%���I:]��q}dk�
~*���+:>�}a�*�wzw���go�'�����za5�,��%�nx��N�Y=�2[S��U��b]Z�_��H�鉽y�n����"�ɴ�ׇ�����O0oHT�U����y�F��dot��c��p2zw|��Ik�Xl�@����5���<�L�z���w}5,<;�;�ˢ�M���iԘ�Wo~4�peU����st6�D�o˪a��N8�&�#��W��TRGS�,8.�0#���c9&S:�2��    �m�+	㖵���X���r<�u˗�G����jI�+ԐiEq3o$����	[�� �������q�ğ(���@In��A�N�Jb7TCU�v�%y��n+��{�Z���B!�� �D�z�������:{�R,{��v��d4rÁ����[p�Lj�e�d���/�c����N�"j{�b��稣�y"y!�3KRV駼���E�F3��E=�9M���$�S�n�D*�0�s�UL|���t�][ؔMV�bK0J^jf5˔��vH)��\��e^Qhӹ�g�8���ߚ}E�s�>����R<�F�H�r[�Y�C!͂��+�=>mn��-]w�����}��ϣRr���(��Gy�ʈjß��!��"��N-H�v�r�t��>�=۵^�KV�@��Y�}p���FX�W���sC�U1)�B-�Q7[KϰLi'h�Ѝ�d�d�)�� �������1m�G��]N��#i�������z��1���tD�/���QƱlD��Dc/�����J-#��S�:鉞��	�ɠ�i��r��[[�)o���1K�!�-3!��B=��[�Ï5�����'��KH����g����]�\�Ns)1E���Z=Ͷd��)�i�ӜHE� $��x���myz5hǛ���zE[�o���Á<
B��[O=����o���5?��e��-��-I\ou�?|t�=\~sU�Sh���eE֎-�T']�8˵{c���b~�j�r�z���b�2�	@�4��e�V[�X�I�n\���ToOƑ'�1O"�vґ�V�^9 ۞Iy��87�K?��;=��9�W�o���52u�����߃[.HkQl�%��o����O -��+o�HfM�y"���l�R%}(�M��^�Z�N�kr@�HZ[�ک?�����LMK	*�s�<�4^�1:v�
�c��D]��le>o�v�8���M�c�)�d(	[����L���z�3[��:�'~��һ^��Yv6���?0~y��.��e�e^%gۥ��{�oN'�wr�#9~{���M�[��t��뺁�����@7�mǲ7_s���X�iNx�ܶ�*N���t{�+���5��M�;��F�I=͟�T��X����t0���IZ�!b�3hLvA7�ժCg�I�j�L;!�P�8Bu��S��ɾљJBv��U�b*�ix�&	Yg<fIE�����j�\:ڍNku٢RK�g���]Ԩ���	u�qA��:[�M#���V�:4�Z=-��i�5cH����/�5�5�\�1R�����P���5)&5�jOe��'�oC�4��_[hZ>��um�\Ё�Q/�Dti��'+�LN�e����l$�s�`㧶��QY����⬚
�Edrj�����ؙ�,����:��s��7'�Nf������!>8߱1��1��o������E0Yʜ�6�K�2�ا�:�m�N�R�O�7^���+r�KF/�E���Q,�$��C�g�$�<N�s.�T�I�i;�>��K�Ƀ;���ؿ���b��V�CgxDOzL�/PL<���^���Ke����!�`I�D��� &�?f\Ӊ���Fm}q��u?��+)b:~_}��W��z\}�x	ɫk:�ߡ�xw��z�G����}�y{g�*�)�^�0�(�������!0�k��
�u"2���*�Z/a�.���x@����_f�51�W%�P.�,�#o��NnBhg$�K�9V�zZ��h y�^_��s�l�`�����>5L0��}b�X�iM}Z�lAַ�կߝ��.�(ر)2%cM7�A�5�m|���t�waIt��ȷxv��%qk����+����?�؈�	�����v�b���m�#�Q?�>gZ��ߩ��FSm��Q�H��bY��h����i�f�R٪=�^��������7�V�Տ�$(��B����\�kA���d`zV9�+��mx�)�.�by�1��Ҍ���һ��l �r����7�����XRrݞ��픗�����SkŖ�Ut?����5i��LB��̑�1����b�eUs��*Ee��V㐷�!��pYtK��ea.j��K�-��5�����j��� ���(Eq�mo~��	�Ҁ�� �����x ��v��2)�)��U�Jf~���	��EkmЃN
���R��lu�_�j���J�<���d?�c)I��-Y|���\~{e���~L��w_�Q��Qk)������U�K�.(��ڍ�_���|�'�������:�v�Y53*�N� c��3�6&���[Z�ea��K����B�$�d���D5�L�9�.k�ŧJp��W[�_A�	mMɧֳ���M�Jp����ZVϑ���ikzjg���L=�U���7��9mk*w�6ut�FWE���.�@&�֤^����v62�sI���d���G�ݎ}��xO�G�ɣ����w��Ûc��7��;CG'�g2w�`]�f���^��U؅��t��dZ�:ܺ���%eG��P�_�Q����w��⠤5f�s�B[� C�&��� <"
K��_&� 	ư�pP��S@<����T����N���~�S�{�-�ܞ9x�׹��_i.�`w~}"P}&	M>��ڷ$�i۪\�୩h�Yg�G"� �����g��*k2YN���@H�R����Q��!X"#��Di�u�Q�T��&��.��1�:�C�s��Hy��:P�*G��A��W���Wn��޵���әAm�G�ŕ���_���&cQ��j\_cH��PÍl���o�ʲ@�d����c]�q/�?���v�c�
O� T���2 Ĩ���g��uşӏd�w��	�d�=�uv��f����:�YoF�������G�g?�Gn@�˓kߚH��@48Q�Փ'�G{⽐+h���>��>���R���qY�d�������F�I[�щ���=�\�]5�����a�3hz��l�W#;l������:<wb !�WR�Z�΁3Ĺ����A��O�\����-Z��.����[硵;:9�?�����v�.u�����e��h����}�zM�.�����=�ѕ�,t��
�e.o��z>�,9�رSA(9\�y���D�<dF����f�<5��� ��qm�[-�ˆ-�.�K���uLwm�������.�w�k0 ��r���Bj*�9�M�\O���+�k�B���%M�͋ۏ��7� �|��O���[��N���O{��]^u�Ⱥ>��W������;���۫'�"E�@���<y�������+�?��>>�=��j�k����ZI�ZO�G� -������[1k��O�kr�ߟ<��{�Hz���N��s)vp+�ү����݈"��k"� �T|�A�� ��.{�����2�.��3�A�I|r�!W��g�Hi���x����m!��j�f�S��u�^쩖�t������9��a���W!Ö��o�G��Z`x�����Lk�fo�"��0�{�}=��T�M.�a���6T�r1<�RP ���|��uO�м��8)��&j��9�4X����5���U�ws��C������7?\w{��������
O|	Oz����2�����$�w��+7��5��SK�~�Q���V�nw��3�y�X�P��m�p���UN��s*��	)E�ߑѶ����p��p��$o�H��l�W��Y�/����r���6�_9vǌ��Z*]�������&�KE�/cyA�
�*dH��D��}7t����|����������o�������d�@���r��S�ܧ);�������?z�?����}غ�C&�����	v��`�|�i}��%X����r����f�ӽ�j{n����u�{}�X9��޺����t��$4��m����o�^g��h Mɧ˟�츁~ צ���?�l���i!�WX�d�.V��&m[��s�,��S\�1
�Zg�ҖuM��(�;fN��O�zx�}�/����\�TT�q�0�AO���c�������n���#Q    �����?��Kv�3�֚�k���b~�b�}�H޽��x�O���1��IŴW��}m�6��Q22� %*�d��Ǉ�^qn]���
uFŰ�dO��f����߀_�T���0	d7/4-���\�ԅN#����x~��G�OQ��������4���3 ��O�Le�����[Mx���NS~��m�!H�>_"643ޟѺ9�~\�	�u/|�*î������*�U�����ï�j�Pҳ���ϙ�s�yW����g���E7����fz��B��۝����:��([��"/H��޶��-eK�N��@v%+*��"R��D��q�bjFYz��1
�HY�WFV9[�"^'��^&1��9��Q7y<L��Us�Ռ7[���=ėx��wޜ�x:::{�{�c
�g�/�O^��5����|��Fج�i%�u�2�E8`��]5��)�/d�GhK%b�-d~��19m �*��M��I�J��D����^�sC�ڵI��z�L�mA^C����q��K�k�����0�8�?(r��h�E�P�5��s�J̚�W��Z�F��"�)���?'���n7k1�1�n4�Vy#�)Gŕ�c�H�_sG(��6n�/���hmi�$��ƌg��d���r�Rv���]萰�&����n��ک��kc�������&~�8�x>z���ԅ ��G�A��_��O���8��{s�n��-���l1=��t�7���\6��OA$;�9�k�#�3���u��@p`�3�M��L�G��2��[GK@�ء��>~��
e6��,9)�������Vj� ���?A}uHN����t�.��m��uS�ښq-��F�{uA..�#p�ȗ(� �Dv�l�������M � ��,ϙ�z���;K��᭬���s/~���
�ȇ"�EZ���I�l���\H�5t9�xӭ��-@e���Q'�	 D�1{�̪EQ�|�M���<��Mu5:y���#�J[{����v�|�\.��p�n�b ��^����&)m+ ��B2���ZO{��*����h�Vqĕ`�A;?\{9(���i�A�%98".hG�U����o���������6nM���RR�����¢�������3�NQ��{2o�5ِkf�=��\vUQڊ7f���c�	�U��2���4�i�k���=��MU�t���gg�G�h�'tP�� �[�������^)*�ZҶ������>;]N�9Z�V�G��	V�W���m��I_0�#q^ 2��5�m�%�Y�q*�tcRM�Ԉ��/�0��_u��s#����	m�p���+���\s}/��t�[�#�|Z�=��g\�,T���xv6R�!h���s�b�B���`���2�}�P�?���4h�O;���٬Pc���MqL����,�56�q�o�+N���,\|^�9m���+Vo��(�˚���r��L@7L�3�b����0����#n���G��ӾCQMl����,5��,�x_�6��x�zv��'ss����{pp���:K`u��/֦�4AD��%��sE2�\L*��E}9V��E�5+��bPI��p[�t���xM�wYH�]��/��9i2�ri�4T�͢PQU&���.˲����e���_��E'�$�?��"�@]�ҹD��[{˟Q����1H��7�-�eg�n�p�����\ �^3�/��¯&�Pk^�����QǱ��ȎP�TWc���y�>
����*	E4��N{s1JPJ��������\� ���8d[�;�	������bB����]��#2�mm�44E��a���"c7���|()�����5G�~\�Ƚ�$�$�@�~�Q��/���N�� j����k��׽�B�Q�Ox"J�!D��g��u��sP&0��Z���O�vg�lPVJ���!c\rЎ��a�ci1А��� |�r(vX�U#�#vD�Sӳ����F�U�n�\��\ӓ���e��6���o�x�~��7�>~���_���N��4�1����~k�/�G���D}I��o��f/��g��]:z""�}7R pBn�K@�,�Ӌ�#�ׁ;|��o!結�'p����a3!ϒ���=����^���"���d�R]��)�ӱ?ʧ��)����M��F�,��s�[�p�D��%_��ɀ7zR�÷�k`�_�a?b'�/��(�j�X�{�������/.�D&y" ��w2���yw.���|-�7���)���-Z�fP��|4�����JǠ��\jn��;�df�h�L�@GE�%䉹������� �&���'�&�;��An��
⋒)�b����M�_����g0�2,��RCnuD�WO�D�l>
|�xG±���^�,���Y����n�5��o�[]���eS�[�$8<&��I�7(0�|����%w���&�c��WKx�4�bhkL��`P�n48-g�T��zEo�s7�r9���O�M�_6!)�Wd����~DֻOd;bsCbѝ���h�4>����~����)�/5>�f!����F�C��6^6��!=�E����1PR�I�'��?��k��Ӽ�XF�|C��5\	A�춈zR�|���-.�r������%����9�����F��=d��8̖�iO�* O�'��C'��+����N���yZ�l�9>����y3:<>�?ؽ�\!�<�:��Ӧ��m���
e���3VO�h53b�n����-��Se[��{y��\�.>�p�vr�X^
��[5���������kP�|��O���g��AgP{�`wttz[��1��u7�Õ@�_��[y[7Ef�G�+fd�&���Y��G���*���>�M���b:U�i?uw�
	���7����jZ.���WQ�����jD͹)j���3׎߯��� ۬�L��[������_�r�	8VKnY����3?+&#fF vi�6�]g��bQ/ح�)� ?n�kh��9�ϝvH2rT][5�͐*���{��A�7۫Ow?n�A���E���vЩ��j3������2�b��oFڲ��%^�{���鴘c}@��ǎ�t���늀v|�|h�4=��n�o%%��V;)=j5�&�!��\�G�0EPhABD���w���W���l����$/�RT���}����s�S��CIڣ�џ�l~�s+	��� *;�-�H����<���	��o_3g�D7�禛�|����B7���}��Ɵ�|\��ǚ�	n݂�y�L���d�q�Z_�<o]}���#�h�N���T4��:�P;� j�g�c�z��?�� �_� 鳩���,AҚ��c���X�b�E�|�����tAm����Go�ީ@'�T�^��&OM��bկ+*��S�\T�K����Վm~jI�l�¢�|���si�Ѯ�?���jZ��(�����YS,�d�\����rA��k�$<m���jj&�%/	�����`]��N�Le�r�v�s�}/ᶵ:}ʪ���!�3�_DPў�!�)�?I�k|����ܞ��4�����Y���?:݋��݁��hl�7�A�圤�՟y2�� 6���O�a�����-���������y�э�+��/7�,4�=Bs��ɓ�����7Ϋ��>��7���ؚ{^�<��^��ƙ�����|]2��e�/`jn�9y.�^�2b�6DLn��K��._��l~���˭W'F�ם�	n���P�%F߿�Ը~ob�D��'D��Q}B����}���K�'�Y3����-� �\���ǉ�a�e�Ŏ���{��6x u�oߪ��"�],�w�2�n-���Y(i�P$���.��>�ݒ�g�L��X�O���uA�z�gn�s{!Ƕ]��H*���cw�Ǿ����IBT���������_��'�C'H����Ka��a���w���7��Dy�
� �q0#M�����H!h�`��D��yr�u�;�������Ǘ�=+�1z0(S�	b��a�    �_���ۍ���<̣�,3'x��vj`E�T��7j��W$��JK_��b�K��p��B2�~u,²AG�3�S��o��f�Fq�����dv̗i�X�j
��-@�����Q˙�2�ժh����y�<3��A�-;�;|a'�a��q�I�ww	��!K��$�:/8�;KZz�M�:�K=&����;�'���W�'ַ;oFGG�ߵB�h<?�z�&��2J}�Q���=�vB/)��Vv�/��N_��/�?&?v�ב��u^P2�h�a�@��2���&�Пnޯ���G}	舅�d��!t�0�	i�i=���ݞ�Ժ��?�`�V"A �ɍJch��Y��@���t��>�j��	@��
��1W�g�=�k���5Y K�8>��x��ߚ�*iwZ\ϊ�	�ܣXI�͛�&L�����Ŷ;��`��4�q^�޶%�'�����}fAPخ�5�qE���\/MK׍V���r9�J'�A�Gg����WoF�b����<��;���eRx9�R������4,l�:��.=�ҧ�����ď\�����K��ɷ�]�M�3I�]^�Y�G�齓�_W�]�2��Qz~�z���'l�ω�	R��/�hۣUC���?l�ȶs;�o�%�Jy���ȃ$���6`�Q,����v#�����0pi?B��^���Μ�}���OL�U� ��3��o1�c�m�+��Tϰgl��y]42c3.��$��⫚BC�͊��Lj���cj�h_Ɛ�h����'H���m�!s���%�R�^s�f��K�2�^�A��2d���R�^����@c��� 
�zf0p0�_��SQA�R�a�4Ͳ�ɭxr+>I�A��{nz��I��h�
�ۣؓ�R��8e0�S������nE��
�M/t��({���S*߱C!/�y��Iu��j�OH�o[i2���"֬P8������S28�֘\:<9�������Ɲ���8ڼ�\�h���0�}nb���J��Lj0���t���v�_��u�2�Ki��H8�]�5ɻ�]���jQL���������^dI�}?p��!c즾����J�c÷��("ye'��%�u��摗9��;��dy<,K�΢,qbq��E�>X�I��J{'��^�?���,���ɶ0�2���c���n��_�2-�y�2�]�,ȅFq�uo�+=K0����W�<#�lȓ&���i
LR��a����ͫ��!Mv \5=�v%�-fו��Wwƅ�,Ub�Zț��#�c����WlB��:��Ԓ9���BK��.j$2!����Į��ό��R'�K�Q�b$/Дs��r�A�gV:����f���;����i�sm���L{d^p��,?`�b�>���4�Q��㾰}Đqّ�)�{��K�ڌJ
�pC$L�\�U�����8a��n��|��n�zG���^��Ƀ��(ٵ���t�����L�1�Vߞ�yZ�?���jV�6[��u>Fv���D���N\N&`�_��7�X�%��pAF&F�)!].��\K~�W���s�����͗#��r���x��eַ�=�_,:��<�{$r��w:/��0:�=9�=8>"M��-��o��C:>&A�Κ�xǥ�)]H��j_?'!�K[�N�eV��Ȼ���������+`**�/��˦W�ԣ�e�����Gzq���~w��I��l�g\�vK�Ǟ�e��Iꥑ�A�o�q%��"���(����&�
�'���^��z~��0,�Cb���5�is��_�g5Y�<u
i�l�p��Aw{����uF�w�@f�.�m���)Ls9+��f9���#��5�
���%L�/�
�	L󲥷�p�B�~S_��S<},h���w�Rr�t��[Q(�� ��!7��1�eީ+pĎ��hxg5+&#�[�E�AgF
R�#��֘�_2��dѯ��2�?�I����O�7������N����q����+���g������ %k�?m#Arno[���=���b1.�����ath����-�zX^h��<>;`(��v$�5k����~��v���>8.��L(�M�ť;rXk"GW�.j���!�\�e�6Do-Q]�o��b���kos
��L�aKR�ka��U�A��yM�w>�c�B"/���8�1�FZ��Ɍ67�5�׷��N�����*/�����IּiO�l�<����U��/�rj�8�rr�d&�*f;#�����T��Ý[���X%�.ύ��l�l4E�
��Ǵ�t�m��ʰA�+*T����}�:���6��ټ.�	�Ƿ�܇�u��{���BB�.s����]h������uv2�Ѣ��������ι��F��9mh�������u�kLK��צ=�h���"I�_ooa:�
��/h�ֺ���TkK�3�,�w~!���X�@��2P����x���7�c`N��c.P���ő'35(gz�j�h74o[;�6���.X-��kyV2�ܱ���~.�ը�s�U��� &Vw@d\KP�-- c�p�V�3J0ž
�{q뜌�Zɘ�c{l�_�������y�DG�)_��kj�?ZQ�;q�]EDQC[+j@[��v4�h�����m=E4��Q�f&`�"zo�鴾�,8Җ��uU��;�Ŗ>F���)�G@W����ѱO�(�.*G����_d{^'����з*w^p!8���F��%\��ґ�]�Me���lӴ�%t���f|sVc8��p�K>���5S$���k��4`5���"�`���7IM������'9EB�m|R!�4ѝ���IN<�u�+��P+�� ��n��{X�ͥu(���j���R�F�U�e���6���nL�^yO���s=y�|����n������p��7�M�Vl��Q8�1���|����o�U���$�EJ��R��������Q�)���(��(sP�'�j�G��Y�=���M=����˧`6G_�.!�0�z�m���i'��[V�.���ə���hU�B3jȴ�2ೊ!?�v	���q@������za���⑿ۉ�(����KI�@e��k�k|'�Q��q��������N���h�t�����f�l����xM��AϜ�w�~��Ys����I7"?-��6�o��}����;n�$��I����P{�^�:^�*�gLz��<�A+�m���-��g*���Ih$�0+�4W���A
nCwpz�7zo�Oޟq�&��҄$m�(m�V't�k�Mh�F�g�P���>3(�
��{�����#��v��	�H���Q�S�&�:���UV�Kh��C�*#�~O:H�"����C�]�R��Uӟ��md ����F���*Z�d��ѤD��̅0٠�qG��8�҇m[�E�Z\ &����%��/���P2P0�vO4��H����	`Z���S�K����;ٶ�I�wL`"�h%�l������Q�������a���X7���TH��ѩ�)J�3({am�.B�L&�;��0>�n/������(�]L��Q����=]�f�`ɱĞ�A�mK���v_0�O�����G�?�<�p��%��M
��a"a��֫�s�b�F�21����s�ͫw�X������	�N�v΍0�F�ﻟh�n/A��o��m'���cPb7͇*M�(�J(�mU+`� 62o�Yc�����fw�%�x7:��d�������w,Fh �ރ���KɤY�����<T��t�NEv�103��M,�E����]�̎)[��8��8�� �$���Hʤ���k׊��tmצa{jS�1a�[ﵒ���6��d+��r�~������Zg�K��r�w��`~nXY�l[�F��e����/�$�1��-�N�s�g��ʳ$[�iRT���B�_���P͊�rz��%i���Alj�w{	(��������#�q{C?J� Wyff���X����^��~otB��ߝ�{�0���s�7���)�ɫ��ϯ���"b#�Dr��$��k��e�7(?��p�r���$    xVlu�D�U���n�$jy��g����q�H]Ղp��q����u?C�I��4�$�M�Y�"�_ͬY�I1�1MzhzԐ;���)3��}x������e�U��$�s`�}�<XY�ӳ�ч����~�
qv=�.�$
�b=��R�e>Iv�Ӷ���c$G�ˏT�K�LP�'�`���3�{#)�y���W284z�CnDИv��ט�v^^�m��W�)p0�}1g"�)�!��(��[�C�^i�n�W]��(?��}��.n�h�}�G�9:��:���0�Ȭ�`��<�
�l��[�EPب�}O�~"?;	찈�� M�!��4I�$���nȸw�&���s�NK��'��eGaQ7�z���;�#哥w�س���X��,<�K�[�w�'������l�:��ٵ��l��X0������v�Љ@[��`H���̒7D���#}�m}`���úW�	����Ij>���(va�ynw�/��Z���,=�3u%l}�ή�_<���\q\oo�`�?z��qH����.�܀4xa�G�_�� H����v���o%�nd{=��Gk��p�+�9��?}�soț�\�����^/W���;��@7�d?�v�Ź�,)ʧ�����G+�l�۶CǍ�Oҥ�K�d��T���k��}��2(�,M
�������u������>�ƈ����G�?������\ٕ�5�#�dN��9H���?�Xary��	�ϰ#�\�{��I��Y�n���'�)����,ݲ��U������O�W��$_�$��B�#�$����D�e�/����l�����c�{�0b�A�A�y�q��CH���n����+���&^Vĝ�LJe�4*��/
�vH��рD�ש$�ߤ�a
�$f\� �:�]c�����eޑ�j>���O��R&�$�G��*�}����@���}�4�.YPm���f*�'r��G�ۡ�DR{X���Os;*�,�ʏr�rD������x�ww����w��X��x){T�Z'�����㗻ֻ�GG�g� Oqֺ�V���߸H�s�^Ic�%a��O�5���#���şj�n-��)�(Tzc�r�rX���C?�c���~%��+2Pc`�2M�����3��pD߾-���I�E�.�꽀��T�R���=g�ft��gH��F�M���8�	��.�osӪ�gW�U�-c�7᥷tG��X�?r4�У�skԃz�邩����F��-���y�!�����5
vm��[�Cb�l.����\�6�^�\�͂XI�1�ښ���J]����k��)?/�@�M�d��B���0�nL�'�]���"N]eC.}��S��0�B'L�,��5�Y��������$ɜ���F���Jz,��1zPh���S�$�s�M����Ū8��ͳ3��/��j�j�j�5b��>����p�?�5��e��]�Rd� �*ʲ�H����0�#E����P�$�'T!���|�'��>�H���8Nȅ�D���D�3�"oڎ;r;n2�<;�=�};��!U���>Cn�(	���i��U�4/�4/���EI���G�Ҷ�&$͟��w���̋�Ix��'��Ǽ��~��Y`{A�J�lƼhF��q��2H�^I��ms���}n!��#͟�T��X��9�i�����\O�zY�	9Ej������	�8V��K5p��+HkԀ��8-��`6_N�5
�	X
�:�/�V�������نc���^1=�xZ��v��B1��F��!Î�EwЦ�fQ�v��&l�Q��c���@1����_��<�2M�!�W�r���r��t9��R����X��08])Yq#�y�A�.�@� y׸����U��x&��Ʋșr㾒TN�� ��X�<��������]
m���r�t°#�
��I�zi�+
jW��T�8�y���0=��̕Ð�jf�s�"�>��)�Z4��/�(�U��\3�&UQ���8qpû޳�,�v�l�c��ޑDR8:�mgK��Q��p5�%���+����7��qD�ނ/�,'죚s��Hπn���F*��3������eY��ؒNm���� %枔��i<�3*E(([�*��k��!��h����z�r����A�:��s�������brOM���8�BѲ�x�J5!k��,p^�c�'�.��`o(W�[|��R���s��,���h��R��)Q��$��d�=D��N�
'�kwF�	�3:S�9]{�2x���7����A%��C�S��5��>T.��y��W�rM�n:u�1��č?/?S�����q#8�M��?�����ko<�ՈȹI�̰M��\&���|�Jv�}Op�v���hẀ�A�|b���ș��n�R 6Z�&zQ�����3�3�o`� h2^=�6u��d�p��a�`B����<!�Y�I㾦�&�[�O4���Ͼ�����m�$c��Em=�����xA���.@�Y�/O5����i��;95"m�O��`@&�j$I�xx�nx�+�P��b�����u��8
���7Fx��>Bx�>s��^�[�Ov���V����;�a������I�S}㩾�T��s�7>�^-7������7��q߽a���i�"�m�,�h�s1�eYr�5O�I�cLf�Ȑi��$��19��&	8�*I��rŔi�9 @-��$�W��$6lc�h��D�����WkDzZ��,���k@2G��'#��r~(��n�����p�d<�{�v���RJ!1�t����
�5
�T�h"���B�Ǖ�{�;l�ס+J9���.d�,�ьB�¤���
�{f�𢞱���F�Z�2l��;O0P����> �lLf��ȜٕK��^H:\������I��������6�Kb:˚�sxy{�xgzl�-�r�un���R�"��X��V�}X���[�����4�!m-o�='�I	���"��83s�|O�(?���%�R\��$��g��ִdn<�����N�{���W2�g�q5�H��o�"@�%�\�1+�9��ttt�f��B�w���:��������Λ�<-���vЯkn�[�F�^�sR��m�E5U�!�,n*�0i\�|/�=��%Ԥ�R�t��E'x�V�W�[����Xz.��H��:��b�o�z�v���n^hZ4�[I �K"��֌�[��8�Xe��x�tQ c�(ƨ4ٺ���j7�SC:�p�����:�d]a�$`�)?B=��\3m˗(,L�Ѻ9y��Ȁ<����	������@'p�8_�}6��
���1�x �}��S-����ܠ�?��ׅT%��6!��#���e����VuIv�t��� ](3�F��O�eE��"U"M�㢊�6p����Ll���3֑2�f���O�l�M[���/�O^�hc��e~B����kˢ0.�����U��ä,ʘܺPa�>vö���o���{B/y�9����	�f�.�i`Va�%O������<�nJYl{�,~O�˃���N3�*�$�\S��@}����,}.��%�>�3�����q�L֐ϫ�ZN04S'-r�T_�{���f� (M5��f �~#�����ucrS�4%��UKg��a,�<g�j��4$p+�L���.#4�]�������*ě��g5�Au�������J��:/�e��^Uq�x_�1a)�{r<\��-?�٤<z��հ�K�£w'�;�g֫�ͤ���l��@ړ~��S_Ο�/��̾�Ϧ��C�����r���(r'd����  _]Z�p�ߊ�R��h��+H������+.��`] X
d���'i��8��Rՠ��,
=Ek g&u�,8�=3�VҮ6]�RiZפ�s	�߰�K	����ZW��a�ڟp��4 ��	PTn���p��L���`Ʊ���*�Е��o��Wu��jY��J ��W\���p���UmIj^p�9�M����8m���31mY�\B;�Id�
    ?^^�K�.r���]�k�T W38��Q�'���^}�t��fK���"�3<��WǾ?���s�}����4��nA�ν��R��#���X7���.,Ўj.������@~��:��w���+�u�<ڙ~�IY����-�Ӝ��0YN�5vjlA��"�қ� �C�+;�l�:Į��=*y�	p[I�����GtG��ȭiN��AZ��`�Q��^3ٚ�D��9%����kޔ����p�^�D��~�%�O��W�0,�<N�,s�|���n�B�#>W)K��lu�%�V�T���=�T�tyλ"�T�)��<������|�!���ow� �"4o�.�i��0
U�'���� ��zہ��2�
?1���&G*N�2����H�2���HI(~7�
����o�?�@�H�xM �$s�,��M��8$�Q��q^�������orȭ���L�ퟃ�Z<`�s3t�|���H^���ƌ��l`	K��F���}�Q���L��?TO�gU��	LR�`��-�u�:-:n@�$/d���( 1&�ԞM����iܘ� 7P��ᨉ+�l����D��R�o���W�yو'|���F�d�	ۗ<�3�G��CN_<���`�Y��d Yv�1K�,�^��QZ$*�oYF����q�9nU�a	��$�(xľ5���aV�~����+&��.�C�8A˳�s�޽;صN�X{���͑zh���F[O�B߃�?TJ���x����P�z\��T�-2қ2m�n�Р�޷)�j�J:-T�Ɣue�W�[5��˜�M��mn �Ac�j�%\�9��Iq1)	��DԟI#疹՜�N�@jF.�d5a�M�n�	�#scO�nQ��K^V����`�������]Ъ���/j��K�j�58��✛����r��_���+���h�5Q���UD�{ �h���G���'�+�5��{�r�����sC��HohS�-H?��2xrB]��yMzp�|�1��ݳ>v/�q�*�k+ʣ3]�F��܅-�*�	V��iݹ�u���ȸ/�w�[�ݏ�8�W�o���}+�3F�$��V$�����oE�9�l[F�o���Ύ�ځ����g��>��	��H�#����C*\3^����(��B��oUN񬈠�r��	y,�Q�t���`�Hy��,�-��b��� �m����	�Q/�q�M_�,>o�m\�h	��X8�ߓ��;��{�;���i+;�)� :����u��N��:_8�{Oo�O�K�_��J��:�����>�8����T~��>%�6Q�zi_El�&���o��xL�Ӷ��g�c�v�$�>��9&��D�MrL�Gk&��T�������c����8���(��O��W�U�y=C3B���Q�W��Bpі��J�f/:_Z�j2a�}���+�}���~���!�$9��+I�ӣٛ�i������3rsf͏{����寳cyCT@��R0�<�ʶ�r��Q��ܤ6xy]/��0���	�υ��|a�2R��a���`X�0��D�m��_8ɶ�Dn��X=,߆o�M�(�5�4�ژ��0���~���@׆  ��]����ލ��-��]Tu���%��j��A5���j�ں������<g�%u�\���
���tfW�����dѴyq���)oCp��ƕU���iq�j|��raUw>rX��.���U��R����X�w<��v�YQí`�B�#�ŐǸi�ޫM�[St�o4L� �.M��ԃ� �T����7����Χ��	�삮�keu��?��0�[,�8�^��ey�?�=C�3�&M=�uɨ�c���	�%��V�I4�%ܧq��b���R�FL;4���0Ƕ�g���Gn��II�14<riQ�ü�,r�S��ջ(��v��N��,=��6v�')����4#�H��
�8Wp��.�D(�������x�-(�ev׭��A�䖽��*kH�l�ȇ��.g0�++~I�����*r��*�a�b��Y]��`���^\�Y\4 9Tw����+ړ�?�c��$��U.��Z��#T��P��5�����U�#�k3�H�4�L5�����M��%��L���#��t�k4�vz�1]����_j���? �;pF��p�F�T�yE�Y������xI�f��Ϝ�߿D�R�r~�;Ώg�qh�?�3'O��.�5��c*��9~����ݷgj���w�I`;���u>x�M��{N���F���o���T����
�Je���$I~za��z��_�����覡ow*q�W�EIeyf;�?������#���MZt�u)��$r���)K��at�{��Z���!�v�;N�p	'�7�����nY(��:��R�1EI��r��/�&^��O1S_2k�f��	t��-EU�j����6���[Y�'LuL殸�S��5l��3�kT��VSZ�;�W�ZX�12o<�P-��"X_��`o�PH�G�(��P�C�yay�4�i��K gG���~��z��Il�R������[�==��5[�׋�#'B�sV��������jq�n]nw�����3Ӏ�_���6j���4����8��i#�hm�,�6n��I��-�����!כ�1y��s�B��%��vi\��z��[Cź�.�'
�Pw:rVK��&�޶���@{.�Pk�\qS������-L4��Ge�G�1�������ӤB&�І���8�7��G�9Fs���ɛ��H���u;��h���Y0�t��@��G�$]~7x]\Y9��M�^�k<���oe1�yN�6���s�����L��f��pI�� �3��k�"7=qf{���	�m�M�a����v>	U9,���G�pO��z���AIq�s��O.�[:i�"�C#Օ�~�/�p��f����ɴ�&6m�
>f�02��0��M(�읬2B\[��8q��w)l�sC'��̍�( �Y��~����(�ݱ�4��L��c �t�ζ�cl�9���ڭ}�d .#>$S�ҽ\���D/�.4fa��j�:E@��e�iO �H�<:!2޸~ �Z�Yg"$��Q����D�s0��m���Q[�zE��X�Y�:K��� ����t�)q��P�Ts���~L�c����멊/�o{�**�\�d+o������}/t�����?ȸ2�č�L�gǾ�4}^��8�����<oEm\5�t�~�6o����s��4@°�h�zJb��B���ct�}�aY�31
~�`�A;j��)z:3��Қl/'I��3��H!�b �z�qY��yQ
���1�>�l���=&6d���S�ye�7H�TY�V��Wr�j�ܸͅFQ� ���(�@u&�L}����Cf	35��b�RH��oܟ��D��ě��f�Տ��<��(�]�z��[Xk=���4>n�,HK⺢���>�)$��ɨ��/�7z��}�dT\f%���R��(*�,pmG9�)�/��Z�:0Qn8��Te�]~Q�~���A�:r�����h-OLo?�r���R�z^HǖN���tm���^��йA2�=?.OyE�ln�.��e;�u�DE����+�0�l/��"����|/w;�l&����e���^�^Z��1���!}����/'vs-_�W�[K��T�T}��nT�e���*��t�n��>{6��/�`��Q�'*�����p���i�K#�̧��B[�MS�"14�U���/���r-I�Ldd��u�����8zp0rbϷC��=��{���EI<��NA��O^8y{Q�����K ���{E���>
�� ���/�LRa�ehJ;��P�\q���S��R���ۓg3!Y�c ����%݉��e�0?"��8�b=�{�
��Q�/��1ʦ���J|i��8�ː�wו�h'*�$�"/� �ܽ�y���S�����~^����=�j:n��[��kZ8��Y��D�a�T9�ѽ)8�y��n3Lg�]|�B��vb�Jg��륕���ԗ�j#�����5    ���y��[[���4���0�⚆��Z2j`�^�&v{�0��A�?E�]4e�Iyѧjĭ%�I�s7�=��dE� v��vY>��?X��Yi����ѫ��g����0g'�B��H�~�.��$�����#r�c��?��<v�0�&qE^����Mb������)�T�}w�~�������]Uy����*�
�j�9��+I�%�FPN��j���̵'A�b����-���͑��D7���{��`����yQ����g}���n��NE�����GP�7�����_D�	��|�����+B�~+?���:*i+~��~|�ON���+�h����`o�.#��ǯ'rO��?Q~��)?'y�>�r�E��Z�1�����	F�O#�1ʤ�}�L�#�.,��ާ�mH󿦪���s�߭���N�A��#z[̧�dx>����/w���σ��1yޕ��>�l!B�u{��z�q)�IЗ]k9%i���V5f��hn����][z
��)t�'n�V���J�pi`����~F��0��ق��&x��W�� �cd2�G�6I`S�$�&�-Ẅ́^�3k�
^+�ߖ��U�%OsV7��ڀ�7Ÿ�+5���Vl�&��Cn��ėӛ>HJ�!J�ƏWB�ή�7QU���"XN`�0AT�9�z��l���6:=q���n�D�n?}�t�C������nlG%�dH��^��0�������HM��}�?��M�;[�O.80��� ���F��3��P��ʪ"�Z\ϊV�0���
��=��C������f�"/A.OQ�s�Q�%0/���,�2��f���4p���i!�ѽ�2���u��n�� �,�$/h?�W)�M�t�ǎ�>��Y�y||�g}xs�����������%@�z��B/�9%�.s5U���|p7����[��wl��qA�(��������
>�VT��se[.�v��bH4��[�l�ɷN-fI��>����$��K��Jc.�lэ�=3$��~�"������5��2�seff0���=O�b���IQۍ%m�2�?�h��t���%�)+��ކ���2ߝ��|�jt4�������S�� ���JB�8��#���ٴNȸ�3 ݢb�_�t?C rYL1ǁx"�ٷ{��=.)� y۸g��_��C]Zh0aƜp��7�VtQ��3�������ua��!h��3���u�E�|Qw��Z�o�r��q���U��b'T�L��M�.��)����$��x��Xx�qFk˕qCك둓�N�s��U��0��+��b�흌������پu������D�kF��_p������n���j�j�v4�Pp���U��Gn�^j����ύX� EG[�x^�ϓX���.�5�\h�(��Ӛ��߬��e����;�fN������7<�v�����s�6��NF���G��˃��[�3�ǁ�~ϩ�'.�M�r��֬����~q&�0�:��\S	��w~���x�$�M�s5�AU�ݝi�|B�I�-÷+]���R�Ơ�J�e������LH�2D��N��tgM)P���E��eo'f�|(����64v#�ԣŗŵ�E��>7ߠhJ��iר��f �U����fKP�l�4���$/����z��^������/�7?�K�&�*C�dܵv���� ����@���!~Q�(Η��頧P�Wga��p��y�W�7Չ N
A�jŐ"e[A��6�/��$�*��'D�=��@]�L0�x��uR/*n+����y��6:�M:I��mDIb������ْ4��}4���m���踽E�Y�MO!Y�Mӆ���>7��v���.�Ӌb�����<��^^�f�X?|��oz)�c��������C�����w�W]��~'�MF�_J�kc@N(~�1�g�B���M���G��~K
�O .~x����=���|n���\͟�&���@z<A�ͣ,'��8-P��0:=-bX��ti�/���G};,������5��%��V�.�U�Z�4Vy^׼i��sC��kM�R���ИT+�Nna�zWI?)]R��ٵ!+]w@�5-�L�
��tU͂��zIo6\�?C_����1b�af����W#�m=YoåN��g���f[�X��l=ʛ�8M�g��O�̜�5���,-���̢8�����������,�b
�'u��7�pC^S�4���m�6�\XTs�#θ��)�s�m�+��)�6�M�z�����U��~t���ev���0���J�.1)c��6
��}��si#�?4Z�d�}�6St�z��������Ez�ѻ����3��ɏ���%]L���^9���L��.��&ɮNb�~$�����pwQ.X��^V���x£/��YW>�%��9o7z����+�[�?�^X�^a�k������+�ww ��#T�S��_.i�)�z�i]U�Hۮ�A=�|ƂM��Q2��	֓�'�M���/��>���ń~N��5]��1�R�/2f�)z�G�HĠ���S�����e��I�Q��_�����CQt5*g I�uXͳ���Y&0�S�N}�<`5��p�\D)Wހc+C@�N��Z�Q�̞l<0D]c\baЁ���P����=��Г+e���H�q�H�� ��Ew���[{'�����eٳY�ܠ���U�_��(������<�ۅ��ff(v0�2�4��d�*�z(V�#Z��li'��lF��gYˣM� \�f��"�J�����H��:w���iF�{�D��Q�/�LwD���?��=Y	)�w2:��P{���Sk�iD��|�Љ��ʅF���E���r<��ev�iq=����L���3�O�\k�z�!¿�V��,Z��7�����%�F�q��e
d��jʰ��WE�v��袚f�DRS�𽑼��_c��q2���7�P�NY�y޺��(Z���^2�/�;�v�!�"�@=�~
<��><��)�񸠘�ÿ��z+K�WE��[��g�֊���~��N/��#���(Y�wQ`���c|���)z�4�v�����R���]@>��T��#�����H���m���9�F#����`��g�AH��������Ѳ�Bq��NrrP��뙑���'�h�h` ��{��M���f�R�nLrv���\r�x�{9x,�&4��cТ`�N���{�H�[IO�G��l%���������C��雓��FG��]�Ϸ{ov��j��E����e 	���*N �CʟɅ���U�﬷@\�#��|�ܔ}�,}��Z0�
�S��u�\s��gr���%������z��8u'Ȭ[E�W���h� ����Bl�؛�)n�����O�t��tL�R�)�<�?��������_��
|
��q�W6.�rG�N='#~�./Ʉ��%!��=W%e8�bG8F�)�8)1Y��\��o;�R��@>ؕ�\�"Q�nþNy�=�Y�믊Dy6c#iga�>�7�4(��F[����c9���sQ��0W3#s�u���{f��YNF�,W�|n���Zӣv����J'��猄:D��������	&1X}��_E3�W�)�A������ށ����O-��G������,��ȯ�re#����_��Z��	 <�gIow�;ͫ���y2&MD��V�J�t��VG�}��ر�5H4�LZuT ^��x��h���l[
�j��
/-�r� s���̝��ã���H�݃���k5���,N� A���ٛ�n���f���a��Qجi��`��ߺ�Ir_W5�ENU�r����(T�Y1��-O%�c�ΑFX}iES�X��Ӣ$)��Jz�1c{��T�X3uoua�����A�T�a�G{�&�Қa�O���28��bL>�I�\=�8_ }��ON�< ����P��W�l�\�Mw	�,��T��7�U��{�����[zO�뱠�(7pn]�'�:�f���S.���"9#�(�4����~+��s���F�+&�F�'s6Q_�    �u���!T���k�,uE������cd�YN�y1BA_!��0�Ҧ��ׇ���=nMr�i6��m��������0������a�3:s�'�Md�k3���� 7E�t�����~��rl[L*��v������O"f����������~���ow�U��,r� �0��'���E��n'I|2���%~jYĔ�^Zv����-�?�MIJ3`����X��z����rd.zz�t}/y,���G���ޝ,��#<,_K�|'�3_����E�0H����<
s�	&�	&��ױ� u#��j	v�dXF����ap���/(�q��OXzX�'�ؑ�9yx{�4�]U&vG���"�S�(qnpj�[U7�:�~��l�a_l��!��H�����l��l�R��+>����F���
)���(�y����i<L<��)b)��s#9����:�<��
��IV�F��q'�;��m��cڷ/�y-3d���}�����8��aj�O�wl�v����޻%��e�Ϝ���R���z��dYVY���r剌�� 6D�H� �d=�0��B����#�u� )�&�p&�JQQN["7@p�׷��_��#�1Ӈ�ciG��Yq�X�G&���d�|�/7���;p^d�n�Ս�s���є�i��G�:�K!yn���6��E�����Z���-l��N� �������2,����QyG�g������)l�ȯT��E�< yo�Q%�\�����U Ȝ9�VfgzO�$٠Is��X�.�T��{9S��U�z�hݢƕ�x��RP�q1���|2Y@�^-A�'5H�餇x�����K���t����^`��F!z�q���J�V�~�է����d��������qv�|�g�`�w�b���C��D�e.��r3M���^�r͠j�P�]C���ů�T�&T�S1R-�d��Y�;I[_�ր{|�+�X+%mV���@�[���6�qI>�����˙�4�S��#	�<�zs�f|o��%n��ֳ��H�d=ܳ��iڥ�8�(��E[��=L�xΠ?�Wըw��Zi���z2��M;�l�7��7v�*8f�Y�gx�q�K�e��
���qRģ�U�(���!7��-�!'r�8�O,:蕒r1�ǵ�NZe8v?W�	dhB�?J�r��eM���̓��+w�oWxmAA�\��O��ȼ\L�]#r+�<4�ٜc�Xȍݕ(�b����+� ��� I��^�=�|c�Qh��Oݕo?�'�y'2+��>�:+��d a�Q�g�����xL����|�/{G{Og��q��?���;��t|m��^����Y�m����r�l;�v�w[L���[��+�
l��1-�Y�.h�'GJޓAy*��oL%�}\�#���� ޅ,�:��if`-��ǹ*͘�� �	�yG�%�MŃ�ˤ�؈�&1/�P���5OŔ���&r���@{#�����n�r�s |������Ҹ8��9G.��h��}K	t�a1��/����e��A�!;��˹�Pϟ 4��PB ���ĨdA�K��<��N����5]��R������F@�L�+e��x9/Ϸ�2�÷�7�Uҷ�ⷨyܥՂ�w�H�� �q�J�J
�F�C�b�@	�H������,�8�z�;Ŗ��CM1�4�6�N=`	�
KfX���<0jY������Ƈ.^��3�����ވ������
I�JA��,���G��Y�R�k���2C�ar�%��R����'�i�9����w'���?�?v��4�y����u��� R���}��iCtڢH��O��ɴ�e�Cw�`�
�r{1/���G��ׂ@��W�ƌ���r�B�[\���Q���xˤu$���_�_��G#� �}��Oʠ���_����i�9��b�D&��Y�!@#�-$A�lL��@!��5�;6�p��Y�����D��T���|>�\ ���PQ|1��a��[�F�˽�@��D�k��ۏ�~D�a��%tK�@x����,���y��ռ�ݘ�u�)�*����"u{�4�c�Bqc����hW�s��(J2,`����Gӌi��Z`��1E����֘K018�2��/p�=E⾚i��Gy�gM��T�G*�\�+�.�����J�z�mAt|b�����	U�k���W�L�D:ą�����W��x�����E^N�kQ���Ą�qB|r
������-���w��7�=~0H�et[��zz4�C�y0�Ϛ�kR'nf3[��hR�;:񫚤FF���O?��X_O/6)q׻[�S��E9{�(go$���y�q�r����0�C)W�\������<jfdjc5�	.:�'w�: r��X�_�������a�Q�ޥ���n��v�1�3I�H櫄f5$�:�z��n���`*����k����v�#�-�dߩ~5*s�@*�c6� ���� bف�4;�ķ�л?
�씊l��O��&��u|��ۮ���&x~���Q����=��q��k�Ձq��B�F�0��2ߧ���է�%����(W���Dr��B8�c�"a�N�(��:it�?�Uv�0���#�ؙ��{�>
���O����c�Z����Y��@ʹݮ1iI�mK����C3r|��&��z�Ʀ\��٢���\�7 "C,��)~�sM~ί�ʐ����m���5c��
��`"
�T.*<�&Ջ�~"�{�QY�5R]S�P{��<HۀA"1 F1m1\�9~As��XjE�L�:����Ƒ,�"��)��M �!�|^�@bCq5�ք,ɛh��D�=���*Fݎ����Cɉ�"�5�PM���yE���P<O��|����<�?O�.6���rRP /V�'�
� �$���ҵ���qBP ׷<T����.)���(v,��<1�3�Me�'��Z�����S[4�׸GJ�_^/N��������UȰC�xg˥�"��thȾf��a:"��n*�!�����)�29p�,�� q�fh'�:��z�9N���	�[�8^f��2�8�+�HQ5]�K<d8��x^�ꂋT��$�P�"���A��C�x���9��I���]��> �L�	婵���7�
l�#�Vg{6R��V"�D�Me�� Lh(li{��7��7�u`A�bS���#�I�XV(2xd�Ί�8E��?J\�O_�r-~m�Mn����Ӌ��kjWx&�Ѷ]�����4쯷�B�9�c�� �A�(B�2���E�x�a��"P_Q/��K��/���lf�F�ּ^,IA�Ru����?���)�[<X`�E��!#A�żg�01ȩ�W�����55]�����(�q9id���Wf����K��7�t���E��6��(6��o��6��c��/8�N81�9���@��}#s�@g]^�/�_/q�����V��^���pۼm+1� �״և#�C�qH����a��?��Iq����P�ߦE�`��@qP����s��)C���������t��W,�^�~F_@ ;j��k�6y�^�T��s�'�)͵��7ʨ��$�y���;�X2���_ӕ4�������P�a_�`�SC��r��R�L�����GJݝ��!c�.7z.b�G1~����]��iן���<���3��?J��4����v��L��I�7���Z���c�����t��H���d�en����X����?�D��7�kO^��z�n
s=w�iY�Ҵ�M�Rq߁@�gV ���Im� r8D@/ާЀ�Q~\���o�}��tU �����̠\�+En����R����ù?�f]�[/
�Pʂ�ax���t-1�GR�-!fJ�E�"��'M��Ao~ޥ��]ji`�H>�|��
���2״R�E#oMXl���V��1�|�?�]jAٞ�Gg9�'E��f�
��]j�	�s�?���NF�#D�D3
2�R'v���+���?�>�*���ѷS��J�N%'���u��xF��vǎ#�Pd�״�ۏ�+9�9�߷�cŉH�0lo$�]o�v    �86|�4��\��G#�1��ڀS�������&$�"O�{s�����i��1�����d�8sM�H����fc4����H2�6��=e&����)�s����ih�D�;�\��T����Z;�IG�w��S0�l8���rB�~~�<1�7G4j¼�\ �4�K���Ӵ˱���L��zζ�X�A�v��F���#~�����^�mx�� ɤ)�(v-�⫿8�n��P�ߓSy	9���v�`��](�ݚ��������g��d��o�o��l����nh�4����q��H���A�4��,�z����|��0�7�"IÀÿu�F�J�D�V�vZPu�K�� ���lD��䠾D�o���G��Y�B�qI�mf&��p�YgQ�4`� �Cqg�4T��R`M¨.�px|}� �t����lK㼝d����}��X�j�`���nM��������m��7lM�xk
���{��� U�ԏ�t�'w��Ct�N�Qe�*>�=&c��������,2�S�I��[բ'WE��ch� �係sRas��HB������h۰'(��2��{��f̕G�J�o��9�ix�zi�M�㢭OJW��t����E�;a�RUo�"�I�rL�O35_Ju+�h@�����B����?ѱj�D�;���Lg<A�S�#9�̄j������=���N;���uj�<��˳��#���z+��rSa`7�(o��Bm��l�ߏ�%ə��%%�a���P��+{�҂0n���L2.��W�E�y�j>�r*1��r�:������ggƣ��ɽ�z��
<\�t�(8�a��<�d6P��jE/����l1���D����tHQt�@�9��w�� 5�և�4��W�`���R"�E��٩LJD�_�;��ɇ�_T�%����C({H*e��kk�l�{��|T�B��G��+�����ѕ��#ދr)��1��y���KZ��zy�T'�+�K��L�S�T�>PT�|�+p����p�f�Ni8�����h�9�u�иK�͎��ի�NяV`�D������h4|����L�6N�:�fg����P��"]}<��:�����[F�fz[��a	ro�z'��b�^9|���)k��P����5�q)�Eo�~c�0(�u.�3q3�FMy���)Js�>Ό�7cP1%��|���2���Zӧ��q����NYu	�J5+}��ǂ�[C�Y_�)��R�jz���
XA�H��Kf2]Ʒյ2�j�T���]���y��)�*d����e_���|yym�^���vxf��~�C� ;��R9o�F���@	hC� ��*�O�j^�so�}]��P���ɟXYj�\��w1e������e�i�ި[��iB�-�VI{B�Y�~��i���}�ӕ�6^��n� T�?4�6�v=��@�M��He��b�>���7�Xu$k� 6G̲��L��Ou0�f�+��(���D�-���RY|!����vU��-�U��=Tɕn�O�d��N�����6���ܴBfC��<����w��}�z�f��i�EM�#a�D���Q�d��TQH!�1��X�YZ��@�	^G�'���F���|�)�q�h�E1{���}�h
.]�y�� v
Vi�7�C��\�*��0W���ԌV5��f��]�%����ev�"}-Ӿ}�����}8m�K�{��a�̃��Zޡ���R����l(����Q����B�m�%m��ߐ�.J�Z���jσ��f�l���2��J��0WE��ӱL3l��@����]�;G�^T��E�u���6��:�Ծg�7Ӄ��|���aF��}��L�B#}i��ŉja_�@�sݎ�BLv�p;��e��bRx\��� ��ǔ�s�Ή8B��ҖR(���m��t@U��!�KN`z�)M@c����"��W¦�]QR?\���b!�b7L�=�q)i�܂������<U�{��.w]e eh�)i�g�q�B��2����胲�v�����r����h����GG�0͏W��{�~���������c���"˨$,f���̔��x�.�"hw���F�NN1��g�H�����G
1Ք���#Z�B�#G��5ש�瘓O��V5u(�R6 /�"�
D�*�lT�
aqNu~����R�j��)SAW���T�J�L���Jk�ƹ�=�-�밴f{Mvr=�T�f�m���V��g��d�;%����:]ַ�:z4ժo�:�-Q����p��|�U�4%���q��N���T')&3$�9�߯��K*��!��^IE4z�=��.:�JF�[��k�6 c�X]��g��s;B����O�Lc%� ��R��R99^RG���F���
G��� M�j��;x�}U�c��w@�|���pC{�F.O[w�uU�p���F-�Q�����&x�&�)�`I���>!iԓ�<d��1����!��h4�y���g��	�=�H#`$e1���t.O��[-M�F�	8�C}G�֑T3�,��[��UlX�R=q��p�����l..�%mC�G��Up �SY�_?se�2���G`	��WF��ճ��4U����F�S6�]%�27Ok�M��Jt�}s�#����E���	-;՛ ���f���b���¢�������ze\��l$�V�ki����SM��M�PD��{�[���Ճ�.xYܪ�ej5U�~�.�eR�8-��2ʠ_��ǈA;�_��:���f�B>�u�Ř���c��Y܉�GB�j�Cg���GVQƊ/N�ȯ	GUp\R�]8�pT(��lq�}��b��4N���f̂K�a t�<�A�K����KV���/��޶�xK�cLƘ�A}j��8��=�8�9ٜ��H���Q��W�O�t�9�!�ĸ �{��[Y��P��TrJh�~6˻	Y�� ���Q��V�������Y���/�ъ��#���N��6	�넃��Z��Θ�����Q��愠�|�c�7<�o�Fo�f;Xᶕ����c���q�Oo[�2ޣ�|<D]�$@  Z�	g�3Y��ľ4
�Jw��ƶ*����(�4zO&�3;nd�3^��'��4x� ����7�ҩ�s����@M�[�Ty�~��i�j�Ҷ�f仃�c��"��e3j�e��k�2Hᨆ�:�7;��6�������m�:�! >�{�D�Z�ss�;6��j/�^ u���5T���B+k����F��'�L����?�ر#�L�z�V��Ը]�+�\w+�q����wy}2�8=2N/ޞ��?�/��(�C����h��L�q��*6�|����FH'�F5F����u2�B�:}�ȹ�F5i�0�&��A��DLA�t
f;-dt�N����v\۵M���#��(3��Ib&P�yX�d��xQ�0�:8��zÕ���q���ۏg7������q{<4�Ά77 H�nܞbP���rKf�-���ԥ�ѫ?�m���1�>����������f0K�
r��@���1��#|��1�~�4��/��D�����lN��b<��<'��EX��h�,/y��9�B��Z��
�I��Z�]$U}؝$մ�$���H��
dUɲzy}zrz�����8��'˨��B]�h`���[���q��Zp[(�%�G�L�@��U��d1��������_� �To���IL�p9^�	�1d�&�E��ǈ���H�V4���;)!]I_�X�o'-�C�;z����p2f=9��n6��z<P��Oo��&"�dN;P��D܌���]��Rh�"k\�K�'��hH5�:En~���P�4��W�6%��Z���9����ǳ[2��goO������?ҏl^�O��-�ݷ��L�Dn��3+]߸�i&:�DVD��7��*��|U����������ϲQ����`��J�$��YL�~=M�b*���կ���U�(ڑ���=���@���~�K��UՁ��q�����q��|�de�F4h�����<���TP�����C��v��    $ �^��v��H�G���I?���[n�٦��mމ�7LS�7����HM:S�	��Z��ʵ�:�h
�<��֘^�EV�WN�m����fR�Nu[tm���t{X�N|WY�Z�68�Jhgl��h�Mh�%Wf[��F�*}z�h�rV���V4���)�/�$ Wu�gL�^�U�e�'FU4��7�G!H��I��C�nE}�����Օ�j��kօZ�hk�#��+{$(���#�y�����q��cÈ�LC���q_v^@�ˣ`$�iI ���$��M<���s��%rV"����>��4	��t��jGL]�[R5�]�|Lܤ��[s:�g����5[mp����lҭ��M���ʋ�pߕC}�m��_��-Q����'� }0.����φo{�$z��-�c�Ԍ�n�W7/4fgT���˗p�̦m�"�	��xY�3����S�w��tl1p��R���ά����wޖ�|��o�� l�o�(2�ZN�&n�HZ�V� ��E�Q*� ą�����)��YX�,�9�jB�ǁ�^�KR"L�1dc�>F���L��(�$"��`2�i����=]Hm�d�����Ɨ�Jy���EV��;D:�FS�γ�uA�B�%��
��S0�p����L�(�¤(�5��8j2xW�#���K�k�}34� 3�}�ʒ�o���B��2���@%p!'���j^n<v�D����C}!6ړ\��U?�v���۹��'L��I�#�e6�@��,؁��z���2M�[����b^���� � w��r�8��E�3���$�OI8��/�)�K�\�X1�u��C����$�3���`ܚܛ������1�1��a�"��&ҸQ��:������d��d.K!i�0Pʬ����ي:�#�퍎̼o�a;�-?�N�B�����:��9��6)V��J�6� �c��9Y�d��S���������+�a���ǂ�e���n�	#��S�F?(������ƹ���.�JS\W�	XL��L�r�<`L�v�cB)�+��ې���?�8.bY�,��C�!��k��b)!��WZ\����"�<g���x~^ e�-�a"H_oyR�c��hω��������+f���4D��O�մ���'�0!i䬨�O�d�#�;%���%�)=�=���1_��tϊ�_�\��Y��G�Q,��|v�s�/�����@��[A�J/�"��]6�2+:5��i�3"�S�hm�%lɩU><IK~ ��G�l���%c�����QK���Y�%��j诂��@�>����*�_�qy*�T���}��W�B�U)�+����fJʾ28�]1�5(1��|�Cg#��h�!�4��:�ɘSI8\�nϘ�[�g�)Ig� �^�����.���Y(헟�׊'��,&��T��gޘyc®j[��3�����$[��i�J�ˌX��G��9��ƒ�}�ݴ�Π��>l��4��HQ�t�b����|�d{!�����31�p�$��v=!�9���41E�ɠ)W���~T��`��̽���d`�D���n^�z�.K�_uם�3ELIc���Ғ���: *-�[���x����Y���=M�m��mv�>ݲ7�Q�\�u�X蹵���vLG��L�w�9�˂$I�P�;8U&�A�N��$��� �M�I�2����z�z�c�K_p��	.}	})���ix�������¸�>>?�x������V�p�j�O��u�����B���n\�����R�N_���\u��H�yx}z�w\���lxxZw�<U���������pf**Ų�k��D�F sg!C�Z�*�*x�g�����t��5cw�gȪ�_�$i\3����;D�ؙ #%V��[1�Ɖ���}�Qi�a�w�b�0i� �
�Z����.#�����+S��L[���~m���$(����H���Fݤ?]��/���.����dg���8l������^#�ǁ����.q},!�E�i-x��w�lfw+��H �R�T<
*0Ӻ}��
�߾DU��N�L2q?��w�B�]D�:[�bS	�t@�~��5�Q��n�ŀ�(�	�[,@�����))��i�8M	��D�4;�}a	�^�����W���^�>�+�VE!7H��Oi�Y�n�r��ؙ-m/x^��_��]$|�a2h��E�LYf{I�Z"�51��7�s`�����	?���S�nF8�D�l�/~`�����T�l�r�-�s+�ۜ���)���q{��b<�?�#�q>E����X[m�Zm�O]��A53ޠ��4�o�۪���vHx�>f�8���MX�\j	/p�wXM�?u�ʚ�t�͡����Koҟ��T?`a�5�f��fzY{Әg��.x���n]}2D���Gj�-��1s���c&X����Zc�w�ls#Hko2$��S$�	uk�_W��!]R��㎰ˋSȇ�ã=~H�$�ٮ�������O@�%�,'�!�d�/ l8�	8���A�2��<TП�"N���#Hȑ��I����ā�Ѣ{3e��H���mN��ө�3̉�=�||c\�5N�.����Ƿ:��'��Ζ���4Ԏ�;D�~]s�[Y+��b�(���%�\�;�2PG5hr�Q��#h�Fo�"FO1���5�{�ᤣ�e�u&�w�/Ζ�G�ԙ��Ƿח��+�	�`n���NV��]�	��4-��!��D�
V�=z�+�#$��W��?��V37,JR��4�rX����<�ض`�4y7p���������_��v��.a�r�$=)�}��J��wD���܁|�{H�6�K�����-�q�4V���Wml�����3y��#1�IL��'=W���E���)!�k��1�ח=�/�`}�^[:3�xy�v�:�~��e%��!��J�E�~d�W��qMEE:!|bV�P�rJ�I�\Ӧ#Y�Mļُ�eD:�$bQ�pMԂ(TAo�3SS����8���s������Ʋ��$�:�� �ai� ���M��:oC�%Q� ^z�go�i�U�H�J���Ѱrq`�����e����$xtI����-S�9B�T����S�{��& d�%|�����l�
��[�\2x�#���cv��^}�<��\	��
sE5"�m��P�܁5`;�+�<�ڼ��f=B;G$�ȑYJ���{��W���g��������m�\M�4��dA�����#���E��>a�^�vuQ�uݍ@�=1U�n<�>A~r�/�+��Z�2n �3�k�XX�|���Ǜ�������Ƨ���Ǉ��o���ys{|~����}�����"=��d�%;�2�U>�ｗ�We��B�):��4�@�Wl"7fO�e}=1�F?���tlQ��QQ����l�REX1v�6[:!%��߶�d���=Y��p�
����w����kt�h�+Q��aȡ8E���BXoc�4��iG}zNƚ�W1=�0MeR�m8��J����B>?J$qyG��\1�R���/����(]F��I���`ʮ�%�%`�j�|@L�?F�[]�Cf�2���
{�l�Q1�,��X-���l��H�4F��K����wQ1��+��@T�'��=wk;<��v�m�����۫Ӌ|Ǌ��L6�$C�_���y��ϋ)�����W<e@(��� <����%��qZ�����-˚SE���Z:��hJش�,���{)�*����89�v+Y.n���!;�C�������p��K�k��T:�i:е	|l��Qޓ"�� ���#%�D���j� <y��X̌Y����X���L�t��m� �ѿu��γ&�5�S?��^^<��غr�n�`M�6�LA�Ga�V��<�5�˪�c��b"K��b���;�8P��P�RU-���Rם�(�o�f9� �,O���YD�g��x=�C��0�ǎ��O�K�9��P�륻�	���c�/�ϒS�qx���L�-��Fw6��׫Qklt����    >��`��z���<����K�B?�y1#�' �r���RFDv'��=7,��hy��(����K+��A��}_?�$���ԥ���J\"A"<.� �E9�������`s�G)�a�L��s2��gs�+��f�E�����(�Ѿ6�=�o�|!�c��>����������`T�`�l�˶�۔!Z36��Q!>����L��
]�����"I
Q�7�J�*Ĳ�*����y9�b	��F��x�U��䠯x��z+�W�-��ꥸ�m�v���j�.q|B��;$�(�L���XM�0�Q��_����T�U*��4պz�����e��<�jVgfC��z��p@�"0�c.�h�d������q/�b��Uԧ�+M`���s�E���f<+�Rr�͘ȑ��F�?>�[�M�K^���	�"hmm��e�hr�NG�� l���:x�k���K��!�<`$Z��Iw$Fx��HK"���g���g�1�VΫ����l��F����n�hMޖ����M;���)v9p�+��q����[9�����Q��P^*��b��Q�
0�B��5>a؇��
*���J2Z �FS�M�4ZR5��|2�a��cC�QP�2u��L��}��9� Y�?]��Y��[" �`�Z)Y����
��f�Ւ
�(�m��'G����ʻ�\'EXC�l}R�9)�W�1�!}ꦛnZ�Ƙ��+vM����8�A��oI��ZK�5�X�AZa�6tp*q�&�#�}�uVl��@bS2���w�Z���y���H���%W�/��[����ٽ�Y>���xy%��^Q���9�G�Rd��SVra�4��c�������.�V�/��V�[t%X}m�V���� U�åS�(xj�7[a5�p�$��H���,u��n=>�jx6�`���:��o���>n�wh�]�띉t�_,�<��zǔ�)Z/̅�NzA��|�bS3����]G�(ؼ�v���],���ޚXС��/�6W6S��S���]�r���v~���N8���V��/F�.vʺ�0+RMZ�� 潒zɦ�p)�7QI���PZ�#����yw�C5�^��ׂWކ���|��A��m�8$�U�W�狗j-B9��;C�>°��*�VL��~龺%|��#�T���c��KC��hV�3��h	)�ҧ�j�ɨ(9\1�W�S� o_��_��ǩ�NbkD�F��{�<r�i0�G��'�q�B�cPR~4��օQ~&�ݞtwoDpw����n���W5�A泒d�����\�My�i���J�vYwo�$��X����PgR���ř�;,Կ�[��Ԧ��x��+�@�d1�ݦ���cY�c6��V0��ϣl��*�W��R����9x�j{�B�U1F�(�e��EE�R�O{_��g���&˱6>�F3�pG�؈{V����"��$�U�����G�{��-�n�n�P/!#�W�d��{Cc���<�u���^��M��n\Tղ�x�yA�"��3o零a��BZ*D(��>V���6�J\ls��Zɤ�}��؁����D�y^h�h�����}����+	���׏vx:H,��ݶ����>�:br��+������)�K���*4L`�JD/��?Q��!��b�0ϖ�/�8S1b��BZ�����na �&7�Q�=����צv .�\�b�j��k�?ú�`
��@?j�q�qC�[��_QS�R���"U�
*1��+&�r
��0�S�<O�θ���SCN
�W��`ou���~���hE�&a�褕6!eܫ�$�aTԠ�J��q[`��`7z��&��K�%f�D��e��6$�"����*�#[��@r�P�����u��{��?nU>U��x�w���y"�?~"~O�h�-S{1��
�Z^�H����-��QɃ��EE=>�u%P~5�&����ߞ\^�y����)�S�V.h���&����4BX�WH��V�^� �l1�5�-z6��G�dS��};9.�Ц�8%kMDX�Y!��bv���~V�T�|w�n����p2�%5���R-
Y:������E�� ��C
��H��e��ݒ��SpiD>tE-V����B��yJ7���i���G���IsZ;=���QIQ;=+R���^�Ó���+�r�C�H������}@��C�P2����e.�8?M�&�W�a�S��Hu%g��T	2x ~���B�"�����+$��5@��#�n(�j3|��Q)�z�
M.g��)�O��.\D���Ӥ3-E��N�(��Fj��!��S�j����� �jO��a�ҡ9���egg�	94��)N�+bjԔ��侶���j�V�C��s����G[�2%70X�tuO�:U�y��e5+�qԆv�bMVg�h�	"[Ŝ�sn�}t,*���)?Fe�^��l�-Ւ�cJ���X��#7���K��x��+���jL�Xď��89�����L�.O�I̽��;���&����tڬI��2VJ�B]�y�`����50|�x��(rՙ$L���T\�K���a�V	'b��(���U���9�1Z��������C�<)���9�"�_�#�8J�~0��Ms���j�.��^���m����O�
-`t�/0�)�w@��:��K}���2�.�~@��p�
�uh#�����-���	;V��}NCD74�sCK��JJ/+P��ȿE|��w��I9|�I�7�X�c����D����>'�G�l�L	k�*7�e"�.&"��n�?��X�U�{�o1�`�@dE4UK�G3\����9�-OC\��w�#!'�xҕ�
c�y]w�p}[f�Z��VތU��SΟ5V�Z�mE:͂���}���$Y��"�t\�A9 ��{����Tm�P��j2�^�S���mBf�~@��ߑX�F��NM߲]$M�]�Hx�oβ2'�0[�Z��5X^��Ե����LQ�XV�3pe��8��p�%���Z6.�@����=�h]^_/���ώ߾�,�ҝ���m��ۯq�#i��J��a��X#ɝ#�,1#��E%� ��$u)Eh}����#�
���];���G4��^��<��qf�/��_��׷C�c�`邚��wζ+K��xM���d�4��S�[T�x���1m��q�@�=�M���A�.L�3"�J��� ��,���[�.�T�z�:[T�8�4%���S�|�"2�]3���A��������
�@�f�j$Ʃ@ZO5*������D�'��.�ߩ�<��<��<��|_���1\�s��;��g��e�hQ���F
P7KBw�7a�C�@:�[ahZI�A����Ht� � �0����V����n1#3^���{��wj��|��coj�A�'0_K�8�W��"%0�?���,�D�P�c��1$@Z�zqQg����[f3�_PL��M��Q��u6��|a'����`>��X.���HH��,2�p����F([��dZ�O�Ƿ��Q�o�X
7ϷN�VԢ�͌/�ɦ�j)���w%�{c1�RN"8�:e�0e�����N��.� ���k>�g:y�S�!�27i[�z�(�,37����wp�
s��$q��!�Co� <Q����j���ٞ�� �r�:�kA�9G�/ϋb��b��'�3z�MO�¥�߀l��S±����
��AW.����5]��R�ꁍB"��q���E:��wd�G�t�&$�~�J���<�ul��\� x t����ӛ�=��B��N�8��;Y���lR.�W,:D�-1����?�����.}�|7. ���!�9�$����Wu�S��cF�P�Ķ��%U�jw�p���t6(�X��D4�D���rבG%(�(fLK�G�聀�xK��փ�]���^/^ӓ��&��e����|�R5?�8��P	�
��Ɏ�^�e��z��;���KT�q�(E�b�^8���x����G� ,����(�ޫ�SÈ�B/U�;��L�    �3�-�w|S�0EL�]��T�1.�<)K^�R#aR"�L 7*u #�wM�����~�*�Ԡ��y�(�Է�㑽R��h�Y ��2���������&��,{�\��`�c4���>d L����|e�����c!'�i���������v_�,��R��)qZ!����
�7Ξ����q�Aj�E��>�U�S�L,�ɔq�Ȩj��M�@L3��8�RQ�X��d�O��7䯉���ɥ�������U(��IK%b��r�p���}t�u��#~���+�(��\��]�$O�Z��r�׸��'���U.�z���:�j�4�'���p�"�J��i�@dWN�;-�&E���~�i���zx��(2S9��������jI^��oM$�Gl}�mVP����muW;��/���RK>v��c��	 �ā��Z�����G\P<<��U���]&�^����H�Z�/����������$d�W�#��@�
eϹ�s&خD��hQN�)�E�ضg�6��V�y�x)Pu�.��u����%�}�Nd��C�u�.��Q�ǎ���ap�1��}�Yю<�@7�Q����|����o�ԓyů˻'D��i=��x�$���x!�<d��׵֓Ї��!p����m�q���MO?|��8b�xK"����	�t�A/��\ �h׏X�t7
"�Ea�!R�N�����-_���{��ۼݵD#�ɸynG��������V���������[^{~�~��'���-3�-�Cp�1��9�)�g��۾FV�k�k�=EM�K�!9] ����^�����|�"���Z�d�DV�y�L�����뿡b�E���ԡ�Ƿ�O�]��w�n;�.(����!Rw��qc�%ױ�$��G��G��e+	�82]Ѷ8�����e�cz�#���n�[6�������VjǶ���Yq G;�J�XJ�ʸ'CX۩�3^~����U��1��s�<�=�h���!�$y4��=�GQur�ct�
:�i ԶJA31�W
m�EXZ6!ra4uc9�8P��V���6w#\yoD�2��-���^F�>���Û��k��Ֆ��B�\e���{#�\��v��u�-���`��ވ�Z�[��m�2�s,�hqv��%4�M��}N��<�گ�/�����,�뎼��'ou7;���b��r����`*d+���ɛ������Z��̕��v�K�!s���~��s�TdF���AVY�z>(t�����+[����1��q*p*�T(
B}-?�^\\^�U�v����t����hEg�u�]�:
��h�3�t�^���hY��֊����PC���<�Vx�o����m�������<�e"�l�3?�� ��Ѣ�-��lk�}%q��pU�[��Q�<Q�tsw�y�N=���vl��h[.�c��@x��x@�%'RՃMXӞ#��Ct��t�S�[ʷ��;AY�H�Ɔ˾(�����q��B^K�>oޟ^��^��<2T�m�G��`Y�>W܂�V��{0I�N�=M����(���O����ކa��ý��ۉ+d;�4mg��ܗ0/�!���0�T�P8(2p�������hl���!E;D�X[�;S��_KU.5�����ۦ�ƦOC[��rf�9G�<���?�<I<k�b�s`uT�07�7@*�̉!53ͧ��r���$�o��#��9m�uHn:8E����C�f���Dg�X��	�����Rr�<�yzvv���z �����	��A����i��B�X�蝨Yk#�ǟhV�-�Y�W
x��OVG�(�v��@m�AY���q�y���d�coV� �B��� �j�/�*����偗.0/H��l�O�7�;�d���������.�*L>�4lWK�N��J�{#*�f����Q�X�	=�'�Rl�x� ˂0H�$����;��v�_��"���I���2�Gh�и�B]h�7�}�n�B��p+� �\�e+�7�5Q���
����L�R����v��O��.��f'e�#�����v�H��.��q���Y�n΂df�+��� �}WMn�T���-p��i��=:B�uڢ�o���R�G��RD���81�gE]D�O���|5���x�Q8{V��5T�H$ -R �wY�����q={�ʓ}c��'@������c�ޑ���fV�?��}��א=��^ܷv`�ʵu[O�뾠�R�n���3��c���쮘w߽���ꐭ4��LhD�c
���{����y� ��oa��I��ܸ��O�Ԅݫ�ͫ֬*�_TlB��'���qʴ&(�d�8��e�ڀ��FN�![���2H����|ɼ�to풢W��6&iS����h�ӭ��H�^�ƿ��w�����nee50�� +�Q�^vkw��Y�F��=Q�Q�U�Y|}K�,�l^�|}����ǋ�o���3pg��̛L�Q�Ƚg�g�<�D'��J	(ǖ�ꇽ�mԺںU����+��>�߃؟�����H�)o���D�/�2ށ��[h��1:ڍp�f��̻��ю��y'�����$� J�>
�F-M���?	,�o������nh�@/\o��A�F"q,��9�i��9*�#��||�}���0��?��n4��oĉ�A�Ķ��0�,����XށoQ貀|�X�����&�g�G�|78N��I�IT��?�����ԏo�W��7��c��p;y�\�dx�"Ņy��]�q�W��%����d���#�k9VM��R���-��.9SKH�-�E�¼\������w1�Ǵ�/]P!>��~�J��7��f�Q|y���"�{��4��$���U��t��)�|�Ӧa��%/��������G� )*����5�!i�'O��*�-J�x"w���wQ�'�[V=W�2;<�������p���.�y�
Bx����)J���k11AF�h$�ǹq.������2��D�KW���>���T����� q+���.P��/h�R�K��lC�o�Qa	������A�7�t%����Kʼ�-�2L
1i�	���RZ�h���׳A��]����O�����$�`)�M%'=G�IlZh2��S�ջ]�v��8#p!��T,���JLW�PD����>3����\s�)��zS����}��*�X��^W�'�b>��8)�C@Ί��⨸��*������}'��`��B%qU�f�vbE�@��֙�����`A�#���/ M�Db��%,l[�}6��z,7���qȖ��v���Q���4��=�|��Cl����]..�ɠ�Ѐ��}M�n�����#�	Hſ�'i����!�zo���z�������dH�dgT��i�f����\�צ���𹷗���K��������a���=/O�6����`�-U0��tHe����=�]���͵i�>�Ku0���Z���`&�jإ��ӻ���2N������[���D�,�.���N�G%�rΖ<�|p:��y���^��W���rQ�Á�g��_�\aº�r�S�}��gsCd�w����qA�m�CY�՘p,R���R�ר('tw���R4��܋��"MeIg�mT��L�^1*����ZF�W�����Tp:Um�x�:j)�qM��S�s>�7�[?׹1��9�}ws3<��mINz�;90.T��+a������˺�D�������#z�������ŧb�L��TT�gX��As��$�}�q��J��ASXŇ�,T|0�j6����پCå��7�8Oh��􉤧�j��]��1��q΁�s����`�l�]D�kqL�x��֍6�i���T�(��S�!۬�!���:�'����1��V/�:��/ſ{a��Gݩ`�0*��`�3jcwy}2�8=2���^]��8�d����s:]�����.y]�N�G���s��36�K�M9.�N�M����͂{")�SM�I�
z���������8)�HM�    (.�%-f�*�I	Bi�d����$~v��F5�I�	��Ci�)����愰g�I����J�{���T�R�V���DLf���c��J\�>6@���<�����E���)���`�h'��k�a�)�����(�7�?6����R0,�jo������ǳ�wg���*��^��h[z���";v�����䄒}9LKq�J�����ER��fv�}'/�ˊ�*!V��7�Q*�8,�ƬxH M�b^~IбR�3U0����@r�$#,Ky���%\��	,G�����g�{V�Qik��\n���K�Qi��V��������v�XѺR�*$h���4;�B����Ñ(��8��C�5J��$����#�e]������rP��8|��j�*NPN����%��_z��UL�>/qK���q	ͨ���7��m&�RUt(;,�y�
 ����;[=c��΄��Β�<m^����A��*bhl+]�������3�����vh��>��Wxhnv��aoXƹqA#��h�T�rb��3� +��^5f��s���/��H4u�hE�q�ҁ5M�Z��1`�.�w��Qmq,P�A�A�0Ɔi1��W"����J��q/�\l�f8��m��@�@.��Xyf�J�� ���2�[�/���`�����y��%-H��˖�f����)dW�g�GÛ���+������J����~��ڭ���C�F�񁚥��1Z�e^�����W��ʸ��qQUK5�AeOE�G�t��LuEH����mL"�R�>RҨ*#Z��6�X>�\�=��$���$Z�</$�]
�����݅sSCl]&����`Z��<�E�j�v(���>�2���A�Z��u#��P�� f�+~Q�C��"��l�4.w��I�4�Z=��M���M����d
�^�$CWx��tǫe4�&� ���\#�IH� � ��u�P���n�om;j}�I��<O�T�t���4.���"�{ }�B��*hk���S�/�H�ɘj��r�pD�7P��d��Ɇ;���������_�1��y���6\堇2Ӆ�ů���rpOSH����,'ܽ��$��	��F%��*|yD�}��/9��h���o��;��L8=㥘V�WD�jl>�C+�u͎_��1^�gU���Z��|�E�����vF�$;|<��1��>ހ6n>^oW�5�r9lX���Y��	�{0����y;����u[����9����x	P��+�nѬ���p����k�����[�)C�"��^
�M�j��p1U��ӴƆ�������c�9�T�Qcv�Q)�$8��S�����<HI��9�Ա���0??1,��7��<���Q&Wi#6?	�t4"��)DH1����$)$�:r���\�D)��;^�)�*I3Pͨy.��3m���z^7� CLo�s��0����[�<Oo�ڟ\~�~�8��(���-��$��q�J������P�w�2+F	� T :3T�1�<\�`�sC�T��aX���y�� 4�6 ��!����gȹ�i^'r�@̩?��t��p����ĽER��:������C��n|-�4Xfa�-ږ�;H��O	���{DF�0F��̖6�>�z)4q'<@��3�ޗ�#��4E@_����	A�bI͉���ذ����՛\C5!:p�)
�b.!�m]�cXXoget�@�D��Y���R)��7�����ʄp*,b�DJ�T���z6fu�R쉚JR�P��0E%�p	�Y�i����Ŕ��ڗ8�Tdg��� ϳ��V��XF��9׬S�n��Q��}����m"£���s�^�	�:qEL����0Ӵ��|�[��k��C1�	�!r�9�A7\[pC���!#+�eL�r^���y%B̹d<���8Ejk����A��X#�V�jA�b��]"���H2ĿӍ �L�����6�sH��b@UrNp���wV�'/�^H
(��4آ��9ѯP�a&Ɠ�VASUu#�lO��uw��M�����^����l�A����ތ��$uۉ�3	��Rn�#	���'E��B���z����k���wYX�/Z�I~���|׍�f�X^�b֛鉿0��#Ӎ�4���s�	��^f:��~h)�rM{`gV� � m���7N��u,Ӈ����#~RH�,qb$��/X�H��Q�^�'A�5C��ٲ�0HL�K�Rŗд���H�VD�<�H�i��̌�{�{p=o�f��q��2[<��k����s���#~�#ҦcƮe���� ���q��E�~�i�;�u஫��(�����$u</������]�/�8�5ޡK�1(���E�M���˂��u3*�g�!|�F.GW�_�����0w��S�da;�&3y(�����k�XZ,�)����`�14�1Ť�ƗЫX�ٷf:��}k��xI�$����K3`Ǯzҍ!llˏm��7�}ؑk9$��~f��i=/NR��!�����
,'�3+���lR횤l�N=?�������-;o�H�c��m[5�\�p]$L0�"sE�Xp�`4��w� 'Y��i�`^��-��
,��I�e>��2�Ky`��8�`����>R=U�$$�NT����b1f����F�e���q��%[Z,���&f�u�����L�z<�H ���l����,�k��N�6�E�7�$�G-��gid��k����7�yYVd�Q����.�1�B3�!>Ht�)��ǋ����xm�����U���X�(�� �hm�[�N]�DcC�Z���J�j	خ��K�
�F�g-Kp����9�2$����Z�?H�99gf��v���v�b�s�c,+�6�xjWg;D���,�9|��?���:� ���r���.��y	�w��bB]� ��xȓo��kմfUסi5����CԗEմLgdsy�gpt؋��1��+��fF��fI"�e1���L׍�+r��p+�N���^?�_�
�.��d�Q<B�{L[XV���L�[�li�#�u���$T���L~d��ټ���*�1g��'�3~"��%0d;	����xrE9��e^�w4~�^��#��z<	�"2���s8�$��z=��c)�K��4OF"��F\���|2L��L	���p" �����%�4��b��� V t�8�(�)�*��j"�8"�W�"���+V��fu�ؖ)��@Ȳ@��a��h����{#��o�)Zr������óӡq8�>;�ȶEA��G�D�[n��.zn�������?0�yc�i���;�:8�H]t�b"�a�Qu%Vb42	d�؈FH���"��(]���JM��L!!��\�6�ucTn��}`��L@�JMnq7^&�L�H��mr,}��G��������i,��n//>�*�Ȼ�_�u�5�V,b�\Ɇ��S�����/��1>���ל?�S��f���-1A0�z�	4�����'������Bp[�\�60D�����,ϔzS\�8���`�
̡�5�'BZ��W�r#,<^�c"�nR��sBVflMв����O�H�h�iX�|��Ȍ�W�o��2.F˴�۪���L7>
V$5��( ��'t�=�Y1'v6��a@�'X���#�?y:Lg{��b��WAk߮��1��x�S�@Ї&ε.�3����-��Id;��o`;Ah��t|p�_�Ͼ�,�nK�&?���V�<e��<��ogC}�B��O��|a�0��	�����5� ����ZVj�'M�#W [��|����/�>hl?��B�wqlPaY�J�y�J%�C6�f3�� \"c|� H_��{\�Z멏q���|���ď��B� �qHf\��ZU��Dw�ɫd�!�=�標Y;�G��b�#���f���(�Yڙ����j��ۏ@e�vQ\�G0����0���g���������SP�Z�.0�w��vz� �	���w<��� �bn,�D��ڄ����tI�6���+��l��u�N�yg��ěv�A�ކ����ű��Up<�    �ٖ�}K[�L��K�nz���\)�f��R'MR;���k��ۏ�I��`>W"�m�gԻB��f�iB��O�ˈ�x���=�,F!���r%���q�0�f�;�����_�����d����ޘRĐ}�-u���D�5����ԛ�\}����qz~uy}����,���}�&IR�~�7�Gg\�zy���N�ڪ��@o�����C^���o��4��T(v~a�y��4� 
�f�B�5��ı���H��%��_�$W�M�w�p��{r�vL��E�.\~�P5}���4�M��zҤ���BB_���1���Ϭ���o?n�?k�)>��F.P���>}{r���"��Q��rg�vZA.���'�A8��D
u��\�s�˙���n��~��a���@��l��=N>g�g�?���~�f�R�C�#�+�}�fM�U�&���_�{����n�xTw�muZ������lI-�mSou!������t�����t�Ǚ)۱0hg6�q���^��o4x�K����~S��� .<a�N����AEԭ�ثw����?���t�B�3�-?��v�)���xA�M�&/�~���~�k�>������K���	)=E\�w���]�f�3SJ?��u�k��ڑ�Y|-_�o?�'=�ޥ�����:~0(0[��W�L�,vS�ۍ�Y��t`R���2�j]�ۏ�I/��e��>��2q<�P�tn�1��+,���T4���Z��N��*�j4d��p��	���NW�ͅ>�
��\���*�?�o҇�l%2���wpVq읋8_���C�O/n����?�o�3-2$�"tZ�� �����bzW��O�j�,�ȒɈ4Ō���9F{�����b�!ƙ��ߌ�ek�U�� �kR���g�Q�I>��"#�-%D�Ao�z
ѹ �����?���1�)�:~-ou�C���>:R�=���R �2�>" ��T��1q��,o5+�D���� $�-�e93���Q�Ǧ:T�_.&�%>��Z����἟��m���B�g������sVlE�]�j���G�\3�R9�X����b>�V���s�|xqri��N�7N/oό���؝�z�-�ӎzzz���üJP��y��j{L��/��>Kˤ��^j�����Lj�u[&�=.lvo��`���{<0>I]��
�D@���L��$���>.PG@}|j�W��!�t1���|�1/"��i���!Z��Q^0�	��`�lN�')�)�n�|&�2��c���3�
xjO@=fk�_gA		�Q�ps�5M��q�eS�e�A�َ���Z��4�ۏ�m1���.�r��kQ����&�(E-&�����7G8s�{/ޝ^�Юx@��N����{�MG�܌�l��ɟY�Q�C �1���2i/��3� v2ۖa��暑#~��;�_&e���|��ӳ3~��y|���#�f�#��N�L��;,K3q�4l��o�?��0�ie_��������r�a�wX��渽#Zՠ�pi�A?�aL'9x�{"e���5��a��1�Jz?�h�A<@��ED��^���D	��٘YK�m섭�_H+�H.�4��8��&A�~�J����x��dҒ���p��Z"�x�����4�{^��ok�o{a����$�:����d�ۏ�m�z?-l���T�����,Ca�if�%(K�A�ilf���ׄ�ۏ@!ܩ���(oYǄD�4��,�z�4R�9.��"��d��7��e+����D�� $m�`V���A��+3;���nG�����D��A��D_�o?�.�l6��1^z����Q[u�ӣ����&tӃ�D�
	D���kZ�|��ɞ�����2��ADw?z�H�<�L~r"�.���X�݁#a���aI43�K�|��K��C�s8�58�#����>y�D��#�cp������j��Z9�b�40~@�U�dP25~�����p`L���ۘ]8����u���gu˛A3��\�X��f��~'_+vp܊�ز��M4_ �|%=Z~����������n�my'�/���9c ��wY��7�U :���� ����m����M(�O��X_�O�k.`E<��pʢɄbfg��w�̧��
��%ou�-K�Bԫ��4�	G�c�3�\§
{�5�k�9ˊj��2��V��G�JX#�8���ARJ�k՜�,f	D�}$��1 ZZN�����x\!���A^=x�ꓐn��%ɨ�rB�<c��R!p�Q��vݍ��
/�+ݮȁ,?��H��^���"~�}��o�>�I������B����� �^�Ɓ`�j����x����u^�	z����;E��k�D�BN�hWIQ���4�ԋ��]�l����{�嶑,]�����x��F���-˲�:mInwM8�"$$�$�!H��W����w�,�(�$�:d��Dڤ٬nET�%
L��Z���V��m)�4S���D|�(��ip�!��o{#4ŉ�G��@x�j<1z�&��>:�����ص�lKA:ǒ����g�Ӝs�bܭ�2��*���jZ!������B��b8fΗ�騍�N9�SO�56�dr@s�5��A�LU�1(��$�"?��:=�vl\��K���jX��D���W�^l_ei�D�E�/$IOy`$d�����/��[mp�(��0���w��rq�(���'�r������wHL���,��*Q ۷�c�}���p�@���G��O�n�$��(�"�5�u�]��y���B��t��K"�{�l�`	R�\Ǘ�"��,�?-����T�Kl��T%7ώ�rP<�|�{���B��tnt44)K�Ō��5#�$ϲ,��$�Ct��'`q�}�e%�XV��_���m�7#�jZp?p�4��W�o��o�F��8�[�i�|�B�?9�>;��������Y�)�ǭk���3b@��|����=L7frJ�X��(��HLGR�S�m�Cl�e
[�L���3$��zҬL�5眕*t10K�t2}�W�Bc x��oly����\��n�<��@{�C{�f=��<�B��>
����>:}v����p�=�����E�5e�fJʳ�4,�awl�PN�rp�4�,��#u~��Vq�EG����Sn�	=t��5�Sʉg_ ߜwmBK�h!�����b�։ =�v|D��)��V����.�%�&��C����f0k΅���pViV~�T�ՙ2���B<1���&?NeU�=�6�
	g%�uk�F7P�e��m6F+2
%���	�y@)����AqɠE%z����3�k{���x���s������s<�>Y�j r��-��L��y�?�U�4[�x���'tK5�	�w%O���N����S�/f/�|t�?AH�6̨Xp����u�O"b]�<~w��:�?:=����YLZ4�nu��~��.������!�BC\�	���s���䅸����5_���}�����\�� �f7
IY[��/��~�/c�e�s61gUU�l�p���c���?���O���>�2�ߥc�<�ܩ���u[�ey�a�-7|�~w�EI��$��ٓյ����8����/���iF�bb*�����-�����i�H#	[���1�9A�;�F�d�H���P�`<�>5/�Ύ�AQ���a�JU�b�@�9�X��)���2����a��'hN/�}�HjZ�:N��� ���:�
�Ӕ�,@�
�(���ݒ^�م}���x4����@)͐ƶ'�j,gi �˖y��q�D_�f�bĈ�^����`�bM(K�i��AcFS�ʴ�\?�~���ws�=�	����%ؽ�=g4�^��\C�����/8��n����:!�6YK�O˹�����.��P�����Mz��N�H$��Y;ǲ��_�{S?V+F��a7�
B��� ��g��w��&wg;��ߎ�~;��<����2��mI�Aogpó��_����KU��%U��QQI��y�4/pՐY��>��f�U��ks����p���N���p    r�:�M�mً=�	��\V�v�H��A/���%;���Hn�2�iR��U'q��/W�p�}�I�t����z���VO0�灝��9��	w A�R�JՓ���Q��rN�	�}V3��af׹�u(���0����Y�v4�#}M��eS(n��f��g�k �gSu�m1J5�#1���Ynχ�i4�^�z6�#-��֖)�<�D?�l���06�n͡���p4���/�R�;�7W��d=�$�>�>�^�ϯ�3�Bc��>q�j���@ןH|�Ӆ�='r���7g8�1�1'�&@�l
�!��CJ��aK����WL}��&E����t�����;}o��߷L�ߜa�G����?"$i]w+��N�C�b[o� ���fYz�va��px'^b>LD�
B<�����[q~k����Cf@Bܥ�vT��8��Ӎa|F�*[��6<�n^5g¹�W%b$���;&��S���:!����&Fj��=��/�]r{�X�o��
�Td�lL/����k1�����*��r6O�N���5��4�8�ZSo��v��s�X��ҏ;+`��;��"�v4v��ԍ�<�#��LR��6�%y��}���3p�^�/�������޾����T�ygb�� Z5¸�>��[�\�	ꭇ[��D��%�'`��ߡ>r�b���ǿ���Jx����x\�BR-|�[���ag8w���B���r2���'4P�z&�S���M#%0��9�����T�5W��O-��#�X=Lc���RM����8��m7h�J�iOL}����E��ӻKP"��č\F1
j\O@�n�8�p���aPgs�
��� ��l2�ia.�5dH��c�᜹AԛX�m{=���b�Ì��2�7CD�cM\�T�)F��ʹ�!F�?�)��pC��JPi���yFc�q}sG�j����6�fE>��ٱ̮g��4�!�W�⏂����*Y��$H�����	�����K���u�v%ϫoVzsz�b�����"�{^�H<�I���e�v��ɲ̅[�܎�q�m�`bk�T5�8���I�,���l�֎҄�-����|�?� n&���n�\���]�J���%�$���9����;��<!���g�� ��+���o78�L��0��b��cj����7CF	�L�N�kZ}�-�?��:��*

�+�.���O!��&!�u0`npM�?5��yZ�f�G�t����+�n��D���t�};Pa��,�ܤν�$N�8
R���vm�k����|N÷���X��_W�¡��pR�(E���M1�c��@/#w|�@�M�����CM�_�g�D�������Ӧ�!�]���b6�X��b�4u��2$�n�x��I��e��
�]�:>�?����n�$e^Wh܅�L����FWq� 7�~#�o�]�ы�~�p�	s��_��~*L!���>�ϻ*t#_$�I� `�����`x�? �^d�\u�<OL�%�I�/�H7�IS������^ �Z��hW]�d�\h�i�"�DЍ��W�Dr�ީ�����c�.��s$�ŔxjR♭�v�$B�;��zav.N�ά��;�|���ګ�bMF�s杚�Q;��6'c�F��hʳ"M�X�(濰��ofpeqB��TD����"-��10#��Q�yU����5Z{�8Ut�$�c*;��߮�ɐ��}d%�8wVbg�]�)3P�Zg�IY劧��bڱM������G�O���[p��u�LbX/q7�<��$5f�?`f5���c��Wt����닋��E���K�I�:~Ϙ�+�7�r$Ԥ��<<���E��`�,4�B$����qYM��be3*̍�E�ϰ3WY��E�I�}'7��H�g����q�,��_ߜ�*�|r�~����di�JZo(N�Wtz��k��P��rtxNg��a�_yF'gA~A�E��D�1@dGvmR7]9�>�+��z8Ξ�t	wy��lץɘm���X�ol��<�놽(�!���ww���)߬��5IB�iP�q�z�pC�J���aΌ�f��)��k�E�����!��ɯ����#R��S6B~48p���L�.9u���n'y��U���9�cy#;`0n�����4��PO��������-��7��T�	��_��^��O�~����V�Q4o��xI����^��uѵ��-�l��s��/�&%:�
1F�r�u��F�G�zk�ꢂe`["Ɖ��o����p�l)�w�<�b�f■�����,��AAma	tiN�@��i�"�K��O#��h_l.���%�w>�Y���[�y$�m���N�%Y���v�����q,N�g�g��K{�,�U��[T��8t��*í%>��+N�\���x%���]�.�Y��H�>�d�5�>:��r�j��k��	�41��Qjg�zE�*�R�]BQd9�jf1��M^ƭNDD�F縁��R�~����$q�ݴ����_���i�����z}t���d����4�Q-�8^�Le1�(e���?9�z��wTM^����`᳭���^�jU�
QjwG��z�4S���ˬ'J~��9z߹�{�E#�D2���NN]��k�p�`�Y�(~$��&�lKb/�J��X�W����r�Ռ�/ߝ콩��1�H+�n�"�#�y���xy��Kk��z����8�_	_�T��zb�;~�>\�oC6��]�����N��x^u����Kjv�����u���jRǡ���l[����K ؍��z���\����jl�܄��%�$��&�P/����?��2�m&���1�QTS��!)d���=M�;W_du�q�%��uI��J)�̐zP�����iLC�ydA�M����@g�rtU=��v��B8+��H�"T6ڿ�`��4A����p�Ea�v��k��g�O�H-,��/�vUo0
�y�XA�M�$���y���vA5��Cu����r���X���vvnR��������I8�<��f� �bO�z��z����i�Afe����7�4P��0�	z1AK�N���%����� ��9W:�V�k"��j���e��G�O"#��:���H*�i�/����K��µ�}�,��76^� �l�D��_YG�/���o��rP��z?�G�����X�T����u�n���@��[���K�S�8��R#u�8wa&�A(p�Y"|�?�ֿ�n�L����&sӂ�@�]��4&��Ѯ���1U�[Xb�[\l�$�3ʢ,�"J�m�
��Wp|�F����p�L�'vaw	�G���/xa�J�ˇ0
�#��TZ����O�睗���	p�)���˂������l������+4����W�d:e��`����(�=#�#���x6q�d`>tX>U���Y��NJvޱ� �;���,��`�;�:I܈5���GH�I�N��y�Z&2���4��Ԡ�}�P���ۄ�\��n�T�)��<����<k��q-��E�c��peK��匌�-�
32R���`�o�{���u��&1Oƶ��_��f����vz�g�j���Ц�I,�:�H"8?�L�h�v���",n&��mT�bT7Ó����1��8vBsH��%�Rb�}��I7ߌL�����Gy<g��yFuMlڣQ�3�크�Bֶ¨�����s����^.�#\Fa�SU�|R���6�=��rH��F�pk�^�p8��(
�aAF�O��Y�~�-��2�FMM�ǘ��pT�?����+Y�0���+���c�t��5���j̽&9�����28��}����od�z��^T�;�`^2������lZ��4`�5<9	���:1�S#IM�
�Yj�g�uX1K�/�f\ҽ)Ȟ���_��h�,_?���� �/��=�ŏ�bq�.x��~�!��yӤmaU�XI�'U|��X�U��~\�1���[G���\�Er 7n��ء��CǼ=��)��'�g�������?��?2y!_�嬢��͉[hX���O�����)���=    r�O-���U㳥{�5�E	BB��d*�bH������ qv$�jCʱ:�O�Z�ʊ�P9T�����=k���X��A�r�������)(Y�4N3�O�%�;���	?��z�#���Jx<;z�k�i�K��pN.Q����'7�Q��^{RdW��5ç�Y�g�a^����co�n�F;�pn��mY�v"M��0.������(ܺ�Fkf3�z�<�W�٤�7уR玍%g��#d��8�>�"�7��?o�d���D<���MOop�	�U���OB&(�=5)j��X�yS��?R�"����u��#��Ԕk�KO~��m
=�{j2��R�S�Q�,e�X����v@ʵ���\_X��>M3dK���g��>d��ZQK_	�a;,��Л���]��!���T�sooi�4c��ߐZ�2*-Vn�j'ʶh����NFe�h>��y��`�:���;_̪���ٵmfc�a�|��xC����Mo��AB��t�u���?�t��f2H��j�ʃH���!ں�k��Xr�������Y����:���[&����^�v�7�̏ e/x�H�;R���S�
m�sX�5���CGםq�8��B�ѧ3��V<a��[>''��J�'«��"�*�M�<��̔!�Wz\��ϠcC ^�����K���\}�굑ѹz1{AOv�����w����E�Q:�7�J��������_'vy�r�9�(����L���4ي:a0�'pp=wcMZ�4�� �5I�\V����Ͽ�wF���yߺ@Q/T��s�^��a�V����䅜L����W�Q���yNn�������Hʄ�x3d�Y�z= ��9Ԡ��dR��u9���o�Az*'�iq�B�.M��g0����b"3�V��� ���j�J�E�������?�F"Ʌ�;h�����5��#%����Z�^���@�0�s��@�l���b�����I���-��d���v�k��ש��-��L';\��ut��� ӂ�eW�ņ/Υ=ճ� ��:��j���d"G;ބ�-�k��R!�I�b9B$?�j�(�c:��1��a��FQ-'Ze�XÕ�f��t�a�Ax�F`+8*��W�)N���$(��A�����2��䠖��o��1�4B���3���w�ap<^���kV;l�'o	���"� �U"�=��EE�`�X��:UH�>�t��������"��l'5/����ߜb������Khj�/�qם��gaӀsq2���خ��� �p��������֫���@v��]�pH�E]���_����!:H�;�9}�s��O�R��X��Jh�G��M�
���Y���0.��I��3적���r-RE E�Tr�������?�`�;avt�i�Rj��8A�*k�*Ł�N'7�Na��K7�M�Y�mºz��^��p�	�����Wi��@k���|�?�O��]AM�T3s��]��8:�g
Q"��ߝ.``��jp�"*<�L�quBL���.&����&�gu��}�0�a���P�U�[K`�C�zq�jQ�C��&�#rZ�d�";�ј���@��R5�9��0:�N����5u׭Oz�
�|�k&3+����.};�p&naҚތI��*Ox��'P ��M9�Y��|�j��va�����P� ��T�q�}���"�DGc�N1Ģ�%�P�C�E:��O�p�)�*�1�l=2K�L��q[nTG���TֳLu�g��s�_I�)�!*�����pe���8R�(b����p�$N��sN�AF�b�c�l��۪�� j�!����?W+�Պ�+�gtʵI�Z��`�㋴�UYI���ai�Z��UX޶��/�gC��ZZV�:~08V n���I�U�Oz�����-yi���a�%j]^�;��������k`��Rz����L+]a�\�������&�3�f����%��ga�)��S�r�n�Dv��`m�����'8�N�=��J^;���������]$
����dte�Krp���ʇ�����G��*y��k�p�,3mZt=� �
���c��7b2�x���M)k6�r����٬2g��D$#\Z�
���"Ā��B�gt�(�ґ�~�s� _��|C)�Ӝ͌]k5(�{w�`�NC������ U���>��:�.aN�u�3�o�E7羂Q~_/�����%6w򌿯t���&2��W����'zz�c�U��>�]���R=������2��0UC�d���,��M��7���%>�����m
���Y�؉�q�y~�Y��1B�1.g�2�8,���4�<! �[����U	���4J�/�ޒ�Zg�wHD9�@�y��{ތƄ,��>8��&���,Vcx�[��Y����!)�,t��VH ;M�Q�f^��Ь��E��|A�gFjRk��2��nhpH2��<���[���
�����R�3�
g�^�fpk�������ǉ-��������KNf���7��ЦPF���ܭͯG�	v}��X���]n-���M�D?NE���e=���k���e,m?�zw�ʀn��û���+t���uە�@&2̣}��S����Nr�~ i���P��0�wm����?�%��vå�F��N]|�nE�t0�vC��T,�Ee��8��M͊Q;#�G�>���hk%¬�N��c���LғFEM�	�.'���9�u!�wtoGa��"�����#͙kI,�S��3����������x��$��+9�B��*�h7��elDP�	?��i�3A�dSO��1�'�,&�z�ɽ1���v}��GOq�%<��]�jHx+]����^܃(��vK���ml"�e���1�F��N�y�&jx�[_F���k�h�أ���x��ҿ�_A�塋��kF��1�N�Y7�eU�t\�%Φ���ώtz�.Wtѳ���������BwD�A=;�q�d��5H�MӃl��{����e&��G���v��ˮ�����̵F�eR���@C�MG[���qC+�#ݾ�U��錱�����\�s
����5a;V����J\{3��9����V �_��b���a��9� �H�	�^�*����H-,��D�(-�e��*�g�-��ޕ*h�����cM�]���;�R�"˺!��`.@��G�*����#�i�[���2^�������^S e�9 �2Q"�l����p����}��}���E��BwQv���ķ�$��c�������0������e7OS�^e`�����˼�KU�c$�H��k�����_D�i�g�]YV��t�]?�G�������r�3����n>�<R]?w��Wy�����nk��W5�9������>Ώ9;=��e��&�v�����_l�v��I��S�k��HZ�qi@+�f71�$�a�({����� c*'�sKP8��p���¹��ღ��KB�q���\hR�Ӛ�``�狫�
�Lb*�[�V��,��`��!����L����΃-'�?�+��_%S�AԆǀ�|WcX�(�D����W�+��G���yߐ�� Q�7�����^I�)���N/�W������av���Q�	�#����g�y�N��M�N´+WJ'M3|�+pK|08�uM���y+�
a
��#%"�u�2w�,�*u�bjA5��`X��/e�~w��6����f���O���uA�3��F�/U��� ��Ɋ�#�2=m�fv�ΣR�t�Gű1V�y�	b����ܯ��5��S�������|�b�n����@M'jE�(}��L�W0�ny���z~�A���)�fK��m��)WXo(vG�;���nO��
���p�T�sg~j�S�������pTb{�S>��]N�NmH8_�uc�$2&UhwmW������8��ɍw����N{����%pO�6�b��Ҡ�X�n7H�(��~��y՞|Y��@��J��m����k���� ��}��N��[�]ئ:��;�)�+���    ��5'��-S�c�^�jG�}=K8~Q�noڦɞ8��I�S0w%Qj$D��4D�<�X��%C7K�عm�o��������c߉_Ц�����9=ӄ/:z����uEm�eY����6�b�];L�,��6��,�ʒ:[�%��Yq�ȵ`�na	�w�ܖ���O�Nh�J���'�Sߗ2I~^�t=���E�&��^�>,�V8ml�ы�Eہ텶-";\��5ң�{]�1�T�A�����ʛ$�m�S�׭B�)@A�pZ�����x(R��������-R��Gj�����+������k���:���>����S)S��ǹ-��p~�܎4�"/�ѥ�'(� �n(�d�E�`���Ѯ����ՠ�%�<���_��b�	���t�<R�i�[5i=�x���8�c��Ώ�ۑf�+m4�6����$��<ϽL}K����G��Xs��k;jX��5��$�H���m�S���(5d�خP�
Y�`�����<A�g����'���Lǝ�{r���/��i�*F%��[͹�D�x�!�	q)��-XaR�阮c,�_Ņ�B+����դ��rZkB>~!_�5�t�*q�R*sd2OE�gn��&�����#�v�����e�(�\��#�8r׭"gQ«MM���8]��f�������z:1s82k�����I�9�}� 7�Ni��$i��3VgR@ft���#���r�ƿȂi��=AW����G�ᷔ���ɋ�M�4NӮ�����Bύ|�%��(��zȇ��h����=�D	�;䑙�'Q�uBx�^��Ρ'��������X�t���xp/��O~�^���'�>�M������]W�\-s���`m:{%�t� !����xmW���%6���3���{�Ŧ�&Q�K��+�3��Z
�\y�c��kJ �=��-2������=�3+�Ijw�Q٢��E�+}���7�	l]�47��7��m��>?��d�nE/��P��$�	"�v�"ȍ�;���v,iZ(:�gV�J��J�O��R�YV��zr�s@P�)fy2� �ӧN�d6�$sE�/���JC%n�v4�҄�W�2����Q:�6�	�G��`` �mK#���Gsm�NopK�%� �]�al6�ճ� Y��"7r���.[�R?�xxB��K-�����DH@�f���N�) ǎo��ywxrڧ���%}��G����D&v��#ѕn(R��LU�>F̈!yF����p���BWd�i&��3�p���ˬҌ��5PH���I��c|�Y����l�Q�u>sd�&��{=ǳ�Ԗ�v�3�&w>�|�;H^:)$$!���/uj ?�s1՝Ԧ�c�Yr
�?ơ'���
�ЈMWS�?E:���9�A*'����#�@�8���S����Ő_��δ��Ay�El���y��Y&F�?�.�ͷW��l���c�V��!
-ؼcl��O(OF6D�A`:�$�7v��Y�Qh��f���ӿ�ͺ��1��;�Q^�qqz~���z}t�~���a��`:/yG�b�s�E' _,�}��WD<���;�����>���Ŗ�`�G�`����X����n��Z�˧�-�y����^��ɫ��	�a�É�X��&����(���ׁ��o�ei��J���<κv�d�N�Hʰ�Ŷ�KCV���h���)ete�{�f���Fq˶�z�Fn7+w:��"�?c���92�J�)�����>LN�LT>�4�5g�d���Z��6���,;B����]/�<@X��� I]����~SH��l�y7��P�Q*��I��W�,v�?�8<��^���Z���|�^��oM�
��'ò���Z9�bk�%�PT잸#*/1�f	r�5��h��w�_"�:��:�Z�)�����W&�Ǜ��"�7F��b��L����JNs�bX�,���="��]Ǐz�d\os��e+|81��븴���#���k���('jnK̬o�\����`�I����lF6�����4s�ܵ�Z�o��wAA���<��B��9S`��!�W��9����M��4p%�<��8lԤ�Pl�M�Ǖ9�0�PT�_���~/�E�N��S�6ÉĖpw]g׃W��c�j�t	��l�C\�2�x�����M�����Xz���������]=���E��r���l�n�q��Ib���ֵ	�k�P�S���~�kJ� O$nki��$\`wU����塓[�6v7���4�HRǲ�]/@P��wo���%��!g&TQE�j�_L��.HZž3�t����k\ˑ�7m\@ˑ�^�y͖��� � �=6>�P�+���^M�[���q#�p������5����F¥��-�Į���3�]���K̕�_��4+O�?����F��IF���гU����τ��M`�����2���81��Du#,��$�t���{����#j��@)�"� 4\X��n���:�E��,�%W!��)��D|a��bi��Q4�d��Hj^�~�N~빒�|����r:�4p��8�AҔoP)�"�-�=�@��)m�@�(�6����9�tR2k��}��Jc�E�GK~.J�Ͽ4���!%19�Rs��y[����z���l;�$�&S�A�	_Ei��,����c��(�=����K�i�a b`g"�m��ˉ�2r;U�)���p7��?�������-��1X����n�׶�Xo����z�o/6����f4�^s��Ο	癇�H���)���7A!�=릉o�,�T74O�z0Ȁ���T͙o���3�t߹�ur݈y}_�۱�"tVz�ۓ�������hD��=u�7�=��oO.OO�=C?�D�zl52ޡﮗ�^���إz\"	�+9��O���n6u���k�փxAh�j6d�߱*I�4���.�j�ݞ��'bfw&V�n�v����@f��$y�>�ғ���Rג�~����Y��Z~��׆����4F�Z���^�:/q�%\23�U0s>�Y5#�uM&�!�������aԭ��
�D�MU�e*w����B�43�sg9=e~p����1�u>��i��7�_��������z1ԋ�ӓ�U��I��M7h�l�C
p�o���,Y�9�Ph�t�n����75@�tX-A2ɶqэ8�YO׭�-2b�_�u-��Ei�*��+�r��4���=�F�jJ���`&j�̩_����r�{��s"�t��#�n+��?�r<hL�f��s<�y 49y>4����o�U)�G��b?�(}z�By�L2�|6���(��67J�AN�R�W�n/��'v�3��
�(H�a��$8���|�ZǾB��#;8_I��G�k�=���;��؂�=��<��ܟ�dk�Ss�����b2�S۳oe��WQ#����b��uq�!	���h�j8��{4B��([���j�KS��]Fk:��N���~��\�S��X�Ǉ;	"��d.y���h����'����l�V4C0?1�R���u6F��j���/�Q��8|b���ƤŘcE�ܢ�j�����������zŦ�u��T�XP�|M%p��ɼ\�U:��e_v�Dyeq�g��S#?+5bw\�-��9�ҵ�8�s(LQ$	�����r?��Ӕ}�p�i���HK|Ѐ�,�� �✛i�L�E�v�GB䆷E,A�,��@���^�s�F�]l;9R�fp�#�����^/7��y�KO5�Zҁ�1c��U>(��q��P��xc�/ c��8=?��1Zq���?$��l��>�A��a]�e��)]��Oh�%cq�����k�MՀ�F��(�^��N����vW�7�^"Ц��5�& �B�H7q��	� H��X�|�ha	̈���v��6�̩_c�~7Lr;q�$��7X��r�}���ѱ����?��rx��?Ǯ��?d
vu @�E��C����{�5�s�����5W!��O��N"r[�q���B4=U?�� Cݟ�����7ã�-Qs    u�I�N,�����M�$�7%I�����:=x�AH���p)^�ͤ��|�u㗄 �fp\���=�}�_⠉G}���r�_��yj���et�|,$p'�Lؖ��HV�{Q�<�C#����0l�/�F��1�oѮ�������H�^.�'�n�����3Ԓ0송!��*[�]J�.�0�$��Z2���L������[[�gsn�lέl޻7�gs~E�e��$��xK��k�x9��ʎ�[�rR�>b��l �����!�ΆlG�@$L���ۋ��u�{�qo/�2	n,��Ǎ��tî�+P�Г�]��U8.u�6P�����Ó_�S��Q��a(ɛ4<!$�^��zQ�H�o#n�3f[���!��[c�M����~s�}��~�WF��PҫOb��y_N��bl}&DϤ��t�Ռ���LU .��/�����G��7)�e��m�k�(�	�T�� 1_�DA�\C�vhO�M�p�;�l{��Ԅ23�F,D@�ѳ�qJ�f�����>j�J�iQ����SI�{VиM�YFm-�����|��l(یX�%��~��k�Ǉ�����y��Q����� Z�X@���E����ΞWE:jLǳ7 ���u1�\L���=fLڱ.��x1F⤝��lu��������Eu��ɓ���$1�_ d\�8�X�9dp˪��`|厕��	�+�����8Q�>Z��!t�D`s[��0\��5�)܍��C�hѽ����޻c�3sq�?:�3
1/;��l89s��n�qI�2�0[�m"��;|d��z�J�Y��ٵ���`��������0�n�&I��4�d��Z���ި�ݵ=0��m8첀ӷ"�M�/3�f7�����y�'�Ԇk���q�Q�&�p�������[5�0�1G
[Qwj�F�0����-�P\`��<Ǖ5ǖ���T5�`Za,���pJW��g�Ch��������k��xn��R��	�P|<�T�fk�n�5 ���0�[�F����5�Mpr�pV]��|j��g]P˙�ItB���A_i���֬��l��y��mi�h�B���Y5w`��R/�uP��ߜ9`�
�G�j9�`��jٔB����0�]|��Q�w�E�eԢq�X��E�=�P�����:G��	2�q�6K�I�U37��Gq��9�ʁ�2�
w]�'"?��
�%��S��R��m��He1H��8L�����+�2��bѩ&A��tԨ9�v�^�I���,h^_
�zaI�A��G|`$��x����%�K;�D�5_p �n�xN�d�#D�3Ѝ�,����Մ+Mpn�+�ز�``O��*0�*LS��bp��(3y?�]{�Z@���������7E⌎�������gd�&�1��l��k2sB/1���׶&�ِ��S��U%�֥�s7��g���_�S�a�4TZ������ �/���&�q �����s�nGs�|}t��9@ۊ�����e;���]G���������%�R<ft$jF��\�l���0�C/ȅ��G|�� ф�ӻ|wtqh���Z���HC�!����OA*�"HEDn'��fk����p�bbZ��Lu�$�i�A!|4��c<��\]aݠ������<
�$��UJwN!Rw��(���7�_�9E�Q�X��c���R��n%Cn^�1�,1c}�^��k�w-���Q:#��K	��йv���m��*��S{�-|����t	��q��\)�'}û$v�K�I)�ݴ��Rg�x��q�g��c����Qj/Z ��Xl��eCh{�W(�O�30�MB�5U�����G5_>�s�d�z�B�k����	TL�?b�֘�V-��S��d���]]H�݇�d]���������7�1��D�~L���χ�~;e&��t���v��K%��+,\i���tg���e-��'��׻��5�R|���t�P�
�OR����{̀��U�WH����#N!j��E���l �� �Μ!�Yٌ���쟿����P�i��'���#�N�9���3�����K�Ywߓ��RN2�<7��~y���7��R�xR�'�r�L����MWg�9ti��O� �<+J�ᜈ+�a�,���]���� ����<��V�����i�f봜�&/G�'��') ��u#���1�����Ld$�j�"��J�{�MO�c��~e�%��������5��@p���2�vRU�����N��5�����/%(^$��uI�\n˄��[A�G�	]$���}�q^��Pe��6T/�a��*��C.bе���|�{B5�+���ď�����M`Rbb
G��ӁJAc���-����a���ё�v�r�(��.���l5�U�����d�C�����c�qWr���scM�3
��Sjx�M��*�Z"�M3��h/E��a	D�#�͹j���e*яĕ�fv��c��"�����4TI;o�1_��)>e0W�����!#�=됱dÂ"/z%U94�`vn��y�*�N�HhTW�!7�Gx�#�$@��3������Y/�V�!	~����yyHzm��8�����]�ޙ}%�#�d�\Ia��2�("�q�����B���J��Nߝ����7��K�~gr�/�G��MD�@,:z�q,����[�L.��a0�@�"r�`�z̰-��ty�'��a�Ft�������e�$[�o\�k�eQG��W�k��D LTNZ�22y�˛e���Hڥ�ە�&�����v�b����Y���al�qĝ�:n�=�ٜ�y�
�0��0#w|�_��h]����D��r�Egy�-�fZ� ��i�N_��ot��X`�����]��l��T��'��k��-�@����E�����C^(e�,��5�a�"em���
��^섞����^E�oTE�k5�@9v7�D�n�e�W6�_N�l3Y��|q�d	�7��`А�@,���ԽD�GvB�!-4��8Βč���аn����C'ws����F��5��`%�6�(״8�/6S?M��V�QM�x��w��E����+|�-`N�D�ͷ�d�B���E�����bm�܅���w��q����Y�s�1��G v�(���B��{�"�p�&T���=)����a�D���X�Ē����T^�����ᑰw��-́	����r8vݘ��bi��!{/�;��f*��$���n�&c��C��j���D��,uuE-��1�V�ZŹd
\��I�)X@��k����ޝ��fm��kǺumcYL�5j� K�T6k��J}'Xݜ�%��n,������3vk�{q}�1��s��M������Q�0��Câ��`(=�nG�׋%��~*k��l��eے�IӤm<�e����e�W�]� ɳ��'26�m.<�\�9�� �k�b�۹�"�~b���7?o[���:���d��ݼs����JU!�b
��nz,���b�G5�IW~��� ��������FM�_kh\	ڨ��h������nܜ�|�fxY �X�!g"ǘ�NB�C���Di�aؿ��ѹ�-�ov��PC�iht��1^lh�f�);�x۵8��Ժ(ˏ��b����������otc��}�ߕ�L�H����|EYu��E����	I"Z�=��¸�;�P�M"�9i)��B�4fX���_,g��>V)Haj�!I�5� �����^�P+xe�^���D�� �u�9�3pK�=w�7^���D��!i>�p�X��Nr���Q.k4�j�5;��Z�r_�.�"��k::z@}�RNٗ"�X ��\��6ͺk�:Q/�}�u�|����"#%�-y����Tt��b��Kc*"�� �&��P��'�V�[�b�8�� РCZ��L��#�$I�T����uE�	����,]���٠�|/�-'�}"���\��Iꫮ�:a��2M�|�U��6���~�j{ma	���Ld�;!�#3%ϑn7Md�"��q�۱2�� �[��r�%
l
\{޻    F(��k�|_���G��xja`�Ә�ڈj<��T�g�Q��YQ�ڰ�pTh3�{I+�t_�W11�5CI)�1>�?���D&����]�zQ��A��ɢ�$L��85d%���=�z��֨��jQ;(�!� �+q�u���P�o�XM�?�Yb��0�l`K�ɚ���?P�^ ��1	e_�$��V"��t�B�7RB�A9��Bp:�쯨��Y)*�l�xʠ|Q�hP����U��J6��T�[=.�rZ*��d�9Kt��w�G��(��&��'��=����,��P�1|y���r���!�Ӿ��|��:����b�׳\�!��>^ՙ"=�f���$ZN2Bu�6zJ�il����8�Fs<w#�1��wi��k(���а�;�X��0l�<�*h���H���;�߀>}��:���#�Nc&C5yŀ��n��"�ț
�7�i����W	�RY+
�{�cJ�����尡�,x`�-��Y+Q����{���s/L6o�i�9��{�N�5�WޞP��(����ߙj.[�L��W&��6<S^����F .sL���.D�?�1}����z������Q0��?E�.��\�4E|��D1,�4u��2d��tQ��lj�O[Y8�Wj#�J��f�^BZo��z�{N�y�x�uBN%"��<���	�]'Ƀ\ύQ�w�(��p �^s�{�'��#}���T�)�l�zLт����|�9tv:!�{������6���;����%?���:�����p���q>�P���Xp[խ/�@h,3���S�gpqW��I@o�`<�n��D�&r�ݹb@-!P4��o&����LY���!]����w�f~p�W�%O? ��G$bg����@���W]j�ٵNf��H�u;��~v)'IY~|���f���;��M���ܞc1����t���'O���������u4/8a~�J- :��;4����_؄�t�n;�2jI�M��qgYi�po5��[�hw{�X�$c�������G�y����.���y��n�b��!�o�����}P9�[��º@̋uA�h��-WU��Z�q��_�(!f8:ۡ�����1r��TS�^TS|^d��A�r���"���4	b��J�@C�N���sc6����XU\�tO8h1g�#�bRf7-���w)�n�"~*h����x��3ʱOr{{��^�J���}�Rd4wdq|�}�*F傃� ��$��.����o�
ʛ��h' �~���t���z ����7�.lF�y��inL�I���g�͍�ݴ��{�˷$fۿ�;����5�۷�>�-f�/���W`�#0' �&;�i�5�3ܸ�����1AG)3;�?K� MF;c��݉2���%99��4�iZ��;_�(;���I&�$�^j����k7u��s_4
�S��<��F"{5�޶�_8�7��-6Ѫ{o���`�����	ue���5|M����L����A�y�&	�\JV%�6T�m��lP`�SM��]���:(���y�TA��)b
0/	�-!v䥜*F07W:��AMV�6�&�0$�|&oJ��H���ܧYU��NAav47��x:�=D�e�= �	�O��Of�Os���S=�b�l)�rl��<W�"�7^z+b��bTX�$^�����E�n���wG���N��[Ǉ'���F��0�Z��t� )%�˘�ГxS�䧂H.�h/�^���+k�D!���耡>�<��cIE*��$�����D$��ڄ�Z�i@�LZ�D�XCw
��B���;*�Z}{�V�K�W�b:2j!҆Z��g�I�l�z5�ׁ/�tI+��F�Z_!�
VOc����b%���L��k�G~�?:���o��� ��b���m��Z��H���t�b��{Q�o���\W�8��S���t.yp�&
�ѭ.�j*�׳
}�����Og�B���y��u���?�\��E;.iCj�@�D�)X,����(�' �DE&h|j��H*X�j��9��0���'�����j�d�A�rl�#xTl�
� t�s.��l$	O���ʝ#�(�+�5m�@�*| ��o'��^��N�I7kʊ�w���C�):-,��oT��s\ga�L��<"'t�0v�Z���f����Oe.Z�~s��q<�hǳ��a��X���d�;�#n��w>�0�\rO.r��е���=�hM�-��W����M��� ���C9��,D�zV�ld��5=�P��}�<�X����_G�a��Do9mLw�W;��y%��|&���#~�d��rT͆Ԯ�;���Z����D�f���@�rv���f��`A�|�l@�!�F9JQGu3_{E�+�t�<J���� >_�g!���L1�8�GT4PyF4�b �?R�5n� @<8EȪ�m���	\��c�H�[�@��@���cD&�hIG�CM���g�s��w񅑑�d�o�j�y+�n��1w���Ꮏ&f�:�NO�X3��Y���^����غ�C`A�������0ڝ��ȧR5Zoio)�eL�p-�g�:���c�l��٤�Mg�lǰ�״@b��X'��(���Vc�8UD辝�]���Δxq�V
'�k�B�e�g`���eL��M��N�SahJ"\0����)u�ހ�P�\RB��-�����A�i��3�Y��ID/���L���C<���h��B���D���6�=e�9�s4
S���I��tR$���"�a�l���=�;�@��mE��~����{����~�6��-zm~��3BP}�إ�S��>x��*�C+x�����3���������j_src�93�4��`���c���M	4[+�"���/,�����]Xy�&�G�Fأ��pd�A½��i^��z�I	�=ئT�_��\wXU��u9����x.��P������Y�e�if\.�R�Ϥ#W`~1��18�a�M?��zV�;�^W��1�fTf�m��^��g�M��z�T-ļ��c5�__\@4M���K�	�{tԙ&��*{�N͜�o����pw@�I1	����/�T��t񌫌��&�ۛ_����7��ӑ��z���C#GMFJ���1G,�p����o,p���CBZ�i?P�T�7�[�+:��ߥLeQu�$��� ֯<�s�8��z����j�8E�et*�O+�ߧ6��s�b�{h�ͫ�}\�Z��L�#V�ܶ�T��(���0��[�m�h"MJ���y���)���S�@~68�ԩ= �y��A�@�BDx1��؃��)����ح�2q)�v8�W]����0��Q3�w=�#ڡ�^����ίr_��/��Ln:��	�Í�n3��$�W%������k�Y�	���GX�q;�5��u�3��O����Kw�.���j�T(�4:��A3����'�E���m1�2��հ$�2͜S,Α[;R�d|o����n���e���n����`">�[�1�;��;�@��ڿ����������H��2�!��,g��L�"�n��su�4��Ř��k]p;V�z��ٍ7�?�B�d�e\��iN�%��S�� ݜ(+��D�m����TA���Ѿ���m�A����	�FXz #My-D,��8�gJfw�Q����݁�G�@}]��;@_��^hTvA^�q�g�W�C�Q�84F�Mf���ȍ��5���4f@h��k��㴕�O�ǉH��:�f6.��[O���Vʑ�3z��4���<'T���`V�x��h}T8z}��T`����!)߫��+�+�\��N ��g���q�����XGl����Y��A�sw��D5����>��y��`�:���~x��r��C��w�P�vm����/��.n�Ǹ%M����~`7�i������K��7���Q��k~�5R}�{���79o�z�u�aO"�����r:�8�� Hk��3 ?  ��^�)|��Rz7��(S_�KġN�Y~�05���T���q���q�&w�ʐ-$� q���ҋ�D]P�PkM��č�0|�y����,��v/��S�la	��fJف��]Oź���iJ��(S셃G�5A$=�
�,>ɃY!Zg�'A��J���CY�ߚ�9���G���E��]i��F��^7��;�����Z�+?��λ�D��َe�ݒ�=YFl��ýyo8�25<�6P��mLk�X� ��z���'�!iٱ��&s֫��
��OL��ƝEP:�b-��נF˛���*��bdWz�"�(�+��P�E�^��תX��*b�,k��\J7�vۋ�������ɾu��ںx���%Y�:��M+#��6v� -�Ꞛmy��!��_r�0��"��H!a�A'2�,y��$��f^G������6�^�h�}�����QQ�gC��ů�J�Α���p�=F�28c�O����֬d5� M��S�m��ٛ�rc���`Ƣ}��%�����D��&Z��(+�&	�(U�	�k�
�7�Z��t��\�[$��r�B�:>�|_ʫ����9.������u~z�o�Q/������A\�m0U��w ��39�g��]SP}����5���,��-O��=���Hc�&/��_1�g�Q��s�5h����j�zr��fR��6���k5��Q5-�����xh +��ym�J �����}����Ma=�?>=�.���%6b�]@2;��!�y]����;��@�� ʩ�Ӌm؊خ����@lÆ�r#
l�:;=�?8��/�\��-W�
o&2�����M�)8g^h���p�n�H7�O>*��m'��t�-�r��H�*J� h��g	o׏w!f�A0"�ka���� ��t�m3�,̂n�4r;U�?Հ�<NS?�mTB3�5N2�@I K
���y����<��ǎ��ɻK|�'>�Q���H����!^(|)e�u����_�>����������n�=}��	�9e�u1�OߘHs�5�rO����
��:��E�~O�
�D���Nces���1�cA"��/�eB[��!�pw :L����1�X=Ձ!�5\=���v^20�� ���K�.A�d"��~����WN��-7Ղ���u�zS�I��od�#ُ\�e�"��?�C}���?v��T�;��+��vh�����T��W����� #$=Q8��~��D��v�q]^v^u׫��RB_��"���0�wK�>�ЃE���QB?<>;=��|��.����O�#��t�*��A?�������A��      �      x�Խˎ�8�-8����w�4Ҍ��Y�;8�|~A�?z�<�RD.�wǮ<�:U�k[�/'�E{��cnޖz���[���̈�8.��0U�}��y�J.�1����?SK=���f�h`)=��H�t*~D�\h���o�c�q�!38gN����}�=����}��܍����d�%��<��:�c8��N�8s��f�L�����=9�6�u]�*��앬Or�xc�L��V&��|�(����IO��z����k�I�1|�ѭ��e��x���' ����`q��\�n#G22�&~�Q	gZ��Z�ߏ7�f�e�݌�"��9��]��&�`�l���Q��|�������a�nٳ(��%�&�2�U�_Iq��$`��1~����4��ņ���|�\ʨ�UZ����-��>�5/��3��_ى�ς�i� �z����۰>�>��G�1-'����&��U��Oj!|<�Z�w1�IATz߃F��;��'4�I5�IZ��nU\)����J!=3�}͵-��˧��qk%�dc���k>()z�WF���k��P�#e=0P��������O
J9�=�_��/���h��ю�$��hn�|j�|*UN�Qq�eb�ς{)7"+��t��(�#�;C�SF����s0LE?^L�_
dܺ�k2��8)(xk��P��}�Z��od�}�|x�;1��S�~1��c/q!+���얘#�G��p���H������7X�SaMKXu�N�>F�>&�^�K��TR�y*د_U�b%������G0�`��E�^1G�vŁ��y�z���/@Ń��C������7,}�t��;��>����D/鸩�I�l�i&�B�z���0�U\'����A��°�d�:�=��q�W���椺¥@hx�2�挺�[��`�t%������z[:�J��w�]���_1gWb�����Щ�x�e�dA�5U.fj�M%;����}�z��h5+�E'݉�=�(�����1/!
�h4��p�O
�?�*`48�G��r��ҭ�z�����[�M�lJ���z�4n��qsC���c4X&�,��=�����;�%��p>U:�*����$�𞮋�-"�Q}U�>9H�Ŕ���IA�^�Er�}�7��D�>\a�9,��h�t���"fJه��7>9��yg�Ⱦ��(�o G�T;�WW�iq}�����D���f%����SqTcoR�-pg឵IAD�T��a9J>׿3�d.2�w�,(8��N�L�����5	����}"f� ���K�_%��L�c4�k��#��$����o"f��x@�>�i��9�s�^�'53��/ᵦj끸��x��4x��hOrs��ؽh���֓i�R7O�Sj�	�F�԰�!$�`����usx��?���d#�-F^&��P�l"0��-T	���1*r�Q=�쌸���D̸�U�:�X��R�<w��IA���u�5�Vc�Fw��^�`��YF�"�H�eD*¯":߸X�bN��bMnrBV|O�"��F�o"'����=�dȝdt'b��=�E���d;­�F1�aL��f
���e�+��
��/1J�~�����ϝ�o"�j�˵/��	��ҍJ�#��'%S����2;�r�-�I69?I�$�r��c,㜇?������WPΚGX�}	����+�s�,��us2`�����5d��ɈBm)M&
fr�|w�m=��>Fy돞�cq�S����2�1��TS}"+�j�����6yR<F��R��u���7�Qs��B	:h�S�'݉��T8�C���Ϝ5���Vb�!��)���A8�.35�`�uF	���?I����Pi.9c:"��<�m�as�/�?='7�P@F#~C�|�aBH���u3w&���>��y��)X�na����P�7P�`���O}�e���&���[\Yx��w��"�BbW��|r��
�[���vR�(�H�2vٶ�����H޹'i)�z�/�������ͭ�
ڲ
^����o���qi==ӡi��x�?,�esvÅ���@��Qh��mq�'y��5h��	�m��R���'iq8-���,���"�ۘ�����k~*��E�l3�V�$���9}�H���*r]Ĭ�V�Ѽsӂ>x���̤�nl܃���dm�}�e���/�nN��LDy���$b����<�Z�m0:=U�f�?
����D�;�|��@�F�)^����<v:�c����yc�B����ߌ�3�^��	 ��=�K�<@Ɂ
���zs��?�{�������I���N�3Y�D�D�jC�qi��y���F�_�.�%zԯ���ظ g݊�Y�Ŝӏ��V"H9�	p�&�S�b"��Xæ��o:�1�j�)�dt'b�{B^��Y���@M>�\�IAP0~J#Y�	X���^2�Gg��N����g4:	 �$�;������R܃�0=v�����*F���&g�;��V�<4GZ.ʚ�k!aq��Q�IuRP�� o@A��w5�* *��TB_��Z�P��>^c4m3%�z�Kx�?]Du���P#�k4qC� "�0�|t�q�/���	Zj�f-���\��Hj��L
���J��n��x�}��2"�����O2�1�N�l5�
��a��>~m�?B���Dl+��#���1jw����p|>�����o"�R�>�'�r/��au�~R�R�T�Y��������W���0ֺ��nE�:׳>��V���
�j���IA�#uB��ٵ<xh�ńl�?I+��7
QTby�$7�mj�5��}�i=m-m�nxy�t$�s�S��Q�t]�\c�*||�5��\�e'>� 1M ��_�d�wqP���Z��jՒ�}��p�D��'���s_��fVI���Io3��IA�.�n@n�X����ޙ*��+I�.8gO<4�$b����Zw�ZnZ���@.StI&�\l� �Z���<4y�ʨM���=��N��=�1_�>��ߖ��ùIA}iقz�%"�߿r�we�'蠤����et'b.�(˅^�{xF"�,ppi(B��=���a���K���������;�N1�M�9�k~"++Y�\�)�L�����aI�l4�y�c胎��H">Q8��V����ҫ{"�e�s�b0�34-%��k�$9����J��:��;���?��N�L#DM�*Y��5p=5>b��N
R_l�%�Q^E�
���:�:���SI��"�l����xO_5�u)ħ`�m$<)����-�61p��
����&���F2���9���Y���L]����9i��>�"��8~
*��T�z�p$U��[�3-����=��E&f�.b��$�c���/e�A���O
���=� ������a�\�Bt�;��T�M�-�r�1fY�Z�C5�V�G��5���������y�l�D��J�������Ư�Ц-�I���_�kGKE0��N��k����-��k�/���"f�.�^"�Y�;$�2Q�>���8)�s�=�k��KB�u`H���Y��Ϳ[���ȅp�F�	�7lLR7gz��⸌�������}�7P*�dc9�9q����H��o��`������ߵ5�;�6k2G��4���̆�������¼�"f1�	�W7ӃHp�RP�0)(/�[P�hz�m�AFj����'i��� M~w&���l����4�����>n��[�Y�v�G\n��;�!=�\���Q[H�q9Y��nIjkeXn�kj�&�n�-h��Ӕ�S�8N��Ҕ˗�����k���k�:6�*{���JdUMA�'tJ�Лo�t�M�g�̑c_����4���֗��;8R�����a�p��%�[P�С\L��Wb�@b��T'�����Od�~1�V�	
��|M�ݪ� ��֑⤠��[����u1�W%�/��i8�������D�8y"->3Z��Z�Sꈗ 
-��fbJ�%�L�.2��G�wW�Od�~1w    �a$��Ixu�rw�xɃ-�~�IA�������H�KOb��Y���t̬�>�x�:@����'3���kѓ��&.����%_���	��4mAF�I���P��%�W�������DWE�9���G{@?�y�	�IgUWҤ���7P)�GI�5�6�wFL�|���Pׇ�v%��~1�VY�����v��(Ҝ�V��2����lA��E�/|=,S�����q����X��Z�_�G�	���Jz�|�y�8�A��m�����ԛ�儑7�X��f^,�>ڥ�/�)h����б4&�F�;óbBq�@��^�2�#��(�Y�DM�Fz�һt��.�C�ì�9����$b���٘�:�0�N��ת��R�O��A�B���H:0����L�9��:��2k����	���usn�t� �Z�njj�;�T-�Q�J�U���Ӂ��mu^�����(~���U3�_dt[O���1�?K�N_ cqF<5�;:�|��%XXZb��"�Ȧ�������p�?�o� Zk���s�[�y������?�*>\�Mk�aCZK�aA�͏��Y�X^��{��ڤӭ���L}�O"fS��D�=��$�-���$0a�M
�s�����맰��2Xm���KK#G3<���uG�ұ�õ�ޝ�=�E�$�X��5�oZo�Z�V�L
ҿ���#pCE�O��K�P]�����Sgp/a�^4ۘ��٢K:�-#�2�	 3��Qw �҂�?���][$���<�G'�u�uu�,Z����1kX�Z��dM
��q�6�Qq��B(J�]�x�5X��t���'s�<���s�V���<�jq�L-yR��Z��!�nM�!�g�B�)�!���0���C���7�/�l��q����مA�k�'�5{�*�㉁#⌗<)HYۃ��Or/���q�.$����זg���$b���U�k�yMM�'�T��'��&���.[P�2SSLr ��>�
�I%������q~�%��D��ְ�#�迁��F6��y�o����²}>�����O��制������xޢ>>�(��Oбǋ�~1���LE���$�^��?@,�"1E��][=�X	8�R�sp^!����h\��W��/�x ��Ο�^#�k��[n���7t��e����{㺈9:�0�Y�y���|��i�Ҥ��4TlAfX�z"���c��D��_Ҋǭ6�ц��^<�~��rc�
8(���$.�+r%�;:�m�{ N��H�E�ɸh��>�_/��|����@�s�.��$rdZ&��6�2�T��t���^�p�Q�4S�֎��ܜ�3Ւ�x}|�ؓ-Ʉ�hRI�=H�_��ӟђ��-i�ZD��ǃ�E���(-�_��p�J����<&�m݂d�'��T��Xoc�J\�X/�!c�x(����W�S��w�!�f�}l���R����-!�jQ��?s
�Ow����}�È�ƚ��i�x�jh[���I6�IA�xZ�J�q���,T���E�Svt�����J��G�����A6	w������Y��.�����M��o�1p'��8AP���aꁎ��%O��t:{����M�8�=�QĜ��)�e�����)I�ʶ{;)H��A���C8k�ԙ�-���+pM�D�;BO����E�T"l�����֒���TK��{����=�PΣ��s9pH�C���%~��MAcρ�нN�x��B��A�e
f�D�؏"f�i���|��*j�si��U�i�2.������1^�s�pL�y��c�tF��c_5>�Z��tx^R��,O$�(b.6T�՜�:��k�ǫ��rm}R/�{[P:� u��\R���gi)f�	.}�B������(�C��ָ�g��s�雈��&"�[ߕM��,h6�R(�d�-��o`�J���#��J���g}��� ����	s1�դo��Mq��R�"���֧IA��o 6�n��t ��.\��hź����xg[�ƽ:P#m�����OZ
_�� �,�b�0p�}�6��� üz]�@��Ks|-븃HᦏK���;ߵ ����f�J���?��mo/{~�U5f�N�<r�]�\��SMX�2����?la�Z3���$F��2?s����̅�§A�F:�PW_�7��g���.�2���Pÿ����h��5�"���rlAL-@���D_��&��Έ�r���$�;t�������������!��K)�w%�IA&j�y�h8�qf�g���h鎦S�}1�b�'�:��~��FE�	Y�� �:yu�mMp�SO���Z+�Q���͟�l'bYf6�����4Fp�;��o�S 2U��� ?�^xc�g�7�dmm��Lz��I2B�"�1'��陎���.�^D&�� vr�y��M��y�=������7r�����R��D-�\Blkz2�M
JMϷ�@Y\^�#��sv�n�^,�{��=&]1ӛ�v�i���:�.KQj��"�H���A}�4�_���3�y{�3��=�^��'��O"f��/s4[^%�\;2)�X��IAp��;~J�����g"�8ә.:I�8H:a~�iR�?�w�~����݂K��-h�T�Q�v����)��g8K��X�>��������"��m^�7Z]>�c�s�S��k���ۃD8�l(�?u7/�3Z��8�-�d�	𓈹�L#��5R�1k�G�b���+��=�;�v�t�����g^k|t�w��;�Ͼ���;�⟍u�������Qr^����m3{P,��i��T��B��?��s�A��1�^].�
��rM��|�E���1)(=g[�'r8e%�p�Z�}�G6lS�v=�X���j�p�W�ϝӗḘ3H�}�U�ۿlR�Ӗ'5��=�Āz�a*�lH~۠P����ϕ}�]�|�gxZK�e3�lGכIk|�tcҦm�㤠n��`jB�4ī\����ok�^�����k��qh��=R ��"f�O���1_d�dxI3%_4ǘ]�{P(���80R�}�µ
W)��n��g)݊�[�6�6h��c����enŲI��`1������*0�@��v� H��V[����5֗J/����SU�_|@���ƿ�l޾.bN��\����@`D]zN�V_����z��4$�1(�Ͻol��8H�%������#|J�m�g�˜*P!����"欥�&,|�}�.�Ík/щ�����7�"C������zt3RD���۳��%[^R�4ll5�-�����w{�L�.b(~)�������CB �cqnR\���p��s��@����t��A�(mV�Ͽev�sFX���ڎ���K��J_1јO�kz��M%ݐ�6U+,iRP��ݴɆ�WT#����\5�iH	���������1V�~곈o�
�Z��'5����i)�w)0�o\���������/g���
Z���"f��vf�w�SD3�&\S�	�lb׫*�-�8�pU`�}F)lk��腎G��3,ᄙ�I������F?E$(F�	`�3�u��ә̽�=�9��ȿ��/�ZQ�DG�e��a<yD��$ŅE��v�8�p��S��:)�a߃��L��j��D�>y���.�M��(��hQ�Y��?�ec����|Z�T�hs݃p4[\L?��㝌�Z��L�h���Qg	�H�G	��&ȇ[?\ᨕ��;�����y*8��Lٿ0S�|ޠi�{
�*��W	3Q�!�D=2t'�%��9`D��=H7:an�������d�j��ws��Q��'� ���࠻h]� 2�k���`������39tD��|}���쇷w�g1�(@�I�ܣ�e� ��зx�,�%�hO
*U�g� �Mvx��g��{�|`�٥&)�g9ۊ��ᢳƪ3�܍qT��9�zM
��2{���N�����3�59�~I�z�`=Q�����Ã�)GJǚ��퇊����� 
��A���5��?T�v���u��l�    ͉���D�11�e�(�F�x����mRtZރ5^�����,^(@
ˮ ��������"f� ���5�ѫ�x��ƴIAT�߃ZI�ժӞ7��s��<V��IF�!Fɦ�Fq��������.�����?e���UwWDNg_3�RjI��\U��i����X���du�N�O}��5 w(���'�hV�<,t �w�.��y�*a6�Bl9.c��_�Y�
�dF�`kR��K�`�:�ܗL�mcx��]��/	�[)��~���%_D?�
^?/Cp�ߢPԖ��ϻT�ڠ+ �#)p]�ܹN���?m�ڨ9zv%¤2M
�m����R�M7)�?"��������u�.ݡ� �.b6�|h���g(���!:��P�� �� _-gF����$HX��{`l��J�TUc�a���J�w#6�������*��}��l�u
��S�tW6�CK}�]���z����:DC�y;��ͩN
*���Z*q����7�2�z�t���[�Z2sY��\�3`G;ڬ-��,�1)���A
�-�/ޖ���B�r�tھs:��,g[s2K�^��5�ߧDJ.tm��d���[��(������oL���J^�/��$~�0{���h�8����(ec�I��IA��{�஄੅#s���g�Ҕ��+Ȳ���Xy]�s5�.zh%+�4n�5����� ���N>Z�S���T����Ղ1�ǎ��f�0�������u\K$�u]_����܂�4t<^��)��QC"ժ}O�1�P�����h�۹�I�!
��ڵ�u[�@������l��w
�%V�.b�qs����un7�֋����@q,뇶�D������N�.�9V|��a����l��.b�T{n�7V"N�m����&_&�f��H_�3�v������$þ�=�$�ٝ#S������A��h2���;���!Pr.��eCG��D��0�H�]�0g1���t��@�<��+s]�/��AF�zXr:~�7���,��X��i�&ɧs�~1'kb6�j���̌�Zt�n�� Y����Rb)��=���45����o�t��>^������`|c�����"f'm��?���	���O,z򺈹�d{���[iOC^�K]˧l�Tu2��hޓ�����-t���Csl������.�sW@��AJ��6�!4�K0)���D�[J�Vwd"��~���-t����ᯝx�I�,.qH�A֚�7��z1-'�fZA:�q*��R�1���+^�t$Mݳ�Wp"����z�8�)iu�8�#:53X꓂�܃�r�mQ>2���M�W��s~�1��M<�4���قYx��_�CQ�� �<��Xr߃F� 6Q5��B�7�Qwjm�3QK�u����D��P9U�k������L	�c�>L
�)�=�Jκ]'�#U��ct�����.LJ��?��M�a�A�Wi��W�{L����� ���(g�Eqi[��p-]��?��[�� �C}u���^7\��Ⱥ��ʀ��jo��ҞK�&�yݿ�Yz}]�\����Ӕu>� ��?+E��&u�����K2}�_CNq���OM�Ջψ:E^�`��,�Gqf���A��K�WE�De�YS;��I���c(�U�P^����z)-Gx@a|�� ��-�p��[�3��m����I;t����6��"f�֦S���c��2Z��w��h������AALj��K�zz�Z���pP�������3�s4�us��i����-#�0��-��������AU��p�$��;�#O-�{��[}�S�m�w3��u�|0k�	����Μ�0=�2)�ك�T_���4�l@R>�1O]N�h�ph\\Ko��=[:M.t|�^1#*	NӾ����o�k+
�:)�Tg� ��p�Zq�@����� ت�ORC�g��3)j�~C�2B��6�5�4�]Ã�j��kg�s�w�;�Mb+�����ⰭR��#�c�ÕY���{f��5�8���IĬ�cW���:������A;�eR��o *�JI�'������)��<�D}U ,��IČ�J�Ĭd�6��-�4�����~b2�Nc�("���;����	�l�%��A�#��k��v^�%|�:�3�����Z�[Rs�+��{��� 1	1.�c��es�ܒy&+�`�V�L���w{h�p�mn��>\e������e	��֦�������|B%����줠��{;P��j`�7���.?��M��F:�I�<z�9�:v]ԝ<�w�64X	���;��TF�B�	:�W<�paPG\ܞ�U4�7tN�~1#�b��jѸr���[a�5,cWt
#���A�wZ�a8/2�I�Zì�p��'s�[(��Z�Ї����2�D��IA��7P!k�O��Y���I�ǳ�xi_:z�݉q1?��� -���uɽ�PƒJ��.�P��=H�@Q��[ h���.iʤ�2]����j��f"�M'���vy�J��Q���T�L�K�e���HYk���Hֲ"/�M���9�S~qDT�n!�3mt�ڗ���!� �fǆ��m�l��@��"t�N1��Y�ֆ�җ�?�K��;���D>�.��F�U>�.B7�?��V�,5ky�r�֌��6F��|��
վ�719!&s�@���g��t�[x�}�.b�ٰ��E�~M�1�i(�ILu��@l݃uWS�n�;m҅�q��
jPb����us�Z��'�J�V�m��k<)�li_@AB�܌|��1�W�L:���a{�/�.b�6@S�3�:D�(�nR�$vRP�Z$���9e���k.�,%k�Bpgn�ws��lZX��ڻ*��v3�$�4��Xb�-���X�L�|���s�8^:݉�Z��gO�NĬ���y�V9A=�H'�H�ܗ�,u�%�����8�Q��K�В����ºp*��.b�qr��+��j��ԓ�G�iRP���Lg�������8����7?ѡ���H麈Yu���D�ӄK�J�V;3)���{�'M��(�Ѣoc4^哖���Fvg�܊�ĥE����Φ>�p�9������I�3����:�ۑ{�UrqhB�<v�\17c�g=z_H[�7��>rbh�H��AEg.c�?�7R��F^�}�C<@�Z4�r�@��/GQ���Nw��[��"fg�),�~u��p�$���;)(7� ҕɳ�;�F��PX������� ����I����<��+'�N��A1Z-�铂��=�Q�>8����-��Ց�0(V�f�I��.�,9?S�����n��� ���=(9�#W���������Owfb91��'��ǅ��&�)�&��Xʓ�y�=(K�֑��������aN��x캸.b�Sn�H�ZLH��PӪN�W� z܃��í�f�_%�l.���֠5�? �ha�I��B����&�_J��梞�m�~R�˫�Դ��ܮ#�?+\=�w�U��p�Q����&�8����6��e�5��d��j���ڟ'��e���t����u3��7u��?K�����'�֎R�����g���s(>y����K�����8I'��$b��¾��ϯ�e��T���[�aR��Z�U�Βt#S8`����5���/���ph������k�0��;�>l@'g��#3�z��
b]����`A�8���hд�A-߄�Cp\��$q|���~�U�j��RY_����ձڂtgi�6Р�;�.\����'w�&[I��"`��dY�Z�����^S����)�֒�&�-(�,��E��ޘ���n�7�CZү��������><i�n������M�� � �Z�!|��E1�?@����nJ�1�С/l��$�t���O"f(�>��2Zҍ�C��9�1ϣ�!q��蚥�R8�ؿ/���M_d�]��c?�usO���'����(jl|���F�=(S#�hS;2*�}nӅ*�Aw.Y����譟Ḍ�F�,\�AP�ڤ���SDH~R<Ҿ%	�+�_����r@��m'�)�'��?��    �k�]]�����HY������ ��n[���%�~Yl��]�E���ڼ�����R������IA���9]668&�d������_?�R�!˶%���E�Ttj\�PU9�p:C�6�VƤ xG�$yHD��@��_�g� ��j��Ẉ9��hH����
�歊�b��� ��GU�{n�����e>�2�<��9��������+-��JU�=�bi�Bqf8����� ��,LP:G���>������&��q��\�ZKh�N�.�ÆS�'Y�x*�-/�꡺п�O�y2�N�1�J���@�kV�0iv�ΆSΓ�R���-(�n�N�����Vu�{�Uؚ�c���!�c��e	��M�lu�Y�,����zk
#�� �}����0��O3ޒ�Ǩ��/�)M�cB�u��7M����nWn��T�����=[а&w���8M�s����������I��]�j��QGW�#>�GB�	P���A"94�l���d�8�}�t���'	�1Ҝh�f�>cC7�ƵVU7*Ȁ�=(R�,FtA�oD�]R(�~�AN�G�?�O��(bv0�:C���n"����0 ��q��AQ)�����JNp�"�tЇ�������(b�:�u��d�/y���U?�N��p���s�zF��G��7y	�L>��A�B>g俉�s�H��k�6�BA�Uo��UL��3�=�T2Q�E�����/r�������������2\]hȭ�B4S]
�.��&5��{��N�����z���JF��"�wf{���G��b W>��1DX�ѸI�)�2)H�7��2v�����Qs��I�H�T�t�a���&b�Oҳ��|Q�Et����"��IA���TTi�ā���r>�g�u�O�tY��o�3��<�$%A&�ˤ �j�� !�D	���W^;���O2�zh��l>�O�;��r��Of���nY}��|֖�-J�ZͶ�^��:�>-˹�]���\��M�\�evj��\�g�(���,�T�~q)� 0���Ͽ�p���tO^��E�D�8��FY�Z�u�G"�Iw��Ǥ��k�w :{�_U�"�]5F����>$>^b����U��z)�a�iY5Z�+7� �Ҽ"�����OWOh��ݭ>H�U�;3>8�v\E$mچ���:�z?)a�7PF$�t`y>R��X��Z�������1�$�>˯�͎? �cȺ��N
jƘ=�������Bt������1WS�7f��k��� ��?�L
r&�=(/>6O����7��^J�hUB��.g�����"f�C{&4�l�v;���m���d��Q���!��*��T�	�qw|F��"fgK��-�o}�0L��z�e��%-�IP.�p�K:�G�7�3}��t�s����%�?�����-����8}M"\v\sD�p�Ҥ ������ZkK��4S0r%�d��r����$�ws��ƛgF���0�3��	�й�=��e]j9`���赬��m�G�p O�1�j�wY�3�
���Rӝ���IA�F���5qD�Gh<?���������s��u�k6�\�'��2��|���a�D ���n@���#���mP��z'�pK�T��c�.b�ӭ8>�m�U�>�j��<)ȷǝQq�$,p�ߨEϯ+�d#jͱ�똎�S�Q�l�:Œ��k��b�ar���@�� �u��4���tgG<P5�:$�⠯ޜ��M��k�
�X�s�qr>��Y�QN��}1�nKO�'�+��
)�� ˤ�ZS܃�Zyg�����Gh<�!�`#����F2�<�o"�E�ց�_��\��ϋiR����A��@�H�Q�ƋW>�e�Mќ��v"�P{�d������,NP̕�g�'��=��l���p�P�l;�q�󻈹�>`,�N�ioU�T�r���IA�L���jkµ���kN�M�:�Y�t,��+��9�G�(�y���(|�Ǫ���\Sǧ)j��ۃ�Ws2qi�y��А�`�'��2l]<� �&b&�n�ѰnD))�B!�!=G?)Ht%��	Nh/!�D�F�t�O�������t]����j�U��>A����'�����!��
�ҡ������ں`��1�ІhS\���
��ݬ�������BX|�Ȉ8�Ft��֔�ktv)�Y�|�������h^wѽD��.y���8]FNLj�Q�\c��ΕϺ:D-%X�{e;X�8�K~�V|�]�>����j+����N^�u3�r�k��EU:���H�c'پ<�l@I�ؖ�)�-��Q�{Z�S��'���������
�I��.��a��?����}yd����р9皸�2)(ik���n���WZ���#��a��g��V�h��H׵���e�x)T��?�$��D3�M~e���d����%�
��_���9%ӼӡAT?�r�:vMww����O
r���-�Ii:���ґ�$}���uL�Ņ'BϟD̜�<�7��&�s�J3(3�AeRP.�A��TR/��u���S�u��?�O󓈹d�Fj=��ˇ����Bn0X9N
�e{P�<�Gq�WR�|�A�jwQ ��gݹ�M���P\�+We]��P�nR����A���@[AկT��М�#��FΤ�1��yͺ�B��^;�WB�ߙ�maR�ԥ�q����H7
��H��˔��i=D{R�~1�`�]ڌ�a+9��"�f��X�����ʱP�rJ�J�j�����{2�t��$bF,GZʗڧ�,i�����+s�0)Q�ۃ��h��@��;����.{vI���x��I�<`{���h��#4��:,��IA`��A}�2�¡Am�l��f�DwNhݬ6Ŝ>�[sH*�-����%�t!	���`w��8��[��HJ0i>��$����`����K���<"�ç.��O�B0E��RNmG�>_�{d���M�E���}�:���Z�P�>.9�9�V&Y����j+��l��B@���lZW�EoD�������]|�Q��d�P�7����:p��F�f��p�"��Zq����"�`"إC���B����(ܤk��������~ȁ��RM�>��`ʭJ�w�rz�ui��:�.ܵ��s<�es�m0-�ѕ����Q��m��'y�4/o@}�[�\,����>FI�*�ZWs�
I�2�1�VGg'�m3� ���"�Z'�T˸`�`�W֊]M��U�Ԣo4��2Jzq��e�s���*yu�$�[C��;ú|���=�M�Pz]�G���4�}��Hp�e����N
��W����X��#s�{��uX�Q��6��&����i�"6Y�������*ft|��� {��c@�u���X������|��`���!藉�~�}z�!�)�3,|Xj1��	}07(�"K��J\w���Z���1)(�Rj��4��в���B��j�C�A��s'b�6��b��c��-  �FK�*(���l�� ��p�u���^��$-5_�QG�K��^��m�6�oMŉN��_�)݆~v08a��R��B�i�����{�������O��i��2n�����߃𣙆�6���}�튪�f:j�6E��ٞ�F������e��?zu� ��}˓�B�=h�
ggۑyC{��5��� �m��v�~�����~�C�%Н�1gfb�$b.adYv�� }�ד����4�J'��u���v�su�1$7j�ע�"'=�/����͐1����g���Q+�r�1��t$m�6A�[�uso� ��'�r6	_J]��\��QPH��J-B��LS#|A桖ו5�H�H�����k��&�&������gm�����գvl�h��N^|��"f[jn�PK�k�ӡ���鱛�L
*�TDm@�B�ց�#i��Q	r�:D;�ǹGQ�usl6��'��T����K�4�2)�ۃ,&�*xG&<���s�ֻ�[����Q�{]��)��˪�GR3.�}��Sh����J�M�A�H�    ׊h�m��zZ=���e�A6[��1���$9Z�L�J�L��^��c;ݓ 4\ܧ�"����ϔF�MJ�u�-܆.��T�T��D�j�G���sP�K����Ǹu���]|1�'�I��1��hp[򪞆�u�g�.լ{:�2thW�2z]Ĝ-'v���xu�QL�v0�IAf�N�Y��B�#Uy�;j��'F��YA��Q����H<�p�pio:��SpY�2�es����f�>�6>�U]1�6X��DVn���/D�-�N~R������#�ј���5�N��Wi��2�HF�o�UM�m��l;K��._��u�$��&iχӢ%t���ÿ,bv���e�t-o�!�p랜�N-@�/���+�wD�����&�������:����ձ�Qʴ�C�ؒ����<@�°��	#�~"N�#�t]��]�KP����I���="|)
�Zy�!:�*Z�ߏt���#קb����B�yY^��~;�%Ǻ�q��Z��)�:����txy����h��"f&��e��Y���t��mQ���ރR��Mc���E�3������:��K>�������j��>�Tz�gq��[= {:��t�����usw\���/v��Hj)W�?� �k�T�o@,5�"�;q���N:q1ųN�NĜ�����_�箳��ϑl�<)��߃2��@5�9�}��4\�͏l�N����˥Oa�Q_<XK���@�-�M�=@$��#�Κ{��s)�u�x�,�t�n@̤.��RFHϓ�r��@��A�־5�#���:tܾ,ٹ���ݗl���/2k� i�� [x��p{��s���K.K������'�
��������6)�6���Z8����,�������2����A�jzN��α��C��`]x�yR4�Y,�+,Ϟ�eX�n1H�kQ����G��k���1�����IAM��P�\��+����#J��u˘���0��"f/-x�*b-�Wg*�|1��wA&5y\�g��A>�y:P�F[OQ.��͜�}��ր���#>��}�#gH	6'BGJ���6��P)8�����nP'p����Y��?�{p���%�/�ߔ�e����g�I�%�1�.-�dM۱�ø��K����"�bs鼼ݍ�;�<p���/d+�ƥnw��_q���o�^َ�8�9l�Л�1����ͻ.b�]��6�FW�-���f_�Q�-y�h�59�7��NB�B���;K�V�l�Жg��z�#�MPv�� ��A�JՈm��+۫�*��S��]g	݊�#�*c�"[�J5/i��Cm�Hv����m@�vm(�v.G�)�=�z��=ƶ^1Gj=[��v�wHuh�A;�:)(.M�[P���I��f�Z*�-?r-����Q���Պ�K���4�i�N�z�3���E����:�[� ��S�v�"dRPH\� ;Z�adk���;~�%B�r���ܣ&ﺈ98!�CJ��9�J �6
a�d1������V둍����B�SLn-�ݨSuS|�a9]R`�#>-���=1��'3�N���3WN;��lM���� _u,�����M2$��� ��1q��m1�./f���J(�xOn���.b6���OJ�z\�T��v�L
Rm��:I����-܏���{[`x=�gv1�$bn��2D�k���A��gC?��5Ӽ�H(���#[��"�*fQ!� �j�.���M�ʫ)��0��txM�[�O�'v�� a&ΰ;l����#��h<F���4仦�w�B>B����>>��\�3,l�{�h������E�LdZ�36��)��"yn��융�nr�rJb=��>;o�Cﴗ�����U��E����9.���R�q��.�F��\M�@������3��^%4}8���oK�%�A=R�q�>�t.gA��ȤO 89�@��y4�K�I��"�0qm�>�M򓈹V	5���2�����+[�6�IAy�7mA��g���;c
,���Ǝ�{��*YNt��$b���*ȯ�#v�m�]��9Ro@2���lARޕ�X�W��Е9��K���ĒS�~1��`�Rd�~f�o�֢Xz�����nA�
\��>�_�Spi��B"r҉l�Љ�D����ym�k�Kd�2�@��0)H��-�Q�0q��v��ר��5Ǫo���4���x��y[���p.��)��ip��l��2o�kn�vtqz4�]1��J�c9�kߎ�&�Rhɤ�M7 U�C�����Ti*�W�m��:�]T�I_���chR�����0ECPg�HN�'�R��)��8��(�OбLe3qo��E��Y���Q[�κs:���n�&�Z���A~�9d(^�a�	�AK�u�cg"��"f�]wXlM.iهV���&��x8�)m�'y#��RL�t�V�Xg����nE�\	�A��k̜�U�Y|�9O
��n��5�A���ûe�������n�$N��V_��������ɜb�㩼�D��!r�Z��]�$vђf���IA���t������}@�*E+P�X�����#ՠm�/��m]�m�ְ$�����k�0uS�n��kQ�7#q�����X]ߎL�[ٔaa��'E�n�-�'��Y���/cat�tcVAT�Ѝ�/��h�UF���P����us�ب1�YEZ���bye+��`r8�:�ҡ';|?�x~�~R]�z�a%���S��h��Xo?;�/���bE���N|�qmINV�[�$�ۂ�h�&c���)�Ȣ��TIᬌ"�h�h%�k�����Y(�t�l�=�z�I��uޖ��U�!:�.��gcq^��c��znYk���+��Kb� �9����y����U��_sW��8��һ� ���;|��^X���a��ȉ,�@�2dj�q�bw��խ!,�[i�;o@K����t�U��:���6B��0��N����}L'�����eԪӲAڵ|�����ڇ�@et�{���nᾏQ.T>,t��B��Ӊ��g&�Ї`��?Ȋ��qh�f�]F� 2#�t
�ls�# 8P��FFm�ʨe���9���rP|S�)u��w���&�CV��=�)��i�-%^������F���[�����Ḻg�:֟dqEF��{��&�X?� 7#��B>2y��h�J�4�&��%�2�51W�t����C�?�Q�"t'(e��nA}h��~�y���+�e�������9�M����U�m)w�!٦8{����0�DPAb��ҒqT��z�޷F�����[$ܰ���5���,�V�)@��I�s��֜k��M�@}�-(��s�T(�}��W��L�������us����`5W�c:g��k?�A�sX�T��hv��O�����%�d�mgKb.�����E��ơ��,��#�֖'�^Vݯ�g,�6T��d�g���������fΩw���	"l0B|('�ßX�K.�s֪��F�t�ѩ\�DP��ڂ�$	c�ěi�ei>�u���
��rB6��
uێ�c������[TF�?~��Č���g��_��S����ӦS�y"�,�P[P��'s��@������S&o)h�gݙ��&�,6�u�&/ɴ_n3"r"���v �B�a9���)��Yg�:�)��ׂ����1��C1����	�.f��9�ɰi?��K�1/)mPwq��&f_�����1 ��*�r+-�&�l���4Rm�Z�Û�|NnΥ�2>�|'4���mAc_��R�엞ָ�#��'�3����Υ����bx������%$?��0Ώ�|)�8��m۵-9�)�֨Az�/�m<
|�}?BP�xY���3�[�,k5�F���k���y��.�X[���2dI��y�@�G��oA��>j�p������b짘{���S�L̾��Y\��� ��c���pA�S�jR�H�o�:������.�/P£��g�5i�Վ�m��+۸H��E�������3s�!G���Y �  E[^�'�La��#� ����ƿ�Q�.t,t �S�f}�IFw&��r��K��5��Kuriݢ�DET1��[P�n��a�~�:�}�ʅ��;n�ZED|�}㉅���R�&��q	�n
�MC� �@y2!#Y7,^8p&�F?��u�	/lXOUyk̙�'f����.�MU�I�J��%�ژS��ea弪����D䛖�KL�� |���ڋFV�U>�2�<:oOL�~fb�~ر�=Ȋ�ܼ��	�O�Ou��oP�F�;�8Y�
}�K�g��i�2�51sZ��lL����<�zS�#�A����B �W}��}��N7ӱ��}�hm8��/s.�'GU����|>)F���X�䉠��/w�,r�䎌�|�9�V���nZ�H�6�"'.���k3a�7�[���<;���Tr"�>�r����RȯX��1���r_	Ńj����|�F��N'��1�J�:Ӳ���,�E&W$��K���G-%���QO!��{Р�#2FW�ӿ����t��h���4�&J;u��뙉��t�Ƿ�~Q.�Q{�X?�G���$MQ3�x��y��^���uK	�͹%�����td���MK'zI)Ye3�ɉ��ó�s�x.�9ۿ���F�M�rs�Zs��gf�FJh!?�(9�OIU�-ہ2�ْ��4�q�XS;��6�}�O�,jO&X}�Н���CTW)y�=3�PY�KDE�DJ�n[P`CGt�3����O��Xm�l�I���󩉹rĬ�S�&k���"���$�<�AJ��5/����x>���!�%^9#�{7����ɱ6���mY�x9yz��p"(-�r[P�TxG^�5|@3$V3j6?��A�ב��%����n bpn9�v���� b�/5�Ɔ��#�k�k��es~�LO_��z]��衸f�aA)���@� ���#-[o
2�K��]�³FC���U�OM��`�ȹ\]��cbcŨU��ރQ�b�ްa#ET�?�#���\~�K�:v^p�/օ9^$��Ĝ���;T�<��2Sj��2�K����=��� �G��'�������>���:���a�S)�wr��c���D�f��d��2\V���=\]ƃ�?�e����3�������c��:/�"fp�׆bJ���I�V�D�����Ν���A$:��ȅz�����͓�������j�[�G��z7����u6��b���?R��5J�N�"[�Х�6�SC�ǃW�"�v~�a����@���{��e3��Y��V�[�oؠ���Rԉ ����0�61`�7��f�)���>͘�"�]�be���"���ۮTa��W��e|�v=�
��M����K����)���_71�T���%Yka[*���)����d��F���
�����:�ȣJ����?�����%F��S#��J���L������?����      �   �   x���;�0��9��唓[s�\�Y]rłZ)E��[qg�[��M�)HUHY�T#P��76�*���tm�/"��RY8�2D_�r��l}����֭E�۬S�$�B!��l�:��v�?����� ݲ#G�)�> C=O��<�8O�u���P���	�\e\      �      x��k�,9r%�9�W��E�H��i�+@�^H�- ���J�ԭ���]���=<���G&=n�ͬ���}��������%[d�Gݤ9JY�ѧЎ!���*w:�hj]
�Ѵ��&E_Z�\(�6$�AI;w$W��Y�A���Ϲ8aR�I������Z�_K�<��1�Xb�[%�k�wm���Qe�oH5-�Ps���t�>%'�:
�b�p2SEO�^��$����������~��?����_?��;�����������ylMJ(y�1��M�7
'��#�_��a�T����$j�5���$�>֦)������R��cSt�)J-�3E��AX9~��_c��}wq���?������f�1oR����B�/��ݿ�����O�#�<2R�����������?����������_�'A������K������v8�S�T|~�5cN�K/ʹ���\��_o�v'�	"us�DA�O"�r��VUJ<��qFy��BF;�M��a�%CR������o>�G��/Y�b��J�X�=&�l���@xQ�Y-�*9]C�Veq��E9<I�r��Q�K��N�T�q�~���o�d�y�a�f�3��w~�kW��b�f;|��ơ_��~#5v�M��i�����&�M��$�#���J�*W�)��
~!�5��A�Gmk�Gm��zS愝� ��͕t,��Rk3�T����Z�6/�L9��:�o�������?��a]s�y�32���}�Φ��
���p^h(�o��t�V��&eAR��h#b3T�a��[���o��F�����M�T�I{�mtUT���s=#2�����P-RaU�ۭ���} �ދ���}$�E+�#*�/^ؓ�J��Y~���Fh�Ʃ  ��дc�|�H���4��Ҵ��i>x�c��Q7��A�J�d��B% �'s�B�q��Љ��K�DǓ��[��a�5��ù�:ϣ��yAFp8�L�+�����������O��?���?��?����������>����J�B֝k+��{�;��d����;U`R+�X��.�Du�$�!T����醸��4��GZ>ʒ�H�z��DK���hNEtA��GA�J���(�r�����,8�&��*:R�.�����O��:�In��_ߗ�C3�lV`���II�K�Y��X�K	%�Gh!��1M�P!.�,�}���U��"�c��q�5�M�@�7��� ��.O^�dx��A焴k�E�"c~�8��XC܃�'��Ų$��%3���Os�t~D��/�(���tH&+��_�w��$9�j+�7PLJK��8�E��3���k>kw�.C;�`|���֋���>�O�Ju��j��yD�P��bA)̼'xV���\Jᐢ�����=g��	➹�ːS��ؠ���jf;x�;
x12�*R�����P�1l�%��M���|؍$KV�mHGi���A^9}W3�~ݱ�Y��*�;��4,q�ɸ�̈́T�g��iF�����k��f^B�ahE��$a�X�I�����CH�)d��_��k8Z+n�ؠm�n�l�;���!�ZPU�ɰ�fI�65�"i6��L��{ǒB�d�O0A9���A��9VI �§l�Ɉ�����<ь���>�̊M�7)�S$�^��;������q��
���(�v��w��7	��ؠ{f���7���;D43�k�Ԕkt���7l�O���#��o���R����?,� &�>sϬT(l�C�%:����%����(Zm���¸1�XJ�dT��^KFA2����j/���CɸO�߀�i�&�$6���ᛏ�:|sf;�[a�̦&6hJ���M��h�՚�
���w˜��K|V�h��&A�V�p	*�q��
����Y�k�R�7��#&���Mz2ۜ63�Aa�@x�H]=�!u5����;�Yޒ =�V,�涖7��*&�g�C��<-f�>Fs(I6[�3e���\����q��&+'I�l�h�-@�cw�n�F�� �I�M�c��}�i�=������VL�%L0�q3ER�bd
�2��'�8tP�ud����R*@O+�����Cu�B�A�4�s���"Ȥ��s%���j	� �#�B���{�ϕoU��%�z��~���gֱ��v�`��h�W�R�6QH���u���k0�Oo�:k� �m�U��@H�1��"�K�k����e��H�U�F*�����zID���w��޵��o$O0������������ō���L~����ur24T���f-K���!���]�b�Bc]����3���$�r8:PAmGTB��R��/`�+��mf|NQ�_TT���_��X��k,i|�(���Ә���<���VT���IH�"����H���J�p��H���/&AyA�r�j�8l+^���V�����ݘSo&��p2D���`;�04�.lo���v,A��T�
>��9��h�,j��VF�!�I���tT�	]L��39�����<�h�<�u�Ψ4����!C'�u0�տQ�{1�ǱT�ķ=���۩� �K��5��l��F0����3H[ZE�n�g��&����6�!�$T��]j9|g��@z���?���U:�h�u��R|y��=�è��lQ���SGc�X�"�$��)z����'�ADbMƓ�K�Z0�K�z�����gB	̥��af�e�Zs�(?����GW*L�W\�U����(�����uܱ�ŭC����,Xc��ȅ<#��P�)�?�Dx/T�;�i:�]�k�,��]�y���5�"��[�N�~���@d.ۚRx�,��� �Hc3��Z(��B�* ��8ht,�N
EG��NV)���5:͞6�ˍ�"$X�"k�����p��iq�/o(X Y/'�}�#�_x�{���Qd�@M ��t/\�vq������w���!�t�����;7Q5�2/��

�&V�Jj�`��8Sq��|��-��9�w8�5�� �"�.�V�_CV��5����_�r{r@.����&��!����}�sxkq�� �n�k��b&$H�G"w��h<����>k�y���5�7�@��ŀ/���Ơ�AM2��#Ƽ�b���2���F7R�@��#�uxI^�k�;��c	_���j ���qHw�Q�k���}��@���.F<�9h�^�-x�:H)4� �HB��%�CI��J��V�lm��i��^CZ��P����i���8���M|iH_/n�`�e� �	��g �G �}+9HUMx�L��^�l!�A����cQyk�ɋ�uU�����t˱�,�d�� �^��4����_�W��tT�dځ��R����H���,p^�r$9�X�*�)b�[�E.%�@"
;~}-��A�.��%ޘ�Um*j�+�m���\_+�>H:��.��������b�f>	gt����������$&��C2ߕx��9�$6�t��c��Aɉp,�e[��f��U���%5���^1Y=pS� dYT��7ƪgE\|�����`��Z�f�YcK�R{;yh?6��:��Z��64%�h�h�a����3�&��ȧR��q��U���%F�3��晗ۗ]uo�'<��{�[��ϻ�1w{��q�v�AJ�Q��2��T�c��F-.����Lm����dӍ��_<;cQɀC�<�	�<��rQR�Li��$�w�d��^������������İx��d�p*�������A�aV�Z��:�u�1��dt�cP;�em���,��0�B���:<Q۫A�A?|��W�w�aV�ɄE��'���k@M�C�^��@�Z�8�;�d��Y"S`���&�q.�/�q��H�#�j��k����R4٤�d��9��mn<��HM����B9���k�@�d�Rވ.ǿ+� �^0 �����B�
<��N(�����@;D$�[� B�7�s|��`��y�8`��L���:��)�=Y|�CI��"��4
3    w��9&]�x('�h���ϯC�k
L�7maƜ,?��{ļ�R���fD�:&nk�w
LI��J�8
���+�X�]�]a���	�u01i��_�������o�g�`U�L{��/���ci���J���A%�������8��)��|�V�rR�חZ%���UX?�2C��X=��)�3CZ���(y<�$L�!�X3��2�b`�:n>�К�`H $'%��DѾGlJ�!��}�S"�4��*����ؠ��Yܸ@�0+��ae���.�v�r�)��L�\�J����;͂�F��8
R�8�AZ%H��1$�f�!\�,.�Z�8�n�yj`�B� r}w������S*ՙ��`orI񽍅U}�4�v���#+Z�>X�?'!���O��!��Qq�^}�.�1\5��kDjl�����1v�2[a'���*zP��������]�Js>T1,a�c���I�6�$q�c�"s�:;Г�Hm>a2���TAWH-J$�ڢ_a��)��B�������'���aV�7$�`u��{�(W�9)��9�m<v�鑠�ު5�k2���P9y����E�2uh�����9t�*�F�L;h׬%ν�-�Ul*f���(\٨�Hْ">�]�����XE��#����q�d`���� ���=Y_sd>ֹ������.n�@m.�A�D��+�A,C@��Q-���1H��d�3���>��K�ȕS��0�9P)�9B�8�4�PrGm�"*�!���~v����΅z�����^-n�d���\�̐j�#s���hB�h�'�x��o��+���Ҥ�=��B�!��:��H�8Ea�<��`W�I�A�����$�s�hJ��¢fH���&Y���7/�J�Ӟ�]����ҽiص�W�gv�#<?��[7�(�qH.������̖�3li�"�j��m}n-n�zl.aY���Z���}׺,"����X��±)٪��~�?[,�@wd�� 'xQ	��� ���}��qA�c���e����+d�p����.Έ�QO�NpЏ�G|Y��ل	�ƎoB,T� ^I�E05(;q��1�k|s�PP\� �|�́u�̂D	'�g����▊I)�)_�1���%�ž�K�iCOG��i<�y��z[��Ɉ�3�ؙ
T_aG6l,(_�pC�1Y0ۜz���B����5�4OޚC��Q�m���D�[��H+�Y��Uc�25߫�d��
]��@*�oƧ���w1H��-�𡧠�0�%y�ד��O���D,_�`ߤ�J�r�D,�]۽V }Ҟ���o�H�G*:YI��A+���\��M��w�EM����rz�v�����OF�q}2����W}<�zI��V� ���FZ�$?j��y�>.� f#����9O�:��8�i�k�o�PPk�u-�'^wj��C�,�{�A��{��>B3��� �do �ز����M64�;��kS�l�@	�ى�z�ITEI������~�3bg'�3�1��Z�E�p�R9��z��=!姟���jAT��T{���Ȋ�u�	��'E�O�廟0���J���f�i4��`�
���ؠw��jb8��5p���
^Fӭ��<�)���K�8�jl�X4*�h�yA�0�a
q�e��0u������S�w��&xf]s_*��z���������wf6�5���ޒ��AP;�!��Vo�nv�`���M!�p�C�4�/��i��%�c�ݎ�i��
��r�T o���%��%�~M����:]�YvrA_�?�t
��常���:�A6ֶ	��t�9n)z2�Jd�X�`UFRKH���aZm��m/M$��\�C���R:��p��ePh�+j�5L-��~֟�8�W�����ܙ�gQ��_�4_��tuQx@��5�F���ִ�N�~[XA�rё�#���8Y+̎r�D�J�~���"�;�A)�26�.�owԷK`�5��f�5%����GcTŇ���@@v��%�&��T�Qt$�NCQ�~q��,%�,�����Ɲ|��4�%��3L�T�yN>�{$x����v���W�8���_Z�1Fz�u�tU�H$|F7h|^o�g���^q$|�9�1d�-�0aO��^�#��-KHѪF&��Q�7:�2�N��bF�!{���^�r����L�)�߷SA����&n�D�J-T1��l�w/�;r-��|�^B_3�hn�BS���uxM��<�P.�C)8,���KW /�M|��@-4�Ӵ����ex�Rм�F�4ت}��r�_E)�άc�����8V�k��қbV��%NN��
�����|�q�[O@	�J���	�=N_�t�4�ں��V�9ǆA6���z�PB�ER��ɾ$Y�Q�IΥ�|hQK^ړ�����s)�]Ox܉�vPR~���8�8lZ�jI��K��k��t�ek�(�ğ��4��m��L���Xb��|U���TuhA�B�����:����˥���3&*v:�6����Ad.e���:�-�Y��b��@�К�ۮ���W����8����Znd��@3+�P$W��;��Y�8�;�R�AYp���|�Q^���U�31*��	Bd@ @�"C]��`�� n�
!� �:N-LH���}��
�S�;�O\Êv5s����,n��f���k�E确!6}�������%�x[��7cW:J/��E][�KH�CT�j���sD�T��_r�����lZIN2�:H��#��A���J`^!��Foo �#*,��Hw6/���"�1�h���21(���6�j�B;H�a�D
�j�g��17��>KQl}I[X�qB�(i��[v�B7������w�yǶ�csfvZ^c��(�oY�� ��璗�#���`���@���E<R� ���	[#�dQ����f�[1�5���1W�3��|��JT��!��[>���6����4���H�Ќ�!�K�H
DS�}����T�og�/7!��1ӹ8g�ؠm�mM}<ڿCD���D�0�c%��vy�C[������pF��5�ID�
4E� ��ș{�꠹�jX�Iq����$7��5��6�!K*X� �{�h�f��U�w3	lHwo��G���9Uc�r���l�'li.c���f�����"J�q�(D�� i��M�%�������)�QyIS`s��d'Z��y�!Tn��>���O�雘��j���룩׋��L`��)�h	2�<���ю��v�T�P�� �%�O���8��M=�T���݉\W�r��R�<r�k��d��gB�\��s�ڏ8���4�ϯ9w���f��^}�
f�i�-�L�aF�P�wA��U �Y繼i��"���Ny	I����K�o�-њ���f�;.�+�)���S���|~ڕx�s�,v�����ōC����yn@�d#�v��FZ���� �Z�J���m��s�ӹ� )Zy���=�͌/�*���0���;�q�zP"���w-�L�	z-�B�@��ۋ��\	�?�
H+i��-jy�*9�	_�ZhU;;������zP��7T�GG2B�H~pН��۵�ӀYk�Erv�����M�������2���*a��RU'��$�oG�e�Q|�B�Zp�#�۔,�{ݾ�f��g�d9��d�*(
g�Ut��I�7����d���Ϋf����e�gPOԫ�́P�R���'��AVe�b1(F�i�L �ƫ��Q��̐f���tMԌ�%)�K -�i���494֩���������Y�8�;δ���T+[~{4�B/<w��$�V�%`+�d/�sBKup��պ���jR:'��nG�c�O6̨~f���zS���A�9��7����9���w����w�}��qhw�9��`+)4�i�&\��Gл�:
��ڰ�e�9A^Z�9O��X'W}����:]�j�-��A��Zv�&P�K��3Kt��z�ճ��A���e+~	����f��u2IZ@VWm�h���    CF'8���=��*�V�\�9VaYs����mə����EC`)1�=�V��	iuo�Դ@��*��fn�K�M���DS��	't�7�!���T��T,���ܜ�J �3P��v�ؠm@nM}3l�W+�X)N�����8�����$���Ǚ*F� k��8���1I�'ɪ{�8���)�ւ�l��w>? 1����bt��F�]I��*t�o���Cp�@�@�������*2q�6�;�Ʀ	h��x�t��=�|�K�|�K����Ҷ�W :���0�<���, �x.�å��vGuܮ`�k�P��7l�`i�)"X�琩� hy.#h���D@�C<Ty����s'��8kE�������s�W�w��%k�Dްk2�Z '��+ke�6�8�����Gt��a�ٓ��|&C���V��}���Y�&����0�/}3l���f}���nq�y]7�jpxo9[�t�1 
�;���[!�g/�W���E� ��������tg���\��{��uKE�dc-qW/��T�sL��(~�K�)]	�ֆ�K71VG���7j�o�����,sBbl�=Lo̬��w�]����1J�1��2��,�J�S3�������ҝ�n.��=�Y� ��|䖉B���z�t�ec7�3��`�Mb��NF��[�f(1}��ε���$�b�9��JO�<��x)���^�}n�Z���-�@SGFȬ�h����4l������j����+0���I���>M̋A��|%����u��+LV�5^)�hH�&#�Һ9�Br�ȗ4L|M�I�K���2�O�h�I��`�szG�Pb�fq�l��%L0c��5� ,��j���@�ƫvH�Q�~mJ\�gu��Z��R�����:��>q�*��4�:e��T#eq���K��9�x��xA���&�%
d/�o���.>�~��
�!8��|f �5MGl�obl�=D�N�~��;�peG���W�Rvu�%@���������?ݩ����9��'����ʒ)ker<d+b+�#��\����,��]�FX���E�BY�ܙ�L�?@k�+���kZ��d����t��sK ��_?�jG����C��h�.n՛K�0�`��l+�J8m�|%��V�\��:�\��8	Z�#��9����dU˲T���H6	�*xe�	2���4����&4l��\T�)6Wΐ�
�b�㢓�j��%�[zC+��"�^QH�bqB�	Џ<��������Q��T�7� ؆��aٶ���$͛k�"͛+����,L��RMR&�Z���ڄsUQ�c�0�W�R�p�
( ����b��Oʥ('�@�C�Ģ���ؔB�k����4S��9���r8y.�(��K��S�<깐�}&�,i��܅۰o����p��G�Y�����o�>p���гh0������:x{���C�Xoi�`����@e�E�@�C�W.�(ݼ�$T4���"�������3�@ط?L� �5W?�@���d&�{��\ �_�g
`�F���5]K(T�IA6�sj�#���d =�G@Dp��b#�6�VZP� P�^-�^/a�Y�k�����d���V�vK#oK�\�\��a��Ǹ Y���;\q&�njN���-[��HK�$�m�����爾��q�!Gj��m�̍��OΚ�}�<;O�z<�K����U�f+hK��e��c"^�입�9��צ��
wo㧑���asB�~x?���}1������bL�:�]��n�7>z?5���(���/V4=U{��m���	L������Az.;�Kl6�*�!)-}������N�:+�xA.�Ht�J)o��K���&>ޛf�>��soO�D�!ǡ ���r�J�1në��әƳ'�/��i �Wo �F���/q.��Qc��EV	�U�טf����藷ׇB$|&K%V?����5��fW`2y�A �r�5���%H|�#��2('{�)��4a��a��CvF�����f�l'��E~5uKkH��NN�@,���!�ҁ|36r[�uX�����ٜ`�́5Db�����h���!W\mV
ƙg��6g�j&��U.�j\S�*}��z4�mq����UV�a��.Q���������n4��(�^����q�"Ffh���s�T^]xk���ٙ.O�;�ِ��8�} �M�F�'�����6���_ix�a4g�^0JMz�<0��J�`WE,J)��P'���L:J�8�|�I�ßA�{�.�"'�7��db�@�C���l�z��s���`�H-N��xF-�t�役�d-��J��$)z���К��7J0J�z�j���^����	,P���]���=��;|G`%[��e�}��w�"��:̲�k�U��"��AK^�7��T _���$�k�FBh �j���A�0!���+��(�+V�����v�&xf�<9��@�*�!{�Z
��X���x���hn bZ6wbu�c�ּ�B���"X\���:H�|�Բ��|�˒���0g���✒VW�v�L��6�B�SۨǄO��t�ޯȳK���9��[��;UդT����{��]�3.�v3A8K����
w���PiLց�T��&�A4`:F����AȠd�W���h)��Y�I���@ř���J���c�ߐ�^rī`�bn���������f�����i�T�-p��Ln�8���R��2do��
��Ot��J�C��a�\RQ����l�H~�Z���w&}&���/���<�6P6��_�o7��3���������@��:�o��}l��,�@\�dD�� X�ͳ} �,a.v�r�	���>���@�����^���G�v�M��Y��~�{��=^��������I�QodON�s���,P!�H��f��ذ���#<t<.I�gM���*�s����7���`�����c��Ѧ��F��ê�I[i9/$�3����G�8�TKi���O?W'����u�ƆWx�9]�M17��G����}(9��������97�o��UZ��D�\I�R������&gaJĬuz������g�Z�-���9�O�\6��;���ggM���A�ᅊ�1�������0�D�t��TJ�e�z�u�XB��Uxv!��`��~�Bu��������SX��w��Z���C���t�:�(+fy����BǢ2�]e� ��\'�p�%N}��/�`�sow-�DPE��7�r��������B��
�T��ڧ�o$wb���8���������b �Xt�rwc�7Wұ�@\a	;Z���sy�ű4~ٿ�ß�\�箣�
��R�}9���BZs�ؠ���Z=	�F���4;r�9��)i_��pbE,+=��7��˽WS�1��:�	�ljv!���P��s��j�iMk��T~V:E���si��i�gճa��%��}R���c��bP�8��x�����۟U�8K�9�B�3)�\��x�&ٜ��H�3Xv?�G�A@X�<�o���O}��MHOI�(\	�����x3�;i���.~� R	ROE]�l�@R����Bc�Y���炜9@&)r*Ee��x�S�V��jKJ*u���oa�3�Ȥ�7�^�� +or۱����8��g5/��Iϝ���+)���Oxėh��9��L7�iP��Y�9(5���h�[ %y���Ԍ�1P���A]P��V^���6�e(��aFÅC~�3�&
�B�^'6�H���Eк�k:� w�h�l����CŽ]�J�l�K���W�P�rl�=�y3����^� ����z0��\�q-4�vv�
�m)m�`XcxgIy�k���Uɜ�^��j�g��EG��J�{�Q<���v��Gb�{E!d�#�P��hݫv9���?�[3��5��R�rv���q��8�<�q�n���~���S��f�@Ns��"�^
4V*2�`��1s�\8s����$4�px�II&%A�gV��m�D    O>�J���� �����B�\��x��rB)��NG�'cI�x�ث�Ӷ�Nt�j	e\�z�2l4S8���A�p޶)oEl�á�����w�ro%������bK��:ѝo5��I8q�@hp�D#�	u=�9��ܬ��8!4=w����� ��5-���%�a����g�#<8�9������={$z���h`&q���l��ݻ\�]�=r������+���j\Ʒ����&�����5wUL�s��|~b����v�����[J�V�X
�$8���TF�ojs�N��� �ש���Tj�
,dQ�0��ϔ�Vx���t-��_�DV�i3w=B��pF�|=� ��!��S���LQ"�,9��Kٍ��v��-Ho/��,���Y��1�.m�൙��ؕ�������o��M�"}�=+:T��3.%����Y��Xˎ��FE7,�n
��m�K�
�W��@����{#/=�A�M����'W?9�#��o�,�~0�z	f����%Ȁ1dmH#���f�����瀆*�Q�͑4c%��1>2�֔���/yv����7S�fG�S�XA��Y�k�f�7.e݊� �Wf~<�b<�?�y00�8Z����Sp��4m�7Ǜ�F�K,�H�"+#Pk��c�����,��3iΡ����d��Z�:p{�k�*0,�U!�F�&,sI�Q��_�cR�Es��:7��[@N�$A�I�C�Vd>����xPN�C�/�Ǜ�d��QL�=qL�������tv*b�^�K��F;�\��_�*sR�J��y����,,
=|L^׹�����v	f���5�,�TU �M�����@���v*X���q�s�D3_'1}�64:h.'�X�Ѥc��@�J�qm��V��Ԝ?����)8�k3A���_=��zq;��f���,�;�.K�����mxs�A�6�/�Z��>@�E���Y�uK�8�d��j/�����x�J�˕�gb{��{����
F���W��{��j����Ʊ�aV�_��8c���~g>�-��-F�^U�ϑA����0��?���<3�|
�ǢX�89����?�%�_�/�*���_p�ͣ�o ���,�S���}�����ߩ�p��b�w]ޛ+�XbKn���U
�KS�7�n2`o/)���R$Q��#���9* x9
[��C��AP���$�MgR&�C��da ���X��]���)H�z�ē���P䭩�#�C��d��TյEF�����ɸ�-:���o��dr	���ᄀ���s�J��)m�ʢ�]��4�Z�s+D>�zѓ㇧�r�W��:v??���������;�So`s�~�`�z��ʃ��&�-�L�]tfXޞ��B9�� ��U��9��������\m��p�
�@K��4�8�"ېe�s�>�~SI�$�C����%���5!�S�`�0�t(R���]#s��8����<���CX+^"�:
��h5Z8G����@��ĴP���}W�.J-U�R,
\�B�3|B��LQ*&��#c,kXL*������hE�V�1�:R�b�>Q-�L�?���������@!��NrU���t�GlvM�ط�.��?f����|�SlE��Ez枤-�s(-hdT=_C>���B�T7��9�#w�S/i�Ia$h�Z�_Z�i��(Ќ�Ã�y2&Hv������;��K�0s5���V̩$-Kza�Kڬ����� 	/K@��]"�)��A�I-�6������y<����6^�ό��0�Wy���@��B0fw ���P����:p��^'$!mv��6ؑ�(s'��R����z��\r�Z�A�q����`l�H\�|��n⬶��%��I��x�'��Jl�>�l��B\��
恺��#�P#��#R���N0�j	f�5���u
#Plz�z��JlW�<	�CJ�L��j4����[;jQ�Ljy!3��/��Ŵ��:	����J@�x���_��,�`������|�+ݛō_{u���_�L'�0}U�Ǯt�:���#�H��Y�f�4��^�0#�tɲ�0C��&k$�>����� y�:���km��O��em��軃�_�i��*�"�Fׯ�q��+�h��XlB2���pTt"��A�\Ǯ�>��Ne_A$���[)����"����UE���Ԗc�����H8�D�."�=���;؜�����ʡX���|�� 3`���4�gJ(�	�g*,���d��d�ō���Lg��Y���9Z?�=a����Y�d�K�p���P�AC�S���]��A�b����"A5�mu�[D�^]�e|^���dJu���5�~/,x_S�~�I��6}4�j���ǡ���:kGvY��W S$�3*[/F3H��_Ux��+�f�c��ۤhea�C��&����CgSw+0�Dd�L$X�*ƭkF��lB��ۖ{r�r
�U�@X�Fw�z}�����k�������X��]��<6��97D�����2n������<^�I+��=���'�0�n0�)U9�p�������*7���=
�W�ƣ}����uh8? (vR#U/��s�6xE�'';�������1�S�������k��
<��蝛���t�@���s�w/2�C��I�Ghxηȗ�5j�G�f0@M6��	Ro�l���q�Z	�5/�r�I3r�=���'"V�F��4����|�&�t��OJ!�{ �:�rkq�no�0<���ظZ�5�V����q�/���[Ծt1�S��|ȳ�G`B�%'{�0���k�E�S�%h�m�m��y=H�X�U)4�g�shrjn �)�5j��,i������Ihgν�v=�q�ڇ������1;��#�7�~e� Qߪg^�,�&k���3�*��Ε��YU�A�W�U���"k�2��j���%{���u��dl�����D�}���]��
��V�s�}����_-��g4�Kܠ+�dpI��h>�~HJVC].��rl�A�`���?pmc K,Q�Ўj�ɒ"X�œ
�Y�?|�Qz�2�=�k�iӦ���9>\i@쏬h��c,.릠�}�x�<D.��&)q�礨-۪�ؠ�пY����h���5N,ؾ&�`Ѥo��6��$X^?fb���=
*JY�}��$v�/��hQ�BO��d��Yh�C�
��F��ʀ����}��>�s� �ȇb�o1��݄�\���ݎ��&��)�z�׋{�; �k@��2쀈�˝w�]�;��S��r��8�5q,�t8?�Y�`�"^u������$wԠ�X)~�L�U����w7�5{ф:9Xf����Ž��3 )�5 ������w�O�RU�Y@�H?0Z$��\*z��w{�}_����k���:��\|M
vB��_I��p-ې븽��3$��-�|��i}�^����H����x������Jn��;<J3��������C���N�*"��/���[�+��
gE����� �E�KN?5O�}#z�{�7/���77��~H者�����w~:���׀�`~E�T��R�iږ#N��+��vD[�r �6�θ��a��g�+�a��6��	��o���+�'�sX>�]�n�����=8���sp�D�	�N����5N��7�Ω��5����i3_���be�&͍?B�?��@���a���j��y����CS5HMYA�qS�F�A����wE ��S�3me��i���837^V���v������8
hhMs�I��S���vj.7���u6Qu6gN��yf��˛�J#�Rc�և��⾯8�w��1p�]7�l�x_T��wN."﷉��d)j����j�0*JЮ�B\��)�w�I͕��s��6��|hyG:lH���D��/����W!S�Ͳ�Y��@��{��uW�wg����E�7#8��	.�������d^���F��J-��;$6v�EppP�YB�V �g){��!����H�e��zTN7]MU��x�C��Q]�1>#�D�}z)w�����)��'��X���_�G����Y    ��
��v��uQz�:�Eb�f9{i��.r.	]��@][�6�@Y�v(DTlO8�Sa<Iq$zKݐe�S�5��ԯ �p*�T"�T�GR�<�2�0��G|�T���:v�;�
;�('2%��[1#>j���5"+N��c!=���ܪ�%��1�zm���1��bP`��B��Sz���A8TPP�4��
�镙C�?%b�JlhE�<���	HП��)�s�#���En�#�AV�^�F^̥y՝���y�#6rP��IY`V�9G���$^�C�d>�;w�����:��Y�i���?�
0gS�g��۝@��{���j�3�����nM}�H���p�
"�IHY2��p���d��ci�em�cV��l6��K� ��$��  �$>��e7\��ǒBQ�.�d���
^_@Qrt^������\7��I[I�Y����Ƌ��|tGG|MjK&�ڶ���3r2+�����ŕ����H�WqFN��	���h-�u��F1LL�[�;w�	��q���E�QP
1����	JAKS[o��d�7��Rj7�����^����b>����;�����._r�^�lj�A���ጄZ�~G�Y��5R��	�K`���t��,��f�o��
h�]3p��k��"���8xL����,)>�i���Txn�l������|e�LW۳�>a:�ॏ	Dq�]1H��V�s&��z��(5m���^�QU7Gm�� �	�C�g<P	�{<��2_�/�3�I�W~\� �I�����E��;!j��.��9pWk��-�õ[����۴c�Y�^�a��(�\��_@�0�b�%�[W(n�����7��ߚ�=���^`��瑽[}�� �A'�#:^�&�%젱�$o�K.�]���i��Q�ʥ�Z0�;КC�5�Z��� �0݌���eGz����Vjxam���J�D���
G�y�~]���S�Lpw��hנS�� �3�ak�=p�<��7�s�Z�!e��C�\�E�x���!(��RE���u��LYJ#s�L����1��aHH�Cs�Y.n����wns�U9\͕u��� ,Ŋ FKy/��h!x�%%Y�c�Rm-�sг�����!J�V��e��R	������wsY60�S��� 9�犀-(�b)�K,2��K7��&��|Iϥm��}Gִ@$(�<�`���|�!�F���qn��*Pt���:��6��FW6;�6�V�	�=���pIJ��Mܘ�+��=4L��J���Y�[W/�P�i�K)�hRKV��'9���(�R)�T�D�Ǔn����㬱� ׬���4���wB8e�0)���s]��e�9��̡B3R��\��KW@�L��DA0��sf���ӕ�g)�KX��گLR�W�d��Rf�B����}�����a��G`O�f����U��=��Mr�
 m��b_��%J��Y��A�D97ۨ砧�+G�U�*R2��BmSP�Қf<?�s�e@��D�(�DS٘�[�]7.]��iXW�2/�ڄ���߹��oJ�\�w�-|�;芲k���������T��)U{�z�͸��M�l����F�C��N3���஢^p߲�T�.� ���7H>��Otr��.w���#���ݜ^$�t���k�A� ��7n-��9��d�z�NZ��֖�Apw�aǗA������YZ��� ��5��33����|,����3���m.>(�<�&u��ě��������#���DEyʏ��'��}�!�ˢY;6���Y�g2���|\.�R�o�����s@�VK�e���s<�*i�tAgl�sF)쌢CIB���Ny3���=����bԸ! �!?��0�B?�����+iѫ��0K�u����3�I�m��������n�����r����7GiT	�&id	N�X�4 ��ҥ|��#bc���AT�k�s�
Y"��Nt�7u�a�d�:������f���hA�	H����޻0)dLW'�j�GIї�����OU'����YH��I���	#�7�;�*�^`�[����I6����`��5��qpR��*���n��6�^�TQ�z�i�Huz��J�C�CE�_]�bk�O*�ޣ��9,��5��7�䅚���"��U�5�]�G�D&�F腛r��Q ω��5�+uvI`�[VE$�[����+�7�����r/�K�p0���xfu��w�0o�"�NHNi�n�ϩ�>t�����>^F�C$����ZS0j�ʭ�x[F���"�٣1y�D�Ў2�9�+J{HUJ��_
ɧ�r�ʻBn8N�?�Txq1�7��kQn�q-&��ؕ6�F�N�8��{�r�c�>�F��#�h���|�3"����E�:6h����;�������g����E�r7�3��]�`)�6A�Xq4�c4�E1t�-�堔۱�i�Hl��㽄���M��O�Ҽ���cy�l�./~]̈́��I8���c����~Y�͵v<JN*��c�ւO�IC�����7�ʭ�
�̙j�ϒ\�/$�ի�:\��H��`Sz����ό����d�4������ĺ���w�yoJ���J��*���%�mM�'��4���M�Y��O��9K���֍����O���9���j�T-���">W���ڸ���X�	�x��i������
��S�w��0:���FJ��q�x�c���'<b ���ͼ���G�&�j�Y56�J7f֑��B�pQr�m"9(T��趛w7kS�@\"���5k �M8xi��..����kP�4���g��i�WD������to�8o�e������x�J_�X�13�N��_c'N��^��K����-��B:'-&��F��Ҥ���=�;��
��֒,xS�'r1�d J��J����KUJ�[u��mRU���S�2�Ν�<�H���:r��k��M�ĬF��R��4�$�o:�{�>���	T&�CՐ��']z�qq�d�	�A6c��
TT���Q3�H��R�8m�e)G�?���G|	�nͬc��5v�oՒ����諜�M�j9i]��.�7�&*�w�� �&ɦ�rP�z#i�a�xP���f��T��/M���f?�@-�rփ.9�j�0
T�t�/�K���R��!������og֑��F�o�7�aU�`捽ӫZ��rS�j&c�I��@�wQZ��!g�Z�թ�X����j�;�(�Z��{��R�,m��v^�E��#��(]ͬ#���&R-v���~��]�>Qf�n��*8*	C6���Y�!	r\J*v���1�V�8FЩj����0j4�^I#̃�}�W��zf9:� '5a���r0n�CS?qq.m(�%F�q/#��q�����w�w�|	*N��Y� v�����s�`����_��������T�C�B�Ɯ�d���,�6�V�	Fv�6_����N�%5e���7�ۼ5=� ��(I�^�͝Rs��&���JU�$ ��=|C=�@S| ���;�
�+��\�k�b{����:xWdu'r�/�܎сN�:�A*qj.�I�U�	sL�'��ʆE�/-��ֳ�����
��N���1Y�����4�o!?����[���a5���9�U��a�$����";��-T�K��bi������ �q�	��h)J�՝�F�s�ɡF{/�k��A�T�/���^p���H铂�3n���#�����ل�V��)��j�&��F@vy�E�ƙ���@��6�"�c��=*��C p�`��w�_�񲐪� �U�)�i��2�����?t!<�2�%)�&�H:��#�PW3���V��#��aM1��K7M���y�z(mtˋ��o�>�d,��>T���� v�`��Z�dÞ��,l�\���JTAJ�ٖ��X�a�*>����R�7�Q�R��E��_��u;�����;�QP��Y�`�ݵD[@9�r?�'j�s�k̹A� Tʘ�_�0p�Xh:*ǁ������ZL�����>�O�&EX�@Z��#�
Log֑C��~�l��R�    uu�+a�%K��	�o�VW�@6��»��W�(y1�GI��KMc},�®(r'EC������-�~�+AA԰GH
���Za_ەp��qA�XTz��<UY�Ѯ|[�V�xc��[_�6�au^4��Al�-��=�� n��o�5�Z1ź���2���%��2/��ᅐS�p�x���������a\�ݞ�uލ���.n3pvs	d�e� 3N�l�5���2����o�3�+l-<�b'"W-�k8du}�p�Y�W���� �1Gn�qdBLM|&��	�?�����O+����J�e�V�O�A�="�{ ��r�d�T)�y��wѷK��rY��cU�Jm0��*	�
�3I���ʾ.E�R�^zε�9��i��d��'l��l��pV[uM	�#�؀�s�ĥ�2�8�=�bEuW��qk����&�qb�X£z��/!�7gֱ��LW�	S
>S�z%x����6�_v�$n�88M6�f�!�L%�+*�%�iW�rk� ��\S��T[�P	��&^8��ܸ|_��ݽ�,�r������A2H��H�m@� 3���:X#a<�=o��:��������w���qt�^\�d���`\��O���bc+��V��D'=n��N�#̹��	:N��[t
sܣ��'�)���~7|�f�2��'�= l6\�P��|v�;�����#,�.��Z��Jai�)N�s�w�$�Q ٫�HS��)~�E��d�)��a���ꌩEO�+�n�z_�6l������(
�*�҂���F��V��s���$`jT��to��S�V��O�4|z�?��7�͡�=��;���t�d�){���6��z6L}Bi�8{;��O���g����T];��m��7���檊<�(F�ϒ��#�4��@�c�\�}��_�)>%��8�b-������L��%bM��EL����'�c~f��4R7<�����������������������}��^3~��:�1���A!i��Ph�˒v�,�q���l��Z���K�J���N��/��	|�&��2mjE�hҌWz1�{�)Ƌ��:%�H"rg�8���}����.���e�`S��t����̯^R�����dk!�AI�uxi�z�7�HI�N�����QK��fr���b'Y��_��y YlLa`��+=���~Q|���E�v	��Q1m+d�#�S�Y��bR⋣��M�9Ї&����z�t���)�L�<ՒV�l�dҭ@�(f�i��~Uw:�����{�ez$p�
��Ě�-��7K�QWw���:������2��x7��Ÿ����'���n�R�!�,�Q.�Xr8�}���$�@�X���+�)\�T��k>��`���F'��[�,|��ћ�5�q���t���7��boq���1��[��_B���#nֈ;'���u�����E���ZI��nP�NP���������]&�~�R�NY
��.�����=g��*�D=�>�y�K6O�[C���5]7�Ҋ�҇�8���:��K�@0M8[�M"\��L�e3^#��{OTt��K���v�]������S���6M�宻����:NB�s�����J�P��;�dM���*8E�jP�l�x����7�u���0��L�@?'fM6|	����g����8vl`�6=��;iiJy8����ۚ5+�bQ�N�8�|�U����׆��mP0>I�)�
:/q�\y��T�k,}Z���ka�+�n.x��#�ƍ��:�"q7��@�n�0(���2h�d�,5��B^��]��)\�f���ՙ� [���CoN�3�N�@Qqs������>\+���~KV:uو��Ľ��I���`����C�!�O�kB���p@�/-�Q�zYϊ)&}
�W;��I-!�ֶ4Tm�6�����^璓��*�O�߱�d��[��ƻS�����'�${ǎ��R��:�R�5�F����?��WWw�S6���I�c��<�U��$i>�-z_�����3Au�k/�_����r'أ�n��A�n�l�S�ݲs��r*�M��C��~ꨉW�J7G����:It^K*{�OP�BNfX[Ku1/�O�� ��ye�i�B����ښv������2�R�˄�(��r�8i���@T����-�evg	�2�{�[�z��3i��K#�|��}��#� ���JPK�̪�S^�`�ɁA˷�c��F����m�c���S��8�4�����x��V$�E�no`�����?�����'z�������LÒg5t7y�qݷw�%�d�'�y��K�}�u.Y7|3tJ�'Jj=(@����l��@�o�T�v�x��&b��+7�ߠ�~�}Gy��������~�}v�`�2<7ظ�kƧ�&��o!���;�U�p��R��kyߦϞ���5&o���2�B>�AQww�9UW�)�z�ٹ.�>{-����П���F%�Ӄo��9o��N�[tz�"���=N:�V�����B{���/�D�8�����m�-��;P:q_�F��夺�>F��D�.M�v�W�X�L��Ud����[<b߂����/A�3-���9�n�l��Ym��d�r�\�U+�"�-z8$S�-ż��Fi�^07�$a��ن��Ż��;�G8_�q�^=��]xX�PI�Q�0�UhA*�j��~$ah������r��׆Ǯ�V(.G��v;�t�Ƌ�Hl��[.�M���td�km#f�QP�K�g4�}��z�nCq;��+4��b:�"k��� M�a��f�����4<̯hb���$�K�k�)&�k���V��	�R��I�N*���Sf�+�N��W�� �U|���[ݲ'x}����e����^^���.���9o�l�c�9���Lp���	���Jq-�tjC���?�d"�5"6e�Ac��ҋ4�ٱ���q�DS�|�n���2��-&��~��S���'�ت���tֵ�&cohe�ѭ��#n��k3���Y��Ai-�-�I�P攛*׃�T�=e����Pm��Ͻ[��)t�>h�+D�{a�i�X���?���r�w[r���+Q�Um�"Ŧ�|�l�Ʌ�ʹ�cd)�g�t2NX���ů�b�f{.ܕӶ�@G�l�q�}u4���.�&��T�Z����]�%�\�?�G��)~��'�Xo������lô�wW݊� -d%r�{�TRZ��W>�Z��Tki'V�*w�ԖAz.@�ѧV]���\5�M�O��g�Cѥ�$F��~���?���tjT[t��y���r���'��o���>@����h��:+��tnl{�i�ӈ'^ImV����%�P�|�NqM�\}��F��Q:r�4j�0[2�(��)~H��Γv�1�C�g#?�قOf7Jg
�7���yYSj�m�,�r�`t��I���TI{�.E�6f�&�'x~jd���M��6�*����琼}�����E�PV*u�F��f^���Sd�����JC�����\%�{�uv��"���#��5�/��'Υk��N}2<eD���U�>5�©O5����ɺa�F?�Ra~��t��y̓�!1;��{/��~	��� 㞍�CA���i�{Ov�����FV�Y�7�'��v��R���I�P������@`�����S���z=��/�Q;���f��#��O6б�m�ឤX��1�V�'���|s
�vI���
����l�\�9�H����]Y-�2E�.�{ �Mw'�G��g����@�ݶ/�(P��X�,�$H[5��C��fm�K��
aۖ0E���vx�2�$�R]�TE�ʓ��O�Z��%�jY��dӢb�ةɃ@��9�Ήbh�ӷX}�}>ɏpi�0�����f�+Z��c�c�ǰ|���Y�.a0f�c��g��~�)�+��`v�k���%�XGu&h2x������
�b\�Ş��^q��z@_&|\�N��/�o��H�	�V��G��8X8
��!0o�̛%��E2��
SΓȗM{fSuH�l�+�.Z�s���    ��O�*]��Hx}���qn�����0��3)�o�ʛn��C4�P.��֚�i�V��駩��}H��d��-d-�5������gwwo<kzՆ�ؾ�*I)
U9�B9���-���(�k/Y�L��;��0h�����4����l~��K��(�CI�;SL�[��K�Q��(o0�XjQ�j&;7���O&�h�����	uOqҽ��(o)�[0���a�o��W�wH(��Ki�eP"��6��H��E��U�<62J�l�e)	f�~���)~
��O&�@|�-:��vbȸ<�:��Ҝ��:���y�B�R�Vo�)�`P�ՠA�8nSu�p@$ ���-�Ӻ��q>��.�f����_8��^�%��aV�fq���,a0�F��c��6�oM��`b�4��+����ܨkڲ�+lt���bO U3��R~^|]�u�nz�q^(��Z�=|f��6@�>�qw��K����v���=a$���p�(%��w�{�� ��G�Γr�8�o�Iِ(��(��ߦ�I2��º�(�kw�� 8��J�S��zP�U�HR�+�Ya4%�Y���˯m'�*�Hbi-�X���?Eq���Ne�E�q��:Ƥ��Cث1E�[�QBF/�NxkP^J��K�h�b/=ï�v���,T����I.�
�>4;
��_��������������?�����������n��h
p�tIǦx�8�7��]�|q��YQ7�ujxAv��4�l��8���Ҳ��H�]J�@��ݳ���M�;<���V�`�U<�������͌7uf~*�_�7�$��}�xY��@?ʏ�5:�t�P������|��Ag�%�0v�th<���ީ���r��OKr��R�H*j7%Ez�S�;��r�bS9��Z/9J��y}��/@0p~�;���]v�F)���6���)~����8AGǲE���\��5O�R���U� �lG����9�΍�M��r�"���N��U;I�w8#�2�i������S)�zH��T�޾^�}�?ҝ'r.�Ko��0��Ԕ�U�?a�����H�c���Ԥ�פ0�&}�f�ٛA1H�w2�d{2�00�b1=ՙ�-�0pt��?a+����v1w鶲FL笵���x3�M+��s{:o�b���o'�M����&բ�ɶn8���.׳Ϝ��k�x�	��-O���r�%�L�x^��h���}��y�bQL�[�|�xT�
/�7��)��酲�_���%!��p����^N&w�9����?��:��_�$ޢadߌ	����b�Ͻ� �P�c.l.�o7��,�;�ۢlJ*�V�;ј�\�ڣ����^|0P�BTƟ*th�mh%K�*�<����U�P���6x�5�D��\��_������������G����ih���~�� �5��Ԟ�x4����Ϙa�`�]!ǆ��7[XJў�ԫt�E��W��62���)��Q�ۜ�J�k��K�Tm@�ݖ$��9r!��6�����zц�+�/ 7���l����|w�ڽG��v ��B-V�����r*{�һ�zȿ� r���9��S���sa�zP�=�3�ؕ��|	��:���P�S{(1_�^��i��=y~ ��qi,CT$�d�/�뙙�j�@��s����nq�$
d�we�E�\(NOs� 啑r�:.�k�K�gJU��N&6A�䯃�sG�׎�*1�#�U(t�_=_Y��wL��+V�ƫ_8�mx��^s>�(���b�����Ʌ�1G0�J^���S�U�P]��'�#a����S$�P%H�-/1�v��:�K�Nn�0���I��3��!~��V�)l�K!�*�t�o7O��lx�o1��*kԂ���������.!�`�e	���}��6ݸ�S0�w�A�v��7�kp�a1ik�PN?:��ka6�"�x���S�����'r�
w�Dj�|V*����5n�˷�ۨ����*�$�隢ܰ��tN,����lG�to�f�ɰsɈ�l��(R\�M�sI%K� �E�>Id�3)&�i��Ԋ6[���ŋ�;D�L1�1o�K���m) Y��6��Ǫ|�in�Go�Lؑ:-[v,�^�����,R�T7~���ќ���(se�H�`U��#�����������!(3/n�
d���~��2��2A�ļ���G%n�E^z��8���H��Ž�J�/aPF�m)s�F�7��x�����?���z����<�	��GBe.���,�lҨ n�Z'��>�R�K��k��x�3����������G�,,@?�v��H�:v1���������.a0.
�1Q?=�f��d��ݒ�o�o1�j��)��$h�g�F����~
^��/B|ԊD�sN����h0�`�e��H|yr�e�/�^4��@��?��͓vh4��a�Cjt2��<��t��|�t
Ϋ��c�'3ڈ�%��'	t*!ǖ��ē�u�o\m�ל����X��(Weq�E��j�}�\v^Vb��� ��)~��'�xk��N\{h���{��JiqZu�"��2�niCڼ���'�q+ִՠ\L8cm�4���􁎸�g�u���ڃ�ĸ~��L�&$(�{�%�2�s����-�=�~	���z��#SR�JCǾ����D�ͱj*Ur1\�w��B��,ٮ�S���;qW׃�F]��P�u�AIr�cϔsMN�IbX�P�N�U�����؋�8L����餭{�LЅ?Ztz�����w�� ��]���������ǒ'���v�r�Z�P7�Ҕ��#OƳ�5B.���$�����/ðc�u`��հIRp�mPL .PN8Oz��]��<���L���pVL��v/���x1#���fX�Q�u��@a�:v��~�b��|#����A����v��]��̌z ̴MY����B�wD���?��O��/�F.>��ٓ��_���s˩IK�w_%�A«�1�N՝+�n��l�|j�P�z�b��TY�Q��KZum�]Þ\/��Ы��ӛ������/z#����C���m�o�K1T��p�T>iȨ�A�}�d����!�Csi��7�^z׆�Sp�]~Ԥ\��ڵI����%�(����h��.�r��,�sK�g,�����͠ޭ��(%dd���ɽ�o�)O��4jjA���J��::?6���"\����Ӯ���%N�Wb.���K���tR�CGJs�Z��&K�]b��+�
R���hK��j,��ֶ���7 6��7"YI�i����t0�d��:�2��养᭨��n�p1�����G�t���c1����r��y�93��ߞ`
b[��������,UΨ+#�����H�<נƍ��[j�}V��l7<GjO}���
q��=Ͷ��X�u�u�%�ϓ��0^�a-�SP�qXQbbȪч�]/q� (e�2L>��R�%��Z���h1��2���%m$��*`�Ļq��S�U�ʕ�ֿ���φ[Pɰ/bP��Ho�L�����#��T�e�W޲�FcSt^YfK*�Q��-��F����i/dOx�ͅ�Ka̂i2������Uj5(�纓ξ�P�h���s�kjY?���i��8���~�_J�¼xo/N�c3<n�U�ՉF���Q|�v�Ά�Aﲼ]ۼ�7 ���D�p.E�cR���^�Ž��،���k�����ۄ	��p.�R�$p������h��{2������$����1��b��k�c��Z��9�1��&Z�@ǐ�)��v�DІ�M��/��u;s�-H?��ܠ���y��N�j�L?�h�>�d���-�ݻ��/.�2�}��)�H�Z�r��g:��Z�}���1�	���]Ӂ��4C-�;���R�V��ǳ���Z�������7y<k�q���Y{��;��J�cUM%�f�����/Cz�ƨ�w�#�}��a��c�Az&��>t�:Ɠ7�W��(��^�P����ݡi�u���L9�>U����
/�,w_0�\�&U!y�i�������ű�|Ns�>�Û'����l$#��I�1��)2�|
Z��;�]��xkX�r��Rk'��8��(e�T ���7���Ў�9"Џ���h�%G�    b߭�Y�à�u�=e�?�/�'����_D⪂��cOٝ�'$��?���J�->���Β:k�]��>���*��࢔H�zѸ��Ё��	�s>)R�jqA[}�0�Q�Z=q�ϙƣa����~V��ſ�1�RM���qd^K��b�L�ߞ4����J�`(�;������M��zG	޹��ڂ��G�v�D��K9�^T�~q�CLR��Bl�"�x\��mM���;��5aG)�BV[�\H����Z-R��T��%�^�A�{���]a��e���eɪ?�fi
\�d�LiW*6TYm�X��_O�����ݗ+ӂ�D��_8�x�>������b�KF<,
u���S�q��̓-�Y�Җ1��n��l]C���0��.�;���M��f��Ѕ�I��S-j��O��0�XD�!=_,�,W�=���������w_T-�������C�vq���7��lzU8������bWtg�r	TV�}� [����өF�4ɠ�F3�冕joM�8)�G8���[ߦg��eu�^7�Iq)���ן����͓=(��2(��"�Ś���"�lꑮҗ7�b�Ky��
�ẉ��Bv�ş[V��YE1L�|37���<%蓡F�^#��D㢔�5�%;C!��c5T��l3᱘Z���D@�48{�.wl��ц�VjA<�F�=J�u�s�&M��zo��y����fj��������^b�.p��i��� V�\]/��U�u3>�'f������z��(���)݌Uڵ�K��ލ+�jٯ��`�E�FKA�� |
<A�̢n0,���7�n���8ܶ%_�ȦhK�[�l�Ȑ���ܷk�g{Pr�RV2�(4��<�eۦB�-��z�m�*v#�X�~HogO��[Nk��T�%�0,R�q6,C��b�	}1z�5I�{�2��e܋��_����26�;�)̂�Ǭ�T��ؔI��켏/Z�u5�p�ܝ����t�m;q
����aL��
f@��ډ�wڸ��`}J9%�>h�`f�{.Rn���@�3y'3�ڄ�hi%#�m�����q��AL��-��5.J���}vt��y�gM�q��W�T�����@�8�N��{�S�w���9�����`��x1����}Y�g&	��	��a���H��� �-R�_�K�fs������ttO-�6���_N�D����cS<�7������NV�I�<Â)��ܠ"D7���{pVF��g�4�i�M��Wz��f|nvt�^�Ф`?�`cd�A�&f�V���v���X}].棟��M���L��z�#���e�
������߀��ݻlo�v�(���߷��9�
ՠMF,Y���˶�����r�����^���Պ�Vl'g���n�0vS�7)C��9��YOd[��{��e�<k^XA �?�Iy��y�fW�f�˧�l�	���m�7��z����,�����j��9�����gG�p��T%�8X�;ʍ��r�K6��i�,A�ݫ����]����skxٙ��3k�l��B0�^�>6��l�|詬�#J[Q������������f֖-f�����w�l�Z߾���6�YXׂ;�&Q��6e������FH�J	K�Tέ�x*�'���t��T9瀿r����Q�{v�p{��{jM���k��cpl���l\�(?�FJ�H�Q�>�47�#�o7���gs�c�(϶���uj�:�{ry��),��Z!����C�;��W#;׳�$������jP��1�Vj�
�nJ�����	���{fQ �T��.Xs)th���.u�+_{B��ԕ�N��}D��������6�3���9T�:��qS�����W�����8��C��Bx���z^�U%�'���z��Egyqo�^4L|�
Ջ�V��B����n����ɩ5m�_�u�V���)��5CU_�ɼ���}좴g*s�>��vq�%��;�2��c�Q͓y���^���u�V�_�y	�eU�``�w�#�c��Zʙn�xn*'�~��B��Z�-0��U�r1(]&ڬ�3�f��-�Z�����W��]��i94�o8��9&�0|�Șz� *�^ل27��7�; �`�c�b�?.ɗC�s�n���^�c"L����ȡ�H=h�O��t^�����z��-��A80|h�A�B� ܗB�0V1=L����y�k�Ԣ6 h���쌺T�?4�oT+�5k���Ȼ"A���[Jmn�Gt�.D8K�3���lH<]�q3t�\pL�u�h�ûw�O��B�:g]�u����p.��&��:�y?7ތ���[x�3������������R?�pow �F0�3߱YP{�myNt��+��Iȫ��_����౦4�ܸ}�*L7��4���"�� ����yD�c�O������?7�UB�&����K�����
e��Qz��c�qn���ʹ=;4Vr��Y�:��7��[��2��Lh���ڮ�J����6]�ώk�OU����
<\aۯ�L��զ'����{�٣a����w�S�>�ۛ�P�3})�ƌ��d'Lړ�{�){�5�J�˗B�� �S7�t<%_c&�ײ����mkÇ��>O�4��oɖ��Rwf".�pE�0j/����xQ��и������d� �d�3ǅ9�V�����0_��ꨒ�T�|c���`�挏�Ar+���#o�~�!Ii�&��:�59��v;�c}�:峿9�PI`���^�h=��;��5 ,�E$���3��CS��-N�WH����f�bmNV\�s�ޥ�nq�(�31dלq�.Av�uֲqS�8�l�ߖ��#���v�'iM�T�Ԙu!�������B1�͗>�	�������)!ݬ&���k�:=:�E�)��%D���\�f�!L7����乹6�F˼W�l'_�T�c�chIN� ���՜"$Om��lx�����o2�p�3�ոq}fH�kwΏE�#�y�/�_���Rq�_����������������������/�����߭��^��$a��;�jV�����I�yE~F�;5�Q�o�ՠ�;7����*�C�M}b��fRf�f�D\R8�\ �G�C��8�d��8�7��Qca���i�w�;�Z)��귘eƫIҩ+N��ߖ�����MU_26��}ge��]�U��i|-�@mi�A��E�7k�<ܱE|�%���
Z3ѱ������l�53=����^c7M����hen�pow���`��f���+O&���U���E�>�ϖogD>�t���$��ɚ�F3ۺ��F�K��V�,����U0#GmK᳡`$�0bO/'�䜡�����ۉ;��5��6R=7x�CU96��pލuÎ�
�b�;_u��+sj�pow@r3��f����a�NFS���������Bxq:w8��O�$I˿٠�5~5�d�2��CM�BH��I��~O��(^͏�Z|�?��������1�a�dw�؅I��u�f�. �^�d��(Av3�0��Rl-��̒�94m��:೛���,��ܼaC�˺.b��hLH�ݟ����#=�m���CO�>e�]3L���^��T�g�K0�7�N�x��[7�ͱ�;�l���$�#�2�b]rᩎ[�s;򑞢����G���[܁�Y�a˙�.���l�����Н�LzK�DtVv�+�&�S��(�u3]<5��l������<�=�G�ϵ#�w(#�~����l��l�.�@��Pv��rC6%h���8Y��O�"�t��c�Rͻ*)_}�T���mJf�d�-i����r�iZY?��g�DJ�Q.�4��E��R��R"S�_J��~�{�{��%f��0��E�?M���w;�,���Thrq�-~}�9�;	�
F�q�&%��k{�~�Y�K���p���,4v�|��T���և[XI���� �.��Ggp�JļDi�6ߟ�R%���j)�^T<���5�BMz軵�'��W0 ��2�X@��)q�R`����6�'Ħ���|9�
�۫D�I^[	��V�:���    &.^OW��G|�V�*�)����v�5�����D�����p�����oO1�4�e]vC\��&�d�����::9~.�b0�̖S/�/:�Rb?YC�p���7�m��D�^~��Ѡ9���;�BA���1h��Y�5��,�g%/����=S�z;qw��܄t
/��(�GE/K*y�Y��nm���
�$E�o!�L�+ȵO�6���D�$~:�[���l��]�EA76=s5����G}�K[��`�����Z�����o�{x�7J���3F,#��/+��佟����}�d��,~�[zb�zX�5�>�(�%��oy�H�ЃP�͞|NV���9����I�>O��������Y�����G(������/6�����0�}�ANw����n�e�w{q�)�Qͽ�0�R���YR�j�������� (��l��ɉ�������8w9�~�Y-_��>���#Ab��E~������"�O6��v���@�Zӽr�.2�5�� ��^
�4�q�k�=�:~�Y|sEgq;I�/a]��j/�B]��W���<�Uh��i�ן�&�ig�è����(%I䒗�S���llp����N=v�AqO�!G�nl��)����\s�$�NY~I;I�p�9�XN�4"�׃���;r�]�"���gE���bW�����B�����$�c1��c<�IA3�A��t+��ID�ȗ�/�b.6��&��,��R�7�N�AM����>٠�%䆞�9���d�O���[c��˹� wN�hh�Z�ZNEk�I@ƹq�>���<�0qI��-^�YT9L���~)Ѥ}4�������y�=��zCOgrX]U�O�˲���:W9�� r�.RWY���,;gN�X��ӍTe%�.N�f��gZ��陨z3�]��X�j�S����n��A�n�l�SR���rqD:f[�)��`M�R仨K�_�zb�.J�5�#��V/*z~���;��鵺$���o�-5U�W3��4��"w?�v�:v%����	Ҋ�<�ޙ�8�w�l�o�w��B�6v]϶p���S ]agݚ��FG�c�!���g���"{�6xH-�FPݓ���i�=� �xU*�L��W]���R�a��ZB5?
�f����d�����5I�n�h�m��k%�)���GiV>�]:L�Z�gS-�����(���T�6�K�P�R���Гe_}pϽ���8���(;^b����wyw�9?��ҴD�}A&��ϙ*�Zr�!�ڇy��=c�[zLv�`�f{��'�v��L������eA=K)��U6)�tj���wc�"�j��/��w�#h��J,�쮗�]�c[
�A{q�~\�VnP\�9M���t�ר����Ԛo%����}al�L1�9�%y�M9�[�����^!u�} ��L�׺���y,&D�d�U���)���w8FΡS�T$�����P`���J�Y��m^*N6�ϐ���Wm#�kӰ�'�0d��r5͗�T�KE^�t�H�p�7���۞Z�z��Y�/Vy����L1��<s�~&�/F�7|V�{��I%��A��|�d�#��[z,A��5�Y7�}/���ϧXj�ɽ��S���Cf-��z�A:�^e
�o�厣�@�2� ��/T�gQz���g���/l��8��`�9u8)��.7`PӤ�������}����=��-=�0��s�T۫t���
�K��T1m���ᖤ�����ȫ��.ō����Gv��.Dh�J��TvOx��T����N�B~v��9��ݓ	=]�-=�"��FKlƔT5�?�v#�\�|go��pP\�T �����Eo�P1E��P�Rm^��P�.@kxj�7'��A�z������)���ɖ�s�|�"��~-�b3���d�}$Uo�^���f��a�	LGQ�ͤ���k�������������~���A;�CNFB�x��*���#���L�^�6E[����I:���3ep��x��I�~�v�^;�@4��?Go�l������Q�8V���L[��1��mdfqoZ�I�)�����a� EgE^ךUq�̃jz�=Qm��uy��A�"��?
�f����<���1=2��Y��)�i�7Q�ڕ^B�g��U]k�<x��+���L8�S�)$m]�5R�6q�Vk'J�?��ZI_��Î�j7S�R�O6�I9m��V{��&/��;��T��z�h��w���tQ�5FI�<��k� ̷A)9��PiApr��<��%���O�m��c�IT@��Es���S��`��'�����N�@���8�����
-I����-"/��ڧʉN������0�%Σ�L|= TC3��z��g���B�p���������z��-=�,,ln��ދMզ��F�'0��l
ZG��8�(e��>�^-^^wi�,��R��B�~
�W�8�'8`�L�ÜEq��`+����O����B��`;�x�[�5&�H͕%�Q���&�H&~����_Kx�"e��*�c����-�G����V|�S�.@םΚ�kT�Oq��s�j�:�Ԋ��ˑ�(#�ÿ�S4�4��L�bbe^���������:�v�00˒ʳ���t�hRO����W�}P�{���t�`��Ps�8��2�*�ޞ�-��\lrOku�K
�Y��5w���X{�eX~K1��{4��Vb̍��<���'�YIp$�e�$�����f���=��\H���V�ڬ
g�x��Ík�/O��vw�bM��t�R�_u���zR�g�A��n���{hP<
�����8�[��~K��|�/��F�n���F]�AY�����ԁ�����ە��K̂�ìde�%����|ݷ�K�d�����$_��m}�A	^��|*^25����%� �B�A+��+6�kW��$sV^�o%�ˮ3,]R�-z�#��WlNtK���aR����sWl'��"���g���@at)v�b��O��z������w������T��:�"�.�h��H/|Q˛th�*�bp���������飂ެu��>9]���Z̪Ak2�R�s�E��?�1�6O�h��r�t�P��.��`
<JU::7�v��,Qڊ&�j�!W;7�=w~w���zK�4���s[�<g���	�T��`��K�˾��0<��r3X^#H�8]�=�!Ś���IK��D/��ڄo��	&:M? ��%�&����R=IP%KV��y�!�r��]`w	3�w���l���i2"��#Wo#|ao��O�Zt�C*�K-��/y|��]^��t+��&bH,�t�0X����5u�_y��[e#�l�eQ���v5�c�I9���&�L�����*�z�R�����)�(�¨>U���RW��5V���v�w]ݱ�ɉ*�g�ٲ#���ut%W�_�aΜֿ��7���8ߋ�@�����AJ�s9��)�$w
z�5u�C�4,=Q&�����q�s|&�^O�֛Z��6J�Z|���K��/�B��":fy��2^!��#EC���}@��w%ޱ!������-���"ކ@��jA��ܗ:w=�s˽�R}n�AMJ���$^���;��
�����k �Չ�<��k�c�1���E�\��y�Qy�ǭ��)~�u��d�����)T3��h{��E�mļ��&�CKA�WR��2'o�-xK��
UK��� ���5��h���y`	2��K5/�R;�s�� �h� �[����6�+��î�D��d�/�b�h�7�O6�1�l������M���qu/k��>�!�n��Jş�5�\������Q��G�o�̬��V�M&D�R�I%i�]t��ek[�C�5�%��}K¢S��;�>v[�_�h��u����w��K��V���D[�Us���0�[��s�>@y�d�����v�)9vQ����o���1���V��d�_��^�7�u�EK5ݬ���¾��s'D��k�ܼT����RP��)�'���Ti�#�)����S����d�ΨXpˎ���v�Z��֫Ϥrm�X�/\����s�!��q��YG%����+�G)�л��:/���
�z7�4���$�nQ֔\�x :	  ~t��z���R٘_ʿX������)~�T�[��o�j���#�k+�9bV��zAy
�7$42ٌ�yỤ.�y�FT�{p,�A��x�C�yEʺجo0��U�L�T�-R�ʍp"����,��а��m��(W�/�"�GY����|�`����,y�64�uR(S\�jz�a�GI7����Ɣ�e�����p���q��T��ڃ��ƿ��n�;ӂ����2"�^#����=�=�@'�ڢ��q��q�t�Ԥ�O�n8M,a�zUE�A�\I��ucd����"��p{sЁ|�gr��{�X�>B�"����6<
�f�9��vGn����e��ұL������A��y�=����#9%��M�LxR����frK�(�S�v��(���SLޓ���레%�Uo-U���������1=��I�p��莋ϓ^`=�i�;ŏ�_�}�K@�-<�T76@r̒j?��f��"�q�Nc���R�V�m����I�#(7�W���p ThH�2�g��T��wR/1k�ɱ;ŏH	�}��$n�����bf��>�T�u܊&�<���3J'�Ȅ�N��l�H�営u.]��K�1�)a���I��LP��/��"��t�U�ꑆQ�S����tS]��0��0��H�>٠tl�ѹ4
]5��L�=��V��Kw�ԮQ�P[;�L�P:� ͥ�X�ko3�X�>�U��8�Km�v��^��/�F-}��ű��0��3����`�w��Ҕ�׳�|?�d\pF��{հS��8皶�T��S��3*��꜃=C	�@7���|L��g���Ş���iN�D�ⱀ�!u�|�/��SԎ۝�G��?٠��-=觠!��d��Uv�
�&BF��̠���IWo���U(��SïB5Y<!%�ga��zN[�5���S���o���
|4l��2u;��Z�����2�;���%��s:��@�n�l�C�������;��>��iB��ێM���]t�������Hz�'��-U"��OEPd���/:�2؁B�t���ޅ�L!��8OB����q�go��(�Q,Xyo-v��O����<���!F7�D�)I��f��^��0�kS��a8�Տ���Y����aW�z�|K�K1�'�&��%�%V[��XK5*�tIly�3n�8#%�(�r��7ٟ�砺}�A��薞�C��c_�l���O��j4)�Q<6�PX:3t��B���o��p}+���y.9A��/�s#��ھ��-\�a�K*����O�tfW��.U��E�H�@�T�HM�aM-j���K��sJ�q�!��SL���Zc�7���^��cU>C�Lګ���`��.�[zZ�PS��=y��E!�T&�M,]<�rSZ|Y��~D��G�HKg1��!���ໆ�'>Bt�@�M|"m険*��.^d�_���0,��E6�����'�Զ�4r-�fT5n.���O�e(�!�b\xQ�A�誰�Ul��e�G��Ui^j2UkK�@U�z�'�TC���3��N:̌���>�?ŏ0�v�l�3����`�H�\%��TP�Y���ʊ����[�` k	;�xoA��$�%ުk�Ѳ�'Q?���J֗�Kֶs�"w�^�t���Wu=�I]�4����<ik��;�_�US+��KrR��5_��Gf� �m$h�eN����TO��&�7���zq����۵����` �%�o�W��ϓEco�Yn�nQ�VKC3��x]b���d���%��I�Y&�k��2�νà`#�^�I%<��A*�s��E2\���XaQ�Xެ�l�ܮ��.��ַ�[�vJ��%��R�,aM�k��L1ų�:A���>&X@Ǧ)�+��ܠ�x�y��� �-<1C�&�M�}ݏ�.�NnqGd�X���6�SY���ڜjk�۬ζ�W�{�s�Bm�`ړ�l�4:�2/�b'A�r�U[��ҍ�]�Ο�~��%�t�$�k<z�@̬���$>v=�z�{�}��SL�Ip����i)��!}��!�Dar�>ȻO&��T��_O�(�	��d��j>�&p��Z�ƥ��rVW��9��}����M`j��I�|T���rENZ.&�J���Oе���=�a�^��B�A�J��R��tӔ��RG��N�纥�/P]�夃wa��_0�e�� �z���+�)�R+�}�i��������}E������d�� �K��`� �|TR��F�k��c)���[s�]V�U
�ْk!���uJ~5(Q�����R���ɵ��t>��_���;�hv�!L律���T�EϻVSi0�C�R@�'Kanл��?م���N�K%��&/�ܥ��Gv�x������\
|      �   �   x�͏;
AD��S�K/����^@�MzgzL�YAo��b(TVE�+�f�"�dU �	2��g"�j����|~Lzr�#�[##�ō�����"뗏XZ�ՠ�`���C�]KU�o��;��s�O������ڢ��w���[�O�&�'�A�&w��v��t�����p�axa��      �      x������ � �      �      x�՝�n;���{=E�7ڐHJ�,�F��	��1��=c�����1��$H˭�L�?Rw�JZ�K��8��:��l�h�ϛ*��Z���Ӡ<����$R�	m�O�&���H��i��u� �F��
��+����_����ƽ�4��{M��	q�*95���v������yJ(d:�袝$4�6��u#���m�Ol������6jE���g*�E)Q�@��4V�>{���l���>�ï �1�y!���C����V�������1tMT�P���ӠȪHQ:�~)t�:!a��Z§&nPc5V�[O��ì�� ��)M����j�4KlQ)�_��ï��^�`ȱğ@��y>�yEg��F�����:�He H�+��=�)Tr�ϝ��:�Rju��A�:���@<�)��Q�_������^W��+fÅWt��Ա��u�^0�!�bt-���vt�+z��
�p��X��W�1�Ωf���	��6-t�4��+z�i?@��.��	Wtᮣ�k-.����Bgs�$��|�
�h�F��n��rX%iHȔ'i��h�~����J�Ų	�C��w�|��J�ZP�J�\���̫�����s����]�i.h��CǑ+�YŃ�i.�>vQb2�<x�Џ����oI떯~MZyva��`ъ'_?���������ޖ�ƒ]��3����������]��������.,�I��t��� �+zTKX�V�Ʌ�{7w=�ϸ��r��Q,wE��c��Êޱ���JkŅ��_wY���xB/.q���P�mk�J���#�v�T�.F����w_��}Q����MW���4�꾼���m9X��E$C?d��ӊ��ء�.� �3����}�(#�̖�z�]����.[�2΁�Bw��W@�}sL����\]M�����eE�@$N1ϥ#���)����eEGmĖ�Dr���S�߫4s-���z��-[���ß]��O�ss3ӗ�f�0�6C�<b�ᗸg�#���n��~E{������~��y>�yE/���q����%nW@/+:3!P��Ї��\]vV�P-[�ܵ�Oܮ�^Wt�!h~ˇ��\]wn�L�H]�'nW@o+:�@ԡXZ�CwUi���Wt�h4t̜zu���4W@+z�b��%����%�C�+zf9q�3��3��S��ٺ�Q-���t2tO {�T�ف�;z\��~:�U������/�+�dh)K׆���NF_W*�8�Q��y�d���Z��j��e�o, �^g)5���oƆ�p�#�|�T�4묥'�������HA^���$�#����<��7/��M� zi�.�����ױorl쩋������s(;�:u�8p�{����g��R�m!D����������F�W�0-��kt-��vp��wn8���q���~<�9�����m�%w�)7ρ�?��؝�׭��5f�w�g��Q�99����v�g������'�B�R-�	��v�ݥ�<��iz���w��=��94�d2Qt-�?����(�Ԟ�w�縴��FXL��{I�"�]giu��|�Hu�#��?	-��d�\��>�e�G�(���$	���w�<Љ����H���Y݃����GW)+:1�g=��ʃ���NGO��}Rʣ�It_�v>:Ϻ��yeF�k|�ǯ|\�����T��Ot�?Gq�Lmg��5F�U{p�9G���u��AU�pG��Bw���Oى۰�n�+י\�U�8�)�=�Ф��`j|�`��:趪#ֱ���Q~)�<�썚��xK�<��|�4�ޑ	B�{2������Oi���NX늞���͈���͝�^Z٣��-3)%��͝��u��:C�����͝��lE�����"�����ѳ�ݜZD��
�����v6��f:Z���2C��r.z
H���Q }躽N��0�f�-�.Y�������ʄ�1[�'O�[٪'��"���M?rx��i������}m��$Ы�%mg�����Qk��g�K�N7�ށ��mM۰�O��o[��+��,)����%j'�s�y��g�L�b���K���Mо���E��
�c��ډ��,'�[a���]�3�{e��F%Xo�E�il�G�A�Y�:��`���3r�W�퉶C���Si��<�e������v~�e�.t����n�wgu�裦A ��y�=�v>��4Vtf�k-�Aw���y�3�v� FKX<�Y� ��腡r�!��ssa;����LH�21m�П���o��ݒ�F4�c�P!�X��c��6��L1��s�^�R蔋�#}{��qY��l/@����v�-���i�T{9A��j��z�._ �$JI�ϡ����Ƭq[����_�h�Z���x�Ĩ�f�w�:���j�\�����#�V4��ł�
澝��eZу�4��@.��Wv��1Ό)�v|ƅ~������$Z�z�P��8�4]{�Ȟ��Mx�~��Nٜ5Y�갺���V7t��n��Μ�М.��7/���C��5fQ��յ��]]%��m�v�'=��ݗ7�F7�e=1|}G��y�f���T�-6%�������C2�񬮧W���X!���w�۟����G˖��н�<��\Wq���5�.���[�8Q��c���8c�(^J��Aw�*NF�����������B��*NF߶���R�B�ɵཥ�sч�Ҋ�:g�X��?Y�8]i��u��v�D�Tqz��,I��>���|��X\n�cD]>�4�g���2�S��h�Cz���3��w�<�KHeEgn-�T�8\�.]?�(��c�a2��ݥ맢g�y���!�o�\J��0���Z7)q��cPk��QH&���\b�������K��ʒ��󆮛���>�v+�s�օ�Ҝ���.+z��IPF��A��*�GW�Y]�I�u�	.tW��|�^wV/��`�,��*U��>r	����x���]s��>K���E+J3�/I�g;QQ�iy��|=��(�)�"��%��y�i{��D��k��]��|�D�d�M׷����DŬ��"��$7����2>�k}���C�
�Y��kĭfa�O�����V��5q���SN����3�:k���U��BwVi�F׶[�}�h��n����Ҝ�^0�}0F����;�4g���낮�[Y ����Js6�м[��6@�C�Js2�Ѐo<<�mxn4��?W�9}k<a�]�ɒ��ڂ�X����O�X�/u�D�F��qn�)�V�҂�=��q.:���gk�(�bx��q2z�;��)�܎���nA��>�=0#��F��O� �C�*�a��:{����6�������h����+2a�QRb�k�������[�\Z�:�k���^Qv>Lm��L��c������+�|���%�x���L {*���K*�z��S홅C�c��N�y~+Fc�a-F�	�k5Ugv����s�ѩ=�}����Ė����:��\�������@#3��{�Ȟ��`���<C�5&p�;�Ȟ�>e���v�����8�Ȟ�Μ�,�=U�8���ٳ�-���}F
}��B�П�Ҝ���[����$F 6�����M��������H���~��П������N���G [�93Lq
�U
�����<L��`�	����`��_�Rd�A��<o�3��[�:��5�П8<v"��/����j?���Zu�{���>tou-���"Zf�@w#:}fܡ�M���&L.t�1���%�]f�dIy3�s-�'�4硫���ob1�!�П�Ҝ����7����F:�枯Ҝ��9�Tk�'�����>1�8���q�uR�R�A��ؒU�J�e2�t�z��x�y�R�P$�������<��V����!3��.�~t�aEo%`���vZ/��Ѷ�>l�vKb���:�~��rtλ����1�Y\��/WA���:Y�Zc��P�/�^���((�p��Oׯ�.i���&&Ȁ3C���E�%B]ыV��JI �   �΁�Tl��1ƙý��ݺT�B������}��J�P�%�[����Ӡ�}�g�1��8R��B���/�y����e�|��,ֿ��]{[уr�0 �h.toHs.z���:3B��X�t݃~�Tq�R�V7�ԧ2tt-�������6v{�;��#��Z�GKA�H��:��-�嬾�~��t�;�6�tX����}-���o��t�Qpk1L�c��E��v�iA'����ʶ�A�	i����/��׿��m      �   �  x���Oo1��3�b�(#ۉ{n�^��"n\�V*�j�_�,-��n���c���ֳ�dr5�d4�5��6mk!`+i�Tn.ʏ��f����q  0H���Ѥ�"�  -"]�4�'I5��3lmkQ=g[��ӿlF�`S�x"�G��$L�'
Q)�p�������iF�X5(����g��\�q	-�8�Yrs�T���!�LY4�����ŜY�9!S� %��0�����n����~
b���K�цZ��`O�`+Љ������x���Q3L�:o�N��g��@�����5�t	a�Xcu��0^��!w���g+3�$$B�^/|F�`���U�S�{x�D"V�^A��n8�/����ٺ	��
�9���@u���u�����Z.-8J����P7_��̮�3uI��X�ke������O�]����g�ۏ��h��w���fS_�������>6�Q�	���ɑ�RJ,�[s���|�ޏ@8%���}�_��N�8��a�R      �   y  x��Ի��0��y��ȑ�3��]Z�t͌/�Sl��,�>�]�j+��,Y�oƿ܈$4�FPE�T֮E� �X����2�RԦ��F��{�����BLh���I%�\ui���.ivL�!��ɻ�����N����N!�jm2��/�.����hn�U�\fՇm^�ڿ㉯��N����� �ӾJ�q�����t�y*��~��ogk���F
%��r����p��zėV
W[�t��n���r/�8E���gp��bsQ���9`t~���k�u:��1��X�"��5"xS<K�I��S�]�=����n5`o�H8� l$|�u:	&��j�/Ov�Ρ�$�JU��e�5p�4��Јq$ �K鿣_��}���ߏ�*      �   �  x����n�6����728CR"�}�^�OO�[�w���h��W	�|�_`�#j8��=�iwJ���C���`v=���a�c	�˥^����c��΃�l���������X<��{���P����o��76����W�}G����|x�C��d�ѱol~�#�-���~�|�H�y�=G����ч��p><xt�j�7�=!���/��,>�@^�|x��7��%Z4��U6��_,>��o�gW�{[��O��o�����������cٕ��я>�Ϸ��2�!Ɠ���t:��]�C.���Vb��C���C,� 4z� ���,?��q_��p=��9)�t;@�,�9�c�5���`
��~�)�� ���͟����W4�ͷ���h~`�~@����}��cF��_�O�w�Gp�o��~��[�����><x"����K�}v�h�u�Z�'W��|��˾l9�ԍ����7v�dp��<�-~�8{��gv�$������y��Iޞp3�蓷'nO����J�|t��	z�б��>NrC��V.�"��}�m��b�����C��	3��ނMN��"9�[��0��Ep��F�4���>��z�Y�<�ч���s~�L_m�cϢ����_V��*��Q~3X��[��}���	���S�q���H�ؗ-�ƨb���	^��c_��5�a�l� ~��~������"���8��\I���=��]�!?��	����Ë��-�?���=����>��F���y������O�$�w����������O�'��r��m��w�o|�wS�G��������l��՗��8�BS��0�S�J����we���q8;���/���}���>�T���|�!�G�\t��ϯ⋿M~y�5�/����M|�7�w�;����'6?�����o�?��������k�l~e�l�=��]���J���o��.S�/�z>��&~W>;a���%Z:�]$���5N�{�#{��S7G|�W����Lc�a�k��?\$lOCoO��^�N��5�'N�{��EB4�	r��/��R6p���䄹�������G��#9�����<O�O�O����譹��Xzw�/W��]߇oO��}x¬�VǦ =��+=q�>��w�'�̓Е:bO��w�g��_|���㣷���|t}_��|�����o��ޚ�ߖ��o����|����w�� ��_|���nɠ���Tt>{wE|���ٛC�w峷'��|�֜�]����]��9�?��T���Wv���;�+��&~W>��@����\����~e'�⋿�o�'��Y�x>:�4��h��e�=�/��P>:�_�O��	����O��_|$��5'���߁�n
_��|vK���o��nG_�����T�w峿cT|��g�4�/�f����_�|v?������go��/�����|vS���o��n
������w��u���%~W>{w��g�h�=�]�uv�A��|�ZW|���ٕg�u�_|&^�b�#��#�����*��]��2��]��&`���,�]���4��������07˻c����^ZϹ6_b���|9^��]��O�86�C���C��?�ba�'6��|�h�r�"��������e+�'N���O��N|އ��#�O����Ֆ�s�̎}g�<����̞8#;�4vΓر�������M��ڂoO$vΓ�w�ӷ'ؗ-t��^$��u�=�Ë�#y��%��|��OO��|v����'�HO�Pث-'�<�r��#y��ݾ��f��Df�>�P�ر}�U�ߎĞ8#<�d�����	�GW��;�}v� /��k��2�ގO����+���](qv-<i��8�=�����Z�n�/���+��M�s� }�#V����;�2�PB�$�.W��4�����]�yy� ��      �   A  x���Mj�@���ݗ	���!z�@�����6NZ���4��C]x-$}AI��4P�ژu�Et[�U�<��JV�uV !{��Ε�u!ha!���*��d�B@�4���-�-��A�� �p����l��$��3;}���*�흼
&������4�r:�����-"J�UME�e_�iz�Ʊ�_W�/#D�E"���� �C�Q��
���8k�-�yj�7|]��3g���#g"svV�UI�T����O��m�q�|y�Idc�1i[|��c�[O� ��Q.��ϵ��<j�Op��5�������hv��i>�Yu      �   �  x���Mk�0���_�{��h��{l(d��@�'	�]H6��rv�S�����~xG-{r�����:ײV��{i�=欦s/[(G.޳/�ܥ�ǧ_?���ṙ("F$!7��}\G�U�4[;�5Lm��-��4��j�C�x]<- � ��		/���y��Iw�0���d��e�=x�9����JQ�4	����~g\��E�Jsg�Y����hq8;E���"����"�x�xn5:o[��TՇ"f�4S�B%���й�i�^���C�m��CE��y����ua�)�HW�q�g��%����Zs,���MnTA�
|�!�\9��o��sz28j?���O�����Bn�������7���|ROԓ$�Yia��ױ�����Y!MN��8		 �P���?� ���Y�~a7+�]|�c��᝽G�V�vn�+��i�Z���]��[c#�@-	�W�3���o�,�s����h���l�ü���O�o       �      x������ � �      �      x�̝]�,)����W1�c��nB+�����險�hsqzTU7��O�K��'M�R3�����w������$4���澨�.��d������q��W������C�����~�����y~����W����	�s����\5ӂ$?�i&�[���()������x.������@�I]bh�¿~��1x���EU���� �{
�BuMa`��"��aIk��B�N�{��B�^4)�!2e۝����/?N�5��Y��S[)I�ܩX^�!pYs��َom���	���w#������6Bl��&��\D��?/B�GD��~�n�|��'�Ϗ��Y�'��ځ���������P[{.Z�!��oX��Z���!��^���-,M?�7�(4j��0��~�(x�"^��SQ�R9��}�yO�Ya��x�y
��VC��ଋ�Q`�QFh��>�"��u&
�~h5��}H��i��T?"a4I�Cힻ���
S�E[m!a�F����D�bWL��4��tO��m0��1C�\�~)�)8��+�T��IK���"Ii��#�YEV��p�=j�/;��%�I��8���W�
�^�~"dO�y�aeF����1�
^�(��KL�NG9���d�<7��{���B�t�	R���u6
K?0(4��������.�D�!|�(#q�6�(��u6
HYА�s���̎&
+fuQ@J#�A�Z�s'Q���G���=6�v|k��P���!)ΰ�g���7;�(Vvdj�f�����͎6
RՐ2�>����3;�(H�ze��	ڊ����F��z#�0+���'^�QT�Y�sEf�ٳ���P���P=e@�u��^S�fG�/��i�<�ө�SpfG�Y��X?�TS���̎&
1,A/��8����3;�(4ѓ�Xn��p��K��o�5eL):��k�ꢎq��pC۝��F!��˺�n��PK���ˎF
�6d�y�2�)������c�A5��j���|��Fa�T�ب�=�����D|���A������m?F�=%��B�����7;�(��z�"T[���g��M2�]ML�2L?��(8���B���s�1J��
��h�PBR�tz���O�Uz�ǾӚ4�� �����C�du� �
qȜ�7;�(��u���0�,��SpfG	j���z�<����Da:���W�;����̎6
�,l׀*�?�;զ-��b	y�����׶(��
դ>
bKs�5ov�Q(S�a����*�{
��h�0X�q Ņ�Z|O��mD�#*��Co��_���h���qIz��B[�<�|x�l��!�g;���P�g�H��!]S�fG�Ey���*���3;�R-�ڟs�;X>j�\S�;�X����sQ����( `/�B�������#R�B~6C���������PΩ԰��e�@�v`-L��!�����g�g�;L�sO��)��v�\��ɜ۟��*8rn���ۚ���О�צ��]�{�%1]?	�
I�&����Y]Dc�����!()$C����r���4F#�uAELI�� ���ϋ��6��#�_<	*`JL� �X^DR�X���	m<������J�a:�ޚ��С+$ �V'�5gb�AhC=."͐�*-�C�%�W���� %h(��>dt6����Pr��!g
e���)8J�(���P�R��\greĬ�H�7�2ۿ}]oCɷ�
=���A]B)k���%mXo�TZ�Y���%M(}ٶ 9��SZ����F��V��h�������FA�>K*���%)�g�H�%��
������Caf=�֩��9�g����7;�(t��#�,q���ς7;�(,�u!K������tO��M�NU�9��$�x���F��q�,��� ���Ʈ��E�aN��2�[�A=/uH����Y����͎&
���;M2QB�8B���̎6
]/��+Jyr`�����F��<���j}���g��M��9��i��~fY$iTH���P��k;���P]EM+4Y-�Ю)x�����͞,}�BF����3;Z(` �i Xi�zO��mZQ��C�#7�9rE��_)|&�9�Ո%{�8�~"���e"c@�!P�/�t�ǀ/3�Yh@�9�q���C�h
F��W�'�g]������ס<sU�#�(��"�D�\TIlT9�S��E�(���zf�\�}�{
��#N��Yz�=�9Q��7St�� &2y>!������/!d���B���7;�(T=�4r�4:c���̎6
ۄzV.�Tb[!�{
��h��~��̲Ǔ�'��gv�Qh���T�y��~N�c.:�ݒݙr�M���׶
���%��vjew&횂7;�(��#�֐g�"랂3;�(T}�8`Ls�aø��̎6
u��q�P@V�ų�̎&
uWeG (UγPd�C�O9�H�{/�����C�E!�|J��}���͎6
�Ϙ/���2�!�SpfGLz
Z`5Z�J[垂3;�(T��v�X�����F8������B�'c�]���g/�� !��r��9��k�?ڗl,�I�d�Z���7;�(���p��T\pO��mX�xG�k����
��h��ӗ��@�a���=gv�Q�R �c���:�uЁq<I�jr���퇂�J�Ϻz�g��ov4Q0���=���Ϙ�3;�(4}H$PZ%Aot2p�QpfGևD:�>[��_<��h�@Ն��d� μ#%��J}�({^�����Ca�"S0�YC�9*sE��m�ly
��.�ov4Qد��aG�.i=���)8���B��%�V�,�rO��M8����1y�7bN=-7���N����~(�fY��"`�Ȑ�5ov�Q���v��J�ϼ�gv�Q���
L8g����̎&
��4�.)')���3;�(�.V�Ä��i��#֗�m�'�(e�6\�Y���CABVvl�M�3�\��+
��h�P@yaJ�!�t������̎6
}�0��Kn�����̎6
�(y�7�0�/�gv�Ph�L~W�����s�f�����4�����}x�J�
�s]SpfG�t��I�>mL� �_v4R�zw
��Zy��S�eG#�>�E�Ғs�{
��h���0	k\1ɤ�ٿ�◅�ApͲ?�sF�׶
5�Z[�����A�5ov�Q /L)u��Ϫ�gv�Q]}����+U�_PpfG����A%��O��;
��h��*�H��8��]g��X��Dn����C!G�*�q��:E*����F�&�fM�
��R���̎6
c�qD��cQ�ܿ��h� ��J�G����;y���B�/�>i����=��(뚆a_P;�P'�v|k��0Q�_��32�q�S^Q�fG���n��F�Y���wG��m��e��[�q�O��;
��h�0t�5q�#�6�=gv4Q��-r�r�8>3�J��ԣ�Pk��w����P@�*��$����Z����F�tj� ��x�5�QpfG�t=ƈ��9t?��SpfG�/���`���x#���Fa�$	�J
�|�Ժ.�q�O��<���
=�x�Px��x'�v�Q�z��@ �SpfGҳ,E:G�s�����Da|��՞��哑䎂3;�RxҜ�Ov�Os!SL �Ӹ�*/d**3f���-����s�1z��	�<$.��m��zk�ET!I�"�ւk��� Ԣ�E\%��;b�{��� PS%�*�	��݌~�WjG���(@�;tl�
�C�%F���|n{��C+��ϝfC�����W皞�r�5�@XKu!$CWN��31� 0�
|�G,T1���X�6]�	}����h�|���E=	�
������C�%F����@�w �c�.r�ggß�l;�D�>y������l
B�Z}��I���L�&˗Ҥ����U�|���~� -�F"�{��h�@�.ڽ����a�r��-J��9��ELSXW��q���t�@!�ީ�+�צC��jmv�X�!���d5��X֪�4�    �+1� D��z�	\�!��B�C�H��>�
�;��B�L7�1��Ɓ`��#�Ƞ�J�*��~g����B[7)�3��5gb�AK0 �X�
��{��h����##����N��h����@0+�j9�t��m�P���@�Z��g�@��a��J#8�[�?r,
B �>Ѽ��L�6�ECRʝe2�{��h�@I����a�8Ӭ�|��a�T���CM�8��l��|���G-FJ�I�)�R�R,�=��D�b|k����^��D����5gb4A��ܱҀ�V���K�6X� �JF� ��/1� �JE�Om��V�C�%F�z��ivh�G�;aҳ��ׁi��_^�~ PQO�\Cfy�5gb4Ah!�I�mQM5��{��/1� d���g��S�œ�K�6�U�D{����~��Mz�;U&�)�p�g��P�EHI�X-��2�G1�5�@����b���Bj�������D �H�A���K�&#虥�9���A%�{��h�P��%@J5�@���/1� ,=��0ZMP��2�T����z^���}��M�@��/NH���2_Cp&F�as�P��F�{��h�0�zg����Y϶�;��h�0��pI�C�{��/1� ��W�sjaa��YXmg)����~j(9�[����; J��;5���L�&z��p��@�;9���pDk��1r�_b�A�z�?!&���B�|��a�q���)��A�wXu�I%q���\r,Ʒ���� AY�*����A��"3��'�T~��+��h� ��Ev�P�
5�{��h���뀄�sOT{���K��>��{T�`3H#������(M���[0Ê�5���1�����c�om?��Tl�"����qM�[:ʠa@�-�z�)�Sp�N�F�G���a�`u��lw������W:&�r���8{���7�Y:�9�.��y�ЀuJô٦J� ��Ş�����L��A��
�GZ��)x���Bѩޟ�x�rO��m:+/�Kj�����̎6
����QV����3;�(���Rb��_=��%�ᆴ�Lɵ��~(�PoD�����+^Q�fG	:ے����Z�)8���Bѩ؂�J�*!�SpfG�+k;����������B��Xu[��Oٟ�N�$+��F�Hc6�lǷ�
��C��$^S�fG��TQ���mr�|O��mD���o�~�f�_<��h�3鞒:�PnI�SpfG��3��wp~�����4�s����k�?R�I��	" Ȉ'j���̎F
���hXe=���|��Hat��
��)ȃ�)�����T5�r��jB۝��F0�B����Y����IF�g��g��ϓ�.����CaNe��Qc��O���͎&
9�) Ke���SpfG��kq[S���)8�����딛#��2�{/x���BIEGM�
l�a��)KRw��� ��	<���j1��Sg7;�(��E�$�ر������D�M�2T���
��h�P4�U��8[o����F��zó\��$�gG�CONN!ޢ]qMυ�_�����U�����{g�k
��h����$�=�TW���̎6
_�1�y�2�,8���B��\�H��:Q��͎6
=�bI��b�YoE��q��nd�������_ �y���7;�(����TȃW�����Fa�Gʎ�>)'���N��h�@z��s�"��YpfG�MEMk��Y�v�/�.���OD����َom?����d�;�P�fG����!��/����SpfGJz13B��.���3;�(`T�Lܱp����̎6
z��I(�~zJ"Q���d���r����
���D方���)x���B+����tu��)8����u���ܯ�s�3;�(���уy��L,�3;�(����	����܉�,lG�\�S�\��퇂�x!���q�DM7���Da��+�Υ��a�SpfG���Me�L���uO��mX��j�R)%�����3;�(H��~"�X����91�%u��XC������om?>i=��)K�Zs,rM��m�ldj�+��<�)8�����O�5�E�a���َ6
M�6G�́Ө?;��(8�������{ E9���s��>VT�Rݭ�0ȱ_����^�
rx0\SpfG#��O-1�g�rO���x~�h�>{��/;�(�O�S5��U��_P�eG#�}D8��8;�GªPu���1
�;z^�~(��{Ydu�=Ⱦ�5ov4Q��"�8���8t۝<��F��/���S�����3;�(�>+3�Z}
҆q�ov4Qȥi/�)�V�̾�������3�5�َom?�hV��մ�)x���ƙR�0a�<��D�d}V����?��(8���B���cO����)8���B��؝�yř�g�n֛��SU"֊}w$�����C!��N;zl"�׺��͎6
]ϲ�����'�<Y��(8����ҳ,L;���ÂzO��MX�cH��k�9�{
��h��%wW������,`�L�Oi��g;���C����I�W=�5ov�Q�SEM���>�V�tO��m����D���xǕ����Fa��4k��� �����D����3�\�'G��S�f��tl˵��~(L�����ͅ�Y����͎&
#~97E!�6�{
��h���q�%��������̎6
_�=��j��{
��h�@�������!9�c�!����jO��^�~k���:�+Q�E�y۝<��Fa꼯�d�
�K���̎&
3����������̎6
���0�!>���3;�(0*�V����d8w�C/f���"Y<�$|m����%SQ��PO_e\S�fG��3� �)�s/����F��:e%	��E���̎&
+t5��Z��J鞂3;�(t/�����7�z��U�N�{�0/�Y(^�~(,��I�*V�+^S�fGIzƭ��<��(랂3;�(`�ۄ1�U: I���̎6
���5�.e��g�3;Z(P���L�SV"��3�F!L]v��U�!k��m?���Ҩ-Jq�s�k
��h���8"˘ ���
��h��K���S"�~O���P��)=�{/8�����s���L:��NO���'Kn[�w����C!e}�:A�A�{��7;�(4�+��r�s���=gv�Qஆ\O��*��`�ς3;�(���O��*����=gv�Q����ky�~���^��رg~��y>+���CA�U�ݍ��J�7;�(d՝�2︩�v�P�QpfG���YgJ��AQlw�lG�sM�";>��(8���B)Ig���T-�=�>w*Q'
N�O���f������C�����3��ryE��m����e`*M�)8���B�Rʳ	�Ƚ&8Y��(8���깦3vڝDpO��m��0��Jİ�Q��B���Y�;��$�ڎom�P�/'����R�m&۝<��F����wO9g�ς�=gv�Q`=!5�Ɓs��䞂3;�(��Wez��F\�)8����л8"�Q	�܃�ϝⷉj.3qY�����CA��x:Еe�k
��h�ЁU�Ȉ���+�Ɋ}G��mڗ���-P�5���̎6
�9ki�\þ��SpfG�QtO�pR�C['�Q1����8=��ym��@:v�}C��jj�\S�fG
:vd�AL1��_���̎6
YW���qZ3�i��g;�(t�A$	��/<yY�(8������ޚ$�?�-]�t�����zd���C��z���|P(�5ov�Q:0�����-�SpfGѫ2C8N⺇����3;�(p&uђ=� ������Fa�<�	k�i�����]��$�%�5���2�m�PXQ�",�i�zM��m��0n� �^C��mF��[V̣P���̎6
�w}f,�&$�����DA�|�9V�q��R�
��z��������Ca�Y�E��Ǚ��5ov�P�!软��B�p�=gv�Q(Y]q=y�r�'�gv�Q�(��6    (�~�/\QpfG�X�~�g�xd�\��|ČоD��
u��ϫ2�m?H�w�zM��8���3;�(����(��$��@�S�eG#�U�H�b}���)����B��3$NUJF�{
��h� Q/�L�0Ϻ���n�Rh������U�^�~(T}2�d͹�0Fi����F��"�2eJh�ov�QQ=e��m����{
��h��sSoDD�=�ڃ�.����F���$������~;�*� ��[��H�+'���C�D��C ��{��\Q�fG�Z��*)���~O��m��=��8��g➂3;�(Hӻ8p�=��}�tO��M*6e�@Ov����j�iK��D1��s֯m?��`��P�U�D���͎&
���Ƒk��y��;y����V��)��i��?c�+
��h�@Ag�C�a�H��w���̎&
-鞒��z��y�3�D���,����9�׶
�[�6y�#�';�ov�Q`]?V��c�3;�(��� .�B�m�~O��m�ҧJi��������َ6
�������	yv�E&aT�%q������0`賵�
q���q���͎6
_Jm0��srF��ɳmXGMH4&S���NyE��M(�*��F�	)�P�)8���B��A%�V�<{8�eXȩK.��9�׶
KI��zG��~�o(x������Tʻ�x�ѝ=w���F��/3�¡�A7�̸]QpfG�9TԴ䙃��c�xO��M8닢$�Q�d*��e��"1>j��U���
]���+�La�xM��mx���9�������Da���jGh���=gv�Q@���s{A���gv�Q}�z %z�~2�5�᪄;�^)���َom�P�݅������䉿��͎6
m飧1��C�랂3;�(����@Z*��)8�����kLsw陳���̎6
��zD�z?�gP�''�I�4
�v|m�� z�@)`����_QpfG�����f�1C�rO���Z�;� u`��b��c;)L}V�b����螂/;�(�,�� ��G���j-�������19��َom?��,B��ȂM뚂7;�(��g_a��� �w�lG��^� �Ʋ��yO��mڷi��*	F�x#���D!��kw��`�D?QL=	�G s�#v�ge^�~(|�Z�$��+���W���F���2J���tr}�QpfG��S�w�!ȳ�;lw�lG���X��Tv';�gv�Q �=%�K�vz�ҲN�G{�����z����
5�2aIq�
a���َ6
%~��5�q��QpfG��swe�j����Fa5����(
�SpfG���L4;<٠�}�A�ZTs��cǷ�
���h�ia啯)x���B�R�2I�-r�0�=gv�Q(:�k nX��s�{
��h����^���PC��^�fG���#֒��OeFn��qC�C�!�g;���P�U
m?�o�5ov�Q ��.��?�~���)8����߲�=��G�Y�)8���B�_�h�V	�����Fa�]ON�Ա�1�����evCx⪞�ʼ��C��7TQ�Z�!�k
��h�P�z#��Ԟf��;y����Љ��_O.=�qO��m��0.8�Yp�/�gv4Q���+<i�v���l�<�.,h�Ajf�;z��~(L}��C´2]S�fG�z/�C<���=gv�Q�A_��I�SP��N��h�����ك�0���)8����J�˳ 1�V�qKV�����U�v|k���:�i%H2rh�3����͎6
��|��C��s�3;�(H�;�����,�'�{
��h�P��J�kG!e:���(8����T-1�:���g�V�l�z��t��z��[�
+$=�]Q�@JO����F���E<d@]s���3;�(P׻�0 ��㼧�̎&
1T�GPy*����̎6
M�ĳȎ;1��>V,:�_��{T3��^�~(�^�����t!���̎6
)鵩�v[�Cʖ+�S�eG#�/���	)�3���gv4R ���Pp���z�_v�Q й>?�#$�'Q��NI�����������[���N��h+���䊂7;�(��}eX��b���3;�(�׬���ɎzO��m�^�`�EBX';�gv4Q(Q��ߑ����s��S楧뗬�w��ڎom?��O9��0G9���(x�����GO�CT�螂3;�(�P^��P��q��[w���D�n=�7bG\�y��垂3;�(�ο�`������Gԡ�ɩ�A���2�m�P�/����*��T�嚂7;�(T�ɡ����F_����F�t����~b��f���̎6
����@I���|G��Mڎ1�,�@Pz�0>wjY/�O�n��<�����'	�X�ď�d���͎&
=j
�SS%�l垂3;�(��%w�=������w���Fa�*̘�*��{��MF�'	A����ĉ�襛��#>[��5�׶
X����ZC;�)�(x�����+��c�\V�=gv4Q��W�젩b8�=gv�Q(z�>��F>'��(8����ҹ�����I��]��IYW+�Y�wlǷ�(�/Y�v���5ov�Q@�r��RI1WY���̎6
3�>b�E-���SpfG:��xrL1�~N�QpfG�/��9q�u���\��2�ȡ���g;���P`�'����:�J�(x����J�<%a/e6�D�3;�(���;��U#��3����̎6
��nPX��b�ų�̎&
�����K�v8}�}�r�.�<�$|m���җ��<c���:�ov�Q`M!?��[/DP�)8�����-Am��1�!��SpfG��)Dqԧ�����̎6
K��O�yf�k�:	�s�5�Z�c��؎�m�P�P�.�z �\SpfG#�U���+��YpfG#����#͒z���/;�(��_�Y7.&�{
��h�����pL!V�O�(��o��8�U������m?�P��JS�s�O��+
��h� ��\b�<נ��)8���N]�X:���O�pE��mfѫ���S[���pG��Mr*v�P���3��Sz�IOP�������C�k
Q�,8�5ov�Q`��v�WǴG����Da��z�#I-�e���SpfGԫ2SZ0�[1�=gv4Q�Y��Pi�Mۯ�Y�Q@�0ʤ�[ ױ�[���3"�Lg�!^S�fG&=�D��$H���)8���&��#�ʫ��Z�����F���2d�O����D��y`H\Ǌ���NT�i@�u��.�lǷ�
%)/@�\rݍ���͎6
C�0Ƚ��Y����̎6
K�0�ʠ�HpO��Mz�g�$��f��g��m���q�1�Y������u��3IȽ4�5	_���0��?e�~+��k
��h�P��#S�9VY�샾��̎6
C�;�<kZ=c���̎6
{T�.�ܠ�z��,w���D�Pǎy�9C��T��z๐pMy��췯m?Hg�"�G��u����7;�(̠���"[�}�SpfG��-C���;ʐ��)8������ b�u��(�SpfGNY�SJ�	W�y����L~p�������Bէ�3�ٰ�8On�+
��h��z/���97���̎&
+��ˌ��= �����F��l�3=�ke���w���Fa.]Q�x-
���Z%�՝f§V����g;���Ca�z&�X����7;�(`T5j]j���~O��m&|�ׄ;~�e������@��t����A$�0�=gv�Qh:�	1�!-�g�r_��į��g����n���
���$�e��̿��ˎF
1�=Qb����zO���P?�b�3p�ό�%Wv�R�:v�J��k��{
��h��@ǎB���,��s�t:���'��]���B�/�w���1\S�fG�����g�_��ᒂ3;�(� �KU��G��_)�����F�~Y���)���IxI��m��Q)�p~ꉌϚ���t�$u�O��x7�{�?2�������ȥ�5ov�Qhz�n{!D�,O��k
��h���d@�B�޷U>;�.)8���B���a�B,ka����    �6
#�>� �m��O�Pj�R��1�P��yo���t6;y�q!#�k
��h�P��ZI�̊�)8���BCuQٿ������)8����T�ƚON�_���h��Y�AJ��5���c=)���;z��~(t��cJ�G���^S�fGօ�2���z���̎&
-��D�#�)���%gv�Q@=-W�`�-J���̎&
=]�#�A�3��u����Ӎ�D�t;���P�Rc���1^S�fG��3=�5���8�)8������˧���#�SpfG���,�JR��X���3;�(��mH�!�'�q��/I�0������g;���P}V� �g|B��ɳM(�&H{>B20�SpfG����'[x����4����Fa%m�=�ܽ�&���̎&
��
0�gz!�μ��p5	�`��
�QW�zo��0��("b��S���͎6
�)<'�b���=gv4Q���uN�/�̭���g��m����D�3�~O��MV��*0�hث�����BR��1x��[��2�� ^M0�=Ժ��͎6
C��tx���-G�{
��h���\�!�݃�F���̎&
:uv �a�4�㞂3;�(�>%�ht�T`���(-}Y�B�TR�����[�
�=���kP��v'�v�Q(��L�g�k*��̲\QpfG�����Tv�m���̎6
k�:t�D���SpfG�X���� ��Lg="F@u�$��cs=����C��˼��>���隂3;�(�0uN?�T�X�º��ˎF
E����n���=_v4R�bk
ubJ�S����/;�(@�f�9�3A��x!�^�X���a�ų��~(���Ө���\�k
��h�0����
�V��=gv4Q�A�)X��;tZ����F�4�Q���
���̎6
��ȓ<&�ϮϘG�R��J�O�ot;���C�$=˲#gIk��%yM��m�^�ۑs����+�SpfG�kS�����U~A��Mj���M��i���3;�(����q��g="�<�$u��J������m?����a���5ov4Q���Y�<�|�,x���B�x :�ũ�=gv�Q ��p`���5ø��̎&
������EW�)vx�2�<��ym���K�Q���:c���͎6
S�6'��8�FgU掂3;�(��gYX��i��垂3;�(T=�Ra����yO��mV�r2`J��In��Sz*�	�V���T�ue����0�����sF����TtE��mPW�J=ﾣ���)8�����'�X�������̎&
��!F�0g�C�=gv�Q�_�/ p�1f�����>V��=�*�9��k��'�2�P�~��
��h�0SQ��m-�/(8����CH3���&�{
��h�0��_x�B�RZ�{
��h��%��[�X
�;r�X ��}������Bו"�Pf�C*���͎6
K�i��S��N��;
��h��@/f�4���d6���̎6
M��&�cT�Ӹ��̎&
H����a�6����kS�) ��Vi�lǷ�
%�IZ�K�-_S�fG����Hma�=gv�QX��5a_���/fܮ(8���B
���9�J5��N��h�@:O<K����K���ShU����[�����
1�Y� (sR���a|G�����𾠬B�w.�/;)t�:ю��n?�S�eG#�UT�(@i�({���g��mR�=e�B*�̲���,�\p�h��_�~(P�[C��Uv��]S�fGzޱ��a�5�{
��h�P�>1D�c��{
��h�0����b��z��x���D!��%�َ��u��;����H۟6�늭�m?�.2�h�*�1O۝<��F�@=0 7��\�=gv4Q(1�<�Ա1���SpfG���Y�T�����3;�(��l��5�Z)�g�fw̅V�LT<���
�U��8���S����7;�(���iv���}�SpfG�	ʎS*ʐ�K��ɳM0L]���TV���̎6
��qD\R#%�ǎ�
ݑ��p�
�ڎom?v\��h+dhk��tM��MZ�/�;4�J�g����3;�(Ԧ'�����q�����F�t~�N{�#���=gv4Q�9�ؑr+b�/�Th���Z�9�g;���Ph�.2b�Fh�7;�(����d�\�p>���(8���¨:�����jFH����FA���X�(�=gv4Q �_N�[�3�3���wN.�Q@0�������0w/�;�6V�a��	���7;�(4�y@h��(׺��̎6
z4EA���|O��M8i
;���9�|O��m�T`˲�KNs����e��,�B͌�3����CaP=i_6Z��)x���B����8��4qR�gv�Q��6������e�_PpfG����x	�)O�䈽��̎6
����	�O�$M��!iW�uN�k�om(��[�dB�c!���͎6
�/I���O��;
��h�@K�s�+����{
��h����N�1���O�;
��h���=`�;�N�Y�E'uj��gc�y��k��kSs[��L�5gv�QH_�t
c_�V>+�w|��H�!���)��垂/;)��x��D��:�u��Q�eG(:�Y��R(���G ����g�=P���;���Pz��P���hb�yM��mD牟��s@O��uO��Mr�5��@j�F���{
��h��ӗ�5��z�Y�)8���B�zSd��@R2�Ďy�P�����;�k֯m?�d<ݡ���#�(x���隄a?-�?��{
��h��%� �Xqw����gv4Q�E?��&��=gv�Q���)���g�#�/�<lR�z�19��[�?���/�)�٫�>�5ov�Q@=�Ф,�9:��*w���Fa�,I֚��{
��h�ТΊ�_�;¾0���َ6
]�M������x�}&1t)�[ϫ2�m?XT]w��W[Κ�ov4Q�IW��ԉ'O�����F�h*I�\b�k�=gv�Q��Zۥ� mTH힂3;�(�U�Ȳ[�u��s��Ў��i�Ud��9��k��z4E㎚Zf���͎6
�s����q�h����D���wG���0�ٿpG��m�>m�_�
��G��x#���DaF�߱H�[��4�z�N� @Ĕi��]����~(T=��{x!�g�醂7;�(���=����SpfGѻ���'�F�W���D�����4V�O�{
��h�0u`�#�*���Y��QE�1/i���َom�PXA�;V��W�u��N��h�Pt��I8C���Z���̎6
C�6K�)Z�t���̎6
��#B�	k��
��h� M�#y�a�[=�d��t�)��g'�g;���P�:;MC"(���N��h��C��u�lsN�ų�͎6
:=�dT�S����3;�(������O���;^QpfG���^�k)����'ǰ�,lO�D�]<�$|m��Ы�x
MO��~M���V�;��!�Y����ˎ6
)�C}����W��7��^�-vN�T���ˎ6
0tP���:�O��	�.bYa$.� �k;���Ca:+6���"�S�fG��T�0q�^��%�=gv�Q �ڪCZyVb���̎&
%��]�V���=gv�QzG��p��9g�K՞���`=g�5	_���P�U��8�@�zM��m�>+��Q�����SpfG����T*�&?�I�=gv4Q�(_��ֵf�{
��h�0�8b��G�|vqdl�;Eڜ�^��U�׶(<��E%�����)x���B_rqTܝ%�\���3;�(,]����cG&���̎&
�^� 0A�����3;�(����c�C�'j�M�� ��Vϻ�_���0�>mN)�X:⸦�͎6
M�AZc���v*9�QpfGѳ�M8M�=gv4Q��t
x���6螂3;�(�>U���{�$�s'z�{Q�}Pz�4<���
t���B�����͎6
��w�4NO=�{
��h��t]���V���̎&
�� /�&0+��YpfG��%/��s���:����`+<ձ���f�    m�PX9���ԩ` �^S�fG���B�8[_�֟y�+
��h� UQ ������{
��h� ���K�!om�d��g;�(,Rς��9����Z�>�L[�R�َom(� �O�B_-ő��⸢�͎6
���~���0�Ϙ�3;�(��� �w,��9+sG��Mb�'�擳�̈́1��YpfG�:9:�?v,�wu�@���	8x^�ym��B��'��EYiq>{ܮ(8���Bc=�°�H��;�Q�eG#���/�mU%%^�|��F@WZ
"���R۝��H�u�O���\+|�Y�����QJl�=��_��������g�S�ų'���7;�(4�Ri)&���yG��m�Ί�{Oɣ������Da_�w�II!�P`�=gv�Q�z�r#$��B�Q�-�B#��c��o_���P��N@%��J�隂7;�(�PQ���1C�xO��m�.8�`|�;��qO��M��Z�J+B���̎6
s��Ɉ 2`��U��]ok�!�5�ب���
{�WeDvC+J[rM��mP�Y7ܲ�$�yO��m��&` �5vp}�Fx���BOz~(�T�SU�v'�v�Q��������y�g��t�O��&,�ĵ����0��غ���:Q����7;�(~�< 1�B�rO��M��:�zl��/�gv�Q`TQS@X+Ƒ��}G��Mf�+�r��P�I��q������g;���P�:�����l�pM��M8�$�h�0�S9ᎂ3;�(p����9V[bG�����Da��݅4ROy�v���QpfG��3�e�wl�yV�/�*�h8ê)x��[�?$��� Z�Hpvq\Q�fG���E����	��➂3;�(�Id�T�/�gv�QQ}�S��X�)8���BM�qKۊ�wy�r��\�u������v�c;���PXA�&L\R���̎6
1�:����ەSmtO�����x��ʘ���/;�(��Oю'[o]0�{
��h� �r}Jl��S���ښ�NsVw:A����َom?X��JбJɡ��N��h���u]pb,���{
��h�P�N��,e6^��_PpfG��@�k���=gv4Q(���겻	�c���(Q�St����B�QS��8'��;y����*��)����QNe�;
��h�P!�#f@�c��)8����T��)C��g��mD�w$Ju���hgQ�^��Q6�0�4A�#뷶(`�U:���)x����!�����螂3;�(H��{�(�����w�lG�����1�)�|O��Mz�3n���0�\�d@m�'''bA�1<��ym��@Y��!q� ������͎&
#|�l�A`N3���َ6
Y�wD8ik��qO��m(�ЊE�3���)8������f���@����u���"X�ǌܓ�z֯m?�M����
�r�ov�Q�z4UD�d��y�;
��h�0��l�{�R�H��SpfG�ZU� �f�a����gv�Q]՛���s�,�)'��$���?�����
��hj ,�vđ�5ov�Qh:[~��i���)8���BǑx�Y�$����Da���!�F�#�{
��h�0�N�?��O�Gت#y2�l�f~�t��퇂��}�ߞ�<�Y���7;�(H�{ܐ&����	㞂3;�(=�����]�=gv�QX�zoE(Bi�P�=gv�P�P��)��(k_�Y�� z1s���@Z�׬_�~(�uJ�s��h뚂3;)��ѓa$����{
��h��GV:0���j�S�eG#��k����}jHg����/;�($Ⱥ���7�UR:w�K_(�p؏{Y���Ph�K����t��+
��h�0�L�P|�/�S��3;�(@l�B�0�I2p�SpfG���nE�ƹ������h��t��%��;�>{_H�"�vX�o�yU��
9��Z/�̖h]S�fG��k�K5��9CwG��mX�M�o4G��垂3;�(��swe��m�SpfG��GS�ky����̾bA�7(���<��:��k��3�����vM��Mj��i�${|]z���̎6
���4��s�gv�Q���c~Ɯ��=gv4Q���q�8�i���QhLH�s��׶
��jU�� Xj���͎&
-4uQ��5��SpfG����"@K������F���]KF��n��:tw���D�'�!���9C�3�֖��Tpv��`�=����2Rhܤ��3�pC��mH?0@�&k��y�+
��h�0���Q�%��y�Fx���B���J�GZ|O��m��rn*��l��<�W�GF`Y9�8<���
����K�%�l�k0} �� ��?��oN��N�5�C�"ͪ"Ox�&��/?�(���wDր|*^Q�fG��k}&�a�)��!����DaF�+3dE��%��gv�Q@]�cP~���ʳ�SpfGѫ������%���E~�T3A�g�_c�Q�!�$��\���7;�(���dn���3���3;�(,͓֯P9ǚtr��(8���ª:�P�"�S	9�=gv�QXz�6��C^��ip\c�)�4
�Ɩ]wN����$�F��gs����F�e�zQ*�ibL���3;�(�ԉ�cʹ5>���(8���B{ګ��EV�VS��)8���B׻���{��i����{�=��<wN��������Gd�Di\SpfG����YK����j(�|��Hu�
8k[����Y�eG#��3���i������/;�($���yFz��.ܨ����U�g;~��Ph:c� ����5ov�Q�
�F��3p���̎&
�H�w����:�9�tG��m���ึ7x���=gv�Q]�+l22T�s'��TE���_�� �s&���2,�!I�yϧj�S��7;�(4}���(���S���̎6
�ךXdϥr�?�)8���B�A�^_วRc�J����Fad�s�<`O��:Uږ�z`�}gj���5�Ca��1�\vl�N��+
��h�PA'�G�~#�9lw�lG�V�)$(�u�{
��h��/y�O��	�9}G��M�����­n��;ad���Y�o�8�����ҫ,	��Zc\P�5ov�Qx�C����hy���3;�(������h#��䞂3;�(���c�z�Bb���̎&
=f�PLRN)�L��X�aikt�<����Pu�]�JƲ���7uC��m�ޡk�߇�s�{
��h� /Q�A��9�uG��MF.z?��%��:�)8������Du?;h��̬�̺l���-[y�U(>���@�t�*�
e!^S�fG���tI_J8�o�(8���j}!IJ�ʘ����َ&
�zE�_��R�)8����!�ڎ����\܃icO<=W����}�e�"V�+���W���F���]m_4��<c���̎6
#�z�O����%rG��m��<0��s� �)8���ªM�/L��*}�zMm�T�$	��G+��L�ϱ
��eh��/����͎&
���"O�q�V���̎6
E�S.��d槲�=gv�Q�K���Z�QC�����B��(z�R0v�ҿS�ty�9�:`��9��s�BՇ�"�����CW���F��dc�����>�(8�����)�03P�8�=gv4Q�/�����;p���̎6
/'��440�W�~��[s�
�"�R<Ϭ?�����:�Xb�5�Q�)8���Bս�3��?{��=_v4R��.���?���{
��h� ���!f!�帧�ˎ6
���윟��ϳ Y'W5�픐�S(ر��~(̬����xG٧*�ov4Qȱ�tN��V�s��)8���B/��N���Y�QpfG����d���}���̎&
%��H�l/�Y_�Y�R���z�%�v������z�Z!�p��\Q�fG/;t�ː9X�=gv4Q�AW��X$�}!�9�gv�Q(zYnA�w�C���̎6
����
�2��,ԡ���H^�
�>�9�Lz?b����Tx�A�P�fG|I���G�@�{
��h�@]����&Y��{
��h�Ђ>�03��    zT�����F��/e@x�N�|�-�s�"aa��;��lǯ�
z�	b]Rs�=]S�fG��'z��,#H:U��(8���Bm����|��k�{
��h�@M˃r���Y���3;�(����S�v(A��;�G��~��S�}E��?�~(��U!Un5c����7;�(Lݥ(�(�yO��M(�F ����y�ٳ���̎6
U/�-�k*i����(8����:�^J�;n�zz�t����u�2S�(���|��Ga�^����'���)x����jv;hj�K{.rO��m6�r��R�=gv4Q��H8o1�8����h���K�"�VW=sJ.z)��֊}� �3	?�~(,�+��h�sE��MV����x����gv�Q@��{���F�uO��m资͒P�4�qO��M���K��T����0�/ąg�a�2�g;~��P �9�0W,;ҖN����Ba�5t�&B��ƾ��=gv�Q(�L|zk�)L�{
��h��r��|6�����{
��h��ˑq�{�=����R���K;��2��uO�ϱ
U��aLϏ������Ha���a!����(������4��y�Va��Y�eG����Pe���t�\�Q�eG#��/��J����ΝR��Lu�ȕ=��|��G�ޡK�d�"RO��+
��h�Pu��=��K�p"�;
��h�0t�%��J�#���FAt����2%����,8���B~9M�iQݏ��%22̗"�ZL9��yf�9�C�t�5Ȁ���\S�fG���Pi��'"�n|w���F���f���sG��mFW߈H1ĂC$���3;�(�4�	`��	[��ܩ�.�0M�\O�v�����K��N�%�uM��mH�Y�P�5����{
��h��A�YGb�s
�B�gv�Q�:�ZDz��#��+sG��mX�G<[־���6�kT3�>)C�g�9����~��h�1�y�Ǯ(x���Bէ��wc��{���SpfGҧ��w��g����FAt�sR�=G>s�{
��h�Б^��=�ĚK:]�G�:'q ���+x>��9�CaV���8$(�����DaD�,�PJܩ���)8���B�]:���Pc鞂3;�(~)a��ǀyO=�)8�����R�y�Pڎ0wRt�������v����I�S���i��G�P�fG�z�	V�K]'3���3;�(̠�/4���W�f�����F��˲��!j��SpfG֫���*��S�n̡S�'�4%��A�\��s�?
�t�y��B��"�vM��m��f���0Z�2�)8����jv{*5��V������̎6
�t7
�@�?��3;�(,��s���{F�'^XY���_��{�b�'z��~(�t�XR���"隂7;�(���%oj;~��
��h�P�� �(}���=gv�Q���)�L"�X�)8�������"2b���SR�\fu��ر?�~(4ݍo>�s�c�+
��h�0u�����'1���~O��mb�=�U�e���(����B��r�v�  �)�����*�FBN#a\��YS$�,����V��7{����Rz鮃���(H�]S�fGԫ,C2~r�����Fa�U�=Ӫk�O��|O��M L�$
��0�=gv�Qh���B�PJ>v��K�젢7�Ct;~��P`�10��,7-�����D!�̬��a�I����F�ef�7��ߝ��)8������z�~G����=gv4Q(/3�5����ə�K�`�)̜��=�ϱ
M{�����i��tM��m�>���fc�R��SpfG���̄��\�N��gv�Q�:K$�jm�ͬ�
�gv�QX:�~P�>
�u2���N%	8�E<��k�?
��iF�3ʎ�W���͎6
���L�2�Jq��w���Fa�:�{��Uj��e���̎&
ۂzB��b࿼��h���7��FN�U�QS+/�m�@�X�玭�c?�ޏxz�p��uY����Da?�:^�<����w���̎6
Mof.�u�̜��N��h�0EGM8��p����{
��h�0�>�hm73��)QW��W�XR��u�ϱ
������/?⊂7;�(,]�5"�����ov4Q 躾#E����S�掂3;�(4=��?1�������Da��I���j:U��^�R� �F�����������eԘ��+
��h�0��а�9�Sw�=gv�Q��Ό;��y��g��M��8,Q*�x�&��̎6
S/Nn
k��lp����KU�\!������͎_c�QXAWH�U
sH����F��=Z�b9�SpfG��O�D�H-����)8����hy,z��V�{/x�����>�J��y�~fS��a3n�q���5�C�t�t�<�p/��	�
��h�0C�QS�?џ��x���(8���Bѯ�HnX����fG��Ow-)�$S��D�(8���B|�0FI!����k�#Eb���Ϯ����9�C��:�
�[#<�W���H������z���/;�(��+�Gx���j��=_v4R(��]�5����i�;
��h����,�(q���TB�i��W����+F(�O���G�>�d�=�H�_�+
��h��I�9@�Q2�=gv�Q ]ǭB�k%�p���(8���B���prσֺ��̎6
-� ��aPl���R��B{������c?^!ꀉ�����D�$�,L*i���r�����F����Ԓ��䞂3;�(�ޡ� qtH�:�SpfG�
zW�qϩ���o�e�!)kOm�H��?�~(�|�5���P��)x����,*�.���k`�xO��M0�.��4le�/D]����F��]�@Qr~�SpfG���\���&x�$�*P�=�☫�2�c�Qh_v���u��5ov�Q@}����Y�����Fa����ߛI���w���Da��K��1wYX�=gv�Q����M��ϝ�'SM<Җ��ݳ��~(����	o���|M��MF"�-@���=gv�Q����22e�����(8�����Af��?�'����3;�(���M���yR@��)5o��D�sm�ϱ
{Z�ve�w2�
�SW���F��J���2��Slw�lG��X/HI	5�4J���̎6
/��"�*�L?��gv�Q�n� gĈ9Գg='��l�I>,�O���G��K����O;�k
��h��tνH�y���KyE��mXg�7Xs��Ċ'K䎂3;�(�Se�)i���հ��F8�����u)<J�PNV�\U���!U�S�������~(��C!5��c����7;�(�m<
�����J�(8���BkzA
���gc�=gv�Q`�քDXK+m�(8������(g��v�8D}������鹯������#:�8ǳ���^QpfG#��3�pZ�.�ӽ���/;�(ė�}����2�=_v4RhM��}M�%�9�wG��mRЧ8�@,�vDn�U�u�6�Li�x۳��~(]�'�C,���7;�(����� �ţ��;
��h��t�H��(�穖G��M�Mz5�	5?�.��,8�������]T�S�+�_ͰG��\ϴ<m�+x����rN:�z�Z��}�5ov�Qh�����j�Q��SpfG��Bx���{
��h�P"�TŞB��,}�SpfG��˜��k'�e;BO6��tbkų��~(�n�SdRimGN~�ov4Q�����R�s�a�SpfG���ꭧ�=w���F��*K�s�?PpfG,U�V�L�s8v��N2#֚&M�U(>�~(t��PVi=���)x����j/uY�\i����SpfG�Q]40��%n�o�7;�(4}���,+���g��MzЙD8:�'
�����c�hǀ�se>�~(d}ƭ��)��Y"]S�fG��r@Vj�$��s���3;�(��ޛ����y�/�QpfG������F��#�yO��m��C�Iʘ�����T�¾C������������s0>�rM��M(�|�Ha�5�������F��U��Cfi5��7mXGMyǍ�:��
    ��h�0Kы�4�? n��xaF]m��8��d�5z>�~(tyۧ�M��l���7;�(��>�Jƶ�=�{
��h��@�ٿZ�z��b���̎6
M��g��0�j���3;�(�Pu�t�F�7 N�'�e33�R��0�g;~��P�/�!�!�0�5ov�Q���B� �	����َ6
+�o���נ�7M$�[Y���T����̎6
�+2�	���ֿ;	���T�(��uǯ�?V�& �6i��5ov�Q(z?�p�0F��M�QpfG��Ɓ*uړ�%pO��m�n��D���*��;
��h���s_p�-P��~߈�1�/�s��{�?�~(ݥ3�*M@R-�;9��������q��V�_v�QHYg쟨{���r�S�eG#�_fS���i0�S�eG�=q�uY�Ci���Z�J�Vڪ����\�{~��Px�Ԉ���<ש�uE��m�^�o�[�Q�L�3;�(,]ِ ��C���̎&
tժD��F�Z��ɳm^�A���/��b=�Bn��K�Bϡ.�9W�s�?
%,�+�5�TV\����Fa�C���^�(8�����xG��u2��(8����Z*^ �F�s�+
��h��gL/�c�S�	獨�k�U�}�=��=�;~��P ]����Ҍ|M��M0duSd��]�)8���B�Y���2B:5z�(8���B'5�f2FH3��]w���D�E}�/��!������+������&y������3	#aÑk�s����7;�(���Ҋ9�?���َ6
��B�=�(}�=gv4Q�9��M���O�=gv�Q`�+�PR�M�d��ާ.�Gi-*Ok.�v�����a�8J�k
��h�Pu~����^f��o6uE��mHW6�Tc�g,랂3;�(�>�qL���rO��M��2
,^0�8�e}�'�{���v���0u)L�Ŵ���=ov4Q���̸#�1���v'�v�Q�Y�)�[;�����gv�QK�1 �ǿ^�w���D�Aw�"ءT��ɏXS���3� Đ��\�ϱ
/���QI�۩�|E��mX��	���V'tj����Da���z�@���o��SpfG|�؊i�s�Sy���3;�(�έM�3����kЋ�e3�`���	�c�Q�'z����B�e�5ov�Qh:o�Ìc?�O��;
��h�0u��Cl�������BAB�Y�T�� �=gv�Q�:K$b�ѡ�+�*���{����ͱ?�~(,}�iB�<:?-E�)8���B}�E�y&0s*�|��H�Y�$et��1�{
��h�0��H���:����/;�(���t&�!��3p����n�\�֧����c?��Z��H�y�W���F�un-Ҥ@�R�qO��M��Jwr��\r��TB���̎6
��<*� ����SpfG�Y�Q
�YR�y��:��I�DaҒ�َ_c�Q�EW���m�C�Ȯ)x����Е�D�1�H�����FAt��;�����ov4Q(9�5�Nک�yG��mXg�|��j�qz�H�]+��X�G�����j�I��Rxz��u�Ǯ(x���BՕ�~X�Rȱ�lw���F�t>e�w=ҿ�;
��h��Q�GtL��Q1�{/x���B�,`
ca�3�/%��V��c�	WϹ2�c?XW��}�f���5ov4QhIw���a�1�SpfG�o�J���8�)8�����o���s���̎&
=W}d\��R<G�w�Qo����8�P=�Y��P身�P����L���͎6
�c�JfY�p�gv4Q/G
�������)8���j
Yƨ}O��9�qG��mD'�d�UG�������ӊ&�,�4���َ_c�Qؓ��S��ʪA�*����F����q�\�t��CwE��m������w
�=gv4Q�����E�[*��F8���B��@b-�{�|�8kVAo���<�$��� :?�hΑ{i)�k
��h��9�j�RF�6�7��SpfG�F�쫄��RW�{
��h���"I������2�)8����*QQH�bg{�;,+��}�8ql�xΕ������2��QB(�]S�fG��_��hP_������DA�#��&^c`�gv�Q����<6���蹣�̎
=�t`�kǏ���L��]0�4��B�we��~(d�@RZ}DjtM��m�^��4V�c�{
��h��S��:���=gv4Q�Ig �H3FI+�SpfG�u`��J���uk_T�>8��� �q�W~��=�CA��r@	=Tjlw�kG#������?����yO����N�MWE���\��J�u��  8ä(���+;)�K�����)�vk�E/Qh!�ۢ;�Bǝ��~(�tZ�=�� �u�����F����o#�SpfG�U��	��jC�UB���̎6
M��4�� ��R�)8���B������-�4Z��)3��f�&�6+q\��{�B�e�QF�}�V���͎6
_z��Y�Vcf�{
��h� z��!B��{���̎&
tV)��(�0���̎6
3�7b�
9ԔgX�;զK[���K��y���(`�yS��@-�S�fG�2�A�:�z9'���̎6
���);��G���̎6
Kw�$a�ٖ�yO��MZ}ҏB��!�Y~wjU7�ؓ��xJ˞+�}��PX�"��<-Fz=��w���D��^_�T�A���Y�fG��{��P{:�q����3;�(�^_(�i�^�H���̎&
��B> cs̀g1�ۇ$���a8>��=�C���D5�Y�+�7���Fa���� ~
3�9�)8���%�Ѕc��&tO��mPW$��s�Y`ՙ�)8�����P�Bؓ��*�M]¦a�����v��������4�\�_S�fG�ޔ��R����{
��h����(B�&b�o�7;�(p����*c���qO��m��a,�w�#�tbGF}p�P���0�p|��{쇂�}��uŘ嚂7;�(��~aOCx?���3;�(t}�cI�� 6�rO��mX������X�=gv4Q�R��d�.)��cGI��Q��r�#�>��5�Ca��]�|��e�隂7;�(��|z��Q$�vO��-b���a<j��3۝<��F��=�)�Y��B�
��h�_vk%(�
��M����p$����c;~��Px٭�j�z-|M����>�g��ܺ�Q�/;),��B������)����B�c(?�VcN�|��H�{o��,��AǄK=0�O��qQ�lǯ��(@x��H�4�	�)x���B	/�2�,��~I��m�x�c���[zO��m�>�7�%	4�,�;
��h���.��C�R�|�#bNo''G(<�v��َ_c?��T0.��J�|M��mt��=�ȩp�
��h�P�����Sn�w�����F���:JAz6�B���̎&
5���|�����_�P^�1��r�4�`���5�C���PR�3�@����Fa�FD�z��/<��w���FaM;6��Xaầ�̎&
E�]��Chl(�o�3;�(�n>�9�.Oz��N�:� ��V��L�ϱ�(�PT��h��s�4�)x���B~9�I8�H�lw�lG��Oq�S� ྕ�=gv�QX�����r�<�{
��h�Ћ�m��+<	�u�uǞ��~�0�dC ��=�ϱ
C�eٿ�6|�]S�fGyi��q�۝<��Da䮼�1Ҕ<P�SpfG��s�Y0�R�r���7;�(<mC����e���u��%q��z��k�B����q�'�r]S�fG��{Hut�y-���̎6
�7bQ����������Da����~%F�O��zO��m�^}�a!�m�s����~�R*�Hr�+�5���r&�C`˵\S�fG��R�cK<{]�����F��Q�O�:{��=gv�Q�,�i�k(�zO��MV{;��!���+/�u#�)����c;~��P���c���B�̮)x����ĩ>��{1b�I螂3;�(TRU���Tؿ��)8����c�Rs
ֿ3nW���Ba�/t��d˳��Iγ ���#&�Q�9��=�C�K-    ���x���)x���/�z��+�Y�)8���B��\S�X��14�SpfG��;'DL���3�xO��mXg�d��	��)�j�<u������s�?
)���8�%�!�k
��h�����)��9��u`���ˎF
�WYv8I��J��{
��h��gM�Y@�ة�pN��Q�eG#��KUt��C���٧LPt��Hs�RC����s��*IJ��t��5ov4QȠ{�oU����7⊂3;�(��`��\P�9�yG��m�>״`HH�%���;
��h�P���,B%Vd�7�J%�%@y�c,N������=Va�d�=Ԟ��7���F�����0��D����D�&]�!�"�����F_� 3繟��
��h��Q�6H��V�<oD]]7�Śs-D�س��~(Ԧ��!��W\�]S�fG�����^�,�����͎6
��FF�������D�e=�H�q�Ո��SpfG�^��6�d�NgN��$څ��6H��َ_c�Q�QW�'I�F�<O�+
��h����z%�0�)�3;�(��T{F����㼧�̎6
��#p��i��=gv4Qxꯨؑ����V���K#�AD+�8x�����c?�����Q`s^S�fG
��i0�Ӄ��=gv�Q(��
���!�SpfG��W_�^ט�N��;
��h�0�PoQHD��y։�����[��
������R�Z�����F��B��5����{
��h��A�Z#S_i�?<��h��u��!Ɩ'�{
��h��M})���FܓM��஋4lq ?�ѩy��9�������x)���}�����F�.�,����@���̎6
���3u
�B�gv4Q�� L�o\��͎6
M��G�O�	��󍐢�7VC	���k�|��P`/T��N��)x�����3	�5�5�I�;y����P��lڔ{
��h�0�n,�-r����)8���B�C7%-A��,@:�d�j�Ap�ֱ?�~(4�j@oܠ��b\SpfG#���X��ڳq��=_v�QH_�� �cb��c;)Tݙq��>��j��_v4RXzW����r	�/$Jz�b?,0Z�	�َ_c�Q��d���9�rO��m��l���*�6�)8����,o]�z����_����D!���tBŔ�:;tw���F�ef=$��G=�i ]�j���'�G��g�9�C��	�Eu��L����͎&
%e�O	�<�t���QpfG���u�Wai����َ6
/3�'�P	NE�;
��h�P_f�Hy��4�H'j�/Q(B٬���cǯ�
M�wܷ"������7;�(�>�Zd�>��:'��(8���ơ��ne�h��gv�Qh��k'����⺧�̎&
-�tfD�����٧d]�l��*pb�U(>�~(��U���!���7;�(t�I8��R���uO��m��Gd�_�2f����D�'�1�1D)¹���̎6
CGMY05 i���CǗ���0g)�<wN��� �>$���}ʶ;y����ӪRGM��i����ς7;�(���\��K�8���)8����q�bL��)8����S�L���Z�q_z�J��>,��r;�v���5�Ca�N��+9:����7;�(,]��	Q���)|O��M&�"ҞF���|O��m^f����yuڟ�ӥ�3;�(<����&2s��N�>�$#�؟S�g�_c?ZUu世p��ވ
��h�0u5�H�J�����3;�(���#������)8���B�v���3�L|O��m��$�qu��<�z{�Rߓ�X��9��s�?
�f�S2dޓn>��W���F��F�S'�ҳ'1�)8����zA��A��Nf�gv�P�!�
f C�sP��yO��mzx��1�+�/�Ρ� sR�k�g!ϧ�?�~(p�1!p�����̎6
1��.��H{Bu�)�(��������ٱ�!܊�S�eG#����s�'�.�5�;
��h���nzݥ1&���cNQ�Bc(88FY���������l� ԲJ���͎6
K�qc���&�A�QpfGH��B��R�mNx���F��g�gX{�t*�QpfG�B��S2OJP[�ͦ2̮{0@[��=5��َ_c?�޳f\��1R��7;�(tPv�O�.�I��{
��h���!o9�=�&���̎&
%5��$i���tf���̎6
#)
�۠2:����K���6��s}�ϱ
��<�#	CKN��+
��h�PAg.�#
�����͎6
M�ʌ=�{:5S[����F��ve�Q��^g���̎&
�E�R�&�s�t��_KU���>�lǯ�
/�;���<s���͎6
Kg�Mj��?PpfG����t���7�S���3;�(��0���������+
��h�Ѓ^}0Z9@��lS�`V�RV���sO�ϱ
y���\A $ ����F��JE�,�O��xO��mXW*�3�5[垂3;�(�%���> k޿I����Fa�"��5uh'K$����,�o��uǯ�
K�����i���+
��h�@Y�L[�OAh��̎6
]�5��*.�팓pG��mx�[�9�\˒?PpfG�Yt�u@��\��� �8)��!�y>��9�C����B���@>���(x����ҝc�ԣ�I�=gv4Q`��"�����9�=gv�Qh:ۜ����o�3;�(���z�G;�����/�C�"���Y��P(z}aQ�)�oh���tC��m�^_`��p�ׁ펂3;�(,}�q҈�m�#�SpfG]�.�Q%�~Sw���F�t�{��9��sM�ti�(;��_���9��B	Q�ق��0�?/�P�fG�u� �f��Zmw�lG��se��	��II�@��mD��%�;l���w���D!bЧ��9�g��ėd�3��(�َ�c?H%�3��V�rM��m���_k����s&���/;)}�sP�@�y/��,�����H:j�����w㻣�ˎ6
�^}Y���w��YHK�3JĐ9V���D������"�\�ĵ߉|M��m(�z�Rc��¿�w���FA�~�r�9 �n|w���D!gݥ� �Yb�s�{
��h�0��NAvĔ�oŭ�[y���/�α����P"�~H+�Q&ú��͎6
��~{R�!�W�gv�Q Pt�Z�Y{�#���FAX��^-��lw�lG���i)A��S�~뎥�P	p����9W�s���_�,e%I1��Q劂7;�(`�L��0��y�,x���B�;tP��l���3;�(���	O˕�2�S-���3;�(�����&�INԄ��w�q?G;Mݳ��~(`�����&�_m�+
��h�@:Kd���M�=gv4Q�A��$Ȱ��M��o�7;�(]z���,�Ĕគ3;�(�^�oZ�J?���w}X���c\yf<��k�?
#�]�UC�Qv<�8�(x������.�[%\xO��m�_�55���َ&
��o*����J��q���̎6
Mgl��(3�C����N�zHy[��g;~��P�Sy!��Y{��c���͎&
3j
$g_�a����F���4�田
�SpfG�/uY
� ���)8����>�)����AO����C��g;~��P�ԫ,	����@����Fa����D�f���rE��MV���!AkmMJ����F����	8)s�h����Fa����%��+<o���O��&�>�pmǯ��(HҨ�sz�䚂7;�(���������)8����|;�X�ڿ��=gv�P�!LAW��G�1:�SpfG��נ�Ȋ��~'~kM5�D�V��إ���+�9�C��^}���,��t�gv�Q�I�� �Y�������̎F
U/H�Ė�Ƕ
�S�eG#z�rI��g��|��F!��h�*�X���Sz) Βb�Z*ӳ��~(�Χ�����>�W���Fa��B�b�ڜ����D��B�_�J)�RO��;
��h�P�Kc�ܛ4����͎6
K��i��j�t(�x9�5T�5�*��k�?
9��¤>��2�~SW���F��#�    �ˈ����ɳm���I�d�SpfG�t�΂�U�xVY�(8����˞5��P�������,�C�!��?�~(L�=V��`,!�{
��h�P#�gq�܄�9~G��mP����%�h����F�����LJ��r�����DA�Vjc��zm����[~��g*C\ǎ_c?���B#�=��f��g;�(L���Y����T����̎&
-�̀F�����{
��h�P_z�>������=gv�QX�����[���~�OGc]� {c��t��lǯ��(t�/s���y��lw�lG���E��&����3;�(Lz�s_a�����3;�(��_���O��}�=gv�Qhz�i���,�1�nb)2�H➈4�lǯ�
/�����{�ᚂ7;�(P҇Ȩ(����}G��m^�Mu�#��O��gv�Q�zō�l;�\����h�0A�AL)�
����0�^�",��D���5�C����Qhq5�"����F��*�Oss��)8�����g-��>O��gv�Q@]�I0��l� �=gv�Q��(���g��=Vy��D�<�ċ<������f��7V�Yp�ۏ���͎6
Mw�@j=��Ӑ螂3;�(��ѓ�u�pA���̎&
I�Y�ja�5R�{
��h����k�8�����E�!\�&���!�v����^�;b��H�<�5ov�P� ��V��~���O��gv�Qx�7��7Rz(�'W掂3;�(LRkM���7���gv4Q��'Yf
}�2��K�1�j?�p��k	yΕ���0�>%�؏Bf���̎6
)�ls�%��̃�)��������}P�'����/;)��r��Cl���Q�)�����>ה%��{�#����+EF\c��yW�s�B�����ǁ�)x����˜���@B���SpfG��2���Ӟw���)8����Kh�����J�=gv4Q(Q'�,�X��c&]�O����������k�Bѹ2i����j��g;�(�9]�nS��xO��m�Y�;�hy��[w���D�B�Rk�T(�^"w���F������P(̒׹SmEo��	=w\�se>����a(/d�����)x���BAuQ��t���O��gv�Q:Wf� cF('�3;�(,�Q��/䎸����QpfG�V�)�B2[\Xr��Ma��P鹄�<��=�c?^:-1�'�.?�ï)x�����u�Bqf*ک�tG��M��Q��+��Ҹ��̎6
/���dߞ���͎&
{�O ?�B=G<�B_U7��?!Tzwݱ�s�BuQÖ�Db��o���7;�(���h.�+�uO��mD��HԂ��/N�����Da�P�;Jl1��&�=gv�Q =��kn7>�cH��`��=�a=W��������R��!�.�W���F����z�>a�{
��h�0tU�m��,X�)8��������ˀ	������̎&
���6����%��5�K2��P����|��P ��$�'5�e�k
��h� /�>i2�w� ����Daey�1����$�qO��m��H2 �BJ9�xO��M$�J�AR%z�։�"�Rۿ���َ_c?��i�<��8'��(x����$U0Iŭ��)8���BAW�nPrXaA�xO��m��H�H�Ԓ��)8�������!���O�B�G���|�8s�칂����>�Z"ОW�H�\SpfG#�;t�f,�ʌ'����/;)̷j�2g���=_v�QHA�?d�?ą�$��S�eG#��c���:�3ϝRў}�c�&I<������:^�1c�e-׿gᆂ7;�(@ғ���5K ����Fuf��Ú}޿��h�0�K�&�c�=��pfG��G��[���i9�fu�(�^C��s�ϱ
M��h����S����ov�Q`]�mBLeΰ�TB���̎&
%v��ó5�)8���BMzkF��F��gv�Q��q�T���o��J��sMÀ2S�\��s�?
t�S|��]]S�fG��_*!K�}N���3;�(L]�/�0c�NxO��M0V5��$��,ԑ��F8���B�;�O��z�N���Eofl4��):yޕ����C��Qؿ?aB/����D�%}���Jk���g��m�N�0��G>���(8����̊��2�0�,x���D�g]�,a^��X*�g����h����J�lǯ�
�����=�Q��)x�����]O�.i�X���3;�(��kw%q��� �SpfG���Y��@O���F8����Ea�3���T��<bP�&�Kj�������"D~�tB�]�)x���BK/5zJ�w�0�=gv��9Jx2�s�\��(�_�������_���~`���Wl]ʌ��u���p�����_�@����w	�;��a����hQ�8a�/X��ߠ���א�V/��?5���na�aI`u���^�[���i�0�^�0ǒB\�/�ϡ���1��E@{��������!d�O�`a�:T��'��\�;a���Ε8���I��1㤗��}ȫ���ތ�"&��aƦ�*iGL%�S�𚂳��F�g��2a?#�#��¬Q�2��[��������s�v���J�TG���-b2Q`�:5������)8��l�^FY9��S�Ꚃ3;�(��5o��Vmtz��QpfG�}Cݹ��:Ʊ�ɷo+��nM,�c�Zs�lǯ�
M�L�VM<���(x���8�oi�I�
��h� )���,��f�-�{
��h���$*�<Y�R%|O��mD��	���>�ZϗR�Ki����ӳ���P�!�ʷ�~G��0;^S�fG��r���uQគ3;�(��L(l�?�}�SpfG�����W�1�	�v'�v�Q�z_�a+��x���z��i�l0�!B�y/�s���
Qٿ'�\SpfG����H�Qj��5�Q�eG#��O�(C���.�_v4R���됹�����{/8����wj�=K�	{��>���k}�K�s������+� Q�2e�?wE��mXg�Vz����Y�fG��P_��6��lw�lG$�F@��5Og�{
��h� :�����_�L�_��B�mZg���9���u.e�����/����͎�~�����o/���v$����}����U��=�m��a�=����� !���1��#�B{������y�A�X�Ji�>-����$؎�ę�EUr�%d�1�=WO�B*Z��erz�v���S�P�;��8���1�Y��k��~ PVu���G�����`� A�8"��)�:��C����!LaܱBos�=_N0A�Aw- ��J1J��	$�`bJ���+�t섯����`������|9�a�J�{�50��9�C�����Q�㢌9 �LC�=_N�AC9a� )&����@I�U]ԉ�e-��	_C�A�!('lu2o;����/'� ���?/ �Q	���/'� ����#�pt�Ó��	&��TAO�j�)Ss���u����t���B��[���k���m��/g6�Xb�{
���Mj�݊�$B\��r���l��F�/uQ��6���١�/����T���w%��~�]�b��;�v/G_��O9>55�&,+��ǲ�C���4A�{��c�,���/Vh�/��� ���ٍ�:�@�S-<D�ı�L�|�
6��L+	-�R��C���Y�s�(�g���/'� ��.,X��'tU?.B	Kj!>�C~��5�A�~pV�e��/'� ���~�� Z=��_N�AB����߃j����	&3�9w$f��i��܉D/A��i�E"�����5_C?��8!H�1���/'� L�K�J����/'� p|�@���t�p��l)qD��*.�Y�s�;!r��2�c'|�@�߇��[�5N�v'�N0AXYCH0@i�C����!���rF�7�����	&���	"Sf���ℵ�1�-����<�����A}�`�����/'� ��[q�S#����C���B�O*���}�{��`�Ж�H    �sJ�q��1�}Q��Y���=�ܳr�������e�ظ���	F1�z��{Y��{��`���;�D*���
r����Թ��S���u��Nq����cɚ���;|�@��j�|��J}���=_N�A���V�?�꾌��N��`� 	�6��s.�0�!�r��������&��`R������K+�넯��!Ȟ@��h�5�C��O�C��r$*a��Ӛ��4��Ni���>�����_R0�%�	�$P�턌y鐪a-ya�ű��~ `P�p�~�)>��|I���%(����)�C�(� �P�Ғħ�^�����	6M���ZF�@=�2?�E%���#w*s8v�������B��\�;�����	&�㲿i$���_N�Ax9�إĶ������/'� ���Rd�b�,!��0����c}z^d��BV��$��b��=_N�AhI=	�1����O̺���	6��'!��%�r��L:,%�$�s��K:+�=,]x�ha�9��������I��b��p��lX���)3�=o_�|9�a������38�!�r���bRp���㄁����3�N��� YAh@=����W|9��2�d,c�֙1�C����!�8��ں���	&3�J�����3����ޙ������/=���A����:	��d�� ��l����Sw�)�>��C����R�MJb|61�=_N�A`��Є�� Lt�UW_�,��3�[S�{�}8�CU)]��a��F�߇sV?���^j���ev�+>v�(�������ti� P�M�����\A�%����q���,k��)�jMZ������fA}�@x)M���F[�Sm�|
;8ֹ/��sO8��/'� T����_��7{�T��_W��7�SKEEk62�!�q�=�U���٬u��Od���GPºr�0���%_�pA�{�Z���V���v(kC�F~������g�0�����+M8�@��A3i-\;�=W�p!{Q��pQh�c���w\i�!�_�H�(bJ_06�T�RĦ}����o/���-�����X� ���TB�*�{���K� t��D�= ���K� ��o/
�J��*@۫�J;  [(<g��q��i���owdG��i��{�4�[D1�6��o��%_�p��$P"���Q��/M8�0��h�M"�&�ڍ���%v|����Am]o�P���!��C�	G�3-Ϝ]�����!�҄3�B��t�ܡ�N�|i�\��T����g���Mu�Js��*y��L��BXA3b˂�T�
�/M8���ޔ��R���\�=_�p��j?Ŗ��б�C�	gڇ�z��[�K�����"��q�§��6{�ɒ����/M8�г�������x��&�Ax�x�BF`�^c�'��/M8�0��"'�Yz���>mSԜA�s�{�_�o��1���1בҼ��K� �=��2G����K� P���h�4*p���/M8����'(�^�l�e��T��j�v�Sk��9w�2}C�v�K����x�C�	G���<3�tZ���|i���~�.K-,}��|i�U[�-��P���s�=�W��#T���ҧ�?R�C�=Q �k����K� �m���+N)7�|i���JX?Ђ��E�{�4����Hȁ%{gi��r! �D�r�ݱ&|�����iD�a-� "t��&�A(�̝4���9�C�	g�x+-/��3� ��&�@H!ۙ`]�JΙ��ޔB��没+E��"?M�:ښ%])d�c�{�4��D{�bY��)�\i���`A���+M8�@b-Q�ܻ̜����7u�#����m�BJ�> k��s�t��&�Ahv{MU��.9��	�4��؉�������A�	G��mZ����Gn����� �mV*,��b���d�P��1�g���C�	Gr����na�,�A�	gZ�MU(�RK�I��/M8�P�md>�r|��Vٞ���q��K��e�cM�2}C�v��c��ZC��� �҄3lS͌�R:2� ��&A���8a>MZW�ԋ�{�4��/E!c��J�Kd�o�ME�cP Ϲ×����ˊ�8�p�D.�|i�����>D��T3��|i���f��4��>�q��&Ah+Q��p3N�
��
_&/3Ae�i:n��i��Њy�k]�%��C���K� H�=}�h��0�!�҄#=��	&�Z0������&�A`'4z:M���+�7�fե`iQ�;�9w�2�aķ[�G����/M8�Pm� ����C+��ɱ&�A ;�gjXs��!�҄#�_�9��T
������&�Rj���,���a[ی�B+��p��&A�`s���[�x��&�A(6wH�EW��s��ɱ&�A�6w�����]������8k��s�Rk�?6wh�ʌXF���/M8��l[����O�����A�	gĮ�)a\!D�{�4��|�^-�:S({v��3l%k_�"�ߋ�4}CP�P�B���v�;�4���­�g���=_�p�z�\�3�C�	' D���9~��̀���tV[؄J�xjَ5����KY/ı��wG�;�4���(�T!�QF={�cM8���O�==�ͽ�{�4��؋R���2�>|��_.Ji�K\�
(ǚ�i�B��@�*X�h�\i�!� ;�S�6��Cp�	g a�M�-7���=W�paڋRS)E����"����u�L�_�_M�2�!���b(�3
�� �҄3�^
�eL��6�_�pA�� s�V��nEx��&A(���T1��-�%۞#p�e��������o��i��'\A�	Gj��ޠϵ0�Xڸ��K� ��^�~���3��4�&yi'�G^��1~��"h�jR�29,�Ȏ5���-��\�My�K�J�_�pAl�΄>pH����/M8���Y%�Ͻ�g�u�C�	gf��+������&���ά���zh�x�˧�?}�KV��J��{��A�	g����b�qH�|i����:T���/M8�0j���+`�]�nO�
G�\���6��?M�ȶ'%ʒx}�o����K� P��R�
Hߗ>� �҄3Ş�'
CQ0N��|i�N�����3���]p-,8"B��?�/���4�i ��9h޻���:�8��� wH��O�����4M�]X�o��x�7Xr
J�ynJ�i�����#��ބT�@�%�'r����j�D����/a<�����
�Z|��߇�ƞs�h-�~��O�
�-w��c��eo��gցQO�Uq���q�ڧ�B�G�Cc�?pJgo�+��d���c�3jH���J� �h��e谒'������!z�2淰�+�9o�h;WL�e������oOP�9<���V��S��WK�'t��o6�1���_N0�r�����{���o�/ׄ3�1g�
�|�GF�/�	����&���K� T[�_0�H�V��=_�pa�%rhZ�t�λR%����B(+���yԧ�?��4"��F�����A�	gZ�ׄ�:��<z��&�AVvm4�� �҄#\��OG�9a��Dr��V�I�k/�s?�O�7�.���Ɣ���=_�p!{CV��4W��V�i�ק��
=����oA�2���T�R
����C�E�@ A{Mx J.�O���F����7!�[ε���k��O�7~k'2�6������s�3��q'BF�2Zn���H_�����;KO�޵�b���pG�ҿ��.5+�Y��1�,EU��@�:1�2��1\�������D�@%dT΍&�����s W��L��P/\�3C���>�#M �G�1���H��Ɲ&-���'ih��@琧�{�?��'�E�b��3\�6N��,���pv��mX���Cp'B��&n�g���\E�g��"�I���0�O�� �k�pt    �\�0Ŝ�Y���T�}��ju8����
���t�����_�����T"������K�<!�[s��5Χs �C8�mg�v�SK-K�0y¿�9	cv�,R 4[ۍj� 	�/mؙ(�XJ�u�6��'����������*�?�z��4a6TZ�V���<Tk���Ӡ�
J�ߞ~�����l��@���%�W�������ZO$��믵���8MX��a�0q��R�3#j�=����+l�/�0�J�R��=�����9�����UF�ĝF���������m�欺f}���Ò����!��[�\��e����e�5]���Q����>!��qR�O� Ma�D�R�*cJ��Q��r=�Р�)��]�Wy�=�`s8Oڥa��ٛ�KG�ÊM��t�:5����|�=���㡵��PK�����|������/�7��P@�P	\�����������BO���� B�2��S��) _�Ag�X꼧�,v>��L����� �Б��k
���#
(��C]˳�B���4��bUq��V�/�7���C�b�#���)xS�3
,f�L�Ƙ�g���L�(�J��!U�\Ǩy�{
���B桨4@ L|O��:�Q���k_/�";v\'��F׏ՎKE�gu���G�!�x ���v�����TA�<m����|O��:�Q�n�&��Y��|O��:Q��LhU0d	���>_Qp��gz1m�t�P�^)�L�P��A`�%�����MA���&��2F)xS�#
^������/���3u<���Y�Nܪp�{
����Y#&��B�Q�)8S�#
��!4�
V���S�1�wh����ĳ:~پ)4����Z_F����
����F�s@��~O��:�P�ؕ2"��Y  �Sp��g����s�g~�5g�xD!v1�u�E�`(���ݐ������X?m�f�a6!�
9�X�)8S�3
	�ͦ���~����k
�����φF|.����|��!;6�!d+��|����fS��R#f�o�������2K���e��@�z��S#�J�k
������S+څ�=g�xD!?Q��ҭ6B]�=g�xF���"���B�zO��:Q(a�����t���wԔ��0;i���2�:v��}S��<�Z�(M��)xS�3
��H��JHipO��:�Q�i(�$*�
�Kn�3u<�Ps3ȳ'b������L�(�0+%�3w�#��ʌ�Ŋ2�L�Wt�Y�l�Q�\�"yŔRk���M�(t{*31���JC�/xS�3
�~�$��5��ɳ:Qh�L≘SM�� �Sp��gȖ�,x��,}��Bkɤ\��R�ɝ��̧�?
=��ռb�V��������b�P��z�)�@��:�Q趢�W���|O��:QY_88%��(8S�3
"�<b�zH]�o�e{h�hr��#��I.����J�<�xR/4x\S�g��/dEű�JJxO��:�Q ��T����C��"������u%�z.<U�)8S�#
R�ĎW2��5�]	v��VZ���gu��}Sx��5��"�5o�xDa{��TV��#�r�&��xF�����>9��pO��:�Q`4�0PRԹ~nW��Qp��G�U[ݥ�~�k��w
j�T!� 4$�g�_�o
ϔ��xH���*�ߩ�o�xB�����Pz�~O��:�Q��0eni ���L�(��["gSH+n�{
���B��&�DZ����7T[��µB(ٱ:~ھ)�4��Vz}���Rp��g����?wYh�G��[{G��:Rdw�hh��L�/u<�����|��3fjW-�{
���°��1f�{M��35��(�z�w���G!�f{qP��F ���M�(�����@3�(x�&��xF���PE�3����3u<�P����_M 6힂3u<�@��VhIz�'�T^���Q��:$zV�/�j�7	�ƹ�R+^S�g^n��e�!R���L�(�˽)��r8�)8S�#
�r�>,IXiD-%�
���G��7Ph��}��l�TU���L�uf�e��B��>%@��3�+
���ڎ$�
�����(8S�3
�&��+��+����/8S�#
�x0U������3u<��/�7���M��k��nHu�}��ܴz���i��/].iS���خ)xS�3
M�(k���h����+
����Z}��F	�wת;
����dVJX�!�d̒�)8S�3
d+�
@���3k"�F<V���pk�Y�l�Q��f!� qp�Rv��o�xF�Ɨd�B�2���w���z�BA�
����
���D;3 ������)8S�3
î
�Z�3�����K���2&������훂ZTD�%4�;����M�(���� �>7	�
���°�3̈́S��ݝ掂3u<���^%	K 9!�Sp��g��rYi���ɻҏ�ث�9�%��<���´�fImp=_S�'8T[ c���ٛ<�����P�b�eɣ�Sp��GV�hOe�3��4c�=g�xFa�=��̴E��w�����NФ΀���]�O���@���R���<⊂3u<���K��TIEw�pG��:RP[���g�i���w|���v�p�>G�U�=_�xHA��\�0&�p�t~9�����p�we>m�Q��V ?UM+�%Ҽ��M�(4[�և0e-�����Qp��g����:a+q)C��"���������l"���M���W����� ���Z.��/ �a>�<=w0���G�F�].�嘃Ʊ��\Q�g��}�����!�������*Y{.((�{
���Ɨ����������3u<�@��_ ���I;�Z�k���g�:\Ol���G�E����eidH�������2X)�\
�=g�xF���}�^~�PK�������Y��%�A�)8S�3
�x��FŔw�W���Kl*,%���e���v�(@˸��M�(��2i�*��V�=�)8S�3
���h�Qd�����z�qk�TgM��Pp��gF�'�������앒��g�Kg%" ק2_�o
j;�&b��&Ϳ��
���g�Ejuօ��=g�xFatۻ��X�3u<��lsJ��l9���]Qp��G���Ac�yf���^��~O�MC��ku��}S��7x�Z�,J���]Q�G&4;�^GT��R)���������$R%�{
���ڽ����X��)�(8S�#
��C:b��u�Xbg��2v�0VJ�#7�S�>m���msRe��7u<� �.�r,�����(8S�3
M��-"�=�D�(8S�3
3�����X��=g�xD!����T��"��<B"�F>ϥ��Z����|ھ)H6����PC�}Y�(8S�3
)5�Gd��0���)�R�C
(�B\kC�G����񐂼L� �L�C�'�w|��xٜ�a�mS��r@P$�.�i��X�l��vH��<��'��)xS�#
9{�Nk�y`��M���B�}�'�9g�R���;
���۽&�yVd
�3u<�P�=�`�QC��wZ���&�
�!�4j�](>m���}eŞ�L�[~K��:Q�l�O\+�&)S�}��:�Q(v���TJ5��Z�;
����<�*FL��Sp��G��U��B�e��k&�א	;�PkI��?m��v0c-}����S�G��d�EaJH����3u<��v]��I�	���/8S�3
bO�� ؟�|O��:Q���`;L�����i�t��x�}Ŧ�E�����o
/7�&j��e�5o�xDaD�E�� s���)8S�3
hZ(�9c���3u<���|D�wk%�H������m�>4�F����:>�8&�&�$<�������Ma�;t�jjSJ!���M�(p/�]k��ȁ�v_�(8S�3
�~6�9e0��9�g�xFa-�Vz�8�3u<� ��5���H�W�&�/-��
R����.��o
�NN �TG�{��o�xFA�^�QEb����3u<�0s}�闐z�Iz���L�(t[˒�Nr��    �3u<���^��PJ�eWqL��O#Z��uEϗ�B�U�0�4����(xS�3
b�YGh8�_����Qp��'f ;K�Bes���(8S�3
�6�z�⧼~�Pp��Gb��2k�sh4�8ôWO��D��Q�Yھ)��� }
�$8�)8S�C
b'�T�2�Ԩ��)�R�3
	��+*ɔ^គ/u<���.K���3���["w|������V̸�A�'�6�*̰⍨ӳ:~پ)��"�3�Mb�������2S�s0�)�Sp��Gr���F�̙$�{
����	��&VYa�Sp���B�u�Y��̬��A�CW���D��X�����P����P��ߧL�ꘌ\��B�b�_�����g�5��?�妿�1R���P���ƏW�����F�m/����EZ4���<������P��{
�z�[[����	�A�_��O����ܳ������g~�D!�Ώ�����K�χ2��FN#	_C8X!�A�&���CS�J���>���69��C��AXB�8��/�7�6�>T5����P�5g�pa�j d �C�S��{Sg0��b*Мk�M��M_�o9R�Ғ���k������ p6��p�rI"y�i�iH��Pt����L��9��M��*��F�k�<�!�%rPQj+Ԡ�o���O)��f���	���a�yh�N�e}�5g�p�S4����)`���7i6U�T�3�rܶ'�W!|��!1vP�6����<�g�;<��R�ܥ숑�0K�P�T�9�'|��!��;j�9���{�<������CB�I��~���q���PKsw�	_�o��	�4�`1��!8�3:L�DD�W����$�%�T�s�d����e��Lj<�#�E'��[�<��YҊ���%�~o��L� �T֮��S�M_�� h�曩��P$�4�!8�3զ�U���D*X�Or2�B��P�&�/�7���CO��	^Cp�	g�ad�3���̶(��Z��S܊���>L P�b��������z��'AXْ�0�N����@��غ�zG�-��������_��6�"�x�_�p!&~ф�3I�����RJ=p�k§�B�f�L�WbI���k�<��-w��RP�鷳D���:��S�i�^"�7!|��!h1��&��j���3O8��
�A2UZ_E��ҏ��o�����pı'|��!4�E���K��5g�pa�D��Pж��8��	%�Y�
7BO<�.a�W!|��� ���>;p�̽�k�<�B��8U
Њ�!@�&������O�HǞ�e��@��.҈�����3O8��W�`>��l�/"��1�&��-����<{�B�vu���7���5o�p��|R�.ϴ��C���r[�Vty=*�߄�e��0�<4%wu�^Cp�	GJ��8	��%��M%#Ak|�&��Ǟ�e��вy�#,])7\Cp�	Gjl/as|�B�{5Q5�}����s��B��CZ��4aO�-o�pa��W
�C*�wE���J�k�]��=�/�7�Y�'t�Ƙ��r��'A����H�Xv*�q�%�!F�Q������L���"��\���5g�pa�,RV�XV29� ��J�0��49�h�4���a���P\awh��7O8��v�\�2�ƠL;wh�;,}Y�ZUϻ�_�od=�^���L��y���l0�>��!�F��5����fX�t���e��P^w���,�/l����� ��YB�T��N��Իݙ���u�tۊ�߄�e���v_>���0ǿ���<��(d�z�q+����Ϛc�+�X�3$x�O�2}C��<�� j���c^Cp�	g�V� ���q��ٷ�T�	����/�(��:P���Q:�!x�#�٣k*��uo�R��'u���QϚ�e����XO�)�T���O����� 0�K�'b,RG�7q����3�$�@�=���a{V��*c������ H/��C�CA��^cQ[΢:'�R�y>��2}C��c�6f�4t�k�<�°a�s�k�C����݃{�� ��睥/�7��4��5���\Cp�	G��T{��y�`i��[��Ĉ�M	�M_�o�&Pmő�-G�{�<���	�� Jo�vĸK���+	�������/�4���>�㙼6�!x�#՞@!-���(��H��:@g��	_�o_:i��+���k�<���m�!�-I��Q'���U~=V��9N�2}C�v]_�'}J�[7�y�J���fP����i�V���>��[O�4}C��$Pa�A��bp��'�A��m}�)!���:p�d�T�p�.�#�O�7���z��?Z*;X����� �Մ]�R����h�DN]ye"�q�ʧ�?)5ۑ
{q��]�x��'Ahd܅�MaQ7�Tm� �� �@ó'|��!��41W޺Ҡ6�!8�#+[4K$+F��Ơ?OPی	����)��R����71�?�H"-��w�p��'A ,	vd��b�_�
C�/��c���I_�7!|��!�iH!��Z""�Cp�	Gr�{M�r�^C�,�dSM���8�,}��!4[ӣІT\��5g�paڳH&�C:&�G��/��ћ@��s�/�J�g��FJ���5o�p��X�O3ǕB�,�d{�5��Ise��q�ʧ�°�gt��h%^Cp�	Gj��M��sT�I��4�Q��-(=�,}��!d45����3�!x�#��m���O�}�+��߆�{\a��gM�2}Cۊ� �)ſ�*W�y����$By��b��F2K�$ƆX�y���i�����^�����x��'�A+�q�o����4��@#��:��i�B{;�_�z���k�<��١�+S^�`�e{�f��JA�Z�������a����A���/W�y��술�Q�Z""���$�ҧG���=w��4}C [�Y��J���� t~���,���m�^����{lq��9b�2}C�@%�*�3�wr��'AI���<ġU���zy�jKܞNq`_y�cO�2}C�6l���etn��y���e*u*c�
uk���3C�m
=?�=���
o�C��Da���y��j�HVL]����=�r|i�\F��@�w�>M����`B�Zw��+�<���%R3����W���Ե�L�uB,�{ք/�7��t���J�!x�#�.�Y'?��J��x�/��X�4�{>��2}C`��UQ%̺������ H�W�*r��s��A����g�pIC�q ~=������S�����5g�p���J�5�i�Oe�OOИ�Ll�=�_�o/�4*L�+�J��C��	'f�Ŝ�Ӱ��{{m&[�5S���Q8��/�7�n��@%�bU�5g�pA_�H\QB"{ux�N�u&'֘z��{���!��'`��Zp�{�<�ۋR!N�H#�%R��#�PK-�U������ZF퐋9����k�<�B�ޠeE�8�y	�^�nPf���ç�ى`�O�/+�0�!��31���4H��S��0�����SC �q§�B~�#)�Rv}�o�paذ��
������fo����#qL�8>w�4}C��u@�H�Jco�\Ap�	GR�/Ŝ0K�c���z�޵��crUj��?M��mu�b%R^Z�!8�3�2*Qk�R�ʭ��(���Zo	OG��R�����7�x}�E�k�<��#���$��ˡَ\�v����`��o����*V�Ư 8�#9؞*L�J��e�,	�KO��^]�xք/�7�a�T%]�R�Z�!x�#��1M��k˻���j�,�3k���[w|*�i���b���mc�8�k�<�B��TZqL͍�s)`ǆU��@f�"�o���!�h�6����mp��'A���TS���O������ΎI�,,}t����o`o�M�5�eF����� t2�BJʨi�Y�R1��,ږ[�JB�����o    �����
	Z �����  ��KmF-1�M��qH�mx���i��Pm�JǾ�1�8�!8�3�2������ؗ>dA1¡���]9���O�7�M$�s�	
��+�<�B+�f��WRoA�+-�	M���ba�5K��o���8�s}8�Ю!8�3j�1G*Ze�h���M��n���,�����2�x�Y����y��a�m�6b�w�1�e�|{�f
ӳ&|��!�d �>q����@��3O8�0��j�2��aD�x��䦕�g�_�oX_z�$+��mO����� ���F4���v��P�oM+���B�g�_�� Px�fK#`[�um��y��j��7Ij2��(~o��v���B�|�e��0l�5B\$b�!^Cp�	G8��,��4g��{u��vuT�g�������^ji=7Hi�5o�p�~BFz����#���eE-��C����/�7��q'ECa~~��3O8� /C%����VP��� ���2�:;���i��P��fĩ)ƶ�@]Ap�	g^�J�Ơ�@�K���>D���#���T���A_v��*l��i�o�pa��}}!!L�s��r=�������;|��!�J<�k)mߚ����� ��t4�i�0�4a�=�X�d�KB�=�m�4�A_��3B�W������� t{4Ϥ��ƴ��碌M0�r���n���ob=AuR+��!8�3@|�����6��#aՓ��(��3��B�{�Om�ʸ[���|y�!����scT�@ܽ�f���Z<���
�������mms�F���!x�#h�'L�Ћ�^�̗��t�+�@ʭ=C �z�°��3.,a�{J�g�p!�a�P4�2H���y!�,ϋ�4}Ch���I��P#�m�_Ap�	g���>�|��2���
G�C�C%:>��4��ݗ/Tr<�
_C��	G�
S-��=�	�vq�ԇ��9N�2}C [�!�%��b���y����h�E���'����
c��t�;K��o��|A�CJD�%_C��	G��mֵ|zf
�o�q���ⶢɄ15h�s�e�� v�y���SL+j���y�����@�ܓ>f	vgb�L���#y��L�^�4�>eߐ��q��'�A���r�V(�ܫCv>@�8kX�fL��E~�������Ҿ��XC�[�W�y��j,��*6�M�E�@:�	1�8�T�4}C��|��&�ʺ9�k�<�����5=���1ܬl������׀���O��~��&:�_;�+�<�B��	T�ӌk�7a-vV�J1GC^f8�O�4}Cx)�Tڐ�=��W�y�����ma�����P��)�2J���ʳ'|��!ԗ.u{��YP��y��e���\�+���lݾI�h]��axք/�7��!Y�+��%�k�<���{{�GS�ZAv*ݓ�~*$Q�q����|��!4}�H��C��M�=��֗�h��ži(�Mlk^&��cq\��i��Hv�,��0���q��'Ah��?s���3��a�ho�a�K<iv��	_�ol�$�3
�QKy�k�<��L��Z�Lܒ��,�ˤ��2�s�!x>��2}C(��%Ʃ�@jt��'�A`��tt�#�ߩ4uV�u6�=Ϛ�4}CP��W���g�\C��	'���7����c�s�{T�9Њ�r��O��L�ۮ�B���y�����<�1b���[��N�#�X�x>w�2�A��9��MIs�k�<�B��o:�i�#�TZ�&�{�Q�$�y�����
��! �Gl8����� ��2�Ԝ�� ���L��5	iEU=�3_>M��ݗ��j��Mw��+�<�°-x�u���[��l��uV�<G�_�o�^���̚:U����� ���|B��2D�}����L�D�M�z��/�7�w�H#Dm���y���3Fi�)��>����Rª���|��@�luWT�����@�@��	G�V4D�ƥ�cr0>�a9Z�+���>M����d9�ZFo�|y��^.�BV�X�ߛ_������t�	�o`ۘO(��R�>KW�y�z�c�)��9�ք���D���[q���i��0�cF�Rcǅ��3O8���;V���n^�)G��ԅ(��x�^�4}C {[leN� ��W�y�H�pb������	k���P"a�%0�#�O�7�R��`�����y��v��J�d�	�W�7����`P��o���|�YҒ;SQ�79��#�_�K����g_	��͐DP9J�⹓Ƨ�B�cњ>�pJ�Ư 8�#%��0E�c��t���Ŷ�XQD)�5@Ϛ�e��P����f������� �lD&�qd�asi�mJ5�T��,}��!L�U��9���|��'A��
AO:��7Ք��YX_�>�)z~=�����R���}��HB�!8�3��
V���pm�d��������>�T�4��zi�ᄟ��:㸆��� �#�n�>�������T�kXk�cO�2}C��J�qb��Z�!8�#-ZO�`%�u�Im�@!jfl�s?�O�7�bw��jjO��{�<�����9s�5�5;�B~��I����O�7����[Kx�!E�}�+�<�B϶R�k&^Ƀh��R�dw&���H�z��L���z_0�E����+�<�´K$CYp�-ع�N/S���/q|/����m��O���L��7O8������\�5*�M#�)z��t��湧ʧ�K�iߝ:�g��-g�p���Z����Q��ƴe���a���z�&�i����)l믯�*^C��	G�=�T�n�`ؗ>���Ls���6��e��0�Ku����G���3O8���.�SW�	���ܕ#ێM���4K�#�/�7������t��$�@p�	g��w(P�9�KQw��/�m-�e�2e؞=�����>CK�o��o�p��t�ÙT��ӗ��P�u~F��t�|�e���o�5"���o��g�pa��+�!׸R�Z�>w�7,��t�� !�{�_�ohd3����X�ߦ�o�pAl[��@h	�C���9�]�@����6=�1~�����l���R�T寘��3O8�P�ކ���3e�oz�b��Z|�܎�9w�2}C�F��c�
�B���� �^�;D�������¨2̛�g����t"8�+�i���r�A!���R�x��'A�Re����q>��z��ƚ��*��r�6}C��a,��Iw\y�!��X>�%S��Ѻ
��w��ˠ��o��o�7�j�'x�R��5g�p�m�j���4���n��U�Hf�<W���A�����#JM��y�	�T��S��#�V�ܚ�^f�(�-�J�{�°�I+	ԕt���m����� @��s@�<tɣ�-�iښ�D)��68���m�����0�S��-�r��'A/�����^p��7�|�ƞ�\�Ӿ�����L�D)�:��-����y����j2f��fh�!��2d=g���=���m���yT�5g�pA^,�ps1�o�L ������[��m�B	v{mRTV&��!x�#՞;��4#��s�%�T����������Y�
2Eֿ`��3O8�P�M��I�kXk�~Ӵ��	*�&��O��	ߦo���h����Ư���7O8�0��S�D���*�:�[ϑ+Oq�E~��!��a�Do���r�����  ث� ��B�{u���xE��Z��T�;K_�oUm�:��|�H��3O8��"�s|Z>�	���_:W>��2X����/�7�lOh��D�I�]C��	G�m��@�V.���:�7�̃cR�E~��!�=��D�Jo#�x��'A��^WPt
w��أ�M��ɈuԱ�lǞ�e���6Xj44n0J����� Hy9�U��B����C��i^kh-5��	ߦ� �`g�=�p���y��j7ZW�J�V�ߛ̗rXC�u���=���a�,2Q�����t�    �'A��l�]BkS*�`i�=� ]���X=�'|��!����(�'�"B��y��n�63�HEiޞ@���ĀY�28��	_�o�6߆�m�Y���,�@p�	G8�%� ��J�C��xi��p�6tx^�L��ͷ��܂b!_Cp�	g؎,T��Fd�����v� ȳ�
�=ϕ�6}CPۛ�)��Jr��'�@�bK�#t������l�ʕ^`,s��:w�2}C��e�g\��0�!8�3j/T5}f��m�	7��P�@!8��m��Ld"F��>�"Y�!x�#��'&��de�pk{�M���J�� ϧ�_�od��Uʱ����g�pA���s=�%���a�=�.�FTQ.�9N�2}C���Ęy�V�;��ɳ'A��0�VЧZG�	��<^����4�f�\��e�!�(o}�`�W�կ!8�3�/���M���r��}�ӓ��.��ַ�?�l�:Ց��)�ٛ�z�!��j�4���+�����2v]�tǚ�i��������Lk>M7o!8�#�5/�k41�wC��&���J�%��q�ڧ��t����� x�#�؉`�ua�u=�{S�v#���*�ٴ��J�O�7y�̩�ir-}�5g�p�m�J̍w�����L*�����=����ڶcL����!r��'�A��os�	��4\��M��3A)���JG�v��6�!��?:rMb�|��'Ah`K�H0be�o�Ů3H=�����m��@6N ���\�u��'A(��	��H��`έ	y�*pľ�!]����O�7�bo���+y�{�<�°���x����K��"u�T�z8��/�7�io��G_L��3O8�P��*p� OÍ�;Ԉ�]*���0b�~{�}��!���HOkS�H�5g�pA�o3��Eb�Md7V��(�����/�0�"�C\�=o�p�N�ъ	F�04�%�6����<]iVH���L�^�H��T��[����� ��T3c_	$�,{�ML��KZ�D��;|��!���K�"k��ר��7O8����@�6H���@ņ�6UWy����9w�2}C���[H�u,��y���z�j� 2z�R�أ-�O�2&B��;|��!�K��I,k�r��'�A`��)�J$[&�Kd��c��+�n�s��e����=i�Sk�k�<�B���d��\�B�]�GN�T�tv���x�m�2}CV=�P��d7������ ���7�/�Ѓ��
�K�RT �D�{ք/�7�j/��k��x��'�A`�Iq	Oy��TY��Q�x�j 8��i�{��}$�c`����� T[�X�y<Ӎ~���;�)��+�,~g�}��!t;	�@yzUʊ���3O8���hB^kCK)-�����N���-D���/�$�|{(�A1��.ề��� 4�9 ������5᧋�K\��Nq�;|��!�=|�Z��pz
r��'A�	��Zǹr�9WL�sQ;��J/��JF\{�B���3��V��۾v��'A ۨv�#M	��0�=�	0A*���U�_�oj��h�ZU�'�@p�	G��̆��$BH�w�5�KX�k��=k�B��o2�V���t����� Lۏ1��ޞ��a�	�/Y�&�麓Ƨ���L{o�%��5o�pa�K�X���}�����8���a|�a�z§��K�F��a�4L��/O8�_&�6�TZ,y�%�7�h71���Ҍ��J��!��rO����¥{�<���&q�I�k^J�M���%�Z�v�w�>M�AX��˸�^ɞ!{��'A���\��S�B��TI	�]�1i%�s:��/�7�n���[�V�!8�#�Ҕ�Q�Lw��3��� ��W4�>���l�J�w\S)��7O8���	T��<�4v� �!|���o�t�;|��!����e��W�y����S���N��s��o1�τ�O1�����ohۉ u�2K����y�y�F���Nf�{�=e�������<�踶����_.�j����	�_C��	G��6���;l%ۊO՘Y;�<k�°�6R.u���x�&Ǟp��]�R���I�%�7M[91�r#ǧҟ�o�V�\��J���=o�pa��T�0�e�E�L�޵m0Tڒ�Eѱ'|��!����LC��;x_Ap�	Gl�`M*j�����LŸBn�<k�B��҉j���F�g�pA��~�8�`_�Ӿ�pخ���T�5��Y�L�Ah�n�eд�R�!x�#5�l���Ik�a�16������6����'|��!�n>��*itL��3O8���[��h�[�Bw����,���L��N�쐹`�-��<�B�M$�Z"!����9�j��I�s���/�7n��n}���5wE�g�pa�L�xn�ti�G�KdW;E/A���:F���e��P�!�����O��n"q��'Ax�􁔞;�������:R��Bq@��	_�oZ�+�
+�
1_Cp�	G�؋`�O9k/��㉒-q[If��|�R<�6��!4�� �n�ꊪ�!8�3s�i���`����,!�]M����O�8ڛ!�"���l	��M�=���?M���+b��?.ن�XXJ���4�O�7���h	k��� 8�#�m��Jm���;X�X��{���<"��*�O�7��1j�	S����t��'A���{@���Z��dv;�G�.���.|��o��]�:k�@�߇/7�y��ao�(a�:�Pک�ė��t��c�\��e�� d/} �Z#�����y��/ӄ��BX�F�6�PP�s�X<G�_�oh��j/��%�5g�pAl�?A2 bM[���c}20���;=�1~��@��=�~��z/�^C��	G괷�q΢R��>��DT�i����=U>M��mh?���x�T�!��31�+�U[�y�V���*9���&;��i�� /�o���4����� t+�%������	k��/]��s�4����~§���i β>'����� �$�>A��`���c�lP��a��y������9P+N`�yT���3O8��v?�=�Ea�c�?�棍B\?ƨ����e���v:N$3��S���y�	����G{F��y������B�0����>M���>V�ȴH�4�!8�3m;�ĳS�u/���^]_&�R;f����� ��2����O�5o�p��%d��4�ք\����ۄ��=����lC�
�l]�5g�p��M0
<�Ba�-�%L�#a��={�B�ׄ#Jn�*��3O8��oE���Z#�oV]@K!��0<�_�� �`����	���+�<���Ju�6dI��,T�{T��)p<M���a��@����!8�#�lx~����e��h���?��@�j6HB�Bc;ke�l����{���s�:ϒ�H ���d�1�:�Yg �����<{�X����>��5o�p��+�Z�<��=) ښ�P5/X}:>��4}C�bHu]�x����3O8����,����@s�ܡ�{pK� %����/�7��� Q3��2�k�<���`�?5k�()���e&
�ZcB�8=�c�4���ͬ��f�%�k�<��˥���r�>;�} ��&����{��i������J��bT=]Cp�	g�V�7mQz�if�ob{�:@�<u��s��O��L�$¡@��� x�#+*��p�	�bC�����z���/�7���J�d&�@p�	G��҇j^o����a��kK�S�����>L���D�J��r�o�p�lgNT�ѡ��>��T�o�q�i�����җ��T[ϕkk/C���3O8��Km����3�-��l7}�R=-�9y�c�2}Ch��^ӂ5���3O8�0�E�'��y(��&����	G��zք/�$v�:��~ja�6����� �m"�V��zӚ��@��r��r�2
���������˯܁J���!8�#3�.|    I��X"��,ɴ]���1��gM�2}C��h>���c�1��7O8�0^>�V����i���S��R���ҧ���KD�K�'P7�y�}��О� �e� }��G�e�׎=���m�Z�4j+�N��y���Aq��������!�A��x>��2���C �9D,]�ƿ:��<�B�	TPX��_��r�b�$+��h�7��1~��!��hEH+����.�_A��	g"Xw�6�
�y�7��7c�bz:�;�^�4}C�6�j�~!%Q����� �-{C�h�]���K9�j�4P�l�5�����Ҟ���Pbޫ�o�p�Xa���2�h��^�Y��_�ǉ�s�ʧ�B9���5V����� �m�� R��^"�}yQ��Ējw�;|��� ɞږ�[bZ��_C��	G^�,�'��hy%R/�'���8�Y�4}Cx����5={�=�Cp�	G���)S�/b�юZU��̊b�q���ٌq�2��p��'�A�9�����3�-��e���c>����"?M�A(+�~�m�D+�dj��y��jw��V�)�Ź䗝	�����fv\��i��@��b�q��F�k�<�B�/�W`hI���"˴�W�b�:y��<{�B��"׷�f������ ;i�b����-�\��WGZ3�$��=�,}��!�h�A�h���k�<�´�����TT�߹�
��-g�QK{:-����O�7��q�%�5��'�AxiO*�E��!�y� ���rE�;K_�� �h�������7O8�P��C��Z��4͝;�l[� ��G�Zu�	_�o�V�u*�~ʊ��=g�p���7@l� 9��;4�	�ʰ4H.��T���!۶c{m1���!x�#�E��J֟k����#�r�!��皥O�7�9m�kl��E����g�pa�@E��d�]��#�S=��u�L����e���mo�����O��I�
�3O8�@�f���$~�)��Ķ��x"�x��L������\	�� ��y���R̉+����ڈJp��2��6Ǟ�e��0���,⠺;x_Ap�	G8ۑ�Ch����	G�������ߋ�4}Cx���X%BG���y�桊+�(��������)I ��	_�� H6��	�6k�<��%��d� 뷰w�d�̄�P�f�3y�"�L���f�K�0X��t��'A�!��'��/�O����f�Y�e- �yu�2}C��2f�gˉ'�=o�p���!��9��{^d��N4���U\�J��!��f����Lc�	�g�pA�.!!��N-�=F���Q��#�w��L���yϽ����x��'�A`�9$ŕ8<J�F�l�m�P�ƅ��͟�oj+Z'=��+l�_C��	J(vg���YV�L��{	`�-1�P�bGǫç�B�a3>�d��E�k�<�´�""��V�[��&~���@�	��?M�A���'���앓�k�<�B�KR�]c�!�`�c�2@���z�����N�B �}}��3O8���]BH���ܺ�8�D��R�g������7�b�H���y��!x�#�r)��r�Sڤ�cY?�Vw)Ǻғ����L�&a\7�g��x��'A�j���J��S���%��^��*�׶ѱ'|��!��F��Cʐ�79��#����J�&D�:oM�i��z��4�쎳�O�7��� �π���c�h����� { ����Z2����J�9�v�	_�o�/�>d�QZ�\Cp�	G
��F���f��	%f[�G�䓕Ft|�i���V=�$I�)�5g�pA����w�=��;�,�1��3�5����ҧ�?�eF��E�C�q��'Ah��,�o
����Z�+5139>w�4}Cx�O@��2��{�<���'�

j	2�����
�f[9waϞ�a��𶟀[X?jr����� ��'L����/w��|��>}8D!x^�L���&�RH	����y�����P��=K/�w [Z�=>�)s˞W�/�7�_ډ��J�����3O8� j��5*ڗ\�y՗M�2�������L�AX���^�ƃC���7O8���>A I���K��~3?uI#&p|���ᥓF�B�b����y���wv�8��):8oM���b�g�r�&�:�c�4}C���?�(͜����o�pa�fSJjXdFٞ0�6h��t�gL��/�7�=G�r���o�_Ap�	G(�s��S�%��7Q���R)� �ߧ��u�.3)��!8�3b����"����H�F7�ѕS�m���y�����r3d�7�t�k�<���͗������V8��C��Jv|/���a4�Ѐ�ӵ��^Cp�	G����҄�F��?~�9�~�g4k�s�/�7���/c��4k����� ��H0���Zhw�*�� Zt�&*=����/�7�]�;tȽ��Ѯ!8�#lX� ����wM���f�F�#�.�s�/�7,/��9���D��^����� �m1�0�� �R�@�a/T3p��7y�!�i�����i����5��7y��#�s
��΃w͒´�&���(x��9b�2}C�os��0�J���3O8��tu�}�p--=�?OX�!�@4�<a����|��f�TB={�gO8������ARZ��1���P�#���M�Ӗů'|��!�ݍ-�us%��u� ��31u{4�W
�p�)�h�E)��B�<w��4}C(j<!�b��6�W�y���>��d�ă��:؈j����l:8�m�4}Cз�3�Z�gKA�!x�O�`�P*N�<�^R�/w�Ik[�v����>M�����P�VS���3O8��2�:��abn0�~��m�.g����E~����2�"�i���k�<�B{�F�b͒��(跟P��9B��� u&�7_>M���(ͩ��M������ �J��+hƪ=�7M;G��Lc�[r|��i���m�?i̘���+�<�°KHЎq��V@�{SF��u�F��G�Uo��@z�Dq�4��3O8�P^*U
��)>�o~Ŝ��U: �YW��9N�2}C@{ [�7���[����� <���		`�ap�o��9��a���w�?M���;��#�k�<��ϡQ\���
~o�u��p}0��z���i����f)aO�p!��O�����  ��Ӥ����v�%���=s �s����L�؞�Vu<����3O8��Ҵ�"4��"I�q�ͨj�8F��SϞ�a��P�� ](4� t��'A��R
���rb��6ק���Q�Дbn��"?M�����3�B�x��'A��K���	S5�	c;,*��#@�츻Χ�B���AEB�σ��y�����"���	cg�%���Y��sǭO�Fj�I�iV~
���7O8��^.O�2�Dr�N�Ga{VYVT	�6ϻ�_�ol#�I��8��5g�pa�V��ye�+d�y�Y�Cm�g"�0)��J�/�7�6���;�|��'A��A�3-�L�m�,���|3��v��R����e��0�U� �:U��� 8�#��O.m�!�lO��C�=�� �|��e����7��H֞�!8�3�6�d�����D�ĭ���+�Z<{�?�lMS����*��!x�#͖�=KG���>w%��HHO����͟�od��e��Zas���y��mO��K�����S�����dn0��=�/�7�l����s��7y��#/3dEy��}%���e6{L�	j�cdϚ�e��0���sy4��`� 8�#���C8[ʵ��(�vm��W��R��#�/�7�7C
*�����5g�pA�̗g��J#�i�E���n:����>���Y����wH�Qͳ������� T{8� �� ku�U�aȶ�F�Z��*��o�&Pu�VI��5_�p!�� H(�T��~�����^�3�;K��o��1FX�	3���^A��	GF|1����o�y9�ݣ��!I�� ��    �L���/Q\ɥP���y��vȅ@�}�2y�Eb��>@�R��F���ҧ��K{�
�GzN�v��g�pA�0�>��-���a+"#>Wh�J��;i|��� ��,%��{��!x�#ն�\1TM�E~{�/�a�Z�L�s}§��x��Ks}5�����+�<�B��[1e{�1�������e�%�:J�W�/�7����+����ɳ'A�VW��@��ܟ��H_��k���s��O�7~+�xZ��ƴo�]Ap�	GJ��"3��8�T��o�xTc�+� Ϟ�e��Pm�F���Ů�a�h����� p5��0�-��7u{~?��<if���"?M���l+΂(Q�nY|��'�@��^��
EqDJ�#��Z�oSk~��:��/�7�nwc;7§���!8�3j�@�Nj3���4V��u�6����sz���0�9P�t ���y��_���Xq�J��4�?�3C�s�O�7��ve��(:1�{�<�B[�P�f������l�v�V�,��e��8���_:n��Rֺ��N�n 8�3+ 0Y���ˀ^���Lք>:���7�U� �d�Hй(��k9����� 45��	l��\���M��N(UV�9��8����mC�	��Ӊ��}7�y�����a����ƮvfH�D;��=y���7��'�:2��w�p��'A`{Nq��f���D�f�3�� �++u�	_�oj���9ϒ�؃t� 8�#T��PХ��o���m�Qq�8����L��ذy��e�R�Ү!8�3�nI�e����2�~�䣪+�,��+Z?M�A�d��X������;������ 4+��B��(�<���/7'�*���`��/�7��sP�<y-��^�g�pA���6�J.HE�~��� �Trg�)x�c�2}C(��s<wF��"��<�ٙ/�B,3H�=W��|�!�1dG�q�´�uXg�SҠ���y����xbJ�ǧ>~�ұId>%�z>��2}Ch�Gk��r�O�f����� ̗i���N,{Se�ͷ#,Z:��ҟ�� h�w���ؤ��b�5o�p_�B�M��^��6��\!��[��;P��odK��o&RA�_n 8�m�Nm����
�+Xҗ�#h>E�=z��i���m���3#�aφ����� {���	둟�ۿϡ|+vqP�����O�7�ӄ<ixs�cW|y��v	�Z5	+��E�-�i��D�4�X�cO�2}C�vڮB��A��3O8���sh*�������M#��9=�'Ku�I�������>��Sچ��y��j�A9hW\��/ln	�eR���\	��~���o�N�� )�FS _Cp�	g^*U>��g���^*e�Z\z�m�4� ^���̍�,��y��n�?	v���=�k��	�Z�zα'|��!�=�]�6��1̑��3O8��Sy)�q��^"�ra�����RO��u>M��=�����%�5o�pA�ns�V�#̽mM�êK~Vаl	��,������C�gк6{r�g�p�Hcj�i�Q�_*]�x�U���
��sw�O�7�m����"����<�BM�Qm���Jӽ�T�m1(��Y����7�b��D����5o�p����MDT�W[m���SY۲'B�1~��!L;1���Y
�Y]Cp�	G0ۻґ*��̣ߍj&��(��d��f�����5�
�ƺ���}��'�A�9���^J�ͫ�=�h�'d-J��"?M�Ah�',AMs��%_C��	G��O$-��q/�k!5�"�P'N��q}§�QU���@��g�p���|�R��"�Ʀ�p�c�ϜU�s�?M�^:ihT�	خ!x�#��(lJ4!Ҟ��K'��~y�ˣ�渎������6�R��5g�p��݋̂��AsG����� 	��t��	_�o/EQ�n�S�� �+�<�[�I ��^����B@��ճ'|��!�i(��{�j����� ��k��Q���_����`�낰z�I���P�05����=�M����������?1�?��?���kɎ��;��S����=�_���t	��'�ol!����̗k��:�����Ze-"��?@���gU��~��Ӓ*&ɵ�C�R�A�,�>44�9�*����Z/�C43�£����vu�R��?��� $ ��\?/��u^C�%���3�>�a��{O�%��$-�gpN��+a<� 	�0.Ul�*0Q���J!A��5��L��	pwiښ�3\K�ca�2�!�bJ+�Ё��r��0�A(�����R�$@l��/a<�Ї	��֧9i����/a<�0��� ̕%�C�%�GJe��t5�Ӣ��ߛ
<C ��p\�L��+lv&�_�ok4K��B�k΄�B�<heU��J��C�%�g����E�q�{����
��&(6�=j9{�ca<���a\a� �Y��M�%ߦg{&�+�t,�_�o�_�H���	�5g�x���1� �.�|	����4<RQ	��!��3�zB��1����/a<���@��?��5�ϡ��&�ep��J
������v�]Q�k��!8�3�C�C(�
&�=��0�A�d���J�r��|	������r�	��$���0�A��n� ���ƚ�քg�42�P+$-�X�L����B�Y��΄�A3��Kj-��0^A�%�g�`�Q��'W�M�!��3�p�j�9$�{���0�R���w�F�8�1`
s��ѱ0~��!t��/�y-�h�5g�xa�8!i-�t�;����K� ��~b���K���/a<�����2������C�%�Gf��Bh��&n"������玅������mF��d=|�ca<��v�:k~M� �|	��`4!*7��q��0�AXc#�L��+�{���´	TC���3�ߛ��eԒ����×/����5�4p+����w�r��0�A@��N�Z������t��0�A�bw�%�����ɱ0A���f�%���!��3m�e�3�m�X���P���
��W?M�$���xEץ��K� ��桎2�g�	�W�x�c���̑��+a<� `"�Af}�r��0�A�b+U&���4��[!�yH�Ԕ�H#ǧҟ�o�K����)�q��0�A�͜;�J0h>Ǒ��|	����	���E����L� �`����'�ȥ�C�%�GJ��XW"]����K�1s�f�RUz�#8>|�4}C [�Qp�12�2�5g�x��f(�����|	��j5!Q���
�C�%�g��2 X�� !�C�%�G��V�D��Q����KuW�ؗE�s��B��	z�'����3a<� �$
Y8��}_	���K� �(�sD2�%Hu�C�%�g��+�B�$(*�|	��)/;Ks���;��Fݼ	��+*ű0~���Ёm�7�N��o?��3a<���5�s������/a<� d�+��\re��|	���������1`�O���K� {9�+�������4О�EŹ���mJ�Q�L��Su�Z��,���3a<�@�^�ZR���)��	΄��k�!�Z��`w|	�i���	2 Mr��0A�:mĒ��>����Ѥ�y���g�Sa�2}C��ҏ���S���k΄��{�0�^HR���K� d{�1��E���+����.|�+���ٛ���/��K�j�X��n��Ҏ���!�P8�/�7Ͷ��,]�S�y��0APP�a�>i�~��0�A��>D�f�ES��|	���/%|[!S��/a<���~���G�B��E� ��Q�XקC~�����m��;�����_�x!F�	m��i�?@p%��j2qB���p���+a<�0�c�:W��F
��+a<����V��h�G������Y�]�
0���r,�_�o�BH+��$3��    !8�3R�	���pe��/a<� ɶ`�y>��u�=_�x��+s+b"����K� h��p���LqC �F8�&dΥ8.��4�!�`�zu� �,p��0�Ahd D�Q"DM�|	�)/�	��g��5_�x�Dۏq�x����F���K� ,�
+Q�)P��O+���D�0!�l˱0~��!���L߮+��=U� 8�#5O�D��D	�(�{���B�ׄ�N(=�n;v��0�A���?B���J���/a<��oŜFf:v��`��9�2p*�������]i ��R�*gor,�GZ���R��J,��=_�x���aR+��@)�C�%�gF��>T)��P�!��#=嗉`�JD���	m��+��L�y���i��P�y����J���	����jjXZ�{������yJ�8hAn���3a<�P�'�1
M�)�_�xa�N]G��9��~w��d�r���
3Z����e�����(jѵJ�5g�x��*�熬F^_�{����˽HXq��g��=_�x���4a�#?�����|	��n���W�:*��{��k1�h��
�Cg�{�_�o���Eù>��wy��0A��CxR�X����!��3����J���9�i\A�%�g���L�E����79�#�ؖ�	JH�����ն�B�KK#�/�7�a�5g�\�f�_Ap&�g��:���(1�?@�%�G�����A��^b���	�	��m^�`�ƌ8�_��_�xa�8A!�D���/��{3��e��'8m�i�������g�m�ܓ^C�%�g�T! #-E�x��0�AH��Ѧ-f�T�=W�x��6\ E1���+a<� `���Wb@��Kl와�[<�q��i����������0u�k΄���l8�ޟq�3���K� �d?��}�S�1K���K� T[ǈڳ�?#��79�3j7";6�_5�0f�e��Jm���?M�A(��1�6(ܧ�=��
�3a<����|z��c��y��0�A�B�؞��\�?@�%�G�ۘui`��㼇�K� �=��:%�(�������1��%C�ٳ0~������1f Z�FU���3a<�Pm/�	#���*�{����˜$�1FE�m�E���K� <��m��P�cE�S�!��3�ΚOƌ��Ž�Њ�f����1�������a���� ���f���	���lu�5!N
=�C�%�gڋ'`JKU%���K� ̗���ʽ��G���K� ��+m�F����7�(�,!��9�D��~��!�o��'<'�Ē�^Cp&�G��N���z��0�A(��R��<��$(�΄���B��E�Z��Q�w|	�4�Y��p8�n@�ImS�"��r����˧�B{��$a|�׮!8�3ld���(�}���/a<� q�T��5�|:�{���B�5K���2��ʼ��K� (�4����V��%!�%��V��:�+�i����e�������!8�3�6��� ���C�%�g����Rj���=_�x�iS��*�����5�;����fS��ĿJm��W-�s�#8�/�#�w�u&XqB�_Cp&�g�M���
14�gor,�g��T�Ģq�V�!��3:_��Q�*9����K� �V��iR�J1�������G��q4�ޟ�o�&�Z"+��:�!��3)��y)�K�����+a<��B^� �nc~��0B�f�z!W�\��`w\	����j��#l��/�+^x�W�L"^����/��o��C@����
�3a<�0m��T�Q�g���K� dЗ���C-�� ��3M^�&�&��k�3a<�P�l�ƚ��=md�U��XKl�����e���h�����w�r��0�A`;Hq�����?@�%�Gj�׋`�5K)r��0�Axm�5験e��=_�xA�X���[?kN��X_z�?s5ǳ�0;>��4�s6	��KhCVrU��3a<����DԕU���a�,���K� ��^k+��q=}�C�%�GZ�5K������w���K� ��cZ�p���~oj�F81�ʽ��xJ��?=XC��N-����3a<�P^�Q�����\���K� �	IE�j �x��0�AP�v@wb��Mp&�GF�-��J��5���/%��
	'��h4���e�� /��,Y|���v��0Ax:�×B���� ��3h!$ D��J�_�x���3$0J�2���;���g1K�ʛr~~!��8�	&VT;q��<�1~��!t�¨�*UM��5g�xa��5a����;Pw|	�ɶ�}�3r�!u���K� t��.
� ���g�xaF�� �W� �_�L{t�O����������B�w���3i	���}��0�A xiE���:W|	��r9t�_�J�+ܺ��K� �{� �ӄ/��|	�a۴Q[	�d,q�{�& ��'Fɱ0~��@���f�Rc.I��>��	��[�K�S�P��ɱ0�A��r`R�	#�C�%�Gbx9���6���{��0�A�`��2VE���b�u~A�Є�����O�7���:<j�-普!��3	��̉���bfMp��0B@{*���k�F.�\	�!����a�9����sp%�g��R%���t��n$��v`��i�C���O�7�ͫEA��k΄����+XRG]���C�%�Gr����C D���K� �l��ޗ�<�g�!��#���#q_����T^f�3e�:����������B�MQ����	����:X�bN�2�!��#���6Xژy7����K� `��;P�`���_�xAm�N�5E.�	�N�ZUP��Y�L�AXy�]��0҈m�k΄�B�{�դ3��{����؋`�8��Ҭ��|	�����Ŝ��1I�~��0�A 41FNm�wm3�)�9H[I<�1~���0�����#	M��k΄���"D�N�dܽ�� ��3�_de��R�,��/a<�@�΋T����� ��3�
c%i�7J�~e�Dվ	5�\K�I�O�?M�&[M �t�_�t��0A`��Pq�ZK�� �|	��f��c�υq���K� ����k}@��C�%�G�T{M2��9۾F��e�Й���������BRP�:�Z!�!8�3�Άk4�ӳ���=_�xa��\��YW����|	��f;xWBY&�=_�xAC��W��Hq��;b�b/J!�������/�7��^��F���X� �. �@��|��0�A�n�Ƞq%�%h/t��0�@���S�*��@X˸��K� ���54Gm=����K/p��4�͘��ҟ�� �L�r�^ �wr��0Bh��6�&�!寻�W�xa��a�qˆv��0�AH`;\]+'4���{�����"Vy��1�RiNh��"����J8��?���i�Pw��+΄�B��!@M��{�3a<�0��Ppty&����'��3S,�_�:��/a<��1�`�cj�G.��3�K%GF�m��9b�2}C���͸~p�-����	���|�����>w���K� {�veO1*�@����/a<�0l�N}J�`b�]�x��0A����N+a=�;��ɶ۠�ee�a�S?M�VTh>�#��5�F�W�	�~*�9�Z&��+���F�D�jz&���n,s��0�A(V8��>��r��0�A;/R��1+��;|z�$�����\�����2���Զ"�k΄��KuW�^�Ȑ�!��3l�'L�J*π�~��0A�)�T�κ��q׾��K� t5[�Ug�H���X�{�YVV�**������[�r�9�X!�5g�xa��
�$�+���m���K� t��/:8Pk��|	��9^f�p��G���w|	��v��4�>���	������#�:.��4}C`�D����"x�&��x��    ���p��=_�x�e����C��/N���K� �n<!����s�%�G$�K��Ju�]��<m��\҈#b���e��P��@U\�P�y��0~B�6��󄿟�� �/"�$�j�?��®���)�.iU�R�O�o_ɯF�B��w�1��� m<�[���:/׎*��T�!���pb�f�v���*Ju�g����������CL���~֝�?�����@�}H{OU"��MT��<�w�3};�g?���ǠA6F˳\���M-�y�A�RG�<����3�,�Z5�?�g�����T���V�T��|X�c�����(	�h�z�(��$�>�:�V����7��[���&���4��ߛ:�Z��)H�T�S�/�/�7�桄�y�Pj���w���R�c�����C>,�1������9z�e�i�4A�J�9���Q
�b�a�f�׋�
�3 q}6��uaKTӎ�{�u|�e�f@hDc-�]K���AkT"d�Q&�є����(���H�\aɢ�ߛ����)��]F�k��A�6V��~!����&�T�ecD��&��,������P��,�M=��<�[���޴�!���Kb���d�����""���ڄ���/���`����]Ze,��6�vQ����X��1k[��!��T<�0�m�DY)t��|m*�A�fKX�K.��_�j���N(%מ0��xS���M�3m�$��4�5g��g�V-�����2�X��/a<���e#^Jii͵�C�%�'�q���(�"�
x��0�A趺q>;��w�v	ŎȚ*�sCʯ0~��!�
�4����R�
�/a<���R���V�{����q?�B*3Nz��0B�f5��,a�ݨ��+a<���k��fOc����݆���DG�	�!a�2}Cۏ4�Hj%���W�	��L�*#@���s/��!��#%�>c{~�˫��C�%�gj1�� 	��x��0�A��6`ԉq�T�.f�B��00�z���ݟ�� Tx��q�ѝ��5g�x��������r��0�A��R��bΥ�;Kw|	�|�ك�jV������K� ��{����q�=�j;�)�H94!9:��	��´�DG��P&�k΄�B�jܥ@j	[����/a<�Ђ��ڐ;�����A�%�g��(�XuR+���|	��^l�D�Aj��=�mǲFUAW*.����O�7�.��E a]�C�}w��0�A�vg�-W�5Ƥ��!��#�&�M��S�y��0�Ah��p!����L� P��	�mf����J���u3d�Ȫ�z�/�7���_Y�r��R�z��0�A`5F�g���K� �t�F�=���/a<����o�Ӏ����{�����탘e�b��&/�윰�RM���֣*���0~��� ��g��3���3a<�P^F_h������i�A�%�g�m����*����A�%�gf1��4ul��>_�xa��Y��Ar��N�f�[af�1d<�
��/�7�#�+I'ͱ���	��v���k�����;���B�YV��m�Z��{���°E��ՙ��=���/a<��=D��㠸��T���%��,	���˗�֗6�}���:���+΄�[wA}���#�C�%�Gb�c�B��	���|	���햻�<ی�R�{����T�VXY����:�8������$~������lSVm�9�l�]C�%��^��*��L��?@p%����2hF�	���Cp%�g �YD9ͤ\0�{���B��ۃF�P���e�^���b������O�7)v?�C��{���L� �h;�7je=2����/a<�P��p��C��!��3d���	���{���B�bℎar+n�Y��U��5�P������om،��3]^Ҽ��L� H2���B־?�A�%�Gj�U��ʾz��79�3�xplU3���!��3��	���ҀSؚPɒz��Wƙı0~����0^���L{�t��0�Ah��E��@3��;�����	&�W(��]�y��0Ax��ٰ9KM%�%PW|	���l#�)5��w�c��2�Z�i�]G�G��C��e������D�N�o��g�x��-܊�\��U��r��0�Ah�y;(f$�uB���K� �4qB(����_�xa��vv `.Oc�H��W^FnϲR�ڀ<G�_�oݶ@R:h����	���R���i��V�r��0A ���2�Pz\��n,s��0�Ahv�|^�Q��!��#l��}�Y+�݅o���1��0���B&s�!P�E��Й�!8�3}�� m�+P�]�=_�x᥶�iu_9uT*�|	��`' Tx��S�����J���>�����$h���0��A=��|��!��T���#�5g�xaf[�"������wy��0�Ah�
�v.5K���sp&�g�ޕF���n<�=_�xA��6��Zei(�y�S_Nm�&���>���O��K' �Q{��3a<�P��^�H��-�W|	�ۼ������K� �`=aE	�R�C�%�g^��G+I�w����f��t|�1~��!L[�8�Ůu�ا�W|	���l}B�����g~�=W�x��,2+�8�����J!�mE8q>#�VY�=W�x���pkZYT���OP�d�S�*�Ԥ��X�L�z7�P���������	���vSB��W�t��0AX�U�:�<S���!��3��|��4I�!��#ey�Y��s�Cݞ�_��0�p�g3�C��e��P�=�ҧ<a�Hh��3a<����1Vh9����	��i'�e�b�C�%�G*�.|	F�Km��!��3dGTD�Fxw���R�ہ[Tƒ��+���� `��>&Ժ����wr��0�A(�]D�dՀ��{���B���}�e���sp&�g�˹	�LmP�����0Ah�>ԠB�2G/�M�촮��h4�{�_�o㭥��B+|�&��x�;9���
��k�� ��3�N�3'�"��|	��n�9��̙G�V�!��#O�l��$"���;h�َZV6�r���e��P��4g�<֏���L� �u��cV���*q��0A�Ph�pmz��0�A(�T�k�=>G��|	���S+@���βw��ga�Sɡ7Ԝx�����6��Yz/+p��	�l/�9��W�TC���K� p4c^ck�ˆt��0A�`�./ED*$9��^A�%�gZ3�k(ꄌ�s�R�p Ԣ:Z*��?M��OX�2��a�y�&��xa���Jφt�+����K� T�K$���n�C�%�g�v�]a$��TPF���K� h�s��I`EKa�R}�kHԚ��ҟ�o͎@Z��c] 4�k΄��؝����x�ɥ�S�+��� B	Og�­��J�z��0�Ah�c[Q1A���9��#�˦�L�m��͋��A�+��==��o��B���2�RFM��/w\	�)~���)!���<	�!��Kg��o���z	��0�B(��
�������'a<�0���Z�+u�#�-����K�1��{e玅��� [�RW0�c%�+Ҹ��L� �x�)��\&/�|	���*V"���q��0A��eS�б`�=_�x��T�P_A�P̴!,���8���$.���o�7�G�ʯeR�)�k΄�B;*1A�9Ko9�=_�x��
`����x��/a<��d4�"��YF��C�%�G��DR�TP{����p� #���k��:ߦo�l1'�(%��v�&��xAm� ���XGe���K� `�-���J/i��	W|	����(����=_�x�[�3h����w�H�Ͳ*����3��×o�7���<��J��y���L� �騈�����|��0�AP{�a�VJ�|��0A�`��W�)U�ӽ9�C�%�g�x��9M)��w�ܛm�<pD    Rn�����?#�H+F�qN���L� ��a�G_���{���°}�Qf���=_�xAm�?h�U���t��0A ��V��׏�s{��*mS�h�@���e��@/C ��!a�z�&��x�C{9|QS�ʑ��/a<�P,�F����i�_�xa������ ��/a<� /e���Z6�.�=���ް�\{K��ca�2}C��8Ae��F2�q��0�Ax)����Z)�|	���h���ZL�g���	��b�RN �G���!��3b�ʼ��r(���ه�7��1b�Y�6��6�A���J�8�>b�k΄�&�.@�B��	W|	�җ��;Cla�_�x!�`ۓF��!���W|	��6^ژ����v�c(�-�D����������Ս2��+j���K� �d�R�� �\�/�{����^�c+�!�{����^%�D�uҸ��J� �5��'OhH1�­��=���4�4�k��3a�2}ChlH�g�ɢ�{��g�xA��ur��G�|	�H�Կh}�G���|	��jOm#%�X���'�A�%�g4�M�A=�������&�RX�@NI���O�� �9`\q-��3a<�Ъ����R���=_�xAl��������{{��/a<�P��ro ���S�{���B�F#!�T5E�qB��DT�%aԨ��?M��=�R��"X��3a<������	HR'.gor,�gP��P1Ixz���u��0�A�n�H��҇�g�v��0A���E0ms6�Ydg���KCѕ��Ds8�/�7�nK��w��x��0�Axi�Y�W��Z%�{���BK��%�
$YI��{����×@m`S�x��0A����gJy��,R<m�\�J�W��X�L����W@��R"����	���A�Zj�P���K� L{�"����Q�=_�xa�i�	�QY^r��0�Ab>�	m��J.�7�p�(sŠ�S�/�7��B�s��#��3a<�@َE����'{h��/a<���e�))�����'��3boÅ,"a����K� p�w���¨��8�^��Ia�<�ca�2}Cv�A\q�����	���k��L5�C�%�G��0B^�b�y���K� ��m���J"%�&8�#3�t�Cx.õ���Q��V�4��4{��L�J6�Y���Q�>KW�	��a7UD���&��|	��i;RMj�s�s���K� �K��eEU!c���K� c}�X�ԝJ+ڊϺ��ZK��s����� qq�1���L� d{Q*j�1Jn<�=_�x��Y��ʟRZ?m�C�%�g���8�4l�K���K� Ěm�1��KM<�o?!ŗ׉r��)�급ħ�uC*�
�X��kJy��0�AH�~B�>�¤q��0B(hB�3��qw׹��J!�d�Eb���lh� ��0�AXa�)�aE���:�4mtՄ!`�57���e��Pm���Ji@��M����������x��0A�/ׄ���HC���C�%�g
����H������/a<�P��z|����%|)�=�Sb�2��:�c�4}C@6�sM���R���+΄�[���#�T��/a<�P��T)T�#�����/a<�P�qPж�Li�h���K� �ܐ�8+�	�w�'�a��4��ko������\y�]"�s2i�r��0�A@'(�2It�&��x��h��k�U�=_�x���Vj��/"C���K� 4V��ƕ&մ��V��Ӄ�&�6��0~��!��U^��2���M���BO�|z�����|	���/�s+��^�=_�x�l�N *Q�0d�{�����A%&nZ�nE�F��یA�,���q�Χ�B��:A3>���+΄����ib�69�=_�x���֛`������!��3�v��a*l� ��33�1�J
yo�ӰU�RZG������'dB�(���L� 4|�T�i[��|	���Y�5����/a<� ��!JF�#��{���B��	�(	V.9���T{[L��V*Q��_��([�7���� �� ��?�[��v�?���:����W $��y�G�a����l�c���'�Ư ,��:CR�0�U̿C��0~�ySoF�4�p�a��(5�-M����O�2�_A����]CR�+F3�}-p��-#_lO�B�}�;���l�s��2����!�DH�iW���C��0~��f5�q��[A�� �e�����m�.2#rj�;���Wb��RQw9p�Ƴ;@`��;���j�	�^�x�n���P���H�*x��.��%����%u�
�C��0~	a�54�ޏ�SM�wW�� $�/Ŧ�h-���o�2�_B ��2 5����ϑ;��t�3@��9w?�{�I�A_N�=����2�O.3�_A���>�и�%iYM�� �e��Ы[3$a?���~�p�a���M3V�s��O�	�]��+����Q`�g�:�JCN�TJ��K�0/nmp�n4Xt9KH�������e��;�K�E*7�����WJ��"��Z��n�ͿA��0~������f�zq��.���ŧ�`�k���"�"w蠮��S�,].6�'����E*$�_5~�p�a���� �6z���p�a�
�,u��L�3��.���L��N�R^�C��0~����Ǆ9ԏ������Xs/CZY�b�x��@��ԝ��9�]��n�O.3��A���Д���E���.������$�s]:��!�e�� �����߇*?A��0~��+�0�n�TW~*i@��܆H<��t��t���
1w�����O.3�_A��@�Ԕf���3�2����;�4H���+��.����/_�(qB��I�C��0~��KN�N�HT�P-�;�[Ie6�+��f�x�n��l!������H�� ���9
�d��wwƯ p���1�kn��p�a�B���8��Ӛ�C��0~a�,���r��d���>������7�1��?f�+
�J�J��e��;/�0��
�:��.�'w�� �w������9��!�e����r�YvV�����]��;�m$�!��j ;c\şVQ�E]��=Ɠt�0=����j�a��2��I��tΒp���ww�� T�Wz'2u�#~7�ņ�;%��%檿*�'I�'w�o �}M���؈��!��^^]�Y�>U<�5�G���QA��PC��gw�/!Lz�ǘ��Ō+���2��A��7�n�9wR'�wW�/!T_�ZC�Rk���!\e�� >ICc��/>6!��U� ��5�ܯ��5�'���}Zo��JY���2����3U��\�6��.������}��}�ؓ�� �e�� i�bS�~R	s.��&\f��0�A�E����Z�g$����� -��.6�'�A����RZ�p�a�
�N��G�c��e���.������c^�ww�� ���?R{9�R�wwƯ ����X:�\�9K���ObP�K)�J���|�1dZ�$��;�	�e��;/τw����X�p�a�
B�v!�h��C��0~}��N�J�y�/f�]��+��|��{�j�ؔ������a�UF����Q�A��Uy��ta�B�?A��0~�噰F�׊����.����o�D�7	s�C��0~a�����p�t"��!�e��@>?A�bQ�Y:�-����ly��\���(� �=&Q�M�R~�p�a�
By&�@�4Gq��!�e����LP?Az��c��!�e����L�+Ѣ�J��]��+���2�:�r�_���#!&n�68J7��0M$YEw��F��0~�Bxi��������!�e�����b�mt����]��;���,��ʭ`��wƯ p�틌��Ų� >��'��%��s��0�����w�"+h0��L�'��� �    �B�4'	}���]��;��J����wwƯ ���E6�i�~j�;���wؿ����v�8|v���K����Qb��P�Q�a���@C*ߍt�a�B�j�(�.Q���2��A�}� T���;���w���?PJ�9��m�e��+��Pm
��"�� �O^$� ׺�c<I7��DJ�M���e��%��B�T�;�ğT�� �e����%�jP����p�a�B��e�h(����2�_A��_�#�ICr�\Õ���K��4G��0���9�~��w��?A��0~	ay�G�)�8�	w�� $�=d��T�������*��%��V�ݐ�O1?�7W�� @��[������X�}Th�Ps'��0���2_r�u�Zhء�O.3��A��E��'���]��;�k�k��)�T7�ņ�aqi�,q��{z����aJ}����'��_?4k_e��*,s���7���{*�#�w���̹d����%F�=Wl��!���@������`�l���̙�׏n��ˊ7C8I �����G s�5H}F���t����h7C8H7�������B<#M�*u��Q�ZU�T_u��KN���[E�(��s��D�MƖ�~UN���p��@X8�GMM"����3�J�p�2�j{S�����$� ��  �)��F���%���GX�R��]��-���lB� G�UU��$t��:�"����$� 4���c�%4��	S>#��L���;ŭ���f�aN���3è�v��p�8J-}ů��������#��C[9����(�s�D#���ċ���t�І�0�Պ�f���t&�Շ�+��n�p�n^b��<�:u:�H�*=-Z)��u3���Bvӥ��s����	=��pf�0B�x��p�n�8�1���N��6Rn�E�09��Z �-�a%�QŮ�d��m$bG�u��G׫!�?�}t	aN5�6Ø�8g�����C8I7�Gk�R3�@���dWc��y�� � L@U	�`w�\�F��� #�V;}�j�oA8H @�&u��_=�F�F�(�ɜ����I�A��K���������tk&�ԑg��G�G�a�Q�)]M5�H)�y���W���A�A7B�QU��D��іC��ܮ��J��j|�L8I7/�t��[��Lȵ8�I؛��5����(� ���@3��3��K<�(��!����������TCnќ���Z0����f'���-$�zP%�8S��>��0�0cĤn����g@�~�	>6��rk��_��C�˛C��¾�ra������5��< !���+��!����/,tnq��g���G�v���U7C8H7+�53՟du)����H|Pw�]���2�A���r�3�&j����ˉ��gu���� ����g�P*g-��4��Lڵ�:>�&n�p��@h�G�ڐU���P�<�8������	�I�Ah��I"�p`�@(���,�-)m�~��p�nfu�/�)�P�Oh_2�J	1J�9�:I �Խa�M.TA۽柏Bv�EMj� F�9�:I7�6�尷�	P촹t�-PU�(6�yw8I7ӟ,���TV6Ҙ�z���m�c7�1��?F�'KIz��w����L���ʹ�I�Ah�[O��|7��v�4��Y�n4L��͗/'�a6�fH��l`[��rɯ�T�S�w/_�����:��j4�n���D��D"��3F��[�I�A@���t�E�-����(�]�i`�e~U��oA8H73���t���?�|Iv�B��(�$�����G�tsT��s�|ѻ]�B˭��g�'��G�;,��HUX�Wv#��9�A:n6�'�A��K�V���p���#�:�:5V7/�����>���Xqd��1Δޢ�8Z���ͻ�I�A���!�$H�z6�L�$�F�S#�@�����Y����bF�v�4�gr$�RU�ژ��N�+��(�h�8�����q��}B�(św��t���}�H=J�>�g&����A$Z�RnN�9I7��IC��R韑��yv��G��<�$�� 98R])��$�D�{.l�����7�뜤�����e]Nl�҂��~���������$� ���Uj���IhQ�L��p�4fo�]=�7��w&��!�_��,�)>��L}�ι�Q�AX��e@�mFu3�H쟔-���M��g�G��~�`�0��ψ�gD.,������t��}&I��4Ȗ��v�������g�I�A���V
�¸�{m$�'`h�ע~��x��@H�_���cK�\��Ը����	?N���Q�A���fC͢���H//,#�A���.���2�dN��f��3���i��1�&{�r8I7(~w��b�,-\�F*~a%)�L�`.�,����M�4n9����r��uxN�S��1�?r"�,eA,���9r9�㙁�ZQL7��;J7�;M$��x
h#���W׵����ͻ�I�A�ޙ��[*g��Ef�� ��1�n�p��@(��i35)��~�D��G��#��_]�x�i�Q�A@��VTwI��I��#[�+4�7?�9J7�'6U��m��e�H�;�d���0��Ə�5��(�R��fI|�x�5*�F����t�����G�IM��T�Oo aE�%�ov�N���}�q����=޽��6�X��lN���̄J�����c�^)=PV1��!���!>ّvj�"6g	�5�Θ>G,7���?Z��$��b�Li�m���ϒ�m�I�A���xP?��A
Ȝ����i��I�����G��ۋǨ6!Dlq| t�ftU�J��^��u��@�ɿ��2;S��-�&~� L\}��o~�p�nп�U/A��Hb�	�%-4c	ab�o�	'�a���%m����j~��/' ���S�n�p��@ɟ��6�I�K]:6��K��"�HYs�͡�I�A@|y�۞�R�<F�ݜ���"�����u����P����y(�jG�:�O��ԊF!��p��@�_l�T�ZVd�)��#��p�ذ��~�I�Ax�aZ%���D+@�n;�!�b�%��7�'��?X*�1ng����(Z��z#���#_��t�nJ��m�0�ŶH�xR@:�A�͇*'�a��I���+�Fj��{L��������u�s�&b�k<��Ɉ� ���r"G�OU��7\��;���U�����Uk���5��	�!���>P���?�Xj�C֠����w ��?J��Ec�&ԧ��e�>��P��0�~B�g���������1^ڝ4��t��C����w$;á;�H%���C��0~��o�ʢk!�U8�H5Gg=�D��ڗ�>��a<I7/m�ڪ=sV��g�Ư ``��G�e�@�;���w�� �"��5_��� ��lB�BP�Q���.�������׏&N�fJ�F���>�1���J�_�'�%�x�n��}�!���}]�?C��0~��5���F�������2�_A�!�吡�Q�1�2��A��CB�D�:|z���.����['�4�L0}y߳kT>c���Wɜ�0����%R���2#��hP2�5,�i�����4���׻ȸ�-���������A���)|��~E��'�`Z���a�o�?��Q���HMbk����(p�#��P��H��9�?J��(��P)��=�w5�����L��B�X������A�Ca�?�IK��iFq<����'�?����Nڍ�*�.�kGٗ��F���$)	
�G$��8���
��q��|��Q(Y�R�%v�G��X���~���G)���nE �NmD�6R�nV%�Ū$ԟ��Y
��<��P��7�eI�:��ݲa�u��s��h�?K��(���>��(��3��Y{��H'�n��4�״���I�Q��삆�k	5�H=����s�����Jt�,���M��W��¤�=�l��n¨O��foi����,��v�P�Q�����ª�?�    ��,?��⌐u땛)��"r�}e��m�>�	-�v������Q�CA�7X����������*²o�{��wʣv�P�Kȥ�sb�Y����"�mT8~.Q��R8i7
4܄i��М��Ŕ5v����Ӑ����
)Lg�~��O�j���g#	�
������ڍBo<uE�����:�s� �3�㈣v�@�Q��z��A��]HM�H�RXL�W���
�Q��`�fҚn�����0����I�Q�աZ�qg�	w�����Ԛz�)��wʓv�@��aHC���>+zvqY�Ƚ�2wz���
;y�m$����c��"`��U	sS���M��(t�Ԡ���&�b��#�..�T̼h�\o��p�n�r�q�6%CZ�F��PU�S����j
����u,�q-���م����f����v�Q
'�Fax7{{K�UJ�f+��w0��ƣ4t�_K���ڍ�x7;*���)���VjvX�
F�j
����˥E����s_�u�M�A�������v�0���cJ~�٢����YJTJ�0n>�>j7
��\ u(%���F��=���η�f�j
�T��[�E���7ԟ�	���
=�֢�G)�����B����eJ�VRvN���]�}�s�\8i(4xq�P�@�-��-�s�N3�T���Q
'�F�y�j�gQ"2�Ъ�'��Ru�_km��ڍ�d�ZI�X�.�/4�f����(���f
����[G������=��0�ۘ?�]�G)����/�5�޿%�Z̃�*�ǐg�z�8i7
���R��H�H��XN����J7�5�?DGA��1�����V��_馝�����=��(��+]ܥ���k6v�D�y�N��S��v�0���¥G�a^� �T(�8�u�YWǔ'�J�}c�4Ĉv+C��D��ˁ�L��(���������)	��v�Ɵ{���ڍ�ͅ�gA`.
����s��ݾ�I�C���5�d�:i$v�8�3}�yo*�1_��r�n��H*B���ng�\��E�ȠӅ��Ɗ�,��v����H�N�8����A3����΁0S��k:i(L �ZE���C,�g��x���k����NڍB[>YZ��~�Y��ӄ���엟ğ���)���n�+���$�t�#4L�|�`�Q8h(,(nE��K";kR���Jw��2�]��b
'�F��� #5Ⱥ*>^Ӫ��h�.lC��)���7�A��"3��z�ϐT��Sk}ޜ~��PP�-�N}N
-�!��_� �(ꁷ����v����b��Ժ���]�O��;��wHw縝���Y��R��(���_[��$ɱ���O�7/	���c�e�R�C�>��Q��鐟[����ڍB/nE�}����*}�H
�e����B�s����A�QXo�����K>�lU�1�!a���3���
�-AV8��n%�"b�OO���8�Q��NڍB�oe:v�O�r�d#U� ���f3����B�~��XF�YG\l#��m�N������k����A�Q@�f7`5����ZLٻ����������Q�Q�7¾���"6R��MQ��&��+�j
��~�L��Vga��B*k����cʣv�P�N��ZV���p��{�#���L7����?b��
�����n�h%n��x��ң���:���5�9 4���+2��eX۸�w<i7
�?%Y�{�K7L{=�97��T
Jp՚��q�n8���$j�Eid�B~	��X��5_��z��P(|d�k�lg�ti-����4��^�I�Q���1�`�x��d�EBh�VWۅ�v�0�q�Pk�p���B����)�JSF�:�:i(T�,� sxrY���Ht��Y#`��:�����GH}�TC`#��v��A�:H��wSG�Fa����T��ֶ�"�J���r�*e,���A�CA=̗�N����9Y����yb�(cR7�n
'�F��3�}��/`M����;�̎WG�'�Fa�Q�U�D�ٚ�D�'E�%ug�^mO�
-���z�}WxK�ݔZR�F)q�Z�.�u1��v��}�;�'�~^���g$��`rɨ����cG��|y�L�׵�@V�/i!%G��۸{.���?j���ɱ>�,�s�OOuRK[��{�I�Q`��g�׷H
×�˔��\}g}��P�W$!�<SO��=�t��*�:����#NڍB/n�Hs��0a�l2�R��3_]���(�T�U��Bc|�y_�k��Y��ګO�O�
j#|=h� -M.��)J�5�n��!N���=��(���=U���nkw�;�S1eu����'�FA|M�@Ĥ��hDe#���`�إ�}�t��P����6�L�4����Ľ�P�����ڍBo/sa7��=�����j\��ͣ�o���A�Ca��	V]�yM,�v*hȕ��yuq�n��׭Q�rU����RԩS��44�7g����Q"E�����쾜�XI�<��)�?V�/�^
5�6���S}(l ���#���q�n𥜑$�KJ�2���Ϯ� #�X�곦�v���q�@���_i������TbN�^������ ɧz��x�-�i���Q��X���I�Q@\��n�Z�n��t��5S���j���(�?��DU=�Qs�hJ�O�H�Z�j�W�/��o
-$��lJ������v����a%^�f���(�x�Q�̒ռ.���7�}�h�=��+��(��R2��fy���ia��x��>h�n
����	$��	�(�H">7H�Z��\�~Oy�n}y�}"�f̟��-_����P����)���1e��۬5�岴8|\&��*�����Q�C!ESj̩AH/���\���45�$ru��Q�Q@�TL�̢;%Y����K&B]��k}���W�	Em�Hnv7��e�`���1����I�C^RC	�~z�i�'߱A�7m��k���8�ڍ��I��M�,6��LP/\�b�9�:j(��\v��UF���`��̂j]�H��ͧ,G�F��S�����@2:��] dX��7�A���k�I����z��H/OOA#���,�r���Q�C�D�|@`F	Az��Y����kJz-+�����v���2�
/��:�����r#��N}տ��I�Q`_�(���S����Ⱦ�\9]}�p��P�/�|��ZH�S���&������f
�FᥐON]�Z��5���SBa�������(�ozM����t�0�v��D�-��\8���N�
����W�U�1����,v��> �T���Oڍ�b���a���sa[�}�È15u�Co7gq��	/D-� �a��4�V�Թ�I"wS8h(��^����Ug²�Zz-m�P"7�k:j7
�ۅ�5.o;��F:7��:r��{ʣv� >�%I
Ш��>#�����Y5�ps��Q�C���_Cj�L���֣o�P*	���~Ix�n�?��8���$>#�� Pε��cʓv��^^b
\g�lO�T���#�����O�
#��cS����X�6���:v��J��r�q�n�����X(� ������x����I�Q�2RoaYv+3�����ʓW�r�Ny��P���q=E�(8�V������樉g�WS8i7
�uJXA��Z�f襨S��;�X�n
�FaySY�s)`g��RԩR�������?8��@��R�b?}>��ꦑz�)�����u�n�׉ﻓ�ʙ�U�j��Ӥ�m\u�گ^'���A5A��]5�c���u�t�W��}Ǔv�P����_v/�g�	>���������I�Q �Y��'S��4�i���2��������A�CA=��jvD�Lr���\�Ңa-�]�f
�F��>t��W�]7K;q[�{�5袾�q\�G���o�t1�]���������>��s��-~o�p��P����Wc�&$+�����"�,3�ϚNڍB��pF�(���$^��?�0����W��<j7
T_�5�,�v41m��]C���:nG�B��$�}�>F/�A��N�    ��f��k]}s�n
���@��8Ҳ���NE�8[Z%��^�Q�Qаɟ��Z!�,y�H/�m�t���N�������/[�̅:���Y�0};&"���n
�F����m©F���N�>$�ܧ�)�y�8j7
�S��.�I�	��?���zU2�|}��PH���ڎ(;ˡ�H�wȻ. �U۸�k:j7
ͧ�"h�b���������H�)�z�k�v�0�c�!����B6���n�7�G���hZ�Z3�'��C��g%��'^mNڍB�O�`�-]s3�qgE�F�@s�g�>�;�Q�QX/i�Bh��j�F"�'���$@�n~+s��P�����kY��Bv��s��e�Q�c,W�'�F��O~��6���g�Z^�7���E�]����(��o�i����&���Ay`$.�\}�v��P(�K�%�A7��W�8�x�I]�$ W�'�F�y��Q�H����R�#��.G+�"�ս͏ڍ���솮��˨����#��Q�F�\���u��P���.��;6���Zm��I��1*�X7S8i7
ÿ�@HFl�Y.K���~�$�@���YG�>߱����a��^���;�;n��]M��(T��2��PtQt��m��mN^�7�A��j�A�۶:���$F��;�y7������f�W��{L�;���F'������A�Q@���ԉ!�1��wo/5���)�Wυ�v�0_��kb����D��B"*4���
j,_���@��<�jv�_u��	]=��OYNڍ���	S�\�����g����#A��a��ڍ>��G(E�+i�=�`�0�vDW[Ǔ���H�kb�v��f��z�҂%$�2r	WG�'�F}ʱ���X@�(��_Z$�s�GRq��V��(��!�hth-�Ѱ�F~A51q��m�>_8i(P��B(�m�r�N�~�˱\�jbf�zE����)�ڹ���"k*/�|hW�h���^�I�Q����VR}�A�;b�)�T���'�N/�D ���f��Ț�?�%)� 3]]y��(�w�*ʒ�s��Z�����%rK����kq������Kqo%�_:�,�u�]����G��]&�;��6�q�nsa��uE�Ue��j���(���]T�$^)K����BU�H�˼z.���5|�$"�D��'�x�t�K���Q�CA{Ir(�S݇qOt__r�a�\!K���I�Q���N��[j�Icsa��k�C���b�\mNڍ�z�U*�Qb��5u#e�X*�֫�������m�Se�˩�d��D��J\�g�����v��^�nt#��"��`#U�b�1����_mNڍ���;pA݅�k�	�Z뵏�|�]8i�F(��D#��TR��P�c�(!�nn	��%r�n�gF��ZY���_lw��X7��o>e9j(D��i��[Kk��xF��%��g/=�x�)�Q�Q��ǔ����ǈ6R���c�!�psLy�n^�5���}�O
�M.8e7�G��T��Xd_ԦvY����a�=�Oq��Q�Q� h@�v޸�Y�����L�%�2�ë)�?���@Ĳ+���2M_
�@DڵS��1�Q�Q(��m�}���"�\ �%wj^�ι�)�����/�3�r	j����m2d�h�>��I�ڍ���Ɓ�s�<��4}m��20�Z7GSG���}�.��W�hY�#'�8_��\��~a|�n^���~a�����BF�n}��J�tu���v� ��TC��k�W"#��!�2g|y6�Q�C��&��XuW��h�$�F�[i�W������-��f�]U�FB�Z	�j�
�վ�I�Q�Z!�}��a��J�	�Ξ�(�n
�����.C�Z�����&R��s�9��oe�ڍ�	Ө�a]�g�Px	�w�C^�L��_8i(`����.�/i���N���W��+��(��-4v��!4�k��۴)jD�Lě�S���:��1f�H6����J�SJf��k:i(�|I��(4�+m.���+^��c����NڍB�}?��9���V_�hII\�_�~�n��0 i�*u;5�Q��li����N�Q�C��1TA7��x��� =�B>Ltv	#^�K��(4_��NX��ES��O�Mk�� ��ڍ���-�1	����:��y;�,=M�o��w��P/�J3Ui�Э�#F�%��3�WW�9j7
�W��ޠ�C@�:��<��Jω㸺��Q�QX�I�~C�K �5-�쟤�:��8��=���@������Qms�}E���vB���=G�F��S�)Q�e�l�Uxv��ٔ�ī��I�QX��Rd��h�����*�J��P��k:j(�ˣ�
K����N�}>�>�E�5J��W������M��9�{�a{��~T��sU���Nڍ���2�̀�r��<�E*fo���s���0�_6�R��R�ì�L��)a�C�ۼ����(��e�A���9���ߛ,���^W�;�����@u�N��N_�ˍg�@ ���Y'��_� %
��>#��ψ3��Ƅ���I�Q��D�I�p�6��ڠq��ǧ��'�Q(�wl��>ս��4_�f���̻��A�Q(�r�i?�˨��I���i+L����w<i7
�oY�=��We�#��z���uO��)��������N�U�g��������4Կd�z�<i�(�Z��#������SA£M���͑�Q�Q��벐�؀�]�c
8|�G�K(�滩�v� տ��ye�3��4}Ñ@4���n
�����AJ�T?�_r��n35rN7W�;j7
����ZyN�a#���h�4wLݐ��p�n�7���Dn+�Mqz�
`姆z���)��
)��W��|��HB)�"��j6(��wSG�F�|�6�)��V�����K���,s`��|��� /�.p��|j}��ڗ��Cn9ƫk����ˢ�}"5���ks�奡���Ƽ����(Lg85��>���B?	�;��=	��
�k���X���x�ѿ� �.��\W��9j7
��=%��=���.q�R�I�K�k]M�?J�e��w����FbR�hvNG�WW�=j7
�$�N�ky�8�����b��]mNڍ�VD�de�a�](�W�̈́���n
���|�gla$�1����C����Sīcʓv������;���7؊�Ň\u��W`)WW8j7
��FʪT��Fտ��G.�_]������o�́c�G�P��h��N�
���ڣv���$`H#2/	���	�4�����v���$^h�@#�zN6���t#�0^��w��Ph�o$V�:�d�6���lT�\X�z��t�n��HH�y(K��Z�V�QF�A�.���wSG�Fa�������������+�0� �Ww�9j(���ڙ��g�����Th`&��|g}�n�H\O�̓�]��k�3Lj5�������0�$��Y����
�CF��_G��?�+x�s/rU���YS�'�0V�L�z�>_8i7
�sܚn��u��������%��.�Q�Q`�WF����)�eY4���11�<�v�������@�W�Xt��k?}F�2sG�������(�?w��N�n+e�#�����P�(��^mOڍ��~S�6.K-�g��ˢF����AwS8h(p_��"�γ�`��O�/�����n�WS8h7
�� %��Jdg�\|��
=I��c������(LoB�I����k�1_
�>=꧇��)O�
T���q`�}�R��7�	f[���j���(�o,u�H�rc�@�W�`�G�k�+��������/� M�!�ZQ;���yf�<
@���.�G�F�^uJ��txFZ%��5B�N%\}�t�n���B�� �.��I�>) `j�W��}�Q�CA^j Gu;þ�˲>��J7��C�]�A������_Pz��v�}�'�7�� ���9i7
��_�J�������X.��ܝ�uҾ)pȾ'a����l�<gM"��z)D5���l�v����o��'Q�    k��� ��Da�8�����(,�Ĭ�$�MdW2����}��Yn�#��
��$���Q���N�1����0�]-��p�n�7�J�eC2����n���.�]�x�Y�Q�Q�5eP#Z�W��x�Y�i��fc��|�����w�e�U��씜����6���N��)�����Y��Uv�\�����2?zo!�����v������Ş�W���i����N6�0��O��
���n܏ǘ4�F� uo<$Ʊ�c.7��G�Fa�TB�p2�PZ���OI`M�ǫ�Y���#�,�*j7?oe��	FEi����Q�CA�
�
!�õ���N����[VQ�Һ����(h\�]�]�h_Oe[��c��,甮�)Oڍ���.��{)�<}x>�.�2�@)���G���}�����C�h�$_(x i�5Z-W�/����#�	�L�F��ҏq���Ϗ��p�n��؎��V��9YF�9�	jd&mi�q�\8h(T_
C�MDUzN�F�� 8�ZY�����(t�f7Z�_��c�N_��B�}:fmWυ�v��|�x QZM��h#�ϖ�%ԧ.�!p7�����c9�a�H����{�dH�2�r�=�Q�Q/U��d���Hȯ�.G�x�ΫO�Nڍ��efЍ�@�s��؟T�^SG��w	��)�?�sx��*N+�ewq��w��Umm����Q�Q �;]K� �'ߑ[��׮eq����j
������EwY]�������v	��Մ\M��(�6���M�Fvыoh:{ݵB�ڃ>i7
�_ZE��V����^@i���A�?v/O�W�Uc�v�2��2ިk@�;Y��p�nп*�U=ϐ����Q��̉-T���ڍ�<+�h���g.�fg������>�G��]��Q��`���)��s�$��.� Ww�=j7
��e����2��T�v�'���}[{�n�W6�E8r��FĲ8�\r+�S��)�?8��~]r���{�^��a�iJ��\y��(�<+ �σ���+W]���A7w�<j7
��@m��N���^.���9A*�p��8i(hp�Қk6�Iׅ�$��0M��ڸ��Q�Q@�uk�"��?6��3���J��:��p��x�nؿ����(qZ'g�/�u'M������'���RDR�j�uN�)/5�`��c}���A�Q�X.���GN����|� w��z�WS8i7
�S�������_Xӧ� �>���t^}s��P���ʢR�+k�a+B�/:Q��纺v�Q�Q>�G�b}�?�/�#�n������v� ��]�Ե�Z�Ŕ2}!��J�p^]��}S�!�5����Ye��o͕����7�սD�ڍ����YT�b�Jgh>�"h��Ou��p��P�ɿ��0sZ$-��Ŀ7�P:6�f���(�$���Q����e��h��Y��n�G�Fa�<��:댡�2��Hd���֫+�?L��.r��������)�?Ӈڗ�Ci��#�v��}�҄�\M��a�]H�N�c9*S��݁�f���(�5q�<��NYfb��&s�F���#N�
���m��ۜ��'��P^RC!��Yכ�#�ڍ�Kjh��������0|Rd��t�P�y�\8i(���H�v��8b���;����V"��wSG�F�%54�tѰz��'��9��Iշ��̔��s��(�w*t.�ʥ��6����u�@i�S�?J|i�#�Np��V���N���"�R���w�nЗ�ȸB�P�Q�3Rɾd'
����G��~�C�q�����PPOˏ4q�?�7�A�?j|i�J1��Sxy�[�����j��(T_��c�HC]�n�,�f�ܶ�v��v]]���(�7U4���("�g��C.���i�9�n��:j(`|���g]��6��&PZ(�5����Q�Qh�(f�j�EY�����~Oi���ں���Q�QX>�d,�$[G��/i�YW�`\}7u��Ph�&�����vzN�g{�yI%�vu���v��|�_��S��c.�����9 �(W�ğ���/�W*Q�Jum$��r����S�)O�
2��e���<�ڇg���`g �&�漦�v���mc3$H6R})�MjQ$���g�'�Fa�7���@��򲷵�����%A(e�3z�}�I�Ca��`�!P��eXv���NMvk�ݮ�j���(to<ԥ*����T�KYT����tȫ)�����E㭈k�����/u�+��쮣��߁mw�(���`^��_��4Xq�ՙ~G�Fa��[��<�:�T1/��X��T��#N�
�YG��C�`#��k��jӥsuq�ntqx7[rK�o�d����y�ۺ:�>i7
��2��8$�)����$I�SI�\M��?f��i&�_�Z�sg=�w*t¬�G�w��?j7
�{�]*�n�~���R�Q-�c�1p\�;����S�D��\rY�"&�z�P��ڷ��Tt��B+eTs*>�gP��(�����Q�cԗ�`�׏��+���g���)�����Ah�7��j�Ɛ�G�s*O$4�矀��&���VW����,��_?jBҖ���]��C�7C��>��.���O�~�P���:��/ן�P�E����BH�f���?�{����y>�٭�+TH��%�߁p��@��0&({��w#]l��P��0f^I����ww�� |F��G�ť����.����P�_?���.�r��C��0~��f�M�v�g$���.2(ξ���ҙ��a<I7�.����s��!\f�����Q�׏ �d�c��!�e��P�-�"k(5i�~�p�a<B��*���r���VGi����f�ݵ.��a�o.h��0���R�+d��?j˰�p��O�[���$Rs"���(ȟ�{����Zd���5�H�}>PK�S��*��/18)7
��?Z�v9�<�y �{�������C��ypR��K�G���Q(����DӁj��ۗ[�����bpPnz��.����<��>��3%�X�����08*��G����~&Qj�a���$��SJ����Q�1��0 3C�]�����W�6��sUϺ3\<N�	��������3R
�p���C���_bpRn:��&I��:+[��ɂ����lNʍ�����N�T�$����s"PR��{Z�b{pR�0�~_PGuRRO:<>B��R��D�r��tTn::� ���4�'�F��,�s�����b��`yGj"�]�)�0��&�"��z
��I��[��47YP��`Wb�񌔣���t���D.�'��`�[g�5l�h#��k�)�s�rq�tT�0P_�%n�e�'�|�<����kď��&\���q��42Q蔟�ʟ})m�ȘaM�U	�����Pt�`/��[ [���D��RF�_]8�-������lQߢ���W�U�A�p����������L�	��l-����]U=r���_bpRn(:� H�R�Ffk#��(»�c�����bpP�0��75�������A]>��i�~g:�I��[ʍAa�4�-�J�R�g$u9ݪ*��;��^'����wb����(a��ԃ�,:O���W�|���������g�����lj6���R2K��b_���T�yD�C���"�3R���c5 ԋ�PNʍ�s�@#I��s�s��_6LM7_T��'����:d.�Siie�qV�)Q%�m�I�1�� ~���UBh�t B����F��<Nʍ�EMBlM�g�^܌�RaŒW738(�X�5-��=�K�B�����[ʍ���T	����h�Y׀�J�](_�'��?(��&J�B�s�}�v!�R�1��g�'�ƠT��N�����|>IA�J�m��Lۃ�rc0�?O��v~@�;R�vY��4
�����a��o�C�t	��jk��r�5�~9U����'�Ơ�	��(hT�� Ct�*C��^|~pRnh�ܹ�1v�>>#�D_�KMH:��ͳ����a0��@#J�����    �^�-�D����Ծ�U�[ʍAM/��Q�Z��	�H���e�1�*�<��KNʍ���y�]Sc���3Z&��p�4�y����?V�nq�f���H���kI�P���Mi�������L�K����ݹ���1��c�仗�I�1`~	�d-��ײ���������Z�_���[����BK��6Ձ��d8�P4��s��������K,C&����?�\�j81*����'��`��2c�9�z4{�Q�?��0��\ڸ�,��|3h!ɛ=��s��0h!xOc��������/�����2�+^b~b�݂PIs��_�P�[ʍ�����5��1�H�����!�н��Q�� f�؈p�R��'nl��*��y������jv������`j�9u��h#avFc�`�9��UY����,�``�Æ9�M��n���m�q�<8($�>R�4�\aE6)��a���*�{�rTnzr��S��Ɣf#U��[d��uL��38(7���� �k�J������Ԯ������a �_̊�'�WyF�]���5.���{�rTn���4h˜m$~�8��
ja��~�I��@��/�5,һݵ����]�C��.:uo�Q�1��h��X�E��h�w���f�yo<)7���$��.V��O�<MN�颉�b_���aP��c�ݒmKm(�諭T @�z� ��	W��
�5oq�u�i���#@�or��2�J	s��x��h�1C{mػܐ��F�+�簓��lBl@M-z����pP?����L�$�5�WEL�:��aypCn��߂z�cD5��݃�����v�Q��V�H7���\�V�W��C��nC�Z�=�?���8� ? |��}@j�n1�Bxo�	�!�ݘ��q�J�v]�PqIvR��P}՞��oȍ���F(�V�>׆�1��dƜ�[\��a���D�˩Sm-�a�S�H]}�wsmW��}4�s��u�T�wV���=��إ��ñ�r���{�~F��4%f+��p�����|��ဲ��*d���U���|s|��c��=l+ߐ=�{�0���h'��U=RV[A���2�Ɓ���.q.}����4����wCx�V�!?���\�V�oL&��+��]��<l'ސ�s)1��V,�tco�hi�Yb���#ݐ��}�0�H{���_���d�鉌�a�pCn?<�JM5�T��n�jϽ����C�9�!7��#���A�Nj��"���U���z�+�����Q�':-k�9����]v#DyXܐ�7�,�s�Z%�=�e���^	j{�-ܐ�+�)S�fe��%oq"�)VE���tC~8�s4�@Ncp5�8�Ǡ�,m�B+?�3ݐ��LCI�֩K1iB�HBĲ/>���q0|2*�0�E����6�ײ�R��l���Á��7bn]�X�w^���c��>��q���Y��{�*7��-�곷z�$���p\���'vNmW;�l=]m}L�,�GLC^εݐ$x�{�N�ܻ��zyĨ�h��a����8 ?��Eu����7�cRxtb�{�ӻ\����)A�ް�����d�J�AM�7�
���e����)D_�]��	�����|En�J�7&�Cԉ�������P^��~E~8��+�̥���w� ~�DF���޵�ȍ���ޚ��-ډ+S,�;�y�$5����rpCnL_����v(��e'��
bkO�5�?�"?$h�O��,��R���.yo,��n��q@�1���8�����w��J�5�pEn,��6$�J9K*�N>�U��mo�|.� >��b
'ߨ��R%��'C{�����8h�>�8KAu~�PH=ȏ��}�0�����oqpAn,d��y�%j/�I�>�M��gK:�|.�|��E�,K)��bu�e	d��Շm�r�|o_���j������JS%�nȍ���֨C��Δ���A��k�����嫿c*i��*��=�Z������c�"7���ch�/�UF�d� �XfJ�a�xCn,��hO���1'˽S>	2J�:��~���~�!�c��^��wJ�.���{!�ܐ����t.k�P$���T?*^���<g�F�H7����

̨>���v����<aA�Q^��,��	+ƌ?� �Ǣ
n�g��a�xCnp�	9�	v�k"��*��M
H~�N�!?4u�>b�)���.�:'-���g��K��普ȍ��M:L2�Z�|(4K���YaW�Ɓ���#�=-�I�xJ�\0���^�!?�W�.K�-�;I�b'Q�SE���Mm���~�+r����%Iz���L$�SE�*���n?��q >Ђ�#H�W�C���^�=�B�n/��᠗����88�Z��N��[[�K�_!u =|nȍ����6�)���(���'%��s̸�9���"7�c�'��WS��k�~��>FW��^����p�����{kV�O���=c�yG�nȍ��"�,j#�4�jQ;�d��\z��ù������7�-���Ye��:rN�����.7��A�����H-�M��( �0�:�r�`z�jIA�QG������Bz���䇃��7v�5��^��g�] �1�U��+ߐ?f�{}Uf��g��kM�c^��"7���6����b�ISI�:�a�ޙ�}���������g���＂��Ե(�����ȍ���,�U��c�U|��<0�]��n���q�BMD�������O�V�*ϤƖ<�c�!?�A��("�vF{|��ԕjPO�e��8h�?�1�T^KL7J�h��]���[�,nȍ��q�v�V�P���=~�/Z}����+��A���,%��}c��C�c��T��rpEn����3�\W��>]
��A�����tEn,K[(�媐���������V��فW䇃��@1ҷ0R�ґ�]�5��e/�z7�tEnP�� H�K��wf�È5����Ѽ"7���4������
T�(���5�W䇃��@�큫*9N����ɬY].�rM��qн�Ȼ`I5h�j21��DH�"j�aypCn|�jHY�k�qD;�c�K��`+����W�ȾPCpfFP{r�^���U��J��n�!7��U�1�\��a'��P/��%!?��En���Y��V��-�LU�4{焳>�n�9{�yz�KȽ��c�9�e�]ԣ�;%�����ȍ��gջ����L{u��,�j��^����pP�����*�������Ԙ�"�0ׇ�r�@��0#� ��uN*K
G\�r����"7�_A����8�ɃB>AO�!�Y^�7䇃��m��[�$b'��^k	��S�"7��/t�*��e�H����3K�Z�aypCn|͔̩�W!�w��Jo�5�|�6��p��˃����4�	|^�$u-���ܐ��LhO�,�� ?�0�)4��wc�W�Ɓ����wک�2mw��{�A�=5e�����1���A+>Т��^��Dd2�%oHEՠ�N����q����r@��k��c��R�:G�5�����ဂ��yV�b�yi�-l2�I���r���=]F~y&��jJ����nȍ�CS����b*A,�B�o=kЄIL|����p�Q�{�ʔ1V˵��U=/(��[�~EnTo'���o�n��5hrv{2==,oȍ��{8���q�a>�>+wR�ߴ���	��h^��nl�Ce�u�|&��1P�K��w9�!7�)0���B!�3���7=!K��F�Ǖoȍ���I����no����`���7˃������G���U�����}�G�7e�5~7�����U���Ǿ7�I������?�;ߐ�Ǣ�)IR�!�zy�p��"?��vEn��5��iF���<�o ,Ph^�p��q0����    �Hj&�������e�@t�Y�����p���X��8�޾=E��{��v�:<\�rCn���0�R��~羊kZX(=<7��8{�$SV ���¾��|�Q9�\Րz�o�!?����	Q�ɢ��9I�ߎ��\s�����q�~�]��f8�V��1�z7�-5���4W����*^��5�s�V�!�QE��ܓ�χ�֯�7�G��NM����C���̉T�T���"7P�	���a5Y���XjN��C����W����u(�cA�s�vR��U��;P���k'^�b��Yai��VT�$��ޘ�1��z�N���8�~@@�E(T�7c�#���*��@e��07�Ɓ��8*Ma�r�}M;i~��:[�g~�F�"?��k4�^�Ĳ;~M���S��$��nL���8��a�Xc������M�(�%����W�Ɓ��(�NBU+6;PE����d�0�������dVo���ګ�^��Q����b�L�!7裀q� �XD���Y\� ͔�Z�spAn�D�`�$��f��>&�L�}Ҙy/�}����A�>��~c�����酜|C0c'�G�7����K_��8V�3���L>�JiEiz�6��pP��RY
����NZ~�_�Fcܛ����8�K_�Ԑ��L7�쇦4.c�Y.�ݚ�+r�`�E�����hT����r���hy7ѿK�"?���WR����o,�|ƊGP{<?�c�"7�'%Ր&�/����\�>�W�Ɗ�Sz�n���8�6o���hT����T1��3Z�nO��� S�j��� J������N�jl<<C��8@�����W�� ��z�W2�������}pCnL�\�]ȭ���݃���"0?��qE~8h��G
"�P��-�Ԃ�f�3*�*ڇ��^��é��z2���TdŨ������tCn̏�z KVT�ȿ��/u���� �ñ���%�H���8�z�Ҙ>A#��-!���L�!7��I��h�U�
x��
�7����y��q$b�Rղէ���9� ?��~
RMX�C0��l� y[0������8 o#��P
&���P�Ǆ�����x�����8�Xֱx�λB1���?&�,�ģ�>��\�v@���9.jҢ��0G���0�@D��:�+r�>�@14�6�?��� �F/��nȍ�sq��w���������'q��z8�xC~8�|C0�}�T��3��ޘlB�����ܐ����We6�yc�a�������>���`Ə�u՟�W�\oa�oz�AG��^���A��A��E�
5!�-̏e��U���`|8�tCn���,L.;�?i~$f�bc���ú��p�.����gĀ�#Z}������Qa�wk4�ȍ�>��+��YY��V�B#ʮfY�KXܐ3�e���zϑ�FZ�W�4�F���p\�$�\C�X�0�LYV)�,�����,��nȍ��6�8�H��Y��X��#u�*
�]nȍ���H��2@��?jZ�(<\�xC�9!���F���l'��� ��'��u��q���&+�}����g��@�=ݛʜAﾅ+r�@>��PK�d^vR�5�\b����xE~8���=]�{?��,��1��B��R���w�HW��5_�Ǖ���div����{�)�p���q��� 8b�Ѵ����ٚu��d����tE~8H��슽
�e��R�C��܁(S|�N���8��w�	R,�Y�e$��e�D�_:ԇc(W�ƁD��\x�$�9�#�ɡ�\9�VSXܐ��FP�;�̻��7�,$�1 ���X�ȍ�~!:v��K�Ǵ�>l�Zc�5zXܐ�@G��������^�5� α\�rnޱ��娿��#8�Y��L	�x�-ܐ��Ւ,#�a�����jOܻ0���oȍ�uiӊ���L&��'@�T�>����d�@�>X�H�8�(S�*��h��pCn|��������<(��B�E��~En����1٫�����gi�5���n\���pP�/���KPk�����o�'�Y�0�s��a����8����8�aZ�i��7z4�>w�6>��E~8��?+�Y��I�k�T��4��<��q�~�b�s�����i�zR� �	߭پ"7�ǠNr��m����A�Y�������U�sm�S%FTw���-.��������n}���B��H0)�:�X��h�{�)L��n�!7��#��%�,6;pP�|�k�XT�»5�W䇃�|�C�E{gߚ�d"-_�5dm�:*<\�~En��8��L�F���)a�Z���p\���p��1"JR�PT`Zl�/�@C���6��6��qP��O�cM�3����kw��5k��U�����q��� e�XB��N"���r�aypC~8�/DO�J�)���-���=:H�-�K��}pCnTO)8#�ڦ�L#�	���JXס\�,�*G]��T� �<*qW{2?<;���p0���_��VR����h	��B�;�0���XZ���6�X>'����U�B�˃r�`��1MTd��WO{��झ����>�7ސV�NE���L��>��ϡ�$Km�3ݐ���Y�����-����gOT�=�<��8>!��-���W����� �F �� �a.�zW�^XfV�Q[�i-_�:d2�6<\pCn���h��� �&���G�q��̳��p���8���RR1��vR�V7�_�vw��H7䛃�(�A��S���X�|$���{3��<G��8@�`&�� �����cئ�S6Ts����+r�`~�.�b/�-<l��6:����5YW䇃�V��Gk뷣j��-NƢ��./߃r�}YDn��P��q3oq�{��)�G�"7�ﰬyo���~�I�ab�9C��"?���&}!������'�U�5�����=�!7����E�V�FvR����U��]��p �&����ޑe2�/n��q����IsEn����������Q��U�����xEn�/jf�c$^�d"̏��0W��]=,o���J��fpQ礜�/8��gnTj}7�pEn|4=�$՞VZ?�Ga7�R��?�˃r�@�~����H�Yl����{ }><7��pP���W���!���+�B���-\�?�"7���d"��w��c�# }P��x�_�!?���F��Ӡ�M�s��U=�X�����+r� �,Q���lVجP?���V_���k�"7��MJU�G��P�c3,ΐQ�^�n��.�>Eb�l���a�>I_�^�!7����oe��%�h'U��5�GeP��a�xCnL���@.s�Q��������=Q$"�w땯��k��I�u��T[�������W5<�nȍ���H�S����bi����=I��\ʻu(W������6��K��O��}���*m�o������������l7Ѥ�?6E�ZS��a����8h���nn�);���9�z�b���6��q�|˙$GS���~@��.Ř�><K��p���T�4������Tg>2��,c�Z˃r��>�Iz�����^}u�������a����8X>�4������O/�x����;ל��y�W�?W7@�P��q��R�5nC�Ynȍ��i�@5�4{\��5�"��s4�ȍ��wXV^��A~qe�8
�ۀ�����]�x������rN�o�DU(�Z���oȍ�����y6�I�5�Q��)��uiW����CW;2�6E҈v����"�*��|}�&��p0a��/�k�􏍃�Q�[���<�����q@~��Jĩ��/�곷'��>?O�!?����X�i�4�o��i%$Q��{pAnTS�9�0U���4�D!oL�E�EvS��ܐ쇲/}�9�,6Ou��a�K%$zxw���@��+���'��L�[X�#:X(���oȍ��BNU�Ti�n�@�wNgVCK%�    ��p��q��n=#��Պ�b1i������óƯ�7+��=$��*���;˔�����}Xܐ��˲mM	����ԙvD�Q�P�z�k\��hţ/�XvR��2Zٻ]�QuE~8���45"j�\Z-v����cے�Q���_����=�.���3������jh�<<;���8�~�q�^Dڭ��Nj~��QE��ws�W�Ɓ�E��jO��`㰓��f]�n�]��.䇃�18�J���)ȧf{���:^���w9�!7��f�ߟ���Nj~I�*��+D��]���p ��6�Q�_R���B��#�����xX/ܐ�+�%���zrm�+f��2���,7���F� jf7�������TÊ�_�W�"?���"�@� ����	���A�U�ö��qP�z��L�g��8��'(e�RS�普ȍ����W�9�.�v;����	-�X�������pP�ϱ�����mv������-��a�xCnT_ȉb����T��9 (��|��q0>r��"�b[������H�V�����AM���B.�W��ӍE|2����F]���HW��A�#�Y���K[�|L���5=�7ސ�7��?�a���$���QD�΀Ϝ�"?`�>�,j<"�w?���GQs���wsmW��},�T���5��DoPg`�9�Cy�_�!7$�9��KƮ����^8�2�J5L�<l'ސ����B#��9����-N��[qO)<���q��1,���Ij��Py�{��VByX7ސ�c�nl�wɊ��Zm�n���!��3�ȍ��b֌�{Av���}L�����i��p���᠇�{�Sƨ8��%K ���9� 7�_t�9��U���?
z;sm�d�ݼ��q0|�k��7��vX��>��8�RbVG�a��p��?��L�����.~�\C�(3͇m�r� Ǉs��"��@L7r�S��Q��?�"7f�HF奢2�$���i�ffR�0��o�#�G1+DE��9i���R$��i=C�!7�vOR��m���W�t����֯ȍ�9�=�:cϨ��I���?��Vj��}pC~8��U�G�2�X~a��#�#S���S�"7�OȩY�xs�?��eE͐�֍7����c�n�T�X�������&��=]W䇃�|~A��j�A���r��%�]�rpCn4�<�[��"���i�x���}W���D_�������W���'��uWꂵ�g^�$����;;�n��D��_"��D�oȍ��U:�J�A��F��!J"i�D�����"�H^/d�=Yw��N���h3����a.ȍ��� )��wn���E�_�����ړ*߭C�"7���p�o$��fDI�B��Gl5���rE~8���*��sP�$�gJ��Bj�ݷpEnT��[�j��Ԟ:q$��on���]�W��;_�_хe�^{�}���r'�X-jq5U4spA~8HQ|�&Y-!�5#�$��c�,k��g�\��zB�`������3iJf���W������9��:��D��i`�)A�~7��>�Rk	���g�$�#���k9�x�.��8@|\�R���L�+1���O��͹^����JY��߯Q;��W�gl�Z�����������l����A�+�|Q��O��ݨƐ�G�s*u/	��_�BaO�0�i����?�~H�dUK���^ZWv�0������To�S��O��	7�Fڶ��s����5	�����?��I6���?b�)O���R��I�o�$��`7����+g5�7�����M�LB%w"�9���_��`�3�t2!r��E��
���S!AՊ~3��Y�K��
������a��M��_��`�C��%����9��f��IxJ0�!	�����k�������㟑�//��?J<'
���{��HGB`QmI�h�qG��GՓ�������7�F��u�����v��K�c��J������4['؅��63��?�G�U���#DY�O�%�?Nd�?!��@1������s�$�ˉT��E��U�������?A~8������ ��g��������DϘ����e����Gp��tv��Tr�{�Gul���4��oqpAn���A��f�����[l�u��6��簽����`DH���*�Z�ǖ������Q��i�W�k>���qЖ#jp+)I�F�4`z�!*��J�?,��8�!7�S�~��=?nP0�8FwD�57UU|X/ܐf&wY��G�� ;�~>J�	N5�$'�����/qpCn0��2 ��S�?����'4jͣ�N���oqpA~8�c���ĚE���f����l��rmϚ��b�����qP�L,�=j�g#�ܜ�H����[��7���Ȏ��zS��06���{0�K�Jȩ#�-.��3&����z��$��i��U�=ǿ���qP=��!5�K�v$��:�22�Ѱ����q������T;��vew����b�:�ú�|s !z�"���J���彯�c�*�?jr�[\����GC��x|&u����'�_�|W\��+�G,
� tp�jJ"��.��W䇃�(���F�A9�B�w�xZԆ��H�R��8� 7�����/i�}����n?C*v}Ps��pտ���q0�{�qn;�Si'u�7�I�½�O
��䇃�(���H���6��N�\��d���e��q��g�Xq���xN��r��I��ŝh��o��8��;��$D��'4��
��ԇ���� Rre���j��8��_�J̥��������q��݃�6��:���wJK-%���x��q0��Gq����%;����p��"������ Glbn�Ԗ����G&Aߋp�9�lܐ�Npf��TjVF;)ouG�^���]��,7��� g#��im�V���zvD�Z�ƚ!�G�"?��9(@�����v���XH]jq�e��qн<Ȫ>!�60�sRi�U!U��jO=�3ݐ�?���8�C]-ȴ���Qz$�m6���Ƒ�ȍ��]�m2�N��Nl]������
�Ƒ�ȍ�A�"��`>S��N�-t)�5"<l+ߐ��G�1e� #@?'a�-��B�57�%nȍ�^Q"%���[��eɐb�3�?�e�K\�Z��%-犢����8�S��O�-����v��r㠰6�J	�ɫ�[hP��c��r*���/qpCnp�;p:%g4������jK���n��GMV�6z���-lG�Gc*�
>@y�&��8(�]�$%�Ξ��9��Άs-����AA��r�/�`��,Q�+�I�;��@���\�vߣ�S�-P/����>C8%���xCn�sJ�O7vN%���AO��w'$+���-"�Kܐ�ۉX}Yl�����|�M�Z���ڼ+������Մn%E�����y_�.E�-��1�r� ���9�����r�H�JjkvJ���tCn_���q�������Ŭ�ښS��A �������.����гRc;I|�?�Xho�yX&ސu���,��y�g�:�Z��yV��a��r�`tGT"�j-K;�����jc�C)�7䇃����,ȡg����J�$�"����^���x�l-ȩ�K�Y|����`���Z�r�`x��4���fqe�/|�(K�F9|8�tC~8X�+V[z��ɔ�>�╇ RS%K������8@/8UuT���윴J�BC'�s�J׻ܐ�}-��
���}�)K���)����Á$_��y�D�#�rm{���,��?Z��8� 7Z�EK�YA���˵I��YY���07����(�V�89Ì�bi҇�����9��2�|s�D_��I#�-N�%�����+�1�>��_����'jJ/�Z�Nj^�N5�5����9� 7��ƀm��8������w�����    ����A��tU)�fV��8�ɟx���^��L�"7�Q������|�'�6v�x�o�"7>� ����������G��vk�[�tE~8H��Y�jʼ��/��-�P�*�4l�/qpCn���P��������M=���O�����q �A��M���N�(�e��1F����������8��Jt��;gH>2��s6H�鏖z�%nȍ��{��< ��#��3ν��a.ȍ��g�0�V��f�hl�ɔ
���^�!?�⋖�DRyȱ�I9���>#hT꼛{�"7z�I�(f`���4paX���� �����q ��VW!�V)Y�Ƀ<񣺋7�=Q{�_�!?���
��ʘx�$�v�NY�0���wEn���:�)��i���FХl��(8�#]��}�+��P��l�2�� ��FLU�/\�j�Ͱ�JBǽ�ĕ�ޝ�z�=�*��~��qp~�+��u`�j$�I�A���%��2�[�xEn�/^k�
�F���N_����b+1<lܐ�x�x̔Z"'�1y�#�R�J��aypCn�����j�U�Q,���g���c�R�n-���?'k�Ǝ<J*��I�}4O�Ҟ��0��A��Bg��F�A�C�p������^�!7��|Wቡ��f�ci�[�q�~��e���p@*�}���J��z���6u�q�vg��\�5}�B{7��F"��kMb�)�����xCn��@o�v��}@��M���w�εݐzZ_5�5��M�w�B�s��j|��q�r���xQ� RO���B/^�v!l��q��_�!7&{�B��e��{���,�^�Nv�����WdU�}�ő|%Ð=Lڞ��.7��{�q�q��9˞�G䣳��8���|�+�����-t�Uv�ʰ���
�'8s�9�z�\���L��q�#9���1���^��.7����=��v����'-�^Z��ڻ}�W䇃|�ge�M��������ާpI������8��s��
=�4�cR3΅c-���]��˃���6"���l���,Y)L-?l#ݐV��Y�l�Q�_m�����0������+r��c	���e���W���C�	��.���tCn,_���ՑBϖs]�'1fIaյ�C����p�f��Huc�=E�W�)�a�{:m�y;z8�zCn4��6���4ԧ�?��<��X�T�����r�`��- �{�>&�'
{���"�yx�������2���Z'�^B�E�0�zx�F�"7��ޓ�DK��N�~x�T�#�2�[�"7��!�)��g�[m^	�`h)55������p��\]@�:gL�{��Xݫb��G�ψ�"7��t�[h1H�~'U�\NIH�6xW&^�K��z��t��I쓒$�g����{�"?������`Q᜔>�a'�2Z#�m�rpCn|��F�a�-k6;	��1�V:B�=��3]��U������`'?h���J�Z����p j-�˲BZ�ʴ�B�䋖�H�����]����'���DV��j_����1�7�Ɓ�UE��9�N��1IO��z7�|E~8ș�eY�L�����r��d� ���W���z�,{�
LH��$��
�;�|x��q �gj{��,@�|,�YXw�Kֻ�8W䇃���08�Q
�JvR�_�G'��i���8�>В$�{�eN;	���*C���3���5yy P=+U��Tj��o{|sR��ry��r�@MFoD�-��ޕ��X�U�����ȍ��� x������$!�$����e���p�����W�+��L�G沏��"��e��q��ש��U�b7������z�3��7�Ɓ�����PTc�������[4j���.䇃V����U�#�\�Ғ�PO	�q�u><c���8�~0=J�j`,���]�r����e�pCn��sU�z�I���m���B-0�)������p@y~��=JR������4��U�BH�nȍ����j$n���rm�>[ә�@͑�q}En|���YH*�>��U�=vֻs���=��8�籺�}Г_���!Q}�ܐ��[���Q��t�ٚ(@#a_y>�k�!7�1���	U9�ho�vJ�Mj�_�"?p�^yp׷�z�ש�*{��4b�Ɋ�������8�ވX{vTcy%�0�ồs-L�K��6��q ވ��I�$�%�8��2�y��������`dd�Wxdi-�I�c�i��gh!����pCn��sV;Q�&��Ģ�|t�e�=vu@�ܐf �wV�rt`"��Y���X	�Π��z��8�>� RB�(j>Y=���D�QĹ���!7�s��+�*��v���O��	)��e���p��G���Tb�XH�w�A3��z�a;��rpAn��@c�&��-��O#�P�D�w9�!7>������6��� !nA?��a�xC~85�^F.�;��$�ܫ�L-���{�f���8h���1��B��bi�K�K�^�a]�rM��q���޾��p��3	�W%��(�x^�o���X���伅���Ws`iZmߵ�ȍ��k�����dE��*���*���{����A����zl� ;i}���p}��qP}s|�=���Vmv`���MY�S}�w�+r〽s�y���;�8�(����_��~E~8H)����Z�K�d;I|�ӂ� �:��n��q�~��`���s�{��G��k�8@spCn/4;��r���I�+�O�S�����+��D�A@�cg!��N���qu�.c/�x��r�z����Oc����Z�sM
s�k'^��L���m�e��i�-P��˃��A�>�"���2��oL.c�ՉC�7�Ɓ��>�c_?ݘ�_�v 0�J�普ȍ���%EҶ�g4ݘ?
zIBeJ��K�"?���,H%����=�J�b�a�=~��8��qP����B��mK-� ���q��z��8>Ϥ�s�����$�SI	3c����+�ÁzV�����O��lD-�G������^��gH^��'f����g�Ϋj�9-jF��z�spCnK[�k����a'�ON#��p���[�!?`�5�jd�(=�T��c#(Ju�PF~���8@_���A32v��Z1z_����H��r�`TGT�H��R@5݈�+���gIY��w�W䇃�B���pL�]e�+���%l=Dz���8�^y�%2�j�b�r���H�#����r�`��c�9{�9W1[��W�C�����m���E_Ы/!v�%�i��&~2���#���˃r���w&fY #�[��')$P�ӹ���oȍ��G�%ZƖM/P��i��XR_��ݐz�c
��?!;o'�WiO������Үȍ���G�NjU�|���2Tj c�z�-ܐ���6?�v��M�:���T�;ߐ8��3`ZcĴ�/���WE����J{x���q�ވ�Xe'��]�������;`��߃���>���c�Kܻ���>�iq����z�����8(~��J�\U{���I�IKJgZ�s�a����8�sqD��Pc�bv�h��c�)����tC~8��'bPm�<��owa��L3¾pspAn?������b(���δ�,�.7����Ͱjj#�0-�<�OF-�@,��=�W䇃��7NlU�$�=����������n���ݐ~#B��j$�&��^gi�^�%���{pCn�{ p��C�]XW�AG� u���������@>���	��:[�oq�]ߖ��uy��r� ����y����W%tFA_j�a<�nȍ��1?�q�/{���}��`5%YR��p<�|s�!��}�U"4���@�M�S�"rO��7���|c���n���0_�Q��'
���|EnL_���HV��X��G3�N#Q�Xߍ+_��Lu�;s�[�Ձ>'� ^èA=I�"�wk4�ȍ�$�c�\    Y	c�'N��VJ7~pEn|�\3p�Tz�kJ�G������h�aypC~8H�sP��ZzX��xb��-H�����+r���<�^�Q�wƔ�!�E�<�����8��a������-N�M�&Dy�N���p ��Uj������N���u��4���ȍ���+��j�N�~Q��#.5;뻳Ưȍ��2��'��`'q� Y:&��ލ�]�r�>�ZG����(��s��׽Z��<�{���8@�A@<{����H�?$C���w{��ȍ��u���V?�������u���njE��_�"?����,�Yr�@`2�$?0$�)Ϛ?lܐ��"!b��l&�J��FP�� ��n����pP��7
���q����4}�:i��g<���q����A��sR->A��X=�^�UvEnLoD�#�����/KF��d�=��a.���9���m�w�`��Q��G�ĖA�}�r�}���)U�C3�@��G�c�$B���\���L$����L��}Q3IU3�!�l_��$b�,�SV��-��2�� �E-߃r〼�wf�A�j)�I՟��-��g��w]��Ðb�8S�h�PT�����]]��x����p@��Bb9K�,׆<��H{�A��L7����N����Z1���T|�F`d����þ��q�|~A�
�f������f�]�spA~8�M��A�{�y��6�j4:C
��2�q=<��8��+�����vR��;f����Y=���q ��	�c��n1�>�IaO�H$�ErE~8��@W�p!���-p�MS��Vj/{A��ܐ���X�z�4�_�uF�P{�	�q<��yEn�Gr�Aͣ53����f�#ykM�֍7䇃�}���Ec���=)��a0�l�a�xCn�|ȃ�ġ�c��>T��.�P�������vEn��G"�s6=_�����}�R����nm���`~�ރ����>��/u�L� LI�Ѽ"7�π��=SP��W�1?6��ՐxY/ܐk��2����uՔ~���rɹ���spA~8X�n���
�I+�. Fr�]�7��A�_P�h�L��Tw��G��^�Rc�߃r�`�G�����2;�q���hQ$שy���Á/8U%F�4�����$���Z��=����8��i@��Co��n�?�=�Hh����r��c�PEL��aX�jue����p�(Ν�z����A���D!Rjb�t��[�(jV+H�8��|��q�}!��,Č=��g�Hz�v���~��� F_ĸw�},�������(��T�ͱ\����@-���Z�����Ǖ<�/\�}��kQ�f��I�5 `��ۄ�pO���@-���	�ʉ���|8ؼz0l=��<�!7�OBdN��R��Z�~ҒjU�:z|�^���8�v��1a�2'��Rܠ�<�4��z��p �τA������ǔ!f^u�����W��~� A}�,���/�bQ�������Ynȍ��U�$űg#�} �N�2c�Gy�-ܐr��+Ȉe-;I��(�����p���q���D��G��V��r�ɨ#�z��l_�J����P�qr��z��:�ϨJ�����ȍ�=]Y�JԹǢ��J��XEԊ�}��ޭK�"?T�����"�Ô��]vi}��	�?���qP|r)���jGӍ|�8I�S���ܐ�ǕI]�BU��;��IK��88<<��p��/��k���D��l�UE\U��@�/߃r� }L�e�$���g+c����О��07����>������B�����ĩWb���7^�Z�u( �a�Z��$�W���I@�i.ȍ��U��j{<�ZRK_Ka�H���ȍ�
��hj%����m�#c�vhXM]�������G,s�A"�l�2%��DF��!�wkq�ȍ��d��m�A��F"$_��f�H�<����8��1px�,3�i_لk���*=�����|#�:�JId1����4�3���D~8�~En��v)N�AB�Y���>��S���ci7���ǢK���9
��_�óٰƶh���7�.��G��̝+�݃�o��#��R�,�֥]��+���wK�b�
7/8׹��^���"7�Nu�@ *Q�V�}�8�ؑf����������ʭ�b���2|�U��g�	�ö��q0|�AB���l�A��q��!=���p,��p0��,,�3K�eF;i��.�C��m��p����8��E!B�}�v��}7���Z���|��r��c�g�6���羅m���T�;���spA~8X��e�@m��l�W0�OZ��r�>k��7����kD u�z�doae�Šs�ġ���>�+r��ñBn����-���>/I�giO�X&ސ$~NA���
�[X�Q�K=�������+r���Tq�(!0�(��4�4�4|���8��SPZms��`oA��ډY�QJ~9�rC�9��� (�a��ٳ�wn"~q��)��#���7��~��m����(��Qɰ�H��껺��8�^pv��Q�S�v҇�=շ�s�vx�����p����J�:��9(;I>�@c²&S|�&��8@_ؽ�sN\r��2�_��خ�����w9�!7>fʪ⨼w���I��$eSL����� %?[x�X�	�Z��w&�U��f�U�����"7��76�mo���W;�~㖑�'����\��I���EmE����k᝕#���Ү���;��V�1�.S��r�i/<���ErEn�x"�@3B����p+I��{���y�+r�@|<��k	)'�e�L?$Y�@����\��GεK,�:��8礜|UO�B�3���P�ȍ���(�9fTё�N�X��s�΁^�7�Ɓ_��� ��bMv����*0���9� ?����-s�	���$oiL.���H�a��8 �\�IcP?�|C���F{xo��q s4y���A��T��`ĎUoԇe���f��N-�a��db�XxZq׉*y��X��q@�h�Tf�?���&#��n~��p��~\�+�YaT������B�����qP>U0�)�C[�.���]$Y�Z ��7��� ��\#�]�o�26����R�-YJ����pТ�;�0jQ����Q��?���n}��qP�L�0W���;�t[R�L_��b?� ��4�!�X�z:������.geF�R�I|H��6Z�9C���!y�����8��,?X�&zzo��X��;S#]5<������t�/�Y�a@A�tNc��(���-=6!n/�[Gt�-�Y~��徱Ex���9��"->������À����90��z�D:�1<�(��o^ګ�=����������)�#m��q��f�aP�aS��֊�C�z�AݍrL�>���;�7��/�.Y�������)=�v$��?�xn߫����5��;fڞ2M�K6=�l�2[q|��f�a�:QYF�(�S���B{[���i=���7�����{�!�N��6�[��qG���}������nIrH?�H#�/�S�33Mǵ<���K?�ZB�RK;o�Q�$5��r8��,?���([0˪T��<XW�O�i��et����Z� ��#��L�F�Al�������R=�������U|:��q��;���?]�#H�_�j�y�sN�>S4f��'`���L�s�����v���!���0��n�=����A��e�@���_�=�
!%�r��3��|9g�=>g�1ێ�߁�f��@g�域�6�Q�x���E*�AX��KAZ�v<��!�F�A}Q�li�^����Lm��ϡIIc��q�b%�FA�!mG���B���P�D���3.l�I�L�@ب�&�r���f��	�Bc�\no1�۰�ɱ0� ��>���g�Di�C�%�&�����rHk�5��{����Q=$�y��y��<���h?w7���$�o    � ��l�>���O��@�k΄����PJ�Q���Km��Ǹ�F�Nso��/a�AXE��Iʘm��{���a��V~B�ҸN�U��`�5Z��6��/	���R[�D�����3a4A�!��P�
%��lor,�6y~	�f��ds�t��0� PS��,q����KM8f}�Q�Թ�ϛ���٤��9�-��/	��Baq߻HLO��5g�h��I���[-S�A�|	���E�3d.1=Ư!�F�����̥�gH�=_�h�0������;�:�� P�L�V��;ms���0����0#*a{	̱h6���	�B�˅%�!�����Km~f��J��y����!�F)ʣJ�b�T�!�F��M=�0��{8*�q嬶���0������_�7����4P�Z�jǂ��	�	�Ĩ��!̞#!�C�%�6��#�.c�3ꃐ�!�F���&tI�	�F��J�%�[×�:��p��c��O^"���늦�I�L?P�@-�	k+�ڸ��LmF�+�)�:9�C�%�&{sP[�����g�C_�|	��O�n3c�!��L���Km��"w�-���!��%���n��!�������W�?R�[dE�!�^k��|	���º���j�Cp%�F����dl#=c���+a�A��_4���,q���Cp%�F�ig��+1��I�C(Y����Ϙ���f��0��B�����!8F��s�q��%�C�%�6u(�1o��]��{��������Z��*i��/a4A( _��c_x�p��,���`#�	ƚ����$�o�-)�ɕ����Gn 8F��T ;���wQ���KMj�j%4N�'�%<�!�F�/%s�yF��
��/a�AX�B6H�B�x��u��؁v�i��#�_�7�?���`���u�z� 8Fԇ*�KZ}�V!�=_�h�0Xi���ƵO��|	�	B�Ekƀ[0�[�;��������LJ���\�a+_R�yq(yV��"�K��f�����{��dn��*�5g�h�@�����g�[�{���u�K��2�~��0� ]�BH�lMxj��!�F�������(4W���=,]u��~&c5͈�K��f��@�`��2��Dۛ����"B�`
�=_�h���o����lb,|��0�  )M(���'ѯ�=_�h� ���G ��#�o�����Uϡ���#�Ѐ�����t
���Lm~���J7δ���!�F���Y�8C_�,��/a4A�����d�Y�'����Km�.�((9��D��.����ҫ)6�M�K��f�� I�E"�TF�1�Cp&�&ƗB��%a��|	�B��D"��`�K��{���a~I�d�9K\y�{���AJ��VV�K���I�&�$�$�%��t�7�Ҥ���YG���	��j�!�AdN��/a�@h�Kǭ�!V�u����/a�Ah�<a�xf��$��!�F_�M�X+����j�(}i�Y9<�Kw|��j�B��<��̙��y��0!jgi/��b��{���a�V}Mʠ��.��=W�h���>��O�ߠ.���+a4B`}�ޑ���љ?��-�>y)�
B]E��&����0
?#4�����!8F(�����<���C�%�6��� J�NPS�{���a�c`��3
��b%�F�����so�"��s��2����_PkC�g���<��Pqc�Gr���LMJ�"R���a�=_�h�P4�ޣĒ��?g�h��u��J�<M)� �F���L8p���[�PE��mD�0W�g���~ �>Y"�5NZ�]Cp&�6#�Va�s��.��/a4A��k��Ȏ(zLu�{�����B�"s��[���|	���ɜ�i�!�y.d����$�S��mf�_�7�?ڗ2�"e&@|2ݯ!8F�Jz����d�+��/a�A`��2�cN�`{��|	�	��Ci�k"�PO��_�h��t�J����^$��6��i��ʭ��j�%a|3�@�A�	�:��G���LM��2�	a�Z~�@�A�%�6U7��tdl 2��/a�A�R2������@���LMt�N������P���h�!3Խ�8���j��о�T^���q��0� ���w�clk.ۛ�	:gi	B�i2�z��0� T]+�x��J��=_�h��t�4���~�I�m����-�-e��O��7�?&�n���Ǯ>`�tW�	�i�!��߼��C�%�6�r�A8`�2�/ �F�u�ڊ���j���Km�r��m��1-<�͋�q�(q�gv�_a|3�A�rA���#\��3a�A(�>�q��o
N��;�������å� k0�q��0� �N�$���0r��g�h�@u��1�^B���|2V�4cj	�Cw|��j��0�r�
�))��O�+���!��B����:Ew\	�B�ͫw���,J9�f%�F#��!l�1qa�,��+a�AHIw��0��F��O�
E�����Zv{w,�o��'���B�q?�
�3a�A��JK��K�9C���KM LeA�>�(�t��0� �R2�O*�xb�;���a~k"A;����	��9{V�6��C���,��u^M�@�I�߷'~o��v��0� T}�R8�cN��=_�h���P��̩���=_�h� �P�@�>���79F������"KZ��ݡdM
$�J3�T�O}5�@C�L�hV�\Cp&�&5��!�V����x��0� TP��|��(�z&��A�%�6}�ρ����'��C�%�&���@�~Q����P�*�}ڶ��+��V����is⎝kٚ@��	������O���_@�%�&[��i�p	Z�u�=_�h�Pt��`ɭ�$|2Z� �F���Θ�����Z�'/�d��Xt,�o� �v�CBN�!M���LmP��4�{@`��� �F����#w�c��tو�|	�	BBx�R�\��C�%�6Mϋ��f�D�>�[ԋ�|G��s��8]���a�(����]'dۛ�	'}�ґc��2˸��Km� �`��!�o�!�Fև*��5!�C�%�&��&��mQ�x��F��,���FuJ��~ 4��m�A����W�	���Y�PF}.~��	�	:˽�'�=���p��0� Ԧ��`�Qx�G����Km��w�(�����4Y���VNd,�K_M�@X�k����� ,Z��3a�Ah�3��1ښ(mҺ��Km�>Y�x�>v�@�|	�	�D��8���1�{����t�d��OL�Λ�~I���$A$��;x��~ ���Prq5�u�g�h��=\�gjC�c�|	��`�)c_i�i;v��0� }�B��Af��=_�h�KQ���}��c�r.��5�&;��+�����'f�R�X���_�h��t���!�\2Pl�\	�B�����+�U�9c���J�Zԡ4C���LD��+a4B}C���1�1O����|���j�k��X�L�@��S�(��~Ƨ^Ap&�6��P��T��q2U� �F���z#��E�̚���KMr��k� �#���!�F���f6|j_�����Q��OgG
������f�� �H��s�	N
�g�h�P������v�q�;�����T()!-^�lor,�6s~iY��Y�=_�h�Pk�m���F�ڬ'��I�jX�PZ���0��~ tV'K¡�kJ��	����̹�QwuZ�A�%�&;B�; �ڱr�{���������d��|	�	B�VB��8R�1�ی_
�e�+��)Tǣ^M?��w؎uƴ����3a�A�z�lΣ�T�l�|	�q {��1����J�A�%�&�� s���p�"� �F�E��BX���݁ZU�%I	OyL���c|3���/�	��XY�6���LmJѵ�P�
A�c�=_�h�@��#�p �Ӹ��Km��fX@���:~�|	�	��an�2�    ��a�38ܠv�!;dw,�o��'�G���&���3a4A_:n�̔W�+d���Km
*�9�����r��0� t}��%��B�i�=_�h�0�.�^�ƌy�;�5uQ�؞�kɎ�_M?P'iT��7%ΐ�!8F��ǢM=n�\�����KMV��L�:G�� �{����K�\��C�E��+��0� L�m�[�<�:M$�����?��	�q?�W�?$�r�"��t���>h���Lm��s�xΊ�"�x��0� 0�Lii	Smx�98F�L���e{�s��S�C�%�6Mw��sa�<�sɡ�j��YhŒh:N�~5�@�A[�����}�t��0� Ĩ��l/��8�	w\	�B�7P�[ź���_@p%�F��
�rH����+a�AHI}$�^ͼN��Q�5��;�CgǗ/��-�j8����pT�5g�h�0�T�0!s��G� �F��d)I�+r�I��/a�A�z%T��r�����/a�AX�V:no�d�P��3����v��{��L�@Ȱ�́��v��)���Lm�.����n=���|	���	�� I�{���a�M�s��$Dȶ79F��U�d�=��zN�ܘrRW���~ |�m&ؿS&P=M)� 8F����YG��s����!�F��u�1�,��!�F��(�2�2�Pr�{����nE�\ s�$s2&�[����=��t<>���a���x3�ƙb���Lm��>��W�@�#�W|	�	B�z�Ǆ�y}��b%�Fғ>���'9��/a4A��BVZ]54����6u���gy����0�W����!r�S�J���LmX{�����?M��{������e�e���=_�h�PD�@�!K�xZ�A�%�&���R�gv`��{�d�ϥ�ю��W�Z��B�G��9��^��5g�h�0��w�6���*�79F��t��k�:{�}�C�%�68���X�\�� �F�Iz,w@�N�0�..l[Sg�yG�G����0���q�Sn�g���3a�A ��Abc �_	΄�aE%�$uN�;�:��w|	�	��ҲwX�� ��su��0� ݀�	�C@����J��T��]
Ϸ�o� Hй�G'��+�Cp&�6E_�=�.�,�'����Km�>O�c��H\�|	���󄉉rY���A�%�#��w����E�'�{l�ToIB�i�~�������C}��̥���+���!FV+!#D,"Sά�;�����/m�z(3R��Cp%�F��HT�En����Ap%�6)���0έ�'gi������%!�.	|5�@hC#R#I����	���m���b�H��=_�h� I�O@il/��|	��/�R�@���!�F���i#!�V�S����HZ�"i��;�|y5�@@!��qƙ۸��Lm�>c<h�EO�{����D]��m����?��_�h�PX����Nu�=_�h��i#��3*�G���1*(�G�쌞�J����P!�(�s�5���+΄��F����4Z��|	���'��a���{������ڡ�(D0�|	���2>u�<��.r��y�-U�Rp�����a�Tx�
S[���3a4AhIgw5��LAZr��0� 4�6���\�+��0� L�6G�8W��Ԋ�|	�	]��d<�����q�)��0��M힅����t�V�g�����3a�AX_�'`i�3Aۛ�	B�̹]�&eF�6�C�%�6ؕp,�i��a���KM8��	 [����5��x{p��+	��X�L?�v���1-���!8F���f�D�ci|��0� HU�OS������0� ��=F�)�"@���Km���"�\���Ѵ�.�q;�z>c|3�a����5LX��i"q��0� �6�.�RgI�+��0� t]F����3.�_�h� z��փg޴���=_�h��P����ђ0~��AO�e͈�qw�W���;n��q��kk+_Cp&�&��b�ԑFL��/a�A(_�ha��K����/a�A�z�p� !��r��0Z ����y�f��"_Fq*�q$�M$^M?P{� k�B��y��0� }��0W�V�Hp��0� ��0nG���[/2�!�F���ܫ�\�IՐu��0� |I�]��wH���C��V��?0����a������Q[��RRL�qn�|	����a�I�}�x\Cp%�F<��<r^�b�r��0� @ �;|�=��%�=W�h�Ъ��������<���f�q䂥�D���f��0��m���)�k�+΄�!���qԚc�����/a�A������j�X�=_�h�0�#�3/�⸇�KM�W�!p�[g~�6n�g�z��Ȃg� �1��B�u����,{P�k΄�a�z�.-B�\�=_�h�P!�O�>����&��h��4����������0� `�ð*�^��pv�:�"�?�~�H):��~5�@(:��d~f ����3a�A�:�uA�0�~��0� ��͐�3$՟�+�����Е!�v���Q�!�F&a� ��3����e�jƜ���g����
I7�`�{w�%��2W�	�B���Nb�k�d{�ca�A�'kb�ȜH��sp&�6�g�7���< 0�C�%�&��8�>#I>]�g�E-����;4��q�W���!l�:��d,�k΄�����QJޯ*��&��h�PA7������%�v��0� �����)���!�F���yp�&�B���9�0��F\	cw,�o���Cn��mM���Lm��c̸Î(��6�A�%�&3�<Fx�Q���+��0� T��B�wH��c'g��/a�AXz�PW(!��0�9��	܌�3>�\�
��+�!���Gq��kW�	�ʗ�hr�?I�|	�� �9�l1(	2�q��0� ��J8`�.q��|	��(��,!K�9O���YPJm�g-�s����g���Ԑ�g$���L-V ݌	`ԑʒ���y��0� ��/_8@�#��3�C�%�6�KF뎠Z^r��0� ���O���,P?[�Q��
�Tg�eFǗ/��4�l!�9��m�5_�h��tO���	k�D��+a�AH���A8Hk��ɯ0!�(�9@"\+�r:i�Ap%�F�e�,bX��ڲ�yS� r;����Bǣ^M�@����B�"����3a�A �� �!��s(��/a�AXE}A�*���� �F�::I�1b�T�=_�h��A_]3a�᧫��_�I=��K�jr,�o� ��z6��;�Ӆ�
�3a�A(I#��_��=_�h����d�D��b%�FI�Y��3E[���KM*�N�^f*���E�
z�r��z-H�s�Ϋ���#�f��;x8U�W�	�	�o궞K-a�C�%�6e��'���K����Lmz�ӄ!����/a4Ah���@�QC��t�9T�-�ʣ$�\k{>c|3�@h��D�gD`����3a�A�����{8�u� �F�M9�}i��l��/a�A�_b!�ȡ��;���Km�>cLXb�m�>N�@]7mL�����g��������y��k�uz�]Ap&�6�O�&`�%�B���_�h�0�X��5�;Ȃ��|	�	ݼ�r�R"`�|��0� 4Q74�m�NJ����{�7̱7YqG������a�n�ˋB����q��0� ����ci1CȒ�!�F�=U��\��|	����#�ĭ;���af�VFH������&���T�͐��/��M��"�犲����3a�A��[�Ǡ���|	�	�*��Zȁ�$��X	�����H,c��!���!�F����K��ZC)��(r?�b�bP�ga|3�@@��T 2��!�Sv��0� ���}g�RF���/a�@������LI�Ud�{�����	���r	��C�%�6S����O�u=]�������˯0�������nL-     U�y��0!T@�#��V���J�X7��ۀ�v���_���JmR�SK�I9H�{����M]�\>���EJ*z�,9Wڑ�B���f��0u?F.�YJ���LM �󄊲�(홠z��0� �|C0I�
�S0~��0� ����T�$��+��0� ��u�� ������A򌚄�W��&����t�kG�0�k΄�aꡒ�Ր*Dj�|	�	BI_:Rɬ��j���/a�A���am�0�Z��/a�AX_&��k-ȟ&RX����%�Xs��:�~3�a��T�>b��_�k΄���{�}��+��0� ̬�aa�1?3��!�F�S���)�9��/a�A��e�r�z�Ԏ�����z/��GO�����a�T���@�}]Cp&�&�҄$5��)�̿��KmPO^8{�:�O{�;����� ��C�Q�{�����\�6�[ꭜZi���O�)S��x�˫�Y��A�'�H��	�	B�r!��:���u���Xmj�ɜ�w�Ҋ'?��/a�A�:q�rn�,3�{�����~( o�9��v.d����C��[�|��f���zJ ">C�k��g�h�0�K/��?!�1H�!�F��.rɪ+��:�=_�h�@���R��CO���w|	�	��?����$=�39TƗPs�@)%!ϗ/o��|�{OY�l���3a�A���GIm�8��/a4AX9� *7�y�O?�W|	�·����޾j<�� �FIz�����S-|�q��M�~��Ď����u*��A����r���Lm����~[�=j:�� �F�BԽ�0� y�t�98F�2�C�����̿�|	��/�C-�c|޴�2$�mwbL����������X�-κ>G�w\	���Ax�Twu�\	��бC���B|Fl�C�$�F)��aI��bB���!xF+�6�$%Q�e��M��&M���{�8���n��0Q's
T����\��Ap&�&�t�������=_�h��_�"�B
m>��!�F��o��:��/>_�h����ML���ۼ�҇���_���Y�L?�����X;|Z�Ap&�6S�E�pbo���&��/a4A(_�C��a�ʢx��0� |��ҙ{�ԅ�!�F���Bi9+�-� 4d����6x7��f�1F�QU���\��	��q'V�Ĺ>I�|	��u�0KK9�r��0� `"%[7��eRͿ�|	�B�[d��-����ao�M�[�OO�$ͱ0��~ H�r��^!��k΄��e�:��L�Bϔmor,�6M�E�^�gz�x��0� L��(�H�!�C�%�&T���C�S�1{E�v@)cN�:.	|7�@����H�>f��)���Lm���?E��;��t�K���a��o3r��Cȟ�ʗ|	�B�3d'��[o��!�F�!f*�s�=��J��tH�8�g���f����5���j�Z�k΄����]4ۜ�	_B�%�6K�'����	��x��0�  ��iv�X"��/a�A`=94?��d��a�T��{��jt,�o� ̠o��1=ci~z��Ap&�6Y�@�'�5��S��|	��N������|	���r����smֽ&8F�U����`h%MX���:B�M�J��~ tM�i�3����3a�A��4!�^<B)��C�%�&�u�3�8Jc��|	��&Y�Z�0�{���!��w��R�-��gw�/e��+���w|��B���+)��B�k΄��u�� ���x?v��	�	��tQB�)ja�C�%�6���@�!��W�=_�h�0��T)5�:2�O�Z��I�g;���V����u~��6��'�t��0!T�1��..�$�+��0!� 7%V��B�r��0� @�z´$�����J�p)a,�K
O�,��,�ɉaR,ű0��~ ��;W�Rq�3���3a4A�QW�W��)Xu�=_�h�PQm�CH�uL��!�F�*�$h��@��q�� �F�� ,�<�=}��E�!H%s�����w�_�EܱtX[6�!8F��%�K<�R)�|	�	B�z%�r{���|	�BՉ[KrWi�|	���#�\0����Ihߓ1八���V�����q�и��LmZ��E�s���!�F��[�vV&@�X	����%P+!�S \���B��/a�A�z0��g3?�U]7�(c�����7��'K���Li��3a4A��O�gُ���
�/a�Ah��b�Pe�����Km&}���"����������]@%i2����q�{J_���2��8�����]<)�<6���9�@p&�6KO�a�!�+�~��0� ���.�d�ź���Km���g�c��+��0� �/�͙a�jo��^�<�Z.�|.��Dh���f����4��RS��E�@p&�6��fl����g��/a�AX���
��^�/ �F���y���(q���|	�B'�q�g���u�v+g�9��8�7��	ޅc�e0�B��	�	��:]gI(q�L��/a�A���%�DèK�=_�h�0u��*��Rj��|	�	��/I"y�0J��m����
��Z���<�7�������T=���!8F�U�a�]�<���!�F�r�S9b�@���+�����[[�Fq��rT�!�F��is���sI��;���T����V�4�ү�E�6G�9I�	�|	�B�'/]8� y��1�Ap%�Fk��a�-�A��;�Ap%�6	t5\*���~�w\	����pNDP�|�۰(����0���� ��#U�
s�a�Ӆ�
�3a�A(I-�)�{���=_�h��5��s�Kۛ���C�%�6�m%dis���|	�	BF�'�5�P�3)e�gp �0��>�ca|3�@`�'t�q�g���5g�h�P���9��s���|	�BA}���{����w|	�B��)��*��x��0� l���PͰ�6�r�T�N��o���F�3_^M?���F�;�k΄���>T�$��Vy��0� ��؁86jm��#�;����<F\!�g�T�{���a�˗���0N ��u�6h��4Ɛ<��-�
�ʕ��+	b���Lm�����dP[c�C�%�6]w�E����$��0� �>YS�Ӷ��=_�h�@��6��;�u|�e�V.9� �������<�²"�E��	W�	�	B�zy����3�z��0� �����R[���=_�h��u2'q��1e(}�C�%�&[ �C�% ��Ę�7�mT��A
]VJ�8�|y5�@@MJ��!3ۛ�듗	��i��!�F�t2g`���q��/a�A(_�9�+����+���a}�+-c��w�}զ��r�@*����������<�	O�w���	�fa���KP�!�F֭�b�T{���=_�h��B�E�l�@�{Mp&�6]�"ܟ.jI&MX�-ٱ��eB��J��~ ���!gl��!8F�FE��u#� ���Km���E�0�����s��0� ,}�^d�۩b���/a�@��"Z;K8S,ȟ 
��-&�y	@�~������Y�8j���k���At!� 2CM�g��+a�A�Yw����P[ ^�\	���Ҝ%������JmR�]��%r͵�6�WVoz�!F
����c|5�@�U�,F,����T�^Ap&�6]ϐeL�9RX~��0� +��KD�'��79F�]���=�6pr��g�h�0t�p�����"��Z.Odk���q�˫�9�1"��`�R0^Cp&�6�)?a�J-� 9Y�w|	�B���j�m�h{�ca�AX:�/�X��N��C�%�&���6��GK�S����\�����˫�/@e٪��L>C.� 8F��n;&��=���;���    aI:]��{)��{�����ی,�Q��^�	�	&]����s��<���������B��1��~ `Tc��+FZ+�Cp&�6_.d	�".:3d� �F���C��^�ֈ�|	�B��HN�M��^�w|	���õ��ӉJ���|i4��՚;"�!���c|3���T[�`�(�bLt��0� ���)e[�q&�=_�h��u���N;p�A��sp&�6Ru>��uA���!�F����}��(��������ɏh�^"���W���O�+�9jK'��
�3a4Ax�}��P!l��C�%�6ET wT�c��3>��/a�A���'�/,�C�%�&#��TI��[>y��K{TsGڱ<5ӳ0��~ �>tH�{��{΄��u�����g��(�C�%�6�k�`�Hi?�	W|	�	���K��AI
#�C�%�6C_]������&��&H%'ޖz��L�@XQ�S�<d��u�
�+΄���tc;`T�v��0� �.kkj)ɿ��+���AX���\QBk���XM�����f_{���$���0�0\��o�CG����+9M$� 8F��^	�L �ܯg�h�Pu�V�����y�u��0� ���c\�X�c?W�W|	�	BL�G+K��Wؑ��,i�(�{M�C��q�˫����8G���h���K�X�"��0ۘ�.��+a�AH�t(͑����I뽃�J����nHy�J�P�=W�h�0�Ak,=�R:+!uP�9��9/��;�7�? ��&q����q��0� �Nb h�/Sm�{���a�n�r�8B��J�%�&[9��x������=_�h��t�c�����ޔ���wdс��Hǣ^M?f�c�p����Z��!8F����˄:�H�]8�w|	�f�;�9�ge���Xm�[:K�1p�R��/a4A����1����yӶE;,��=xm�j��@Qw��!
����3a�A��u��K��I-��/a4A���6 ZP�Z�|	��z�b���~&�b%�F�ne��R���^�8tsg�-�z�q*�o� ��G*3W���|��0� PP��s-Ef�����/a�A�:�e,���O+�;����R��ȹ�t�3��s�%�6�J�<���s��ݪO"C��Y�8]����Kǭĳèi��}��0� ���4$�����p��0� �N�YiIo�
�C�%�6S��Tٚ0"��~��0� p_r�뎟8����_:\'�8��U�J��~ t�ъRrx.ec�k΄�A��,q���z&��A�%�&#��.�K��p�'�A�%�6M��b�fh�Y~�|	�	���Ucڿ��j�x��KA�&1�Y�ca|3�@(:]�3Ik�f>�j� 8F����,�	�!�F��;x��:WY�+��0� ,��k�[��⿇k�A�%�6L��9��#��j�4���"�p;�3����@��MROc?�_Cp&�6�K� �ǅ��|	�uu�R��1��/V�/a�A��ȵI�Ux�5�5��0Z �P��w���B�L.!M��v���	�n�����}5�9	+�5_�h� E�m�a��j=�	w\	�B�m/�u�Cp%�FMw� !�*������0� �/ͫHoY��(q�T�.)�9�z:�	ޯ�e*�Z�v�N�B���Lm�>O������کw���Km$�-%4��s?#�� �F�g��^�L1��`{�ca�A��dmGir��B� ��Bз�ɥ��������t�f�SH��!8F���6�$�e�h���_�h���X�̵͘@f��ɱ0� ��0�z��|���KM
F�'0�ZiG|�9K��ep[E�O�y�����O������k΄��]�0�%���1^A�%�6E�E�R�0����1^A�%�6�Ǣ�����/V�/a4A���"+`o;��~�	����ઋa���ث�B�m�
�s�~��0� �n;& �7�J���/a�A���f��
e?��/a4Ah���AD�A��/a�Azw(R��?B;GL�S˓Jp,�o� P$u�L�=�R�ӏ�
�3a�A���S|J>p��{����u��g�C�3��Xm���̭ѥ��0�!�F��zV��&��4?�k���m|
�������a����0� �k΄��i֭Z�s�����/a�A(�<�'�B{s�|	�B�=U2���\�!�F��t���u��S=�y���9�mIq,�o�U�H)n��B�+΄����q�W����KMf��	K(����S+}��0� ���Y ��c����_�h���F��븣�VN 5��]H��\;��X�L?�[2'�Dh#A���LmV��D0�5RL-�=_�h� %�(g�\B�s�C�%�6C��ul�?)��|	�B�_rz$̚��d��P�t�����6�8���j�B:�q���rB�+����C�+b/�~f��Ap%�Fk����L��W\	�B�:q+=�ܣlw+��+a�A�/�IĐ��LgVM_���'W�c���f��@��L����^Cp&�&94���ؑt��/a�A@�:�r��F���Km$�Zi`�:��C�C�%�&5�/����i���M{���ۛ��z��������|�&��qo\�!8F��S��Ķ�-�C�%���k�w�C��62�� �0W�ƿ�� S��e����������B��:�A<��$%����jk�S�3ħ��j�c�mQ���߯�����6!��v���XZL����C�:���)����Q��`��_ӷ������S���f���H�0�(��d�>��7X,?�,��C q��X�	c��m���?S����_b�b�a��Z��B�s��M���C�kP�M�������Z"���;i�yӊU����>��L��0x��0��<=�
��ySE�P��.䧆�/�����[�c�+l�<��I��
3���R���������D�,�O��H~޴]��
��^G�;��7�����|h���`.MΛ�To"I���F2L]�����u���x�k�ٰ� �����?��pn՘��o�?�>� kB�=�g��zIu���j��%�c*e���u�T�v"���e�9�_M|��0XCm�`�M���C,z�A�^)'�~}�W�?"����VTh���M1��5K�)�����7�nJ�
Ȁs��y�]�l��i茎�W�?R_|��*�c���U���'� �����à,�K���>oJЕ׽c�QW��u�f�a�������j��������` ������H=����CK�����$�<�Gs����à�������� �M´w��jR��,?X�H ����-�U���K2�<�%/��X�C;��7���Λ����0��j:f�b�aPY����"��o!�t��C]y��i�~�Y~�.���Tk;�r��hn��e�����7�?J��%3`��rD���J8���G��d�����c�>���#EZ;�X`*P��)������ÀQ}zN5(t���%�޻���yS�q��f��AMC�(I��6������i̖W��t�o�M>G�3��9ԟ}�����sSJ[��ʛ����ODΔԙ�y�P.I��L�x^/���1��K��`�g��}��rp���XF)}�v�WJ�	B�z����$3b�� �6�y;���d�?���Rr�L?X�H��)Gc������
�GB����"j�|��� �/�� t}�	w|	�B*CmB䰥��>�A�%�&=�q�5g���J��[j��T�����V��0��~ T��|��4�7�	�)��Pal?�r� �F�U9�v�Z�ӹ��/a�A(�oJB�;�n�~
;� �F��T��eCྜྷg>~;�G��`�f
���t��    ��0��qr�:&�k΄���D]��#�-�r��0� |)����1&�q�� �F�4�ƕ �8����KmHO�B��B޿�Λf��=�DiHZd���K��f��0Ew��-���y�g�h����x�(�!4���KmP��B��3p��/a�A�K�S���v&O��;���Ar���D�������BM.�2pk�t�������tߔ�!ז8�5g�h�0���PS�;�H�|	���{$<�^�Y�!�F�j�dh0Cn�����0� ����&"9�	?X7a[���e5��c|5�!fP�*cC���/a4Bh�4a`�
�5\��+a4B�S�Y�a5����+a�AH	U(-0J��+M�{����뎵�Q�MR$�O~����?�����\O���f�� �Q��O�!8F�zpd�{S|
mor,�6_F�`�V�Y�!�F�9��'p����r��0� 䲔&�pC��E��s���U�x�g:��j���Iy�$�E;��q��0� HR'/�#K(�t�!�A�%�&�N~���cLG9�m� �F���"�f�%Rf���/a4A�Q�'>��X�9h�2���fh��(і���������x��o.����3a�A�C����dR���Km����Ҹ��!�u�98F�A�,A!u�0��/a�A� ����4A���m�18����������Kce
=8�	W�	�B��k��X� h��/a�A�:E�iE�BZ�A�_�h�@A7kݞ�T�+�C�%�6m�C���r�x�������� 'L�gG��~ L}Ƙ ��i���=g�h��ST[dڡ�,����{������a! =gX�|	����s�gN,�-�|	�	��F^-�x>NE��J4����/x5�@��С��2�%��	��d}$�� s�}�|��0� X�Y�=��������Km��Ty*�s�w���KMfЧ�%(�9� jL=V����/Sg��$�o�EO�"(�A�)]Cp&�6��h�L�k���KmD��t\�3��~<�+���a}5����$��� �F֩�Sd��S��M��ׂ�j���X�L�@��S�G���3E�
�3a�A����B��I��~%8F���Vc5��3�C�%�6���F�E�&Y��/a�@hu�K� �3�'Ic�ޤB1�9���J��~ �P�2�\i�g-\C�%�61T}+Ͳ*��,���;����u�8a/�L�t��0!|��R�s����=W�h���T�s��'?�ť��2���R
�'��~ T='�1M�ϰ�S&|��0� pT%�XGd�'g��/a�A�šX�����|Z�A�%�&�����$�0e�����/a�AE�,m��%����M@�K����\:�_M�@�1~���ȼ��~��0� ���B�oY�y�r��	�Bj%T��K�o����Km�*M�0c�ȥ`���KM
�{����(��9Ti�K-q��uc��q�����h*v(���\f���!8F��ri"�D���C�%�6E�i�O��r��0� t}��X@���|	�	&}��dtlk<	Ο7�/��I��G�+9n"�j����K��(d��s\Cp&�6C��5n<�^���/a4A�/�[�S*�#��=_�h�P�59�5�n�@�|	���U���=�'�j$:��g�O�T	��_M�@ؾ����͝A�,��@�1-��a/=��	M$�G)̛|KU�J�Ryѩ�6a�};�Fk�Cp&F���q_�^��M��h����p�aΑI�=_b4A���
��B���?\	��h���f	xκp4'N���7dY���ib�I�_K�A��t�J�XvxMx��m�>5O2������/1� Pҹ�$H;^��́���K�6K�	;���ib��{��/1� ���.�I��u ��[mIC�9���������u
PYa�^b���L�&3�RI MYc�j�&�b�A����D��',���K�6��	S,K��!��	�q'�c_�$�Cm
�G������u,Ư�M�EKPV�O������31� ="��ڦ�9�{��h� �+1��ʪS���+��h�P��Z�?������/1� �̐�\z�ʣ��@	閷C:��I������B��~	[�cE(����u���өv_�or,F�Q_�@�Q[���;��h��ރ�!J���_b�AxiY��ɲ]1{��=��K��N?�9-5��/�K?�ncN�\Ҙ� ]C�%F�YW�sjOEW���M~�h�����	�q�3���Cp%F#���l8 �����Wb�A��kz��1���O�;nPa%��PHt,Ư�}�͐�@Yr��31� ,6�H�0e�Z�!��	B6G�JZ-r���K�6����Ȣ3�}�c1� �n@pD�kN�v�/��G��Zv\��������\)���2��k��h��Q���y��/��|��a�3P�2��x��M*=^�	0\�=_b�A���Xh���="��_��c�!Z������E=B�ԌE���!8�Bե�e�����O�{��h����m�2�'帇�K�&���TA^���)�C�%F�mH��.�RX2��ڎ�ջ:�X9�ӷ̱��~ L}�H�=R�뼁���L�&=��pEھ!J��=_b�A��4܄�c	B*���_b�A`�b����4羆�K�&���ڒ�S(�u8b�wcƙ=��t,Ư��[5Y;���gb�A��P��4�~��M8�C���
;KW|����=Ɖ9C�58�{��h���Q�:Xu*0OEk߹����Vs,i���u>�~ ]�N��9y��mHW�� ����q��m��v�D-�3-��/1� ��^Z.9 @�w�31� ]ъa�� �`��)ua�~���1���k�?륬7	���'�y��m�>+�0'���|����i�	#�^v>}��mD�+� =O�\B���K�&�P���ma�y&�w)���s����б��~ �>!;��3v�}��-(d=/2��N�Jb�{��h��_����D�8��u��m������S��t��M"값$=##���t���X��*�3LN��~.�@��w�l-K���/1� ���©��
�{��h�PA9��D��g"�Wb4B����%�Ps�-���J�6����4n#�)ᣝV*{n�F戌�x�����/as�Z{�t6Z� 8�� �th�3'� �or,F��ҭ7Ka�(8�=_b�A(/S!��Z�q����K�6�^��$-�RO+B�/-}��;ɘ��q,Ư�� ���-�\�`9�j� 8�&�t(8����+��mx�+�2d���b���K�&5�/J�'��S��/1� 4Qr�$2��6S-Q�3c٩z^ܗ�T�k��ұ�-�yH���L�&:X�;o�c@�}�c1� ��G%��%���|��a�[y��֞y�;KW|���Uݞ��,�f+�8aG��i���}6�M$>�~ �>	��܏��\Cp&F/�>�4��{��h�гn�'�S�u�p:s�A�%F��|N�0�2�!��	�T�vLy�" ����o'@��vD�O�|.�@�饧J��v� �H�gb�A��;nI��,��|���K�6R�˗�t �gn��t��M8]��;�\;�R�!�����C�yjl��s;p׍\a��3�l��~.�a��o�R�>��7����̗n�<[jua�{��h���	���Z�E��;��h� /�ͼ�����7Z� ��	¬z�q �TF�~��1�~C{Z!D��g�|.�@�>�Ӣȓ�!8�	�
]�c�B¸Ρ�;��h��R�V���!�8��/1� t=lB��<-�!��	�D}�2�������.v�^M3��/_K?�~9����N�79���c�k�𼄊x��-8D�о@O����L�6 �  �����3;6���=_b�AX��}��{Y���hX���<`�y�����s�?t�6�N�W�1�5_b4Bh��tE��ֿ��w\��a�l�a��	<C��!��BJ:լ�F ļ�!����D�(��q'�[�z)q{��W�_K?^�����{#w������nT[�R���>�!��B׍jיF-8O��_b�A��B�g%��|��!#��wXب	�)����3Q�:W����F��K?�nT�$	Y�$���L�&%��D�������!��BՓ>BlT8�{��h�@��@a�er���K�&t�@�z{���T�p���%y��gϩ������v9�~r\Cp&F�A��_b��8�{��h��QOk�g��x��m����a��R�?\	��h���#2K�"Z'bDҤ r�3�p|$�s�?��[o�<b)T�/���L�6���'{�#�:�;��h�0Po?ɜa'OO��=_b4A�Qw�2p��<�i;v��mzQqZ�)��gS��@7��%���=Ư���+y�H�����r��M(G�J�r��c��/1� 4֧�w1W�N	�_b�A��	kǋ��]��/1� p�z��Pͫ�8Nw���N�y��<�1~.�@ =��~r�4������h� �]ݣ˹xI��/1� ���)�Ku���!��B/Ektڎ�A�%F��R�+�S�8�3߁�|��1F����{�_K?��n,��Yx���31� ��^�Ls��W�r��m�β�S�-O�꿚�+��h���R����S��|����Fd�Qv9�@X-������v�]��k�?��g���
m%��31� }�#T����r��m(�Trl��<��C�%F��^f���9�� ���U�TiO+��sG��a����P�~�������T����5_b�A؟iE���������!ϗw�O�+`��Cp%F#�W��R��x��mR���Ր!��q=hV��i�)��T�s�B�z{Mx�!�H��31� �<Rm��j3����!��	}τ�]�Hr�6�A�%F��ۓΝ9�}���|��a�́B*b�L�"�]w� �O�ZwtYx.�!'=n�\F삶or,F�;K�L�f͌�|��a��?�A"�gZ�5_b4A(Q�ٙSϵ2���/1� 4����@
-�S�6J!]�i</2x�����a�8a�B�����+��h�PS�]�X��'���=_b�A�������K�%�|��a�b΁��^3�Ӏ��/1� `*X�<Ƭ5J��O���ْĖ��@\��k�U]�V.��tỂ�L�6���'�'%�_b4Ah�O���w �?���h�Њ��l3,Z��{��h�����K�1���TiS7|�)f�_��h�_1~-�@(��H��c�9�5gb�A��6昘�� ��=_b�AXz�!��0�(�p%��	����3�.�2NX�|�����
��������,qƔ{�O����K�A��	Y�g�����!8�By�&��3����|��m�˾<r�7̘'_� ���҇>:��cI����/1� ��/]�`����S�;v����>�4����ҟK?X��{:�Q�7J�x��m�_ڎqZa? ��{��h�0��rO(e��+���|�������&=M���K�&+�`����*�	su��TS�yg��#Ư�U�Ʋdh��5]Cp&F��N���2����;��h� AO�a$�M!�q;8�B�3_��!����{��h�0����ҩeؿ��M���Ɏ%�;� ǣ>��@�!��ՙ�+a�-]Cp&F��_��~D怸��=_b�A`�.0p���Ө��/1� ĠO�	qm)�79�'�������?��r�      �   �  x�͜On�8��y��}�I$E��2RN����Uy�ݓ2l$� VJ�g�����s	�8ߠ����fh|�,Q��ޒ���jy*#�B����ӛ7�n��c�Yכp�XzJ�C�� o�}��P#�X����R��t����Q��`��Wo��\J�7_t_>FnJ�7C%S���A_��;-I�t*`������КN4���r9:yCG�E-d������B�$jW�3�tŠ���txM�Z H)i��|]�N���ąN��r%�x3FE˩D��X��L/t�CMR" I>����7�{)I�8:�yt{_Ӊ��;�⮧ϧ���HsY���,W�-��etH2ނYp
�� �T|�B)Ǯ끶�������8:�ytb�}MG,A(�B�Og��K'���}�3�Ro�y���tvŬ��H�5�Ԛ*F�6���1�:t^yT]{�0"�Z�4�+ﳝscV���t��v�Mt>�}�s.��r]�a6�QHK��tʚ����Cz0��Z,�t���\X|�y���-��J�D�bh7u)B����B��N��({d;N+o�yЩ�?bE'YFs+�L4�ξ,�d:�uM�qnh����Bϥ�2�5�ڨUJq>�]^�d:=]Ӊ�C4D)��]^�l:�l�!�4�x>��,�ؠ3���}(ŧV=�x�ܔ�_��!k�sD�Qx1�l�U��1륾���=K ��"�f���Լ��R�`*��;�v\>G_M@_�?�G#j쫁��C��[��2%����jp��:�����L0?�,��!A�4g�I�\eg-trƼ��ы���q>�?�+��7^�[�2�Fq>�?�K�Q��,)E�������޹����C���|:��W�#��(Gi-,jp�oF����I�A\�ԏ`]ȃ�;�"�E+K������ @>�%�B]{��_�}�T4c��8ף�ο��#�`���t�~�ԧ��:�_���"�^�6���� ��:�_�N_��+`,#� ~;���裟Jg��@j���Z/=Z*����;���,������f�Og_�u2�Q��J-�r��$G?�W��C��o���B�ɩ!����/r}T0�o��d��[r�Q��Sx�e�,���+�y:1@)k:�D}��|:�N�L�>����OS�������)>�N����t��툝��S|�Gmp�M�X}H2���>����y���Te-y{��(UY�Y�OU~�w�s��A�Bڞ�M��O�8���޹_�漲�.龽`��|kg]���ݭ�mD��&�`�WޗI���<�'�qX�L����$N�S[Z�A�8<��3�Ώb�ytT�a�Km�>R����[�К?q��	�� �~s��6�\5�Z��{�w��H��?�����I�岦�,X�������ѱ9��蚎qzA�6���s>��NWt:u?Pr�<���s:��uC'�o))�;�L��_�O�ǰ�S)G�c&��`��>*Կ�g��2�ri"W�Y.�������a%Hц	���ΐ]�3H�g�#RZ΂S��կx.�#;�;�wWp:��?σN)k:�����Jc>�oU�.B�ŀk:�k�P�Ӑ�t�U��
�BiM�����):�η�_W�34l�XI}Tw�y>�oe���S�k:Ȥ c�O�[Y�U�X�k:��%�!δ�=Y��,}�ک����l�lĉ}�����%�ڐ�'�gmy������� p�1��馜`y-��u�Gu��*��H�Ir��z��6σN���SX��XBR�OgG��|:5�59 �&�c>�ݾ��x��t�(��o�t>�}�wN��B¾����4�ͧ���s&����:r�����Ήtb
iMG-���V�H����s&�ƛ�Ef����։t~Z�9��R�Juy[����t"���3�r�[�X�M�=�5JDW=����;'�Y2	��͉���we�J��'r�Ŭs�+�n�,d4Z��:�bֹt*��M��� B�8�Ώb�ytS�����pd����*V�[ց9ʣ4��jm�&7�$���̷H����mV@�;;�����I�ZZө�r��(ϧ���~.�
���; /���Χ���~2}֕?��FR�#�~��쫺�K�������a���|:���'������x
�<�����'�ic;`��i3m�GU������ׯ_����      �      x������ � �      �     x��Z[�#9��9E�/2A��(�{����sl���v��EZ.��n 3�!R�������&��͹^�l�6#�#���៊�R�z(V�[�"�	x��N�1>����{b��ʸ��T�$��U����8��>�.*N���s��@��߿46G���w=ō
��i����=~�¶��z^�� ~�g����׿PR"��޺�hݟ��v��?W���p!�	 �=B���8F�/E��R��M�jM1'������O/�_H������)�Y�3�;~1{lG��U�!����{�ߵ��Z�a����_��ԗ������\3�-TB��P�%��؊u��4����B �����W�X��9'?��v�~Ok�<? ~n�^C׉�n�/gݚP��[�,�p��^.]������-���k��P��s]1h��N�㰘?G��.�/N�hJ^��b�g��J���Q���/�ƈVI�$?	���
�A���i�Z��1���ȵ+�xCA�ش_��,Z������q�P:�� ��|�(%�4��6_$y�y��.�	M����DV�$k���V?��q}0�#�
}=߱|d�~������'��م��|�W�|�BuJ��n�!���M��R�V��?�>N鋑�]=�C�_	ɫtǯ�7����N���Nl���Dp|!H�&-l�g`'�Aj|��ʭ���ՒzГ�yc��=�̽ve�qA;�B�ޗS�u~��V�Bǖ�Z'�-��Oҹq��m�6�B̽G!ٌY�;��,P�s�|������X?J<ܷT�sg\J�1��^�M㖋��],��A�X.>�^��8c�ЫJFp�w�3F�kD֫����s���0���^�� 1'����wHg	��1�(���?��e+�ŋ�i��z� ��P1�6QLw�1hi8�)'����y�ܲ�-ǺH�b�N84�����:���fS�W���E#��y[e��Z�$��5w��ԡl,�"�(��z�&9��ߓ���*�����Q'���'ۮ�����Nһo{/w�g�4���n�ߟS9KrV�T�r;rA��6������������$���͂�N���y�0��g��j��u`j�W��rb{�����b�ڍf��6���6dDv)�,'S�R\-M�f_�Ei7U�%zO ����`�f��m�C���,�D�C,vR6o�ֲ7�Ӌ��K�B[x
1gwfѣ-t:Nsm��[�иv)�ç�G�?>:?��U�V�9�Q�o~�0(������E���'�(a3_�@���,'Hg�_�9���X�����֠S�<<1�.�B�{0KhE1��[:�ܵR�0jL��ٖVk�b�9](�D���s�-�"��c^�i�rӆi��d�n�Vr��`��wrDi�P?���B2��r�����9��^2�I~�o�/�k�w��<� ?�h�|Ֆ�_Ҟ7�!��@=_ⷘ?w��)1�Uz��r"�z���,��MQL9V��)g�+��T��1;]�<��k� ĵ18lJ��i��B�~4
i<�<��ZlQ��˻������j�iU���Z���R�i6�Bo�4�b�0#�`�����b^��Vl����@"(V*�ZL/�[�^��@��0/��-�{�0u�*����#0�<O�z:���r�;B��~�+<C 9�g�s��۴ ��6/�R��~2sλ�ʌ�#�]�w��6�S�9�vf�6�v$�-'Y��1}�������7u�<06Wz��?�w���AP��7�H�+!�������
~���×���0�f���$n��J�	k$Ӫ>��QZ�.�`u���Fm�m��_��(������_�[9R�,#_��m����4(��� hT���1�y�L7�؃n�Xw]Ż���������?��0��lW������yFJ��e��~��֭�>#L})|ԑ�sX;�r�!�!�n�7�i�ߟ0�}f��b�o��wX!�Pj������� =��+,��� ��_�T�Y�;���j�B�E�����z	K��� Jc�P�T�R$E��j�a��{��*�xC��B��Q�wŨmץ��).�����cɇ����Ԡ�-��o�c��كO��� ��<�3]�;%���^�|n�_a��	��|�P� �l|�J��y��8ɼ^��M�%ey�1�
.]�r؃���? q�����^8�O@e3��׺��O6�U��
ͮ׎����@�qAKWy������􂝈�E���g�,�+]k~�`���ъ���9�<�n��@�2��*�-	��V���$����|=<��Y+a�\d�1���x��p5⿱0��`c��c����͋�){�㷥>��#�<𫘋��p�1������3I��{'}�7�����"��9��Ou�;.��[2͵�^�?Y�q�v~�6g�Oe�Q���Sл�Q'��Nfu[��/���8����h�^��߫sn�4!�-J��ݸ��Z�����C�����f���c|���|����4$��m�%�)�a����Φ/�AOa��Ÿ����0��Ѽ�r|�����cq-ð�|2y�}#���um��	1�E� u:�����!��ٶ�*�A?�5T��*��9�I��\�#X<͑h� ��Z�v����{ü�����V>@\�"�g�s����-�C;y��4�'�E���́Tx^��J-쿧�^0���B�q�;|٠�-D�D�N&��2�rta�~g�1�� �O!��tx�xuf�8t�Z6��ZsT�-�����igo����K�����B�D�`��)F��������Dt�����<� ����������      �   �  x��[K��:�\ۧx���H�T�e6��`�	9�.W�ƀ�zݑLJ�'�R��b�M$�͹^��#o�y�wnc�ep5�:A�j#n�[�RB��^D����z�9�y�������8����<7��F1q����5r�ƈ�9�q�%��Xu��,x�XC��|�˺����o���ˑ��U=�����\5X�Ǣz-[�IϾ�񾧬}���k4�-)qc׫����=]��Hߎ�.a�I��U=7��l�K��@�c�p��� #G�F�ˈuTu�J��&%5�-����w�������B"J{>6���s̄��Fq>l�G�>e�EHk�\/�":���*M���u{�)���_f��=���X�|7�`"��;�[6�bY�P0�}+eFE�Gw�j�溋c9O���I�#�>í�(���s�i-a7��%�9p�%���b>��_��m}x&�{�ǲna�>�Û���\�s�(��Ǩ<� DE��,��eX'*�^@�4��(-��Cc>O���O���_�|��S��ĝi�`���E�!e�^�2�(e7T�\�F�~f�-��%��F��"GI{|nbM1�(9oW=�Ȗ�S�v���˒���rY/m�ڇcCX�˺�=}
3-f+��z�sY�M�֤��4a����6lWCRd��vDj��T�:UV�gy����Gs/�so{>7�"�
��41�����jJ�Q�p��e����y�4S��$N��W���6���!q��znb�̅��e)}��	a�͛����I�Ac��6��XD����ٵ�`���$s���^��XC�(�i�~�8�7dm��I$�%ddb��T�Dk�I;�u{�)�����D)�e=7���6.����}��@��Rk�����N��^���q��t���I҅���^}�� ޣ^c����&Vk��e}�yA�E�Oŗ�F0xQ�������gw�;��>y춼@o��^��X�"\K�w��Z1�V9��%��t���@��*C�C|S��`�>ٛ�-��$�+�sk Rg�O_YR\`P��mp'D�R�(�k�
:��$E�,���@�ŽC|9}����&V��(���|��^7�qV�H����M�Wܜ��p�6�;Y�-��'?5�����Ct�X��B�Ŵ~�e�1-���c]JA=����Y1�����cY��W��{J۩ ��v�����
qH3-�I�3y���\��F㙾br)1�^�$q��o�e�>�J�w�RtR����&��
��������3���a�y�zY�����X�zJ�[��'�����FN�|la=JqD�wFquJ���E�=��	:��Hm���9���p����:\��>�շ����L���E#�\�-�e��t�g�0����[�ӧ4����v��=���X'�����G�� �N����q�[�����ZU�-�˺�=|b�-G���+���㹉UBE%L�e�
�w<Bq`�!�(=�%���V��`����``/a�:=7�jF�g[��\e���CS'Kc,P1�����:�,�W�\�#���On�`�'/P��)҇c<6���iY����lG(�C�-������� �`*:ήu{��v��e�|F��M�:y!��l�i��g3N�o���R��_P(��d=&=e�-�ŧ9�Q��n�S��&V�ʂ8��i��AqG1%�)��ʋ��W��\�ص�pj�;�?>���WJ�r빉�U��L��� d�!�bA$��4.Uz���M�F��N ��g�q{$������3M{nb��J�������[,���D�,�_��b��B{na�`���ι�-��'4�Y�r�}e�sk�@�fz��}��'a%0��Ғ�&G����Ʈ�d��~��[��'�T����,�4�M��;؛-L�w�6�ؠ�C���	6�a�?�Rg�V���p8K�-��S��mn�2�����0Bq�Ps`���u<Y�+��2�
���:��y%p9��-�o���  �þ��&��A���Z��]��ȱ�[z-�b��=>@40T]�;�u��'�GF(�aϬ�&VH,_i��κ��i��[���(�^AP���`:�-�o�8���H�}b�5��v5�e�ḱsE�q��y�C? T*� ��e�Xϻ�[�?>����C��1��Xk��2��ư-�����E�'��>U)%�r�P��Zw��}z���������u*����p��᷈��"�V-�@P��.�Ԃ4,8h�B'ѽ��㓼	�T�3�}nb��o�q�;J��m� 5��Faa�iBX\@���h-Ҋ_g��^}��>h~%��ػ�ski�_���NKF� �#ϛ	��0b�����0b?��O�����S�>1�H�L��X;2˄�i��z,�oe�ŉ
�j_Z��D.��@Ѡ�ko�奝���I�WN�J�����X�q�-�D>L��5�m�AN^��=u��R*UWB2(h��3u����C�+&������XQ0}
��=�P��t��(��SZ*��[���C�B�%���`[��z�p?��&֦����j"m���/����ln'(��PW|�U\V;s���D_��н�?7��>��r��='����y�a���m]�vg�\�A��R�����-�A65ż��z	���$?�j�|YtN��;�et�����=�Gd�˓Q�.�k�E�"t0�;�?���T�<�޾��&֊0F	٧<�h~5botB#���a�c�Pn)�Cfl�5t�S���^c(��^>���!?7�JO�t`Y�n_Ɩ��bg���Zw5@����Ks����XS���à[��'?}r��e�|���?6�B��M����Ti����Q�_�Z;�뻪��*���d�C4��~/���?�鱉��������2��+!�wI�K�S���_sGK�E�?���B����+�������jG�����ez��s��D	�\��d���J̐��y�&ߗ�w���m����ߙ�s�6bAk�iup�������[�|>�n�����H@s�[�1���;'����GeJ����{�^*:��c�H��Q-B��C������,}Cy	�h�����(�wo_"�?-�	�w��8�qc�-��Gm��؅���9�Zs^���#������;���!�Cz%H�ϓ��&��������g���A�ȥ��Z�0W��jEB�7-����5�u>�b�o�'��Xu�5o�/�{��r�Sa
:v��Q�:ޙȑ�����ϗ?C�;��>�S�x���>7�Ne�]�[c�c͑�a��ČҚ=:���ܗ�а!8�@�r��[��'���pd6��ӧ�?��vA�EE���)�PN�b�,�()��xTe����Z�TO�{{��O!����W>t𹉵��D'��B]'HcE=���ВB1_@�z�����4���3���%Ŕ���"�>�OM��]?R���1⩳���R�1�w���/@�egsj7�\�&��toa���[D��]�S+�߫�,
-����@qͤ/Ώء9�+7���h�#XC�>9��������-�ܽ�\���{;� 5����lF����U�9���yu���'?@э����M�΍y1BY�ѱ������\0��B���h���?$@������~{�4I7폯�K���s����u�_��r      �   �   x���;
1��wq�>����������aB!��a���H5��f���@ٵ)j��Wb�!�,��5B �@�o�D�Cȕ���-�N��<������*ˣǽ	>w:�\Q�R	}��n��-NM���	~�ӿ�?)�����     