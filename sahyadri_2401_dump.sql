PGDMP                           y            sahyadri    12.4    13.0 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
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
                        false    2            p           1255    17592   create_address(uuid, uuid, character varying, character varying, character varying, bigint, character varying, character varying, character varying, character varying, character varying, character varying, boolean, boolean, bigint, boolean, numeric, numeric, character varying)    FUNCTION     �
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
   masterdata          sahyadri    false    9            O           1255    16441 2   create_delivery_option(character varying, boolean)    FUNCTION       CREATE FUNCTION masterdata.create_delivery_option(_delivery_option character varying, _is_active boolean) RETURNS character varying
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
   masterdata          sahyadri    false    9            A           1255    16444 e   create_get_customer(bigint, character varying, character varying, bigint, character varying, numeric)    FUNCTION     �  CREATE FUNCTION masterdata.create_get_customer(_store_id bigint, _first_name character varying, _last_name character varying, _magento_customer_id bigint, _email character varying, _mobile numeric) RETURNS character varying
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
   masterdata          sahyadri    false    9            P           1255    17280    create_min_order_value(numeric)    FUNCTION     �  CREATE FUNCTION masterdata.create_min_order_value(_min_order_value numeric) RETURNS character varying
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
   masterdata          sahyadri    false    9            [           1255    17158 z   create_oms_user(character varying, character varying, bigint, character varying, character varying, uuid, uuid[], boolean)    FUNCTION     L  CREATE FUNCTION masterdata.create_oms_user(_first_name character varying, _last_name character varying, _mobile bigint, _email character varying, _password character varying, _role_id uuid, _store_id uuid[], _is_active boolean) RETURNS character varying
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
   masterdata          sahyadri    false    9            W           1255    17149 o   create_order(uuid, uuid, uuid, uuid, character varying, uuid, character varying, uuid, uuid, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.create_order(_cart_id uuid, _billing_address_id uuid, _shipping_address_id uuid, _channel_id uuid, _payment_method character varying, _time_slot_id uuid, _order_type character varying, _fulfilment_id uuid, _store_id uuid, _slot_date character varying) RETURNS character varying
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
													   				category_id, category_name, sub_category_id, sub_category_name)
                    SELECT cart_id, item_id, item_name, item_description, quantity, price, item_image_urls, item_category, item_shelf_life, total_price, user_subscription_id, created_by, updated_by,
																	pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, row, rack, bin, ean, hsn, gst, item_status,
																	category_id, category_name, sub_category_id, sub_category_name
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
   masterdata          sahyadri    false    9            b           1255    17276 2   create_packaging_types(character varying, numeric)    FUNCTION     �  CREATE FUNCTION masterdata.create_packaging_types(_packaging_type character varying, _amount numeric) RETURNS character varying
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
   masterdata          sahyadri    false    9            L           1255    16447 '   create_role(character varying, boolean)    FUNCTION     �  CREATE FUNCTION masterdata.create_role(_role_name character varying, _is_active boolean) RETURNS character varying
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
   masterdata          sahyadri    false    9            B           1255    16448 �   create_store(character varying, bigint, bigint, bigint, boolean, boolean, character varying, character varying, character varying, character varying, character varying, character varying, bigint, boolean, bigint[], numeric[], character varying)    FUNCTION     +	  CREATE FUNCTION masterdata.create_store(_store_name character varying, _plant_code bigint, _ds_code bigint, _phone_no bigint, _is_sfs_enabled boolean, _is_cc_enabled boolean, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _pincode bigint, _is_active boolean, _serviceable_pincodes bigint[], _lat_long numeric[], _zone character varying) RETURNS character varying
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

                insert into masterdata.serviceable_pincodes (pincode, store_id, created_by, updated_by) 
                        values (__pincode, __store_id,  
                                __store_id, __store_id) ;

            End LOOP;
            
            FOREACH __lat_long slice 1 in array _lat_long
            LOOP
                insert into masterdata.serviceable_pincodes (lat_longs, store_id, created_by, updated_by) 
                        values (__lat_long, __store_id,  
                                __store_id, __store_id) ;

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
   masterdata          sahyadri    false    9            &           1255    16451 6   create_update_cart(uuid, uuid, numeric, boolean, json)    FUNCTION     �L  CREATE FUNCTION masterdata.create_update_cart(_customer_id uuid, _cart_id uuid, _cart_amount numeric, _is_guest_cart boolean, _items json) RETURNS character varying
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
							values (__customer_id, _cart_amount, _cart_amount, _is_guest_cart, __customer_id, __customer_id )
							RETURNING cart_id into __cart_id; 

                    __items_length := json_array_length(_items);

					if __items_length is not null and __items_length > 0 then
									
						FOR __item_counter in  0..(__items_length -1)
						LOOP

							insert into masterdata.cart_lines (cart_id, item_id, item_name, item_description, price , quantity, item_image_urls, total_price, user_subscription_id,
					                                      created_by, updated_by, 
														pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, row, rack, bin,
															  ean, gst, hsn, item_status, category_id, category_name, sub_category_id, sub_category_name) 
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
							cast(_items -> __item_counter ->> 'sub_category_name' as character varying)					
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
															  ean, gst, hsn, item_status, category_id, category_name, sub_category_id, sub_category_name) 
															  
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
								cast(_items -> __item_counter ->> 'sub_category_name' as character varying)
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
															  ean, gst, hsn, item_status, category_id, category_name, sub_category_id, sub_category_name) 

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
								cast(_items -> __item_counter ->> 'sub_category_name' as character varying)
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
   masterdata          sahyadri    false    9            >           1255    16914 $   create_update_delivery_charges(json)    FUNCTION     �  CREATE FUNCTION masterdata.create_update_delivery_charges(_delivery_charges json) RETURNS character varying
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
   masterdata          sahyadri    false    9            ?           1255    16453    create_update_permission(json)    FUNCTION       CREATE FUNCTION masterdata.create_update_permission(_permissions json) RETURNS character varying
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
   masterdata          sahyadri    false    9            N           1255    16454 *   create_update_slots(uuid, integer[], json)    FUNCTION       CREATE FUNCTION masterdata.create_update_slots(_store_id uuid, _months integer[], _day_slots json) RETURNS character varying
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
   masterdata          sahyadri    false    9            I           1255    16457    dashboard(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.dashboard(_from_date date, _to_date date) RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9            Q           1255    16458    delete_address(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.delete_address(_address_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            <           1255    16917    delete_delivery_charge(uuid)    FUNCTION     }  CREATE FUNCTION masterdata.delete_delivery_charge(_delivery_charges_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            G           1255    16460    delete_delivery_point(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.delete_delivery_point(_delivery_point_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            c           1255    17277    delete_min_order_value(uuid)    FUNCTION     l  CREATE FUNCTION masterdata.delete_min_order_value(_min_order_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            _           1255    17273    delete_packaging_type(uuid)    FUNCTION     u  CREATE FUNCTION masterdata.delete_packaging_type(_packaging_types_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            9           1255    16870 "   delivery_option_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.delivery_option_filter(_from_date date, _to_date date) RETURNS refcursor
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
   masterdata          sahyadri    false    9            f           1255    17147    finance_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.finance_filter(_from_date date, _to_date date) RETURNS refcursor
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
   masterdata          sahyadri    false    9            n           1255    16468    get_address(uuid, uuid, uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_address(_store_id uuid, _customer_id uuid, _address_id uuid) RETURNS refcursor
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
   masterdata          sahyadri    false    9            @           1255    16469    get_cart_details(uuid, uuid)    FUNCTION     �	  CREATE FUNCTION masterdata.get_cart_details(_customer_id uuid, _cart_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
DECLARE
		 __cart_id uuid;
         __customer_id uuid;
         ref1 refcursor default 'cartrefcursor'; 
		 ref2 refcursor default 'itemsrefcursor'; 
		 __min_order_value numeric;
         

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
 				pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku
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
        	pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku
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
   masterdata          sahyadri    false    9            =           1255    16916    get_delivery_charge(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_delivery_charge(_delivery_charges_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            ;           1255    16915    get_delivery_charges()    FUNCTION     �  CREATE FUNCTION masterdata.get_delivery_charges() RETURNS character varying
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
   masterdata          sahyadri    false    9            F           1255    16476    get_delivery_point(uuid)    FUNCTION     b  CREATE FUNCTION masterdata.get_delivery_point(_delivery_point_id uuid) RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9            E           1255    16477    get_delivery_points()    FUNCTION     N  CREATE FUNCTION masterdata.get_delivery_points() RETURNS refcursor
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
   masterdata          sahyadri    false    9            t           1255    16480    get_invoice_details(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_invoice_details(_order_id uuid) RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9            X           1255    17137    get_item_prices(uuid)    FUNCTION     _  CREATE FUNCTION masterdata.get_item_prices(_cart_id uuid) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref refcursor default 'itemsrefcursor';

	BEGIN

        OPEN ref FOR 

            SELECT item_id , quantity, price, total_price, special_price from masterdata.cart_lines where cart_id = _cart_id ;

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
   masterdata          sahyadri    false    9            ]           1255    16481    get_oms_user(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_oms_user(_user_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            ^           1255    16483    get_order_details(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_order_details(_order_id uuid) RETURNS SETOF refcursor
    LANGUAGE plpgsql
    AS $$
Declare
        ref1 refcursor default 'orderrefcursor';
        ref2 refcursor default 'itemsrefcursor';
        ref3 refcursor default 'shippingrefcursor';
	BEGIN

        OPEN ref1 FOR 
        SELECT o.order_id, o.order_no, o.total_amount, o.billing_address_id, o.created_at, o.updated_at, s.status_name, o.payment_method, 
		a.first_name, a.last_name, a.email, a.mobile, a.line_1, a.line_2, a.street, a.city, a.state, a.country, a.pincode, 
		o.rating, o.review, o.status_history, o.invoice_id, ts.start_slot_time, ts.end_slot_time, o.sub_total, o.delivery_charges, o.payment_status,
		p.packaging_type, p.amount, o.slot_date, a.latitude, a.longitude, a.landmark
        FROM masterdata.orders o 
		LEFT JOIN masterdata.status s on o.status_id = s.status_id
        LEFT JOIN masterdata.addresses a on o.billing_address_id = a.address_id
		LEFT JOIN masterdata.time_slots ts on ts.time_slot_id = o.time_slot_id
		LEFT JOIN masterdata.packaging_types p on o.packaging_type_id = p.packaging_type_id
        WHERE o.is_active = true and o.order_id = _order_id; -- open cursor
		RETURN NEXT ref1;
		
		OPEN ref2 FOR 
        SELECT item_id, item_name, item_description, quantity , price , item_image_urls, total_price,
		 		pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku
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
   masterdata          sahyadri    false    9            Z           1255    16484    get_orders(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_orders(_customer_id uuid) RETURNS refcursor
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
   masterdata          sahyadri    false    9            Y           1255    16485    get_orders_by_id(uuid, uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_orders_by_id(_store_id uuid, _customer_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            R           1255    16896    get_orders_by_role(uuid)    FUNCTION     V  CREATE FUNCTION masterdata.get_orders_by_role(_role_id uuid) RETURNS refcursor
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
   masterdata          sahyadri    false    9            a           1255    17275    get_packaging_type(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_packaging_type(_packaging_types_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            T           1255    16487    get_payment_status(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_payment_status(_order_id uuid) RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9            :           1255    16919 "   get_payu_status(character varying)    FUNCTION        CREATE FUNCTION masterdata.get_payu_status(_order_id character varying) RETURNS refcursor
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
   masterdata          sahyadri    false    9            K           1255    16489    get_permissions()    FUNCTION     �  CREATE FUNCTION masterdata.get_permissions() RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9                        1255    16490    get_ratings_and_reviews()    FUNCTION     �  CREATE FUNCTION masterdata.get_ratings_and_reviews() RETURNS character varying
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
   masterdata          sahyadri    false    9            g           1255    17337 *   get_reports(date, date, character varying)    FUNCTION     �h  CREATE FUNCTION masterdata.get_reports(_from_date date, _to_date date, _report_name character varying) RETURNS character varying
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
                SELECT to_char(o.created_at, 'Month') AS Month , to_char(o.created_at, 'DD/MM/YYYY')  , st.store_name, count(o.order_id)
                from masterdata.orders o
                join masterdata.stores st on o.store_id = st.store_id
				group by st.store_name, o.created_at order by o.created_at;
            RETURN ref;                               -- Return the cursor to the caller

        end if;

    end if;

    END;
$$;
 f   DROP FUNCTION masterdata.get_reports(_from_date date, _to_date date, _report_name character varying);
    
   masterdata          sahyadri    false    9            !           1255    16491    get_role(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_role(_role_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            "           1255    16492    get_roles()    FUNCTION     ]  CREATE FUNCTION masterdata.get_roles() RETURNS character varying
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
   masterdata          sahyadri    false    9                       1255    16493    get_screens()    FUNCTION        CREATE FUNCTION masterdata.get_screens() RETURNS character varying
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
   masterdata          sahyadri    false    9            $           1255    16494    get_slots(uuid)    FUNCTION     t  CREATE FUNCTION masterdata.get_slots(_store_id uuid) RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9                       1255    16496    get_store(uuid)    FUNCTION       CREATE FUNCTION masterdata.get_store(_store_id uuid) RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9            C           1255    16497    get_stores()    FUNCTION     �  CREATE FUNCTION masterdata.get_stores() RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9            #           1255    16498    get_subscribed_users(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_subscribed_users(_customer_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            %           1255    16499    get_subscription(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_subscription(_subscription_id uuid) RETURNS refcursor
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
   masterdata          sahyadri    false    9            H           1255    16503    get_wallet_transactions(uuid)    FUNCTION     �  CREATE FUNCTION masterdata.get_wallet_transactions(_customer_id uuid) RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9            M           1255    16504 +   login(character varying, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.login(_email character varying, _password character varying) RETURNS character varying
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
   masterdata          sahyadri    false    9            m           1255    16505 b   merge_cart(uuid, bigint, character varying, character varying, bigint, character varying, numeric)    FUNCTION     Q	  CREATE FUNCTION masterdata.merge_cart(_cart_id uuid, _store_id bigint, _first_name character varying, _last_name character varying, _magento_customer_id bigint, _email character varying, _mobile numeric) RETURNS character varying
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
   masterdata          sahyadri    false    9            i           1255    17355 6   multiple_order_update(uuid, uuid[], character varying)    FUNCTION     �  CREATE FUNCTION masterdata.multiple_order_update(_status_id uuid, _order_id uuid[], _reason character varying) RETURNS character varying
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
   masterdata          sahyadri    false    9            /           1255    16508 %   rating_and_reviews_filter(date, date)    FUNCTION     "  CREATE FUNCTION masterdata.rating_and_reviews_filter(_from_date date, _to_date date) RETURNS character varying
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
   masterdata          sahyadri    false    9            U           1255    16509 *   remove_item(uuid, uuid, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.remove_item(_customer_id uuid, _cart_id uuid, _item_id character varying) RETURNS character varying
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
   masterdata          sahyadri    false    9            .           1255    16510    roles_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.roles_filter(_from_date date, _to_date date) RETURNS character varying
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
   masterdata          sahyadri    false    9            r           1255    17668    sales_entry()    FUNCTION     f  CREATE FUNCTION masterdata.sales_entry() RETURNS SETOF refcursor
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
        JOIN masterdata.stores st on o.store_id = st.store_id
         WHERE (o.created_at between CURRENT_DATE - 1 + '21:00:00.000000'::time AND CURRENT_DATE + '21:00:00.000000'::time) 
 				and o.payment_status = 'SUCCESS' group by st.store_id;
-- 			where o.created_at::date = CURRENT_DATE - 2 and o.payment_status = 'SUCCESS' group by st.store_id, o.total_amount;
        RETURN next ref1;
		
		 OPEN ref2 FOR 
        select st.plant_code, o.payment_method, sum(o.total_amount)
        from masterdata.orders o
        JOIN masterdata.stores st on o.store_id = st.store_id
        WHERE (o.created_at between CURRENT_DATE - 1 + '21:00:00.000000'::time AND CURRENT_DATE + '21:00:00.000000'::time) 
				and o.payment_status = 'SUCCESS' group by st.store_id, o.payment_method;
-- 			where o.created_at::date = CURRENT_DATE - 2 and o.payment_status = 'SUCCESS' group by st.store_id, o.payment_method;
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
   masterdata          sahyadri    false    9            s           1255    17676    sap_cumulative_order()    FUNCTION     �  CREATE FUNCTION masterdata.sap_cumulative_order() RETURNS SETOF refcursor
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
        LEFT OUTER JOIN masterdata.stores s on o.store_id = s.store_id
        WHERE o.created_at >= CURRENT_DATE - 1 + '21:00:00.000000'::time AND    
                o.created_at <= CURRENT_DATE + '21:00:00.000000'::time;
        RETURN next ref1;
 
        OPEN ref2 FOR 
        select ol.item_id, s.plant_code, ol.quantity, ol.unit_of_measure, ol.total_price, o.store_id
        from masterdata.order_lines ol
        join masterdata.orders o on ol.cart_id = o.cart_id
        LEFT OUTER JOIN masterdata.stores s on o.store_id = s.store_id
       WHERE o.created_at >= CURRENT_DATE - 1 + '21:00:00.000000'::time AND    
                o.created_at <= CURRENT_DATE + '21:00:00.000000'::time;
        RETURN next ref2;

    END;
$$;
 1   DROP FUNCTION masterdata.sap_cumulative_order();
    
   masterdata          sahyadri    false    9            -           1255    16511 ?   search(character varying, character varying, character varying)    FUNCTION     B  CREATE FUNCTION masterdata.search(_screens character varying, _column_name character varying, _search character varying) RETURNS refcursor
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
                s.store_name, r.role_name
            from masterdata.oms_users u 
            left join masterdata.stores s on u.store_id = s.store_id 
            join masterdata.roles r on u.role_id = r.role_id
            where u.first_name ilike __search or u.last_name ilike __search;
            RETURN ref;

            elsif _column_name = 'Mobile number' THEN

            OPEN ref FOR
            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
                s.store_name, r.role_name
            from masterdata.oms_users u 
            left join masterdata.stores s on u.store_id = s.store_id 
            join masterdata.roles r on u.role_id = r.role_id
            where cast(u.mobile as character varying) ilike __search;
            RETURN ref;

            elsif _column_name = 'email' THEN

            OPEN ref FOR
            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
                s.store_name, r.role_name
            from masterdata.oms_users u 
            left join masterdata.stores s on u.store_id = s.store_id 
            join masterdata.roles r on u.role_id = r.role_id
            where  u.email ilike __search;
            RETURN ref;

            elsif _column_name = 'role' THEN

            OPEN ref FOR
            select u.user_id, u.first_name, u.last_name, u.mobile, u.email, u.password, u.role_id, u.store_id, u.is_active,
                s.store_name, r.role_name
            from masterdata.oms_users u 
            left join masterdata.stores s on u.store_id = s.store_id 
            join masterdata.roles r on u.role_id = r.role_id
            where  r.role_name ilike __search;
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
   masterdata          sahyadri    false    9            0           1255    16513 !   serviceability(bigint, numeric[])    FUNCTION       CREATE FUNCTION masterdata.serviceability(_pincode bigint, _lat_longs numeric[]) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
Declare
        __store_id UUID;
		__delivery_point_id UUID;
		__store_status boolean;

	BEGIN

        if _pincode is not null then

            select p.store_id, p.delivery_point_id into __store_id, __delivery_point_id
			from masterdata.serviceable_pincodes p
            where p.pincode = _pincode;

            SELECT is_active into __store_status from masterdata.stores where store_id = __store_id;

            if (__store_id is not null and __store_status = 'true') then

                RETURN CONCAT('true',',',__store_id,',',__delivery_point_id);
				
			else
			 	
				return CONCAT('false',',',__delivery_point_id);

            end if; 
			
		elsif (_lat_longs) is not null then
			
 			select p.store_id, p.delivery_point_id into __store_id, __delivery_point_id
 			from masterdata.serviceable_pincodes p
            where array[lat_longs] @> _lat_longs;
			
            SELECT is_active into __store_status from masterdata.stores where store_id = __store_id;
			
 			if (__store_id is not null and __store_status is true) or __delivery_point_id is not null then  

                 RETURN CONCAT('true',',',__store_id,',',__delivery_point_id);
				
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
   masterdata          sahyadri    false    9            J           1255    16514    stores_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.stores_filter(_from_date date, _to_date date) RETURNS SETOF refcursor
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
   masterdata          sahyadri    false    9            l           1255    17145    transactions(date, date)    FUNCTION     X  CREATE FUNCTION masterdata.transactions(_from_date date, _to_date date) RETURNS refcursor
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
   masterdata          sahyadri    false    9            V           1255    17593   update_address(uuid, character varying, character varying, character varying, bigint, character varying, character varying, character varying, character varying, character varying, character varying, boolean, boolean, bigint, boolean, numeric, numeric, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.update_address(_address_id uuid, _first_name character varying, _last_name character varying, _email character varying, _mobile bigint, _line_1 character varying, _line_2 character varying, _street character varying, _city character varying, _state character varying, _country character varying, _is_billing boolean, _is_shipping boolean, _pincode bigint, _is_default boolean, _latitude numeric, _longitude numeric, _landmark character varying) RETURNS character varying
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
   masterdata          sahyadri    false    9            S           1255    17148 '   update_cart_prices(uuid, numeric, json)    FUNCTION     �  CREATE FUNCTION masterdata.update_cart_prices(_cart_id uuid, _new_sales_amount numeric, _items_list json) RETURNS character varying
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
				
				if __delivery_charges is null THEN
					SELECT 0.00 into __delivery_charges;
				end if;
				
				if __existing_delivery_charges = __delivery_charges THEN
					SELECT false into __is_dc_updated;
				else
					SELECT true into __is_dc_updated;
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
				
				
				
			elsif _new_sales_amount is not NULL THEN
			
				select delivery_charges, cart_amount, sub_total into __existing_delivery_charges, __cart_amount, __sub_total from masterdata.carts
 					where cart_id = __cart_id;

				SELECT amount into __delivery_charges from masterdata.delivery_charges where _new_sales_amount BETWEEN min_cart_value AND max_cart_value;
				
				if __existing_delivery_charges = __delivery_charges THEN
					SELECT false into __is_dc_updated;
				else
					SELECT true into __is_dc_updated;
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
						special_price = cast(__item  ->> 'special_price' as numeric)
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
   masterdata          sahyadri    false    9            4           1255    16517 8   update_delivery_option(uuid, character varying, boolean)    FUNCTION     F  CREATE FUNCTION masterdata.update_delivery_option(_delivery_option_id uuid, _delivery_option character varying, _is_active boolean) RETURNS character varying
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
   masterdata          sahyadri    false    9            1           1255    16518 H   update_delivery_point(uuid, character varying, bigint, bigint, bigint[])    FUNCTION     w  CREATE FUNCTION masterdata.update_delivery_point(_delivery_point_id uuid, _delivery_point_name character varying, _plant_code bigint, _dp_code bigint, _serviceable_pincodes bigint[]) RETURNS character varying
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
   masterdata          sahyadri    false    9            5           1255    16519 2   update_frequency(uuid, character varying, boolean)    FUNCTION     �  CREATE FUNCTION masterdata.update_frequency(_frequency_id uuid, _frequency character varying, _is_active boolean) RETURNS character varying
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
   masterdata          sahyadri    false    9            q           1255    17681 ,   update_item_from_orders(uuid, numeric, json)    FUNCTION     �  CREATE FUNCTION masterdata.update_item_from_orders(_order_id uuid, _total_amount numeric, _items json) RETURNS character varying
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
   masterdata          sahyadri    false    9            d           1255    17278 %   update_min_order_value(uuid, numeric)    FUNCTION     �  CREATE FUNCTION masterdata.update_min_order_value(_min_order_id uuid, _min_order_value numeric) RETURNS character varying
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
   masterdata          sahyadri    false    9            `           1255    17274 <   update_oms_packaging_types(uuid, character varying, numeric)    FUNCTION     �  CREATE FUNCTION masterdata.update_oms_packaging_types(_packaging_types_id uuid, _packaging_type character varying, _amount numeric) RETURNS character varying
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
   masterdata          sahyadri    false    9            \           1255    17159 �   update_oms_user(uuid, character varying, character varying, bigint, character varying, character varying, uuid, uuid[], boolean)    FUNCTION     �  CREATE FUNCTION masterdata.update_oms_user(_user_id uuid, _first_name character varying, _last_name character varying, _mobile bigint, _email character varying, _password character varying, _role_id uuid, _store_id uuid[], _is_active boolean) RETURNS character varying
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
   masterdata          sahyadri    false    9            h           1255    17354 +   update_order(uuid, uuid, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.update_order(_order_id uuid, _status_id uuid, _reason character varying) RETURNS character varying
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
   masterdata          sahyadri    false    9            6           1255    16522 (   update_packaging_types(uuid, uuid, uuid)    FUNCTION     y  CREATE FUNCTION masterdata.update_packaging_types(_customer_id uuid, _cart_id uuid, _packaging_type uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            k           1255    17264 J   update_payment_status(uuid, boolean, character varying, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.update_payment_status(_order_id uuid, _is_paid boolean, _payment_status character varying, _payu_id character varying) RETURNS refcursor
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
   masterdata          sahyadri    false    9            2           1255    16523 6   update_rating_review(uuid, integer, character varying)    FUNCTION     �  CREATE FUNCTION masterdata.update_rating_review(_order_id uuid, _rating integer, _review character varying) RETURNS character varying
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
   masterdata          sahyadri    false    9            3           1255    16524 -   update_role(uuid, character varying, boolean)    FUNCTION     e  CREATE FUNCTION masterdata.update_role(_role_id uuid, _role_name character varying, _is_active boolean) RETURNS character varying
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
   masterdata          sahyadri    false    9            D           1255    16525 �   update_store(uuid, character varying, bigint, bigint, bigint, boolean, boolean, boolean, bigint[], numeric[], character varying)    FUNCTION        CREATE FUNCTION masterdata.update_store(_store_id uuid, _store_name character varying, _plant_code bigint, _ds_code bigint, _phone_no bigint, _is_sfs_enabled boolean, _is_cc_enabled boolean, _is_active boolean, _serviceable_pincodes bigint[], _lat_long numeric[], _zone character varying) RETURNS character varying
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

                insert into masterdata.serviceable_pincodes (pincode, store_id, created_by, updated_by) 
                        values (__pincode, _store_id,  
                                _store_id, _store_id) ;

            End LOOP;
			
            FOREACH __lat_long slice 1 in array _lat_long
            LOOP
                insert into masterdata.serviceable_pincodes (lat_longs, store_id, created_by, updated_by) 
                        values (__lat_long, _store_id,  
                                _store_id, _store_id) ;

            End LOOP;

    RETURN 'successfully_updated'; 
			
		else
		
			RETURN 'store_already_present';  
			
		end if;

    END;
$$;
    DROP FUNCTION masterdata.update_store(_store_id uuid, _store_name character varying, _plant_code bigint, _ds_code bigint, _phone_no bigint, _is_sfs_enabled boolean, _is_cc_enabled boolean, _is_active boolean, _serviceable_pincodes bigint[], _lat_long numeric[], _zone character varying);
    
   masterdata          sahyadri    false    9            7           1255    16526 =   update_subscription(uuid, character varying, bigint, boolean)    FUNCTION     �  CREATE FUNCTION masterdata.update_subscription(_subscription_id uuid, _subscription_type character varying, _subscription_period bigint, _is_active boolean) RETURNS character varying
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
   masterdata          sahyadri    false    9            j           1255    17561 4   update_wallet(uuid, numeric, boolean, boolean, uuid)    FUNCTION     J	  CREATE FUNCTION masterdata.update_wallet(_customer_id uuid, _amount numeric, _is_debit boolean, _is_credit boolean, _order_id uuid) RETURNS character varying
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
   masterdata          sahyadri    false    9            8           1255    16528    user_carts_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.user_carts_filter(_from_date date, _to_date date) RETURNS refcursor
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
   masterdata          sahyadri    false    9            e           1255    17144    wallet_filter(date, date)    FUNCTION     �  CREATE FUNCTION masterdata.wallet_filter(_from_date date, _to_date date) RETURNS refcursor
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
   cart_lines    TABLE     U  CREATE TABLE masterdata.cart_lines (
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
    sub_category_name character varying
);
 "   DROP TABLE masterdata.cart_lines;
    
   masterdata         heap    sahyadri    false    9            �            1259    17208    carts    TABLE       CREATE TABLE masterdata.carts (
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
    delivery_charges numeric(15,2) DEFAULT 0.00 NOT NULL
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
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16632    order_lines    TABLE     �  CREATE TABLE masterdata.order_lines (
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
    sub_category_name character varying
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
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16666    orders    TABLE       CREATE TABLE masterdata.orders (
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
    reason character varying
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
   masterdata         heap    sahyadri    false    2    9    9            �            1259    16727    serviceable_pincodes    TABLE     v  CREATE TABLE masterdata.serviceable_pincodes (
    pincode bigint,
    store_id uuid,
    delivery_point_id uuid,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid NOT NULL,
    lat_longs numeric[]
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
   masterdata          sahyadri    false    204   ��      �          0    17221 
   cart_lines 
   TABLE DATA           �  COPY masterdata.cart_lines (cart_id, item_id, item_name, item_description, quantity, price, item_image_urls, item_category, item_shelf_life, discount_type, discount_amount, total_price, is_active, created_by, created_at, updated_by, updated_at, user_subscription_id, pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, "row", rack, bin, hsn, ean, gst, item_status, category_id, category_name, sub_category_id, sub_category_name) FROM stdin;
 
   masterdata          sahyadri    false    235   ʯ      �          0    17208    carts 
   TABLE DATA           �   COPY masterdata.carts (cart_id, customer_id, cart_amount, discount_type, discount_amount, coupon_code, is_guest_cart, is_paid, is_active, created_by, created_at, updated_by, updated_at, packaging_type_id, sub_total, delivery_charges) FROM stdin;
 
   masterdata          sahyadri    false    234   p&      �          0    16558    channels 
   TABLE DATA           �   COPY masterdata.channels (channel_id, channel, latest_version, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    205   �i      �          0    16567 	   customers 
   TABLE DATA             COPY masterdata.customers (customer_id, store_id, magento_customer_id, first_name, last_name, mobile, email, subscription_id, subscription_start_date, subscription_end_date, frequency_id, delivery_option_id, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    206   (k      �          0    16574 	   day_slots 
   TABLE DATA           �   COPY masterdata.day_slots (day_slot_id, month_slot_id, day, month, open_time, close_time, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
 
   masterdata          sahyadri    false    207   ��      �          0    16905    delivery_charges 
   TABLE DATA           �   COPY masterdata.delivery_charges (delivery_charges_id, min_cart_value, max_cart_value, amount, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    232   �      �          0    16581    delivery_options 
   TABLE DATA           �   COPY masterdata.delivery_options (delivery_option_id, delivery_option, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    208   *      �          0    16591    delivery_points 
   TABLE DATA           �   COPY masterdata.delivery_points (delivery_point_id, delivery_point_name, plant_code, dp_code, address_id, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    209   �      �          0    16598    error_log_table 
   TABLE DATA           }   COPY masterdata.error_log_table (error_id, function_name, error_code, error_msg, sub_id, other_info, created_at) FROM stdin;
 
   masterdata          sahyadri    false    210   �      �          0    16606    frequencies 
   TABLE DATA           }   COPY masterdata.frequencies (frequency_id, frequency, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    211   �2      �          0    17281    min_order_value 
   TABLE DATA           �   COPY masterdata.min_order_value (min_order_value_id, min_order_value, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    236   �2      �          0    16616    month_slots 
   TABLE DATA           �   COPY masterdata.month_slots (month_slot_id, store_id, month, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
 
   masterdata          sahyadri    false    212   V3      �          0    16623 	   oms_users 
   TABLE DATA           �   COPY masterdata.oms_users (user_id, first_name, last_name, mobile, email, password, role_id, is_active, created_at, created_by, updated_by, updated_at, store_id) FROM stdin;
 
   masterdata          sahyadri    false    213   (9      �          0    16632    order_lines 
   TABLE DATA             COPY masterdata.order_lines (order_part_id, item_id, item_name, item_description, quantity, price, item_image_urls, item_category, item_shelf_life, item_packing_type, is_returnable, discount_type, discount_amount, is_active, created_by, created_at, updated_by, updated_at, user_subscription_id, total_price, cart_id, pack_size, unit_of_measure, weight, brand, varients, inventory, special_price, short_description, sku, "row", rack, bin, ean, hsn, gst, item_status, category_id, category_name, sub_category_id, sub_category_name) FROM stdin;
 
   masterdata          sahyadri    false    214   �@      �          0    16642    order_parts 
   TABLE DATA           �  COPY masterdata.order_parts (order_part_id, order_id, order_type, fulfilment_id, shipping_address_id, discount_type, discount_amount, invoice_id, is_shipped, is_picked, is_packed, is_paid, is_sfs_stock_blocked, status_id, status_history, status_history_timings, cancellation_reason, awb, coupon_code, amount, rating, tracking_url, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    215   ��
      �          0    16657    order_types 
   TABLE DATA           �   COPY masterdata.order_types (order_type_id, order_type, order_type_code, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    216   ��
      �          0    16666    orders 
   TABLE DATA           �  COPY masterdata.orders (order_id, cart_id, customer_id, is_paid, order_no, payment_id, time_slot_id, is_return_initiated, is_cancelled, is_delivered, channel_id, status_id, subscription_id, total_amount, payment_method, payment_status, feedback, is_active, created_by, created_at, updated_by, updated_at, store_id, billing_address_id, shipping_address_id, rating, review, status_history, invoice_id, packaging_type_id, sub_total, delivery_charges, slot_date, payu_id, reason) FROM stdin;
 
   masterdata          sahyadri    false    217   ��
      �          0    16681    packaging_types 
   TABLE DATA           �   COPY masterdata.packaging_types (packaging_type_id, packaging_type, amount, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    218   �q      �          0    16690    payment_transactions 
   TABLE DATA           �   COPY masterdata.payment_transactions (payment_id, transaction_id, order_id, total_amount, payment_method, payment_status_id, merchant_id, is_success, pg_message, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    219   hr      �          0    16700    permissions 
   TABLE DATA           �   COPY masterdata.permissions (permission_id, role_id, screen_id, is_read, is_write, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    220   �r      �          0    16709    roles 
   TABLE DATA           r   COPY masterdata.roles (role_id, role_name, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    221   ��      �          0    16718    screens 
   TABLE DATA           x   COPY masterdata.screens (screen_id, screen_name, is_active, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    222   ��      �          0    16727    serviceable_pincodes 
   TABLE DATA           �   COPY masterdata.serviceable_pincodes (pincode, store_id, delivery_point_id, is_active, created_at, created_by, updated_at, updated_by, lat_longs) FROM stdin;
 
   masterdata          sahyadri    false    223   '�      �          0    16736    status 
   TABLE DATA           ~   COPY masterdata.status (status_id, status_name, pg_id, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    224   ׎      �          0    16745    stores 
   TABLE DATA           �   COPY masterdata.stores (store_id, address_id, store_name, plant_code, ds_code, phone_no, is_sfs_enabled, is_cc_enabled, is_active, created_by, created_at, updated_by, updated_at, zone, area_name) FROM stdin;
 
   masterdata          sahyadri    false    225   (�      �          0    16755    subscriptions 
   TABLE DATA           �   COPY masterdata.subscriptions (subscription_id, subscription_type, subscription_period, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    226   Ց      �          0    16765 
   time_slots 
   TABLE DATA           �   COPY masterdata.time_slots (time_slot_id, day_slot_id, start_slot_time, end_slot_time, slot_limit, slot_current_orders, is_active, created_at, created_by, updated_at, updated_by) FROM stdin;
 
   masterdata          sahyadri    false    227   �      �          0    16897    user_matrix 
   TABLE DATA           �   COPY masterdata.user_matrix (user_matrix_id, role_id, screen_id, status_id, is_status_read, is_status_write, created_at, created_by, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    231   �w      �          0    16773    user_subscriptions 
   TABLE DATA           �   COPY masterdata.user_subscriptions (subscribed_user_id, customer_id, subscription_id, frequency_id, delivery_option_id, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    228   J�      �          0    16782    wallet_transactions 
   TABLE DATA           �   COPY masterdata.wallet_transactions (transaction_id, wallet_id, amount, is_debit, is_credit, is_active, created_by, created_at, updated_by, updated_at, order_id) FROM stdin;
 
   masterdata          sahyadri    false    229   g�      �          0    16789    wallets 
   TABLE DATA           �   COPY masterdata.wallets (wallet_id, customer_id, wallet_amount, is_active, created_by, created_at, updated_by, updated_at) FROM stdin;
 
   masterdata          sahyadri    false    230   ��      �          0    17087    __status_id 
   TABLE DATA           0   COPY public.__status_id (status_id) FROM stdin;
    public          sahyadri    false    233   .�                 2606    16797    addresses addresses_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY masterdata.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (address_id);
 F   ALTER TABLE ONLY masterdata.addresses DROP CONSTRAINT addresses_pkey;
    
   masterdata            sahyadri    false    204            1           2606    17220    carts carts_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY masterdata.carts
    ADD CONSTRAINT carts_pkey PRIMARY KEY (cart_id);
 >   ALTER TABLE ONLY masterdata.carts DROP CONSTRAINT carts_pkey;
    
   masterdata            sahyadri    false    234                       2606    16801    channels channels_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY masterdata.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (channel_id);
 D   ALTER TABLE ONLY masterdata.channels DROP CONSTRAINT channels_pkey;
    
   masterdata            sahyadri    false    205                       2606    16803    customers customers_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY masterdata.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);
 F   ALTER TABLE ONLY masterdata.customers DROP CONSTRAINT customers_pkey;
    
   masterdata            sahyadri    false    206                       2606    16805 &   delivery_options delivery_options_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY masterdata.delivery_options
    ADD CONSTRAINT delivery_options_pkey PRIMARY KEY (delivery_option_id);
 T   ALTER TABLE ONLY masterdata.delivery_options DROP CONSTRAINT delivery_options_pkey;
    
   masterdata            sahyadri    false    208                       2606    16807 $   delivery_points delivery_points_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY masterdata.delivery_points
    ADD CONSTRAINT delivery_points_pkey PRIMARY KEY (delivery_point_id);
 R   ALTER TABLE ONLY masterdata.delivery_points DROP CONSTRAINT delivery_points_pkey;
    
   masterdata            sahyadri    false    209                       2606    16809 $   error_log_table error_log_table_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY masterdata.error_log_table
    ADD CONSTRAINT error_log_table_pkey PRIMARY KEY (error_id);
 R   ALTER TABLE ONLY masterdata.error_log_table DROP CONSTRAINT error_log_table_pkey;
    
   masterdata            sahyadri    false    210                       2606    16811    frequencies frequencies_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY masterdata.frequencies
    ADD CONSTRAINT frequencies_pkey PRIMARY KEY (frequency_id);
 J   ALTER TABLE ONLY masterdata.frequencies DROP CONSTRAINT frequencies_pkey;
    
   masterdata            sahyadri    false    211                       2606    16813    order_parts order_parts_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY masterdata.order_parts
    ADD CONSTRAINT order_parts_pkey PRIMARY KEY (order_part_id);
 J   ALTER TABLE ONLY masterdata.order_parts DROP CONSTRAINT order_parts_pkey;
    
   masterdata            sahyadri    false    215                       2606    16815    order_types order_types_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY masterdata.order_types
    ADD CONSTRAINT order_types_pkey PRIMARY KEY (order_type_id);
 J   ALTER TABLE ONLY masterdata.order_types DROP CONSTRAINT order_types_pkey;
    
   masterdata            sahyadri    false    216                       2606    16817    orders orders_order_no_key 
   CONSTRAINT     ]   ALTER TABLE ONLY masterdata.orders
    ADD CONSTRAINT orders_order_no_key UNIQUE (order_no);
 H   ALTER TABLE ONLY masterdata.orders DROP CONSTRAINT orders_order_no_key;
    
   masterdata            sahyadri    false    217            !           2606    16819    orders orders_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY masterdata.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);
 @   ALTER TABLE ONLY masterdata.orders DROP CONSTRAINT orders_pkey;
    
   masterdata            sahyadri    false    217            #           2606    16821 .   payment_transactions payment_transactions_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY masterdata.payment_transactions
    ADD CONSTRAINT payment_transactions_pkey PRIMARY KEY (payment_id);
 \   ALTER TABLE ONLY masterdata.payment_transactions DROP CONSTRAINT payment_transactions_pkey;
    
   masterdata            sahyadri    false    219            %           2606    16823    status status_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY masterdata.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (status_id);
 @   ALTER TABLE ONLY masterdata.status DROP CONSTRAINT status_pkey;
    
   masterdata            sahyadri    false    224            '           2606    16825    stores stores_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY masterdata.stores
    ADD CONSTRAINT stores_pkey PRIMARY KEY (store_id);
 @   ALTER TABLE ONLY masterdata.stores DROP CONSTRAINT stores_pkey;
    
   masterdata            sahyadri    false    225            )           2606    16827     subscriptions subscriptions_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY masterdata.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (subscription_id);
 N   ALTER TABLE ONLY masterdata.subscriptions DROP CONSTRAINT subscriptions_pkey;
    
   masterdata            sahyadri    false    226            +           2606    16829 *   user_subscriptions user_subscriptions_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY masterdata.user_subscriptions
    ADD CONSTRAINT user_subscriptions_pkey PRIMARY KEY (subscribed_user_id);
 X   ALTER TABLE ONLY masterdata.user_subscriptions DROP CONSTRAINT user_subscriptions_pkey;
    
   masterdata            sahyadri    false    228            -           2606    16831 ,   wallet_transactions wallet_transactions_pkey 
   CONSTRAINT     z   ALTER TABLE ONLY masterdata.wallet_transactions
    ADD CONSTRAINT wallet_transactions_pkey PRIMARY KEY (transaction_id);
 Z   ALTER TABLE ONLY masterdata.wallet_transactions DROP CONSTRAINT wallet_transactions_pkey;
    
   masterdata            sahyadri    false    229            /           2606    16833    wallets wallets_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY masterdata.wallets
    ADD CONSTRAINT wallets_pkey PRIMARY KEY (wallet_id);
 B   ALTER TABLE ONLY masterdata.wallets DROP CONSTRAINT wallets_pkey;
    
   masterdata            sahyadri    false    230            2           2606    16834 $   addresses addresses_customer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.addresses
    ADD CONSTRAINT addresses_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES masterdata.customers(customer_id);
 R   ALTER TABLE ONLY masterdata.addresses DROP CONSTRAINT addresses_customer_id_fkey;
    
   masterdata          sahyadri    false    206    204    3857            8           2606    17230 "   cart_lines cart_lines_cart_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.cart_lines
    ADD CONSTRAINT cart_lines_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES masterdata.carts(cart_id);
 P   ALTER TABLE ONLY masterdata.cart_lines DROP CONSTRAINT cart_lines_cart_id_fkey;
    
   masterdata          sahyadri    false    3889    234    235            3           2606    16844 &   order_parts order_parts_status_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.order_parts
    ADD CONSTRAINT order_parts_status_id_fkey FOREIGN KEY (status_id) REFERENCES masterdata.status(status_id);
 T   ALTER TABLE ONLY masterdata.order_parts DROP CONSTRAINT order_parts_status_id_fkey;
    
   masterdata          sahyadri    false    3877    224    215            4           2606    16849    orders orders_customer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES masterdata.customers(customer_id);
 L   ALTER TABLE ONLY masterdata.orders DROP CONSTRAINT orders_customer_id_fkey;
    
   masterdata          sahyadri    false    3857    206    217            5           2606    16854    orders orders_status_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.orders
    ADD CONSTRAINT orders_status_id_fkey FOREIGN KEY (status_id) REFERENCES masterdata.status(status_id);
 J   ALTER TABLE ONLY masterdata.orders DROP CONSTRAINT orders_status_id_fkey;
    
   masterdata          sahyadri    false    224    217    3877            6           2606    16859 @   payment_transactions payment_transactions_payment_status_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.payment_transactions
    ADD CONSTRAINT payment_transactions_payment_status_id_fkey FOREIGN KEY (payment_status_id) REFERENCES masterdata.status(status_id);
 n   ALTER TABLE ONLY masterdata.payment_transactions DROP CONSTRAINT payment_transactions_payment_status_id_fkey;
    
   masterdata          sahyadri    false    3877    219    224            7           2606    16864     wallets wallets_customer_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY masterdata.wallets
    ADD CONSTRAINT wallets_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES masterdata.customers(customer_id);
 N   ALTER TABLE ONLY masterdata.wallets DROP CONSTRAINT wallets_customer_id_fkey;
    
   masterdata          sahyadri    false    206    230    3857            �      x��}Ys9��s�WT�}�&����l��M����g"&b�H-������o&�EՔ\��g���,
�B}Hd~�H�I�%�tP�������	I��\���E%��v~�NK5��ɔ5	��j4�\Uo��6��|R9����o7�sq>�n~���u�	'VJx��O�o��IƳ�x��KW_�i�̫�[�'�յI��r���c?]���GFP6�&���ɆF
K��%d"�����')X��@)iFS1���$	���L
�a��w�Z��Ay��l��y�����y2_,�9u�i��+׾�����o���`m��VYilEIu��I	 <����^��\�����j��=�rȕМ#8{Ѣ� �=�> K݈��3������iV!M�S�v
n+���G�c�����o�?T�����ѧ
 YN.�����s���ہ&�u���ht�>������O��g_�y}���|����v�i�ν:�ƊהP~�̐sA5E�� ���"(�0x)�/x; �g¼Μ�b+K���\;�2�$"<r
@L�.cwWW����尹�j*�"
z��_�ܲ��j[���N��dz����\�I=-x�����M���x��t*�*hd��=��]��y��$�qe�p571���2�4�UzӴs6���Uґ�X����Ÿz����yc�7��BQ�� kQ�"^�]~���]�yv;]��*N�_�$P�����]7:����	�u��]ݹ�ϕ�rBW��z
���_��cC��û]e�D:�PZ0-�L������Y�]���ɀ�W�&��R�-�?�U��r�ņ]�XA-�����X/�ա��;�<��[�˭����'����-g�آq{q��7�z�@�R+ԌOd��:h��,[�MIH�o�h������j��V�r���F�|��]uOT��ѷ��ːjв������>��G''����0Ç������������͗O�FG�^�o;=�'���iu2�[|������5R�&�Q�]�m"�]z�U��S�P�> ۈ�XB��ܨ(��DiGV�l���]��a	�+x���vz��(W��rE�1]�Պ�g��͇�ɬ;�~)$�0�'�X�]MB�������u�e���GKx��G���~�9Vާ�]�42b� ��z�\D�.h�
���\��VZ���8Ap-ڨ2�v�&��^X��w[���8���ׯo>��k�7T������00�c'(��,�.!^�7i�C'٨l�Nl>:Hg�1��G߃�z.�<+c�N ���̳�.)N��f��]��	���6�H��hUoj�tr.͕��us�x�A��N��������o0�(>�$���Lb����rڕr��es ��!Q����:�W(�5W�)�:@�0���K�M���	�\�[G	A��F�d�"V���Gb6����i�����E�|^f���Q��@{����}
UT��^��`B�B�I����߃���JI�w�V{%͛ *3���:��+�R:��A�6�����j����O.&K���z�� ��N��m�1�A�� D����X��L,���*�x>�+��"=�>��n��b��<��t�Ui�X�~ϰ�<03�L�=��(5����`�jg�#�e�\e'x_�D�7@�i���f`��dBP*���4��؁~�'i^]J7[��<-��M����x�@o�0�Ya�Ϸ���7 ��]է��`{�t��lZ���#����.�� �X�׳�L��i�:`@�V�{��1e�-ة�����Wi� 3H���� ��ds>J�L��<P���|f��O<��D���|�g7�֧3�9^��y�-�]R+!�~�^?9GB+Z�9���x���C\��U;��.G�<uM2؀ᵤ-�j�<��L�K	���!@��.����3ӄ1�d�+V�n����h,	�_\V�O��@���!V,��V'%F�P�)g�	j_.��d��|>��L"���`�W�؃����ig�*� ��IN"�jT� ����&!�7�Oe!d�)��pW�g�t���}���I����^N����4-^�_;y�H���v���n'��o0e�� �UeƿXB��1��!��-�����Z�U�q,�$!x�3@
�=xt��F�5���g�� �������ڂ���ʣ5�ƥ��m�\�¯��j,�h4��/cl�S�f+g����5d�@FJz��h�/�Q��ev>.A���0�Z���`}X���ڭ�������d[	$�o\���<�չ�ޖt�<ul���A�lkC����귓������/�fa��wW���sc�fv5���u��|:�^�~����m@k�e ��MNx"���Ib�-�6���t2��	�11�pAT�����c�c�7BD�O���������K��wG�c8�>�멋n������c�$�"�g3 ��8&?V��G�������.>B^h`ϱhgD�G�蛰C"���2/љ9AP�@�pf5#��l�=�qԲ��	G �?�i���xĠDg^}=}�z���B@p�c���Q-��D#�>>}��>���G�ߎ��/��_ (�O�ԇ_J
v�vtzv�$�^~9=��!῞����'���A�qW�@�XBz�(��PX�x �`A`��=�������χ���n
�&�!8Y��R����R.��a�S�YZ�WK���I���	�P}��f���CՒ��շ��T���V}�M/�2��c �o�Gﷇ&�������G�PH�aeEi":FB���0+iV�9ڀ	U�ǒq��8I.����ps�I�:�X��%�r]�C�-H5���a���~3�-�i�y������>Q�0e/h`�E�Տ��ch,05�&���� ��2N2��ӫu&#���j��* *!q��u�̀��L�r��p�A��2S�@�.-MI!YC>J.h�F`u�������04�6�N�f�4��������r��\�'�rH-�!|{���Ig	��>���E�EV��r�t�jlĥ-��0ZAV����>��o��j�K���x����ՒIfi�R��_L}v��ݷѧ���t���ٻ�
�����G��?���� �؞Kjӣ�������Cढ�x��Ț	��℧���=ș������m ��i���bY��!(��ﯣ�ч���*N�s��8�ISh�(P����vAg��鑼US0���iES*Dt��a �W��C�!Q$�Q�hi!�+/���[�������r�Ҳ/�H[��e��^�&B�58ৠ�+�r݅�EHl Lh�M� WF����L.c��	��,��XL�T'�K������.�jZ.�����"mM�K�%��6+W���):/�e���
����)Z{۫�k�LM� ��'U�=�� �{�J��n�)���,�<�S(�p�[�{F��,}��$D��I�]���"�	h���8:�{4��]����^���B� �PJ.t	q� ���Ӊ$*��V����f���Q�P���G�7ăN^�����d��
jaR�!�☜j.�b�����nvSs�llm�X���)��yJc��q�kutqq�Q��������z>���Eu|qQN�/>�<^��@i4֏)�;<�$,��X���㉰�		����U�_���/Cg-a���:V�4�`;I���d���41/��^�>�0���L܀i�<s,��������fT�����'�D,. ��&�=�E�5%)�XI�9�+#\;9pj��4R�m)'J�¼�xE�o��Nj�Q�:Xu��s}��f��/�]Ig�'J�F�V�S�zӡX��`�O%�~��.��Z��yX�`��J�gnU.�_���돫�Ć ��aQ�d���%x�?�+�R5�bF~k(-!� ���gw|��q�����8,���u%R�~!q���#��Œe�����z=    ҃
̒~T�[h�DtT�{��E@ ��r#+I�	lE�OJ��=�Δz�6�����#����bz������v$���Jn4D�Z3,"���M���X^��̫�&S=�,�˖����zZ7+yW3�'[(�DtT�[���hwEX�I�0�ƕ�|+�ƙ��ډ��O�z�=���}���J7�+��^(Y��mD}?���՛5�HPL�q�H�J{���,6ؼ^�� (D�HKi�.�.Z�j DAC�*XtB�A�A��IIT_�W�i*� 	�i�,����
#��
�V�׼[�V6��S�}�WuBЏ/W���&:wH��֠�c��S5Q�D�V��DtS@Bۤ#�C[֡-�KFsv<Т�^	C(0'h�� ������Wg�8����'�r1ğsp��Ų�kjYI��l���S�bQ�����o_J2s<���n�Fw��ʚ�2���]�o�G���9�쀨��@cJ�l":F��(�@fW�K��ͣ�)7;ͼ��ǰ]k�	���L���W�HqN1�D��o��5��%�եT�_!�\
���=��h2Q�'0 ���4L�A�.��I��l=\%�][Iu�  ��������|m�e�.��И���z�;��h�?^.��e�Κ�K�d&�p"D���cdb��s����L���P����=�������@��8�H�MF��"�+<%����W��qD2kR*���^%��KM�s�*=�]���[�����!���ښ��ua������?Fo�f��JJN���_�-�x�����1����JR~��G%υ׀�9�|�YG!��Ety�l���	D�D�,2�����_3���-Q��v�����l�X�b�+���CN3�{��UD��L��(n[bBp�[���;ƚ��g��:uq�2Ȝz���ڥ���?��2U?��j��,$Q�F��MS�DM��%�~׾ƍLO�n�7,��݃�3}��tJ4i�=����`u� ���q�rf�2�rQ�f!�y�q�u
^9rK�9w)9~JDO�2�����2\���'��V���C��R�M�8n�C�wy�pSx�ñ��~w��8U�yo��{�rk�1��AD@��Э�8�������Iq��ЀW%S��P�����ʛ�X��:D��,k�bpKDi��x�� q)qk�sC&�1]��T���+ 9FZƬ\�7哫P �\}� ����&�S;�_�;��8� 
�lh����=����L`9`�|���)����-n[�e�k�z�[�����Z̾�����B"���=���`e����Z%sK�I�<4��d�TCpA��n,DK*L3D���f7��PHոy�|���v^i�x��V��B��J�R���i��E��c��L��y_gܣ�j ��C"�B75�/с�!)	�BLG0�l=�y�m� �^���ی8x^�QD��#`��~4���yolF��ݚ2����zv�	Q�0��fW�;������@��wFט��~b`ִ�W��E��
.��/���DK�Ы
�&10�9�D�RqZX
u&��1��rێ���9	��s ��h�ϐ����j�h��
�������2��m��e�
\���7�&�>��c2��r���6��_.��[K�� ��]� `�WZ@�Σ￐����f{��`�.X���F>T��Օ�OS�w�N�/�O�Oe��u}�X��$�+8V�·Կͽ�>}F�Ф�	1q@͐3C��n� "W`�	����y�$����*I���@ʃm�g��d`�J�N��0�R���ji�E̜��xl�e.../��������-��N�kP��m�q���ݮ'���X�4}]�m���Q6q_�،�qѺҮד��Q2�?d\���D������h���b�ĳ�`�;�<m�f`2u~U���qB=lDAS�L9�Ʀt�>�Ɋ�^͏�I�����l=-�ݖ��-��Dt�2	�^v��U^�/M���R�E�#w�}Z�RX��O�� �ѥn�t�8��"��)����u{�S��W�����Nn�6��!y���ƕ�N1d
����G���V~I5nl�H�A'�"�Ag��)Ժ͡��#�����zX��$�ݸӑ`�)��.�F�� ���s�m�L�@-Sz8�Zs<�OyQ�w��!%�����\����+B�w����{�bw�׫���H��VqѬ��A�F}D?�Ƭ	��a��O�oUr�%�	\��N�rt��&h�FHр�8 sYf��H�rg�W���>^|�l"Z]�7[b�X��<��% ��+L��j���4��)mI����<�9
�*�݃��ݬ�Biʬ8��1��JGM=�w2����.�ZѺ�˫�n��8Y4I���K�-�'0�����6[�� �0`���Js���F��3�.��Ǐ�A؟xpظf�ď�F>LK]<�Ʉz��=v@�B�s��mJ�.�ƜF��Y� �Ac��ᒅ���$��@$ݚ�!�h���6�ԘX�������0�0���wW�E�Vޔ�ތo�����`��Z����֭���ţC� 6�0�\B����T̖u��N<o���0.|]��I��%�� g&C��=F!���B.�׮Z,/g5t�Zj�a7֒��:���%}!����3QfQ۸�W� "�^�,���":�2�C�1i�-$vx���*o2k��8�XReU��!�U��-%Sq୮ �T��}��Y'&�@��t��E�X�-}i�W���X�4���))�X��"�ڪ��#Iڳ�l�c����f�]I\Иh����6��C�9�U�H�sK�=��˫��x�eR�=.a�����/5elh��4�B� b�d*tVX��Vh8-��%M6>�H���v�i��Lw/���%��)#�YIڃ�n17| �\a���d7(���ް�c����������Q�G��n?+��¯9�����7+Kv/��.��_��hp2Kږ9�� �{³�q?�%�^`I5+ewR܀��5*$��e�n�����נ�6�Y�t����r3Wի���XL��!#���а�J�f]��z��I�$Kk�s  ��?#�����pp�Ms�D,K�{w0�%��2���b�gB����!w����*k�2��C�NJ
!{n���T��X�Z�3��ۧ�{��^	�ZV2@��R��ʑi���8p{�$�����eu���}����Ng8栥2��}g۰]D�8N�'�����X܈O S`���qx`1+_�����O��2�5� l(�5D�>˷�训��b����ƌ�@�e��2Jro�Y�p��Ox���\))���x �v��O }��ٰ���B_�og`��k�{�t�f`q�}��46o�� o�q���Ͱ�D7�j����K�3c�.�Y�!�U���J��`z���L'	�@ho�a0�AF�,�YS�]���ǲYR�$�oK���3Y�8N��7j�@5ES���ʯ�4$	<�+�yo��@+�`M4��7�·�����1L�������ԫ�zW�\o���H�@<pQ�z�g�E�=~�G,����bK��X6e�'F�r;�WOC�ρ(OZ�tww���:�����=��G1� 34�����F V@�
�����X�K�+ͷl,|�K�-�\N�`
���+�N��)� ��*0���u�wQb4n�������������%� X؋��)��,�D�* N&I�*�fOЭ^%�����z�bz@����ߒ��X��C�%��;'���d��;B>+w�g]]v"�\p]��9KZ�x�%p��W�P1����/�������,(� .3���s�|(�aqO&;Q���r�r�M�˄��Wx�׶�}��!���|����-�ެ�G�d����l<޹�h�X�aY��yL�л�k[EtS��h��ǥl��Y
&�G��a�y�b�!b�v�iÛo�ڃ�&�Va�D�p�����Yu��Vk)~� ���;#��ǁ�Yb (  b���ח�7�0���s5�y�ߩ�>�j�˒c��c������v�4�]8���;��7�4%��!l���"��ؠW���A(S��*^�8+KhA�;�Иh�f�,sU�,6�Z%�u�ړ&(�K��s�o����N~��^�j�����/��)@|%�ȜˑQ����o�6Ye(&W؈�l6��qf,���R�� ��Wu������-7K�<�d���U��Et�2�a7��Zi�v�C0��z���!v�Z���u����uL?���b%���iɭ"��f0y(�VC��F���|��|��6�� H�Ë�m���q��0����˔^.ߗ#=?���eo֋<�nφbw�{�#"��&��Փ�gAc����L�s�[u�S1�> }ANl�[�"$��Ђ=#z�.���D.�fN�g���	��v��`�΅�"��	�1!J�Ť;E!O�Žlf�)��l�Xv�{:w�D�>R�:cf�������f�*��Fߝk��#�^�Gi���F����Կ�I"�"y���o���yCTNw50c�x�=��?ˌ,��;�jvpy%=p���d�Y��
L���6�]J#��H %��h��2ݿ��rX}����D���x��r6���OX�k����k(~�D���y=����=��&A8|��Bۄ��v�����3U�H�`62�Ib�oڶY�lMi�c�T6�\�;u���o�"�ŕZ6���AD7/S`仼0[�_���kĒ3��F0��a#���="�[���u�R�^�|�W~���9�T��AD�_�z���ea�      �      x���r�H�6x��)PSmǈ4�$4;hY�եSHr�kGGT$���I�'H�TW��f�ݾ����&�If��	$e���vWu��ڶ(0���뼾e���۾T���i_�<��"b��*�2�	��[31�r�7��]�,����?.���᠞���g�4/'v���O�2������j>�?����^�a�-���ի����AmF&����O�A�����l���ؼ4�2�0����l^��l���0փ����׋�:ı=����h{�&�f���y�g��eF���h���B��0HC�9{ါލ_a����*���Ͻ$I��o����Ӌ7�͇��� 9鹕��z���6���Ifl��De��n�I����(�:a�'��z�s80����y�.���Y��/렘/K8=3���s[���]�����#3�?lP�sx�n96��z���������� �:��@�H?�2��#�YS�����]����eC�«~Z��CP�;GX%M`��G�����4�u�8��g�D
oA2��
�6l`��V���d<TKld�x1z�٢��AQ�݆�k36y�zͲ^��'e�0��nR1�&0F=�_5۹�[�VQNf�|W��W����v�&���{؟�E�٨����~�U�������fc|�Ȗ� ��2++<ñ�XM�&�����(����ʏ�Z���/�\̢���p;�t���"V;ד3��d�H�(�&W�,�I�M��/�
Xx(�C�:�1û��ڷSo�N\e���</�3X�ρC$���%�Y�������qp>�x��7������zn��ʨw|��r��(����RR��~�Zn�L�`ɡ�-���������L>*�+�X����b�t��N�za�M:��$i<��kr��n b�jFWx�L�Rë��/�G@RvT��o�:�8���ݱ#eU���Z��/��V�B�����~���AJvꁊ��t��"�p�u#	L���� �f~�������x���Mpuy����I�8,����x��g� &n�J���s��&�,OX�dO�8꽶X�۹�f����vt>L��O���a�;��(�2۞)H)��J�w��*�]>LI';�)�uu@nꯏ�7���㋣w�jd,�����.*�7yN꧝J��̔R���Ĳ���&o��
�M�ƌ{�_c8�r\�C�9[�Ja��3��v>���y?p�1�ى���l5��"a㓘��j^��Q�x���"���N^��zq@rv5A|�v��y�	XI�\�lj�AVC@2�ߚ�������qRen>���a�0�9Jƻ��8��ஂٯ�A��Z0�a�?�O�d,mF#^���r�$�����)�j���=��f���=�u_�����)�#&U.�Mu܁j�Ҵ��~�v�8��l��7X�O����n�H�ȸ��fZ�B�HMǡ�"5*R*a:�o␫C�02ސ�p��.�j뒱໻�h��yyq��<����U���������;�@�2�"���]���#��i�	��^����	!R�)s�)j�wU������/�4;@]pa�����j\���d�
,�	���Ƞ.�o"��~Z��I���k
Ox1�-��F�!�¯(�E��%$x�t	�/"�l���$Z�9��g��������!���o��z��^��ݼ�jb��r1/i���`N|�D�ow=��n����]-QJw��pf�"#���j9�R񈀕 �����GX� �;7@�Jx��~�H����û˳����	��gN�{n�p�^cxƌ�Q_��4r���<
י0ޖ�����h4���I��l��O�#�8�}̎�(������I�*�h�=�oJ��B�?5j�@���LR;�A:L`�313B�[EY KG�	B-/�с7�@��hr~����r�;���o������X�ITm5���í�@��g�̀�����yu�
r�x,��n(�]��ߞY5�H�ܙ���LM-�
� o��L�H,�'�9�8-���$��	nFՌ������v���W�������Y* �
� .�dI'��1)v�:���Z0BDJėz�Ӊ���.x�T�V�Dj�*D!������+��=r�� ���ZYe����W��b�.ϏO�,�W����ϝY9�7�2LYIJj{��\b�QR����@Tƽ� �����_/�`�@ޖٲ~�0��p�:N�I���ҢCj���rN�@�5z(�sK:�ܤ�{��u]+D=�r���_Nj��N_�������d^��f�7?�~��u@u
��]ϼ��D�$���(�Efr�P�-508?dl���Rs�?�^[��|p��N-�7��ۯ�_\���{n�@QlA��&/����i�lf�eLې'Eѓpz��������+0V��V?9�jiDD���f�Adwnb�E9�H���9&��A�65���W@O��@��]�;hY"�8,��5�ߋL�~&b��t��4i[�`�}��d�3RN;�u����7v$MX����o��������V���������g+5S��'���\�Y�3���D�7��:w;X;/�'�^:�3�A�����y�!818����)4-A���~�m�� ���3���e�K�7�/���KI��ɢp�a6.'�b�<`Z򟂒 <����?�#��M6_N3�~ +^�:kA��YӵP�XґGC�Ä���IiE�wN����8�
��ZO����C��DR�`������Ő��6u0�P <E�u��ɂ�d�1o��0���HF�2a���	�"�9��:)�eY�ri�6���0Q�E 0"��_�C+���b���y�,��PGaF��2ꃡx�����yc��$��#6��W�[9� ���z�$��������[�2Ʈ>�֕����1��ၶr��	����
���0��U�q�	ɓ,/�� 3|�3�?/��ܝ}MT�׎��NQ�M0
	��n�����3/�F�&|V�;-u1���d��L�j����� �n���$l���Rr�da�?*�黒��8�H�H2g}<{���'Yx'p�؀ÿ3įjxuuv|޼;�8�����-�� �*F{{:	%�GDq�h����DL���T�NR����c
l.��UTɻW�W��?�T~��y^�42T�6YkgҘ�}[Č�0S�E[D Z�J�V��(�?�?^��a�A+�Lb�(�hDZH_�=��B��T�\��aT��w��Mp9�3�2����.�y9�����uA��Xy1�'����w.��=����,����-\�#�Wu�t���*�-ұܥ��;ԵV"���S��D��(K
S���&���C���H4�C�`7)���@�����Ȍs̐�S����;?��g��sq��{���zh�2GQ(�X�}�v�&�r�X�hT�ǥ�xg�ox�<���2� % ��һ�Ƹ���Լt�"1�qr�%�9��f%���7k��3ZK��12�Y����a���,�NƓ
]&���\t���,��h�7BìԲ���*�\#�aEe��f�� �Lh2�?D�瀩���q����;=;;N���/VQx�ga膫}
�N��Tn1�51���UE��I�mD�u�MI�=�4�*�2� 57B��0�,p�5'���!�z��AQ�$����(M�&�fh�,˸Ș���JW�DOH����w�	��T����̜Ӆ�CC	OtD���z�WX/�Q��
|o�,J�'�9���#S�w��+?yq��@�~`��5��Q8T.fR�_@5@�o�n�ټ���mA9p��}�@w�
2�8忁�c`��.ki��1|�3,%V]ĵ��~E΀� (�����
�hDN��X�U�q�C�s�����8���%65�� �в6C���&�z�	~�迣����-J���{�]�$n�    �.!wΥ<��q��U��6�>����	O(|�Q����}��]��y�,lE~�e	��P�Fr�$|;�#�hZE~:b/{`�]�&���fND"�!��\=��m����ksW��:C�y�zyʐ�֠�_�ܟ(8԰��#^�l`j��m0M˶���i��l\eH�9�|=�I�~�v�+�
���m�u[�o)���4�E������ߌ0vY/�zQ.�59ƧH���F�ݨ��o��`��M��^P�+zIZЬHǫ��C�e5�`����ϙ�k ˣ׮����	5�,�~ԉi�*D�%���耑�/�4s��mʐq�ϋ0QET�,��a(�^=u�����?D˾`Q��/pɆk�T'甾�f~=<9^���?���o�����7�=�`�Z�rwB���h;�R�D!Ȫ4��w�[t�`�0:f{g�Ti��,d�3J���PxC���O�Y}u������L���-	���S��~k��=l	���IM����g��j{~�%[4 P ��*ᓨ��ZI��Y��}�� N3qܮ�!�b�wT��E�b���J�y�i�/�D& �%/�������aa�mR�
�J��3-f�#3`�E!w�������"�e�K�'�5�e'*�~3JɽY�=�6`�&���y�~fPuO���eAI���87�1�)4��AL�i���!�c�|�R9ͨ�/����1Լ���U����v\�m��&3�N�>O��~\e0̑M��.7	G����ǖ�n�_dSeA��Ε��[��=�|0|�3����bQ��6p�M`�Gt�
ŏz{�m�<k�y��/�4OX 7�q�Cl|�\h��#�)��� :�|.����������|x{\���"��"�&G<-n�U>��C*���&�4��6��Eb�#�|��
b��!(x�ەZ%:XN)lS����L#��TcFHOH�����>8GN��n$�V�O�eo�v*�k�'����w	��bGv^�˲�0dt1y�|�����vs���)M#Z�V�dX^)x�r�-ی���Y2�L��R��Ѣ����U֐� �a訂����%~5��o�ΏπXSD�Bt̪}��*��0��6oJ~�:ԱQ,��U,F�@�.O���.���ro8u�M��X #(�P��h���	�4-�a�X�,e���k��RM�x7����KLlI^���h\h��?��F�mT��[[Χ^�~F���&X�e}U'���Y%S������}�mbb0H�5M T�~�"�f[)�(J&Z)��˼�`���3�c��.�de�5r����486Bl����_zn���ܛ'�u��̫���<��8N%7�Bh�@k\���r�;���<��9"�%V%a�f�T���)�U�lV���o�5B�f�<�cRx0��uQ��Y�݃ȿ
)i��*��"Z#��+���$k�h��1�V��XuK��ùn�f��0Y�AGpK�5��?�����6��+��ڔ#����x���5F\%��h
v!4�]8�Ҿ�
��7�*���]U�[:%��X�A�PЬ������U����&�����[�s+5:G�m��C�����{S&�To�_�ދ��'\�bC���;ޏ]H� 1���+d⼅�q1<�z����Q6�a�Y��Bf���I���'<׉�_�l����
��ǂ�H����4��&W�ƒo�%;Tрq�0R�;������x㑙�e�:��nF�dl��#�� ѱ�^���
���`l�;#X|*ф���+�o�Y=�-Sһ�(��B�SN�e�Wu�2]�R��C���m]ڏ̓X�Wk�z����B�,�v�|�1��?��Ol�ѓ����I��P�����#Ƀ
SA�������:���~4��9={�e ޜ��vr�`嘇�����Bqg�'�dl�I��D$�~�E!,������|4p	&�e�2�0N�C�������i"My�W�&�S�k`�v~���?��H�j��vu���E� H�Q2��b�,P��Ӥ�8>�> �6m%b8_I4�29���?686���f��MLgd�3695i&�d�Dq� b�%R�[O��N:I�;�v�16� �@�$�}�*`/���[ٕ*>�A�4O\���h�~ܿ��tUmN������s'6�%��r_���ih�l%��rfm?,Qq�"��_%��J��MXGv{/�>[p��F�GD70�� >��
�eK���[E��� �ykMp465�8��'Ëӣ�������k��U���%�x����Dw��f��E�d�e�.�zT}rc� !n�o[#�1O��]i�L%��ښ��ɏ%�
�O���V���`����n�>+*˘1�'�&i�۬�A�J�"OXTl%Y	�E�q��pu����`���݂5Ûi{�	���apt6��	j`xܞ^�ܪAL�{�>Q�zGռi z�d&xfA�`<� ��.2���'�:'�A��j�'�u��W� �e��mCF~�-�(9!�/ӕj�c��$�*Zp�p��,up`]af`�g�R�ZMU��E�;[���˘�-Զ�4<T|�TK�v0D�g�n9�5/�����)(�����,�8}�.��K*�,zo��I�9�����
�̖R�mҦ�4�A!�S-����vI<� �<t���0��
�~�cV��Z��#���?�&ˤչ�W����,Xm#�Vn�L��<U]�9[�^`��>Tl Ll#���!��:�ӳ`��<D�uR���臅�"e\�"�a�foX{Pη���![���$QMM�{�Dy�(��*0]�I6_���G��Y�s��IE�RN8;&2���l��e�C.���7�+��_�����@�{�1�kR٠'�E���T��uZ!�'��^�H�bR�3»"R�U5f�P����E��"w�!~�mYؙ�Đ�ߚ�!*�V:C5=؎�T"�ď��Ɓ�U"ӭf��-[��0��A���_���o]�5�p73`�e�T!db��I����Hl�)�*�,ؐw�`�M{��x` �3��׏�;(��׷p�ޞ]~8��q��\�;P���$�[�#!O	ӱJ��������<s���k��"W��JE��IA�Il��qa���@���:�RŞ=��J��s)AM��v�h*�~G�$���Uu�ʨ����ΈX�!�*�M��|��_�`�ߒ��D�D�5h?!�2��i��cw�G��gm�Q9d�7�x�ˬ�8)����U�`��ZCl��c9sj�<w�}}z���Yp��l����N������4[l^u��G�/b,�9r�����"i���@	]��wtQ!�,�d{�����e�7+�d���À!�$Z���g=�ͣ��綯,?�e���W�kU�K5�)䢏�b��8/��q���h�G��&�`���"ҹ�R��O��Дc|�L;�����sU��02X�y-$U2�¤2�1Sy��a��f	�1۞�ӝ��$8ېu@�Y8`Z
����O�_�ժ�MT
ޤ�hS�$ɘ�{B��c(Ǔj����lc�5���4�]����u�Š����M� �tn��̅���12��D�,\�
-���R�T��ISe�\�e���RQ-{C�%�7�x��uv�����śFej����ޛ���}b]RH�a���+��]]Ү��~�r�;�4/�iU����2ҕ�F�u�i�&}R:�O�Ă�ApTM�S�1G�<����؁��3�35�&/:>�b����0U*-0/�/�T�bA���^qT�.4��|=ޗ{�m߭����f��#J������hk/(}u�Q��fr����D+#G�5y�9�JK]Wv�Rr���3���v�"X=��)H�m)�Q���Mj_EC�;_���2]��~�����&�s?�Τȱ!�YuJ��8�\j0J
��)����ep�	*�`xk��9'C�;GCq����.�rF��s6@�?��V���ާ�{:Ȗ�l	��]�3sor$���eS"OF�)`.�Ӵlح    p1u���e�z����@#�RCLo�AO�q��1!��}�?���ߙ)
���
d� r}����k�A��r�l����V��nm�
ZQh`����:MBk"m�e�"$��!"�bC�h�/��gd�o�N�l���n��얢��goN�������?�G\��n�H��j��0�>lM�$��c�D�JL���[�-b� ����CpA��{����V�����a���,%$Ӭ��s� �k������ؚ)2��2�h��7G9Xi���ܖw� >[����)H�M���c��T������1�eM�S���z4�&b~�(�\66H�%s��ꈎC����X5��Jp�ց�̰���Ф�U�����`t��@%�������PYZ��	?ݷg�ﱺ�����U��������ś�[(��ro?���yj�6��Y�e��<�xZ*c��c�����C�p�n��8˥y&���c�t�Siu]NJL��,Y��|�6�s)�O�q��S�wZP/�[�Xvwm��~\��!�"0J7�: "�X;��%�{��zV-�����yT�Of�ʆ�cAyg������J��+�p1]݅�E-Ev��5xSET��)�}x�*��2-�I-!5�J����!ڑ��?�TΟ���m����F��>*H��y���&�8���6jpx��`Q�̘ů����b�.�T�EZ �1(�"b,��F��ٯ ��	���!Z��h����t> -m`a�|������t�i�I� z�a����^�I�H�M�������@ߥb ��U.*��ޏ�8�խ&W����TF�H�a������:��m�iF�5U���'(��4.ɨ�Y�v%��G��Z��ԯ��������x�~ ͘��+���ܽ�74��y�%a�>"$�42F��l�
A���GT��~���~�H���|6��u�eQˌ3��脱����D.���$�&�?1�ɻͨ߭)mr��"W&��{!�$*�(1�V''Ъr W��i?�'�d�:B�-���&|����[�3�5GI��mR�
���-�L�Y$h�ĜM���!~��vЭ9�Y���k6N����&�ֈ�)���AL�s �Jy\U�r;��O�ޣG~<t����&�7*���!Ta 1���݈u��o����!�|�%ʨ� e���eR����rf�M{������Br�Q�":&�pI���8)1=�s������a�n�r�c3�Y8�N>w�!���\�d�a���Xu�uY�4썆*Lj��N_��0~�#Y�Q�uh��q���ɠ�����d.)}��;3wՁ��sD|��&J;;@��{L����3jLyh�#���N�۫r� ����
P����A^X��v��2/�\�Ƭ���,TG�AZ>҅My�)�Ld#�݈; fl�nU�A�MqciO�1K�"���!Z> ��ߣ�Q�:T�7�W��E��(?���ZH�EQS�����b���"��fj���-j����wo0���ˮ�]?�.�u�����`;{���I	�.�l��>J	�A���¥�?{�ֱ����@`28"�S���q���@{�H	���29Vٔ_�
:1�h3v��Wkm���v!����S��I*��d|�T�5%�u0D���i 󤹟��q�ų����I��"����� �oG1��ï�W(��� i���~�Աz���F_�� c*�j�P��}�|�ꥎQ[t�QGN�S��p��n8�Q�,�D����$<�(Q�&Ҙ���@�����u0D� @n���@0��f�x<���w�����
1��믴譎��^4�E:�����* u������8��������iJ �B~��+��w!�04j�}Yy����`9\�;h+�ź�J���k���H0���%h�+��Hʤ�\�ԑ�V:<,3B���&�J���n�O��~~��Ӧ:'�Kٽ~nZ~�SRSѓe��#���O���i��_K��J�>��r���2.n��=S�c+�B�4��[)v����t�0�M������H,�mn)2ޏc��46E�ᖂ��2i:0=w�����6ȁ��ڍ��jr�������zn�`GE���v�D�zo�殚�FL?�������`�̧q#�, �!����:�NrAW��S��@:����xX���Њ'�^�kL1�hZ��!cы���\ߗ���D}EJm-H�ln���Mf�/J��W��=��e�yj�ԇ�x��v].<��SIWEPqh[��x�XRX�F)"��{P���0ys���:����8g��?<krۇ�L��U3�X�ޫ�A�Q��6a�a�@�9z
���;�� 4�(v���r��Ǳ@_�� x���T���r�ys=<���^c{�U��*%�ain�|�����c�����^'&.��Ŋ��9�Q��8w�$�1R�<�<��X��r�4��$:��M[h@�����NXL6N�0�*ei����A�U���C��Ba�	�C��	���I*Mb�M#0��R�wm0�O����N<���'�,�ׂx�p6/k/˷~�A��pӶ�}���V���Sw��%�A3mz�M+���0�Y�5�x�	rU}ʑ$�{'Z���y5w��6c��3l�KR#2M�����$�a�hgۄ�0!l.�0:��i�9pܬ���7�7>�!�PK��&o�4Jmf��L��a� ���B�λ�w�+$�T9���L��l��,����Sy���Łk�<���cًN�����>��b(Wf������=�	�Ho��E��l�T������<OC%v7�6	��	���C<�|���t5�zs���Hw>�7��x<<^�S��ia�׈��{����݇.�kR�?���:H����c��	ؽ?����{wGj�ǰ�VAS�M�)�x��s��I�+p�0IF������f��V<w�d1[�*�"�h�	p�҄�.6v�#�h��$�Q�$ۥb!�=w����-��	�*��`��
�=�K�j���׷�������h+�vc�b���H��ji����ȋ�QU���*�/ۿX�}�f��qL�%�� &� `z�%0I�ݩYk �kn����G� E#���gq�
М���:9C���� t�րtP�$9_\N��)_��:�b��MҕF�r?�_Z:��Y$�觱�<�Zs�v�J��H'���;�����rZ/��Z�k���~EG��g�S%8?�8�$N�	���'�����lm��>����W7�>)<`��"�5@23Y�%+�ՃQ�� x�6��+�iLA�r3�6x��pJ�)�Ś[,ҹ9;�"লG�}d1QK�7w~,TaS��0��B�P<��ǩ���vR5d~�G�N���ɕXmL��A>?W�~���#�nGL/2��E��T%i?"^��i��}��0L	G�B��?D�3�ÖԚ�N�%�HG!Т����Sϋ�#� ]ʍ�PA������ѿE,/�2�=�+�l�L��Q=�qgly,T��&B��"�E��9g������*�ʵ�x�O׽��8zw|��K���}E�O;W���in~��v�XRz�G꿑-)Wkl��̹/��@p��%!�����\�!�F�-X����:T}�(���"�a�S�(��R��!~]�E����.w<�n9�Gǯ��Oq�#>��≇�t���i�xlg#���E�`&�_���sj|r�g��)����v�R]��f���nj�b��}h�R�?��e���C�!
�}-ֳ��u�Y8�,���~��zx�4������%��xa�`�`#/�̨^N_6��� c��BT6g��\�}��t�U������xn�k��/��}�)��F�Se��͈�4l瑑F�z����-qL���!�bz�����H?�������z�3'�C�;�T<*;��5��$]�콵��|^��U���iL�Q���������*�T��Չ~��J�Z�x��Tlŋ~&�$Y�s��q�h��|1w~�g�ʻ�ٳ    �` ��ώ�/�*�����^_�L�`�%`��u�*�y��N2Q�D��d3Z�������/�!�����2���a�埍��8/�	�捹�"ʹF8[�F�� �t�YG9*I��׊�*hX�h3�;��g�f1K�:��JdU�mq�s���y� nBp�$����Sߝ�D3���r��L����������h:P�4�&��T��sl�)A�����;2�G�P���,��	���TD
��m��^�T"B���C��$T�)MځR�ڊ�7jFDl��sD\$a��}�K�E^�<2:;fH}͐��3�B0,C,g\�.t�ϊ"�D�y'[ׂK��T2�\���h��n�T�'YΊ����ܷ��`��s�D��+l�o���ca˴7t���<W�%P&8(�y��y(U�-PXt�2�������C�9}1Բ�l˵��J�3YX�����y	�z�R/��9أn��8�w�W]i���h�<����2�X�[1�\G��Z����0��ق�1B�S���h۲��������^�g���A�h9�[�@��*�'��{7���h�fj/NF�#(�/W���Ɩ�֦@�,Q1v98h��L�Z�V�T�:�0��<��=��Ծ���Ws�:xPS�j�/�M5Ũ����^Px���?�<�O�3�%�9�OB��*߷��A4��T�|�l�؎�+���t4m�[�7C��1o\xt��AQ_�����} ͥ�&��x��k�2��ܴ	 �yߦL��E4�]��� �>3Ę:�m��s��(�3�yw=�~x`:�����_�G���=�t���MT}�P�A3����1��rX��='�A��4OG��B9F�8D��G �����:%Ğˉ�>������!�;3Z|BJC�/�7���\d $��r��kI%��:y��� ���L�|5�t9G%܋^���xD��y-ڪ�UIW�M��u�r����E໹��A�W�<X�*��)�����v�'V����M�[�����SU�1���4���5m��{�I�bcq¡9������sL� ��z�,�������$S�5��f~��Q�I[�;MDC7�;T�(8�h���B�.���qj����d�	j,�%�(�p������w��P�)�ן^|�p��M�5F�W�/oς���qϭ3��U��fÎ��ocD�V&*l��V�տ�[�i�η)��J���К�+�)�T� �N��!�9��i�:����&��%~�d�z«�>Ǵ���1��/�E۠w"�����,�U�&��y��\%a��?ۼAL,���$�X,eA����EؖV���mX�M����"]RG�UC�t��Z)���S�^�DԜͩ�:)��������������M��j��紗{���D�X��s((��cd�]8�3E���s�!xfB���J�A�kjRųHG���A������n�?cB�{3��<�K�m�����}��F	s`�����?{�?|�n�*��@7)��Awq���";����N��[��6�J�%���ap%�д�]��۫�}O���1Z�>��{�b*qg ��Evy���JO�>�4�/E��$u�M���A'ڥ�v0�S��Oy��B���M�u��5��s��@�W�W���������!�����45EfZ]�t�B������{��V�,q�d:L��l�X'�����]qV=U<P [�)�sh����=���M�c7�?�1xd�j$2�d�q/�W�=���i�Ԯ��C֠�m����	L[j|�.i	N]{��
�\24˱u��x���%�ik<Z��e��}^�xΰO�gf�3��!�f�c��5�k�t�J����&��4x���q�)Li��ұe�Z�b��5��:p�C;�H���f�&_!��}�A�P�v�T��H��EV�n-���c0��η����>X���]L��6�vfQڅ2G�b�|�����y'��E��Mi��<NU��vE� Z��x�8P�����;@o��pc�1]��b��X
��4�n�j�j8=���ߚŽ�vcn�zG��JW�!�_nc{.� ���rSx���7�rpi������
��9��������иWAz4�K��4~�:�Xz���}A��6 ^g���U��|J�9��]+�]^�&hd�3���D=�̃8�t�px��S����^K��5��GJ�\4�9�5�
�MV�U�L?BȒ"��p���x��5sF
���^�߁���o���7 �1�:ٟz-���'�fF�m
�5O���X������0û�(��p}������\5�/����u�{5fo@��������Ek���?�M��Ё�'܀���\��u>{?���?:����+���;�����@;�99��>=&FOSM}��i���ܴZ�h:-)@���x�+Q&�<�uv�]���ݪ>?8�a AY�r�<�Tdads�]�S@s"�=�>7�=}��|��Gﮇ'�D�����Ţ��k!���o\3����YfB˅�����L���wU��~j{HG��I�4'>���/Fs4���k@�j��3���l���U�=���WAm'e��?�^5��<��g��푲�������k��lӵj���Ra��$�w���ƣu�<����u5F��ճ
1��F�cF�.<�Nu�+�w e�r2y�M���O��+�Gڽ]��I�J�m�`iƘ�pj�mp�YB,�	����hi�,�a�	Z�'��u�X��+���yx�å��9QpB�ח��M��F����v#$��U���=��zG�ߡ�bC�7�N�ad���Ce�Y���`����M��n��|I}��}Ew/�G�Ћ*Ai1�i���Y���p����!]u0��k�V��b�"�
oT1(]�E!ᦵa]X�&1�g��TS�>J��UӸe��凅K�ӲvlbN��V�&�r�:�2ZR������T����Gʿ=ۢ�)�-m('<�}#x��(��|;��`TI�]��h�{��&�<�۹yhpS��G�l��_���ůixu�N���4<�����IVV�{A��jEYA%��|�f����*��� �$��k�W2�G�ɟ�gd�b��F[n>_����if�o�N�H�`���S龌�}������Gw�E�l�dg�<l��*�ڻN
	f^��{"�4@yJ�ø���3���q,�`�T5��>�-�����y/A5c���퟇''��?����7�/����ֈhh{a̟�a|Չ�:q����m䛌ɾ����S�����>�A�"�����ԉ��e}M��}�e���d!��h�۪�Eby���o�5�MT��)����Ӳ�v�������{kEjxږRI$�~R�F�Pٮ�&F</�`D��%��O��$�W�<�*I�q����'I&dYkG��b}��Xơ�R�mE�ex�W�#��w0DK���fi�9o�{49\#���uԟ	ťC<آ������[C�n��)X�H��z��K K	��2/'9_�>b�+>���:���]}���"Ų��d�ۦ���yj��t��fV�"@>`Q�(�mu0D��?W�T�LR�M�vx>A�&��p�-�=*��'��M�RK���c��Eh��>ʯ��OALEiK�97v��es�&֦�2q(Ԁi)Jh�`��|Q��,ʕ��|�L]�XX�3%"�^�>����ep:�,��`f�-��� #�?����eܐ��T���ZL�!t0�,�W^qB��j���U�d�).�{f�M�n�́lt����(�jmJZ����G��]��� ֣O��J4���S�W��ٹ�������N^���~�J�.vژ�	���w��s�B��b��nR�|�ˢ�ͷ�5/,W��l�m���a4�
��k��!Z��, 2%�l�y@�goN�������?l%an�H�p�,�r�:����+��@�wI�J.��^�_{��>{�f�ɔw�;�:�x�m    �򐸀Kb��!Z>���k7,7q���<�4����d?��=Trz�.|wa�f�y��"!�P���k�rO=x��߶m"��v����y����^C��N"e����{āy��8���s|�R���Q����t)@�3�y��vlO�9|��iD��"�{�M��E.���C�.C��k��H5?L@��qO<8�P̻��z���M�X��6�����X��h�VNQ�]%�F�#m8��-��0��,]�EYa��f#ᱲ*7kC���)ljZ�T�`����v,�#$# �he�7�t�^���bxr���E���.`t0ڗ*Ȕ5h*6xg!W}V%�ya8X��]U�O�"<4�F(G��H�A�}�)��t1�jJ� S � J�`,=�����G� ���z9��oMM�@�h!&ER�.}�|�V��)P�s�S��JH��c�4���M>W�M%Y1%q}40��B(�<ό��(�a4PHlg�cP�(s��!�������^���0��XDN ,��f�]�6���E�h��~ßԯ$���0�A;��]���������c��~�NG�D_���r��
^�+,Qp��εMKW�G��r7G]H�=�b��)&ad��ז
�J�6�� ������p�0i6�k8M��w�1q�>�Aٲ�k�0X�R���Fg)NU�E�ҥ.�OD:��E��Ֆ�g!6�T�=�>�_	r?�� <Q\^_��99~�X����/��*Ėa+iӗ���amEߤQ\$:.bc1��{5����n�����lCf���Xx��O�]�\��D�9��5n�g����/M9���,�� bA�u?B2���V;��i؟����B�%�?S�{ݬ�+b&��/v�/�g���)����Gp���5��aj�-G̛�\�U!
�&F�ac�D6�,ry�0J��`�!�k�K;n�K>������u�m⋨��P�S!��8�U����7��>Z{�Vɜ�Ao-�}at��Ka���Gck��E��5�턗����Տx�xS��(&���_��*К�$�Vg��z��0�g4�w0į�"�����%�S7�.�Oޟ?ʁ(�jeғ�@���k0�������
;`�}�Ʀ�Ӹ�pV ������(��9�\���)���A��˸��d�%�w=�P�����u5q�n9-�z~�_|>�~�_P���g2���� ��e��X@����r,��r��y7��$Y��hH��]���t�OD�P��]�Þ2R,r�D��WHX��p$�zx}v���2�&�^�s�����L�r�}!,cچ<)�������I5�A��w��.{7k_y��u����D��.��A;؃��`�7��x@C��E����	^/�Όpi?���w���ȁ:�0-��5�/�%�s�|U#E�J����al1�G����5��d�;e��M�9Đ�1%���7},S�*��M6����0Q�``\�¢�A�l�:�p.َq���N�
�"���&Ylc��<�,�m�6���+��j&�uC��]�_��Fn�a7��N?4M���������`���s�&�e�C��2����C#��k`׉�Tv�Wk�ﷆ�$�a'����E�Kxf��"B��P*b.g��C|9k��"�8齃yV�J�	y���2���y&�W,|p�N@&�l���t�PN]���u
���-�
�o�[�f�]Eq��U$`�L$E��WY�)���p]��3���%��d>�0Atԙ�1���4�	.���l�D�e�8�v�U�4(�1�������!V���1��VNGxj�2�
zܪ\i�ͻӋ�[l�r}|~
�r�D�S(eE�M��8
�xZT��k�\A����R���'g����(�L�;T+A�R.iɳ�<����S��2!/��P�tO#��]P�ݫ�+��a*?b;�݆�,j��X�����36����,7�%L��,$@�򐜁��nq�aި�����Mprv��x���#���Koڠ�l%�(���
&�K-l�Ğ���3Q$��<S���&�e���ݻ��$�c�ӰU���C`�fJ�&w�:�_Io� ����X�N�2j�����$�a)��A��fe�
�s���w�
[7�k���To�9f�4R``����}<E���q�v�ȫ�R�4I�̚=H�<짩4V�y��qf�p�Ar�����-{��&�W�E���2���?{n���{���X�a�gM���(��d�>�{B ��">�o��{�s]��D�f��#�D5�e���^w�%�b��Z1���f�'�,��Z������j]���4�j|�-J0 Uf��g`��$��B6"�뎊j2.�zo��?�e#%(4fQ͝�X���U�gt�z����D;J<�!i(�jc�������t�5�-�\at(A��A��pi��fT�i�%�|������m����F6Q�[4�R�Y�6�*t��>]ʀ�I$���E�:m�
p~�i��@Y�_�Ws7�i3v5�Kll��S���f�����R,�1 UZ����`�_�|zQ3�&�����軕�J0&����FH_�o��"dr��@���"թ�"�fۿ�D�����N�?��� �$����A:6�f��c6�U�Kǻx�����"e���x{��B��H�A�m;`�K�C��w0�f��Q��1�f�?�`P��>t�\h#2�>�4.�,�&[�_�j�@x5"��B#j�Qq�ϰ3j"���"��f��'�w0���?��7�k���j��W�z."4�C�*V��I�x'!,9Tр3%��{��nN_�Z���p�o���䪯��S����yѿBm�쪾;|�ÀH��l�@���RQ�ѕ�Z�d��=T+k.��{���H�x�7�\�IoV�����
��lEy��<1�w�#�m_�B)e�'_k6=�d��WY��w3|�f��+a��4*�M���heGK�pK2&���!Z������l�zS�*N#NI�5E�O����&M�4r�XV�J��?�B���fPW	B��>b�������/����[h��z��K�����_�y�d��.>w���Ẳ&/C+	�J�,5� �`l.��W�B�B��*]P�iځ7Ag�]�D^I�hF�+�`�u�+�L���*�zV�_��pu�~R�����0���2��Luվ��>��)s�|��4cnR��)`k��#�rZ��Gh���!�E��ex����$%ÿ�!{�s�������O�
�.����@���fə84X���Gps��ތ��{��v�^�>|�vR�+�*�ް�9���ب��l�;�S"70]0M�'��U�\ЦK=�TU:�Y�`-��ˮҁ�G ���;����(���a�&y4�7��t�P���X^�vy��=)�2Q��jb��x�M6���S��3.�M)�͝}v��6$��H$��&oJ��>ӧF���LR4j<e�a��.�5:[L}���l�p���ƃ ]��Dx��������@�T6O�酷���u)Nθl򑖤��L�o��P̌��7���/�ɍw�G8���gVM*�P6�7�&�
��/���M_Ҷ���!�N�W�3�g���zK��v�j�բ:��`���vG��b��1�@�f1�6kef�B����Z��ۙ�T1�!�L��!Z��.�,	IaҪ��-������z���3iGk4�^Y �M�0�t��j w�`&�#��ǄNz'ԙ{859�?���bx�M�z����=���u
�A�	�>3u�MY,���w ��aBf�?���s�B�>��ȅ1"�me��M��CT˘����ҝw顝���1]�������M�h*^a��7=� Ba�b�(o�!"��3��6J�E�g����z�҂@�����z���zo�y�2g[��`��	ټ�p�k!���b��6z�\� �^�S��|i];
���̀-��U�o!���gf�r�u���;�rU�|�����`6_N	���^[    �⠮���;h��J��x�(,n TVD�m����a
���e1Jp�++��=į�������F��TC���l�6�¶���Q�%Eas�Ux'���OBɸ�_û���n����<�0c�DY��3;c�%Ȣ��2&r�`���r�-:Mr�¼�]%S}����r��0�͌X��΁u�`~yٻ���U��~x���]&w%�HE���6rd������GyWW�Ǭ�8O���k��(L�%��Z9H1Z�!5���8� u0D��?�o�|�эh�X�rq\^�^^��_�[e]J.]s��B�+�DJZ�9!Ϭ����),]s�lh�܁B�FF�Q��`�/��$��8�̨�+i��\�ܚD�!�$3�����j�������E������5.�Xt4[�gUm	�v�U��L��OzJ�JH���q��ظ�*�C�B�k㳢�����ē=�^�!�������e�ٴ\�v�fWpBRuT�k�η%�)���3!�޾j��D_��J.��&�GW&!
<4s���]�\L�q�b�3���_��Ĉ�y\u"U����P>R�ߴ�Lb#S�C3��y$e�Y��[��C�s%0���:buO�#�[{_�_��-`�Q�,�fx�zx�%=1<��疎��}��O�4�E�#3��l9!?�T���gpt�dh��g�1כ�A�8D��̓��TG���1�m��d	��fX��ő#�p�^P�%��r)�hHر֯�hxusz��<���0$��I����5c�k���-c��f,lQvZDY_�*K��V����� ��u0��ӗ���Y��&��Íe��� �T2V`Q7�y{�L�ʽ�<FL� ݴ�9����,��<�)�g~�|�c�;��n��@7JJN���r
�/�����Yяw;�v�,�z5}���g����"�v���)���G�x�8kg�<�_u�v����n�N�c�!�Kwn�{�?[�IN��B^O��������sI����$���8+8�$Oqyx>c��u0�^���)���z3�g]�Az�>��Йy!���gq8X�q�~�-��@>��/Ϋj\��Q��C9E���]邵��|
A��Z8y��el����l�t��������ǹ!k瘵7����`�(`���!���H�l��	r��d�)���iw�oNo����p=�
�W#%c����I2Q�2�5�,o�Vy�g>��d�&�{�������97���e��7�{{D�_���C.fO�15��	6sA�,��;������A;�x�$�4]X0�����]��*s����������{���yt��Q>�f�>%0y&2�ֻ���wi�����Vg�(��0�.R��!Z��*,HJ�f�x�3?������b�hȹ*�}�䓘F,0�I�Q����~\�:���	g9�/0�j֯' ����Y5)*���QM緜�� �A6���#k�^9�W���b�&&:p���G�.	���5@���Q���S��j�A�2}7Z�/qd�����.�t'y$*���W�I��G:R/����ɡk��v�*8��f�8�:D�u"���v���yj��\(8�,ͲPj�d!
Uһ<u-���Sz�7��t
,�`㑦���.�ې�waXa�8X�8���@m��Fb"Q�i/�ZQ����vL�����r����+�z؆�﬋l�������m��&�$�Y�E��&�&��P%'��_�`�u1�Nwik�B�A�SL|rӾ}vs��^�_S^jp{z�sK�H�>5�Y�(D���.����-?��k��KE�Y^$�(����,X%��i�e�s�o�\9���U���H�� D4�o����h�/��5�������M��	Mz��'��B�"���"�.´UZLh ,��R����hq��թ�Y%;�[��N+�O�ˎT^p����e��d�OR�i�Pr�(���������^�i,��m�-�.FY��|дCG7� 8]x,HLw]�1z�>>�[�P���x��K@�_vݓ�O�O�)��$%��'���*pR5��jΡ��L�SDm��M��D>��B��)���чN�<���=f"���iXX�E\26H�N(��#����}��GNߞ�l Q�%������(1g��dS���.R s�<R�*��q�(R�w��0cD	��Dn�:��Hh�Gw0�^�N�q���&�lMX�<�>�sk��쫗�������j�.�"֗EƲTI�&�� �Mk$���t0��>�����`YVP�V�"��y� �"Ӊ��(�:+&y8����~��!�,yZ�N%Y�{t���Ύ��^+��T�t���CA5�o���-�S��:}��U�rQb�8���=��+Ȧ�M�]�|�i������~��Ɏ2��w{����$TAB���֗� U:�v5g3��ژ����)+�ʫ^W� !�G�a����n�,�>e'�ĳ�B�yLH��r���Fb�y9��X�����u��d��fnM�s�Q$�}7S�jX�"�E.�k��+r6���0ן��g�͖�F���k���mG�4��D��`[������GT$&	%�9X���w87�D�яp�����!�X&j�j����+3������Y�R�u3F�2�e���sؿ���g� ����)��VC��i����e��V�/�?g��g)���&��d�B�A)��:��(�8fZ��h慢g(#���~(�N�.�m9�|���G<
�#�3�g:��)��S�/4R.��+/����1_B�ӖqO+����[���<�ۄJ?�N�l�U�׌�WL������af�� �*R�,�8"�8���Q���3�Cb*iՈ+�l�L��j���S{��t��u�WZ����T�x81����ߙP&yoX�
wjXMl3��54�6�0$C	mq4W�������������9?Q�6��4�����yƏ(sZt�;K8������};xN�<,�w�z¨�`&����3E�ݬ0�˅Ǵ�?�>��C1=��s���)C%��+�������V�v �	��N�U
p���B�*�����>[�OY����mm�$@ZrL�^�����j�<��$y�:)K���\�2W��cC��ս�غ�������1�(��s�?<�=�ޝ^�\�,86��j��v�J�Y�E���#Xσ�`W#�X|��UDGo.�:���)����Nd,TI�yv��-I/c�4�"h7������v)N6�5T��NIGRpr��3�,I�އʓ�̥a[��'��|�(��ɌB1@ɺ�l2e&�6�q�:�Im���f�����Oԭ-�`m1���A�����٤��H�7X��	)� ת�!~z147n�R��U�Xao�-
��-o��i��<�D�;�Y;�m���A1��QF-u
�������m<4C�W8��sB׶vfS��< �c�~�<b�*���P*���LE���ӑ-јl�e����ggYճlo�����������1��V��$Á3c�1�U��\���RKrhj������;��Y{&��r��P��r��Qks���}C�
z~��@�L��!�A*��sl����z�_�#4�:Qӿ��4��7:��Ԧ�/��z+��[�=�lp ��\��o.�<�j�����ۚbvLp}%A�"���"
��  �n�cX�b�*��2@������G�z�E���<sʎ��y�Y��P�˘��bD[�������g|��Ǽ����/o�Yq3�f���f'��I�$�z~;�ۀN�(�&Z�	�&aB��f��LIň�DB��ha�fjǧ�5��Ŋt\��>�����s:�4ow[�:�VB�տHo����C뢌����]v����$q���B�@��L������AV����׽a&�>q���Uc�Y�ҵ����t�he \�3E�j۽�F���<'���c�(���2�Z������˼W�u52���gR*v(l��+�Y    7t��7�A	q�,��PT���K��}8�f�����`�?�R^5�S5�):�ҹ핫o����aт�-1pL���f2�sB麰-(�����)�'����]�3��e�M��b��Z�+V)c��������S'�\����Z��Kj�8V�X��������m>	��ئ+�����+�a~��Wd�ׄ�&����u��G��!"!�K�f��P�4�C�vv�he?��0�6��Y���RI���Y�ui����h�'ΐ$'�<�lUk���͑0M�d�$�����Q��z+&�h�gν�- ��3��BO�u$�tV��/IC��RR�X�eY����j �&�z���S�-�Ӿ�m!��_�-�}wrv�oS��q�ƒ��lծ�t����I���yn�;]����s�3XH}�fv0����Bm���9��A1Cc�z�����$V���脀;-R�����t+1V
��r}~��5Ԗ9��!v��`�ҡ�t�}��ߝ���_HA�5�7���楩a�R�]��i 2c�@��vn>�R��y����:�R�l�T���|�:��3L����	�?uԦ6��x���-�f���b�1��)�B�i���F��gL}K��<$�&�$r1BF_���h������L�3�����\�}5���'��5M��E���k�f�^/v�IT���X��P�&��8���>��;C�Uq���!V?_~���|�o?��ܷ8���"�-��lт��4�8�X*�0�0I��y�� l+b���T�@4(�ri����a*E�
�*�Pa�������Ѳ-�t���j�A'�Q��޾��\3k���=�;��"	:�s�K�7��n���_"?�.�<�ɨ�s�f��Ʌ���g|�Rqf�
��G���걲�������Y_=B���q<�����%���Md��t�Z��s��.��`�é�C��b�4ëQ��K[��@��֩�*-�"��`A_�7S�G據�c���𸨱Лΰ*��b�Y���e?w�of�� ƛ��x��\��K��Ҹ�㣞GB1��֋D�W7.�L�xɰp��E.�8�1S���aO� �Bla��:�����V8��9�꿽�����Ճ�A]{{�"�;��e���{qc&�,���b�C8���	7[(���O\_��;�ff��7�b�)����!2��١��+δ�S<7�'��9�Qe:j<��z�Ə���Q��ME0!4E�-Q�L�\]�Ƃ��wϽ���?�ʮ���O�����3��"�f�x�>���K�(�{n�n�6��IRDi��9�P�ΓL"�a�y%�@I�'Ϡ�!j�u�R�Fqcn5��4���·?�R����<�g�U��e�60TX�қSf6�s��9�Cm�kԎ<��7�ʲ���vR�f.ãb�3��+�U���9����'�{�OD�� 4����=��=:)��ɌA���,�H�=0�Lf���Iͤ�H�� �=.]�^n��x�/�-%Q������h]qv�N�P�B�<j̪ѩ�ҨR-�h�F��T��׾�qr[��#4Ng��C����دM`���\K^�?\����(��`���w�.��;����R�)v�,&B�I����f���^�
gp<���\ja���Z�»Ym�����V?��J�t����/�ܠz�';�	�F{gn-JĪ�HbF��!K���|�$Cee���Ӄ5k"O�k���?��R�d�S�y�"/�|�l0��7��b�.��t���(���V�u��v�O�,ܿ=�o�-p���C��g�C��S�l����S8c�SS��V�@I�B���e�ڨz�H�~L��-��n�s^�p��Fwyy������l!���s	����Y�L���x="�1���QXjRE�~�ڤ��JTJ�WG���]��SV�6j>�e0����^��.N�>2ܓ���B���I���99A��Z鍱��}���9���|N�qi����:s�PF� w�����˟�׆���E���̪�{\^��|JwIEy]6���m�3Ȫ��W_��+�)_����G�@(y�#:�zNc�T���z��,�@gQ\�q�ji)Y�����i��j2�EJ&��������pe/�����W]�����φ7�]��0$�-�����Lj�$S	�l[���;��n��:�� v��K������M\����d��f.aq������������q;�"�S,�#���bGH�e�0;��oY㞻s��:-n���rm�y��"Gc��~DHyO(�(�Og��?K�ȎyY�s�lD��@���W���:��0��k`<$�9<d��\��lJ�<��@g�L�9n+JXk���AN���a0�Z@C����Ѹʧ��7��k:�Z��z�%҉�G�lh.��
��?�S�_������㟌I�\�Ҝ������;�_��N/�Sx�1�Z��m�~���w��USgl˗/��!�f��,�Q� "�$)�5�<�L��Rq^бd�/���ܿ�8�D#|�_$9o�����OFԫ){��$��X�4�Ꮔ�C�X�&�2���x�.��P�y:�ܴV(|<��eS�βy\�e�]dMhK��\/���_ L��DY��ljs��(�
�lJʆ���x-u/�������9Xo�U�r�|閣���a��U��n�_4�m]];&YD�>��x<y՟��cf�fUc�5�i�\S6v+��t����گ�V@�:�-w�I�N�������am�$Nv�*?�_on��Y�n�ө�LJ��%8�oL�OX��1��ZF7Sw<�����" ��V} �f��ױ&r�:pv�谱ڳ�v8����
W��
�������H�Ő~�j�/�e�MRa`��:6�j>%B����f�����Lu��EE}�W��w}�	ӿy�ofe4&��4�y!��Hq�@�e �J밐�2Z��AS�K4�@S�Yi��>���>�2PKL�>Ik��.�0�ԃ�����W h
u.?FF)��,E
��Hb?���d�u'�]턿�F�޻P�F�_���BE6X7MY��_�}��L�������8-� [����>�g�dQ��|����8͒�zG�-!�N��F�|�׊�?��o-�op�ox&�8�����жd��ɺ��,�y懔�P��$��3b8`U��0��-,	�aQqEj`9b
�1VI(~����'�#@��[�vփ�3D�u��tx?�TA�ɘ�b�-7��:���f��p���"��o��lPy��0~'y唭(�XQa���϶)+�}����D�d���婋E�q!�a��	���5"���0D3�[���%U_{����S����k+�X�4�.꟩m;xZ�#)�X:��Dm��OD!��4����;��i�@�%$��c:nR�3w{�ZD=����0�o���T�b��}Zb��N�8�K��_;�~�P*�:}1�*��r�5\P���q:����h��FT���M�cj��E��eP��7�u���ṯL�g�%d�̴�3TNX�]
"��>kL�0�o���,�O~X-�(�і�LuV��W0���
V�U���W��Ml�,JV�O#UGZJ��0Dc�i0k[pV��<ES��$��j�(�A)K���j�a�%d�@V�_�+���@�����Z�!��D�P^nTW����0A,�K�Px�Q$�3�=_�.\9������N�}�C��Y��=K�i��^�<���dd~�.m8�U����@2�n�!~�=�Pi�L�7���/!^2���7M���ϴ[��ڭL��*�G�:y��UXdB&~��O���n�&�ka���nw�a�.0��	�;�00�f�1� �'o��>����D҇�˵Ť�H eka�a��l�|+��򤝪-l����ƞ�_(��{�d��
ws���A`��^�f�������"X�W�p�Îښ����B��z���cL��o+����0��M뾖�b�9(H����'�v��ģ��	�1��$�b��ߺ��-�Ji1    {Ā���3�_���}5�]p��.�5�9��F�w@���)�31�h~��EP?�OfD$G�, Լ�XHp?�]�އʒ�e��?��ԇ�,���Q���r3��0�f�1B����D�=!�����)��ۄ����q�*��q��a��f�����k\0��
���j��9n��a�.��ِ�kzj4��9�*��!�`��k�"�c�p⋪-U�}�A\���Y*�n���BwX�������ƯE�S*�c���0_�ٳ�����)�8�x����އ�D����3O�އ�˛3�}���"��yG��(h�US��0�р�:�Wo��G����i�_�X�Rr���b�N�K��ن�ҡ��0ϑ�dz7~d�L������12��p<[�q�@�İQ��f�x,�� c+B�?��[Ө� �q�%8�M���mq+������y��Q�S)�[~�Ä����mը��m5�	�ss�����ЀY^������_!
a276�[&��N������ٿE~5�E�J��&yͼ���<J���!�>�3'�5�-�[�Ww�pu�i��O�����;�&�dlAv�7�毵�z�8��O�>�}�%	�
�:���7��U��?Qo��a�5Kd����?V(m�l�q�o~�~��-Tʲ�x�L�j���-��{l�keyeM�L7a����Y��H����8��b�*��Cs;]<��C ��˫��c?}��Fc�(]���M�W��q@�#�Ȓ��A�ܩ��N�?���5�9�v�k��M�k̝n�a���f�����4��d�����(F�=ǀmK����
a��ϘuK��Q/��<�5$^��L�K�<�2�#	��|"���6�=K���o�xx��{��W��4��q����a>eJb>�l��	R����Է� �v������zx-/�	�2+��a#��~7�*�Y��`K֝`O��H+�P���!���{H���C/�'�%�d>٫���g���Y�RV!���[��;eZT ǎ�*�{���~��8��^6�XĲdLh �=a�aXe7����|�j$kT"hzf=/0�!qď��ă��ˉȌ�B�XW��N���!��QY����Y�.�l2�@|A��ġ�U����� 
�u�[� ����V��!��9DQu
H8�E-�薎��Nߜ]~:���O/Vd�Q`w�����A_����Ǹ�S��p� �ˮ.M`�&jCANƽD
���G�MB��\e�V��gw��x��̤�wJ5�WQ��6�מ�
3���"&��ޱ!�4؎��O��tJ�~�^����Q���L-�+���ʘ�,�Ḛ��m�k���Z8 �6�^#,��G��{,��J��Q9�0�A}G����f���G�h�k��	���������A��q^FJL{t�=��I�V�	e��<�]�pJ��j��T�CϭVpH0��C>���LOw�d5/�`t[�=&уs���UA�4��-O��]q�k:G�)�^��4��֕��p
��^+|�A�4�Y��J��+G2�$�M�,�E�w���P�&,ͺ7/u/Lt�̴-�X��]Glb�HW5_^^^~�o��ے�;��_ID����HD����sG ����e\F�J�,Y#p�� ����G�%�m��0���'C�r6j#��1v�L����x<z>do|�����s��:h�f���.�xy`Ѓ��Xl�2H�"�W��׮~�=/0��#F�3�ogeA�A�*q1�ɒP�M�6ZF�\�I,�P�(�`�Q/P�bj��h�p��|hQDDxeW|j=H��Mq������������������R��O��m����q�XW��c�+�@�y��e&�\$�6O�ř���G/�5�_4�U������U����,&��.�B��ZΜϒZq���WyWǂoG����.C�MZ���>�,���s?�B�ZĽ eR����-���>��m����t>�}l���y�hٸ�Ę��� ��(N�� �7�a
���6��I����3��ă
�-f��Ip�j~u�'�:�"��.����m�`Nc���`��"-��5&&)�y˩����4p�1ژX�>;��1_�5u�pr�f��@,4`��x��xUZ�׊�iƗ�;`���J�;̙��(��e���ͺR�oAa@5�)�ūf���;�(��JQe�Zr7��i���r�R$^�ҮI�Ma"$��NY�D2�����Z	7�Ś��~��u%�6����+���������u��ւ����D��/'�0�6�%h�C\^C��vB8�e3�IC4��ߤD�c������Q�_��2tz�%Z��i���)���ʼ�Ժ	��'d��AC4��_��R�R������b_$]��������pO~�n�W��oB�؊·��L6���M���0|e���Re�(�r���"�KPIE��mma��YGkf��Q���������Ŋ���c`��m�n��{N�+�%~7�A��$��#��eE�����m-���f��	p?ᩯ>'?ͅ�EC��zs��LG*�)oa����,��QԷ��fA���w�+W�Z֊�l>[*�i��;vY*��/R�-�,�2�`�G��I�����]�����Rc��aޝ?X������/lLk_�;�nw�>u�-b{�O1���fF�k�8ю��6,e��5�d�k̩�B,��c/]rj����&��\9�E{&��q!�ER`N�eh�N3ui�eϞi��hH@�u�
V���>�(�=n� ������TB��I���F�����D�4O �.VME��	J��
1�z�B�x�}�S�HC4��k���2���6^��oo���'W���W���T� u�Ip��yO#�RKX�J���������PI*���\5���>�'��	��n��'�NH�m�i���C�Ut��i5Òb>����Kl�i���|�c�k��#��	'U�Xx-pF϶��G����޺�$?F�܅��a'���-��kRLR��yG�dFR��~��o�t�95�m���ŉ��ȝUL�ؒ%M�
�n_�H���V��Y����֬�E�X��x�91H�PE�IϬm��٫1n}��#���H�[�/Y[O%�n�Ľe |��a� ���u �6|  "��h�:���~��QAbo��.�o?|�Z-i<��-�U�H-�����S�I�n�c��_fa|�S�}�W�IE�[�N^*?F4��ϭ�i�{����L[�y~�z��_e�}��MՍ��*J8�ʴ�j��S�հG��6��W��U�6�tbd8���~�ڏC�>[�7���/�2�î,��3�PӤ��(��|���{�<����D"B������'�{��\��؏c���ؚ�n_�w7��׭�gm��/�u
�U�|�^]��T+C�6G�N���_���ƨp^�Y��-h�^߱b���y ���30�c�� ��ށ���G,���|M�6�@�~V?�g'�o���[�;�Sİ����wEQ�.HCζ���'� n�k��+��?Ԫ;�Fp�[� �pjfw��ȕ���$?����5�#�Jo#m����`���fS���a�=�v��r�?�Jc��(1�Q��R�a��P���$�[q�5G�����|�pc���O`����Z!J����柋a�Q����U���a��U�t�)�r̖�B䈞2��9�ms����0���f����QX��V���;;�r��r�^l���e�G�ʲR���Zѯø��/	|����&��w:,����'������vѿ�xurֿ8F���}����9�D��~AV&�v�2H�k��2�dbB�x2i�Go�����0�����ӗ�qb���1�[�(�iM�N�kj�tԕauw)�[��莒�2!8&,�<d���X���&�~�V�?�^�E-����\�+����w�/��жN�%laA��X�3���U��e��F���*y�^ 4�	h-�5����ys�֝�    >�o���,S��AN�8�6jV*
�81"���Z�O�
�C���F�Q�����b�n��9�8 �nC���Og�PqWZ��D���E.�M-�0�Z�ۻ:��^��J�S����RH�-E��1�Z2l��O���"�_�0��m�׭������-2��6���sS�,8�!j��"�q����2`{�.���R?�id��И�T*�݂iZ�`m8�+��L���ϩ�3\`e��qV��
~J�iJ�E����Ǝ�+r`�x���	�ڄ�Y����r[�~c�M�FϕV�D��8�Ɨq�u��Wm�ߍ�`��^�D��jQ�K\D��^��D��28�Dx�D9��$�6n��&�>7�lR܄�(_�ʂ���PԈ�m��̱���$6��"���(x�e��!����D�9#"Q_�3�C�\=��f�%�G-�{�t|����6j�����,T�:���S��٬D�
ړy:�v}�L������̶>X�k��`�I;F$7)K�%�0��t�Q�2�u�	>�f�&DA!{�ЊY�Z���>�mV��E��:�_�\y/����z�r��f)���D�G�R�se�Aq�^}�m�rT3�rht�O�O�#����k��p��n����TL�2�;�O�DSSb�?�x��v���-����Y]�/"sx�J�p�ʼ���O������ו�(�Z�է珟&��+W*@�Бֱ�J��C4��*rZW���Ӌk�����:xHǘ(�)��D�(��$�KH�I�<�L��RaP�{d�Ug��/U��]5：dw/;G��p�����ݽ���K��j:k�g�;ؔ��T�� �3nJ�)�7�����x:�;�!.7�C�,jZ��'f4E^�����̛goZ�^�p�]�����Ӭ�&�,uM$y���(�Tj�a��1�"�k����ka���i�҄˗~��p}z��ܺ������z󂯐����Ʌ�N��L��1RQ�������x����j"��A�6i�[�V�+!^w���X��!�HJ��'�O]����T|���=S��i��_��)L��|q�����őڍngm�p7�Aւ���>G��)�μ+�$:��s¹���<�����ӧF��p2FQV|�j+�|ZT�!B�Ď�(�Q���*-�+��x������ST���#м:�����ѝy4�xْ����Y

,��T6�8a��i4��"�"��\q<�,��o��mf�O!*.>;�\53G�n嘆�d�qbS5����y��~�^�X���k���k�4���8g�`����PG��Rd��uD�|:[�KF������a�9��N�N�:�
c��J�1���á{n�����Q�������C��������C$Sr9�1X�~�������r���1���
Xuyo�������h��������z�'��H��
6�m�%��(Q�-���$QH��e���_�O!Ll�t�0DcO��G�kLvG)]�����b�nCmVE�F��Kh���y��ϧ5�����pƢ�0���=0	��pp���!Oρ(p~,��3��@,I�9�ǳ\�\��N�G".�%�f�0Y��y�y���[C�Z)�M?�L��|Q?���_ek�z'��3|�;�y�/���G������h.�J��^~�{�(��9�a�� �̑�2B���d�CLy72dF�p�nW��'����TF.�CS5� �gP�3�'F��t���:�*��.���C�u�����U"y�E��[�	���;n��H�ԔM����@��$�s��[T$4��=�6�k���fӻ�:}{z�?[�E�~��ߎ��Pwa�~ ����Lf`���8��*~�q(���S�Ϊb��Fw��U��;�3�{��-�lj
�A�����%����]c,|FN����b<o�2�3��ʵ=�jb�N��M��l����h2���&E�j�D�|ډ2]����2RQ��>�3.����f�!G��\�Z��p�N�/
t?�W��w��uӷٌ%�cx��{u�{�;]Da�g$R���$*� ������"{�`�0Dm6��zg����%S���ɢQʛA��H���E�Ny}G���:�1Jjֿ��!VQ�E��qib����^����\��Ƒ�����4�����o����o�JT�"�J����s�RNI���2�6>�>�9��7�f\4�bt9�
#z,�ֿ!
�|(�+���;8g�考{j�5S�T��.ɸ���Z�3��V�r��%b43%� z�q̴l&E��]�N�Ο��jN��\)V�#����s5�Z�-1��u�t�,� ��2�盻��H�����L�Z������ D�UpO� �YC4N�g��T&w`��ӿxo�>��p��%��6;ǝd�f��9�8�p��ǣ��a�GnFJv(X�:�#��\�`Z�+F��8��h2Fy݁������	/�H��8@��˨kt,�2�*a���l�0a�+��(hja��n1XD�dg������űC):��,L{�7i� 'iC�Wޥ6x��V���^v=�jGG]�\B(Ӝ�D`/Nfi)�(*V����Z(�����{���8���%�gw��k���*�8"�*�ۣ?M�_$a��֢#v/��	)�O�������+%؂0��%B\-Z���`�f�j.:��3�:��J�Ad��,��#�q�����<5�Q"'Qz��yC�;%$�Z��?Dcoۡ�G�~�����t�l��ږC�mk�� ��Gw���D��������Qj�a15��TSSQ�Τ�G�2.��V�� �8��6���U&�h�H�V�hWԚJ\)f�_C����AdF����+7�f�{A�KYu�U��#����Ӷ��@�"�@��۟���t�|�ٳ���VtݔC�WL�2fh��ڧp������M�!���ռ�E&�%V�2/�R���.�0[���*�E�`C�oW�y-�KF�|G��.a�;<}��Q�7ܪ ��b�����Ȑ|l��k=-�F��nO/���������Ř��Ǭ��G� [��T�E8�=ԙQl'vP�_}�� Ys�Nk9���ʰ(�?ur}��3��EN.����G'�=^�,7]�ˮ�3�$؊._/N|N1�^|�ښD�^��S*TU��q���ss��c�BX%�"�����w�IKe����6��X����78Сu2
D�Ch��.�TK�H�,��k9�Z`�o�D��ka�zi=[���///�F�Q�x�����E,Vo�W,(�i��¾�r���@^0���ز���:D��C^~gB�nbs�D��d�?wm-]*~�V�]ji��@�#e�/Y��l������"�s�Z�v\l�X��c�$i\D�9Ӿ)��(L�&�Ϣt�"%��G�2��C�d�"\2j>/�N�~<�_5�;&�S�wR:��6�<G ]�� �~����ªlP�]1/��s`�P8+�X��-�~c,����q_cxx�����j��!nج�������0�8.M�1���B���?�ܐ����̪���j�.��Cؙ'�2	��b):� ��UV?R/����BG0�zn8�˜1�65��3$�ŤmL�E��~7��a�ï��/|!�x�h���WZ���!v𓤽d�����ct���n�$����t�/��5��o�zj0i����d�ͅ���_���[-�(�/(;�̡L��X�Me�<d$7�zI��ha�ց�������0`���� �3��α?b)��R7KJ�~��c�8�a��N�ԋ�)��G�uT�59��(S�Y�L-��m8����g��ôL�_�1kvt�W5��>I48JV�����ens�x�����;��_�<���Z���^�x&BYz����}��W-�I(��A(�m�W�B][_���)$��Ecq_�����ei�D��Bp�dl�e[b��H{�u@�Q���"�m�R��l#?�|��.)X!�f��/7�ՅD�l}��>��    ��A^9<2�K�?����I����?����)Bѹ����`X@蝣bMa�Ϧ�.쾆���÷p�X��ը�P�P�?�ߣ���|�%��/7��t��s���3����_��ŚH�:`a����C���qc�]*�/�ӻ����i���������K��5x:|�`��6�Ӯ�|�����x��j�q��S��d��;.r0�T.AY��1�����)K_M:�_�_�H�gæbR}e��o�$�l��lԘY��,���\飽i"�s��%�-���㹃a5�Wm$ξ��*ŧ9�&����ti�R`��u�&r;.�2,�i��D.�Dƪ��0\SO$�C���S�-�Î�KF�����x�HòM)D�k���Z�i7ҥ��(�:��ʂ���`�/*V�Ă���җ�-t$� !���tNx2Lh��
�o$
����î�����}E�~�t�k� ��<7��7ә%���s�Va<��,�Ol�p�0���q!�ǆc���Ef��=�@/�ګ`G��d�y�|�V�x��w=�#�m�h�h���խ%\B����E�����P}5�B�̘����P[����F�_�5��N����O�8	��s+�qGM�Hw���{��'o�v�	�m�U���$��ׇb��x!4���0��W�W�{�s�k5y����=Dh�pq��[w�&����oF��`Ae�������0g�z����)u�8�k�����Řy���-�2#Lq�V�:2#:C�)�-3���e�'1m|>Q�v6FF����3e�*l�G���]�S�� x�?�0���<�����>DE�d��߈�,Pm��`%�:�v��E�D�"R�"� @-)�7�t��� �	���u D�ؘkW��˽����^]~b�������mȷ��¯�?_�6�7�\�P�y����%�ZA��j��q�#��DD���[\��y~���?;�D�5�����`������>爡�4Ø��oX���S�������
���<X��f�Ō�/HvY�'����^�{��-��`C�/-WA������xY[���w�[�垌�]5��r�=� 8�mƢ,�5V�'�`\�?U�Ne1/4$�W\�t�TB�H�Sg�p<R��2�hڼɲ?I�8҅1f��'=퇡�ZaC4��V`����c��������]��� �%�Sakc�d��@��hn/H�$��4��,��R,�q7*��I&E��
z*�Z�,d���m���g�-e����
~5����҉6�ȥ�*L}�}��dZ�b�L�"�=��b��?���㵛_��Cz�0Ews��"��;7���;)�Anv�����~fH�ip
҆7q���Z��{�刡`�f���J-�[��G?P��p�*�˿�Ͽ�_MB	dꬦ�K.Ћ��vm<[KF�k� ���[Q� VN�
Gt��!1�=�K�2�Ү�� 	g�&*r�.ٜ�qW!�1&��d���^�b���l���3 �����v���g��#b�a�o�/����vx�^���_�i;v'$ΛH�f��f6i)C�{�T=��W�[���~M�;f�8�I����{;����8�n�n�6�-��END�9��q:W�j2�e rֆ�sœ�4�3��Am����/�R�^vv[b�L�Ba�]����:9�ޞ]�,I��}�@�����u�/;G�v$��M~WYf]f�E��hg��#�����M�<���aJKǬ;Ok�4���iq7�D|�R�$���""�L!O#c�-D��$a6Zgkvۨ'�m����C4l�ߠN�C�C�������w��е��.5�]�X~�v$�e�>��F/����W�>�餪�h�w�>�~2jYq��w;O�O�̋W�� D�R��p4��8�h��:� ����L�D��G���� a>��#55�鬚t�Z𨭒�~�3��8H0��`K�$j��IZ慈ˆh�cK�^�$Xts�!F�Cۣl˼�3g�����*�;��i8���'x��J���������>��lh~���a�M	�b4Gp�=wC�9�Bnh�p�zI�A�6f'.����.S?MA��/�ᬆ<��ќ�,�F��w�k��p����*PX�a$R!F؉-}��J����<�c5��/c�-b�O �_ı�X���,�"b��G��4�NӰ+��4{n�&"~��\�����\�e��*yP��p��:�{��:�@��!������H��t�@����|���5Icn~e-�[��x����g<����dV�S��$���&�zR�a��_���F*�^�QO�I�4�0������O������k8۽�WH��8	Pǆ��1�iz�S>����~�n�:�ō��6����#������J��Ѽ$�B(�A`�ԛ��a��+��sac꒾��N�a���֣"v�Tj�5:���t[���a��5�(x�-hX�X�|��m�QE���ekm�7-�P�$k�Qw�2�D(D��P�V���C��!j�{�-Ի(f)[��t��9s@MC�zw��;��:Ie��il�ҚidtT��VhJ���H������0j�E�_�A��</j"�na�_�ٱY@ET�ˁ�E�F�a/����/bQ�}�Ng&ˡB�@����b
k䍫������ �q�l\���ғT*�q�ƪ�c�&	��a<�}�V�zXZ3-놫$�?��M��G���Z蚺Ng �:&���\����C8�=c'ŏL�r����VԚ,+p!��n���z����n�R�2ϛ�YX�>5�!$DW���赯zBF�41���C�5�D�pݺu}�]��Cx�����j��U���r�u {���߱�x�ܓȍ$�g�*�3M���b+�C�,ma&���?�����ԈiJ���&����PZ��{:A=�ޱp45V��	#�H�UX"�'�s� �FW�۰ �E
����೎�Pg�Y�eY��Q�A��q#���l� �C��!����z���׏a�g���xA�K?�<;�pur}}r�]��yG�G�o����
�n�n��O}n�
�o���	�c�3�ҫ��K��-Z-��@Y�_�͗~؜m��$MU��Pf�Z�]�4t��mF��!�o�<��]:t�n������O������	-�7���%���~坛�}�d.����a6�,����G�w_fe�~ŕz��>:�:�m�l2�p�r�nY�3��e��;Ni���������w���X(ҝq�"�0����k:�W�<�i�p�gEn�������j7)f:ƏŤ!��>���I����LK�(����Fe!E��٠����ׁ�AdI�,ja��}�b&q�L37�a��y����_���[�fw�O"s��񣱦ӹ\�9x���Z6��[7��(Ϊ��S1:�"4�UG�4� 7��ҷ�^R���3�����r� ��`��#�� ��s^VLĹ�d���Ο32�A��#�<���+dN�:�@5��v<�J��*.�1����`��K�Bfs�p�o�2/���_������E_x�x$���K�gC(���ƒ���ݢ�a��R�u`tWh��Ml��N}��U�D!5�0D�hԆE�H��]2�����e�Q��)�tL�{;��R�|BP��������JX����|X������翫Ѳ$u߁ٹF}G=�pK�t<I��C"$q��1_�e��m��Z"�zℬ�id3W�.1�h�1����ŉ]�����1�L�N��w�:8/K��3U��A�Vͷa����SJi�.�;Gb�]Ƅ�������D�h����9�#��gNb�ƅ���@�$�R�IT�\ ��YlY�e����^˰�����-����W���?�{�/���k*fR�:��i9��w������DZ���Z'I��뮮��k���e0gO��i�D'��X���b�m -�5Ϥ)�(�W���;wx�@E�����n-r��C6~|(��w�T4��{E�7gs�����ɡگ=�>Y��b:���\�o :�<̬�V#    p0}	�[<��F�� p��YĻ�۪U�YF����o�z��#3�����%k��*�tąRfM�B�����d-Q�ڛ�N��ܣ�ON����w'�XN�f�`�f�c�$�&4��I���ě��y����Ib�{�:��C�y��d��j ���?5�N�ܼ�RJܸ��`�G:F2*�pA���qa��(��m�)ƪY��Cd�����&�ә��:|�&E��_AxF��������y��K��T������T�*_�O�XA��+�"�C4��WM��b����]��S�0�?j�掬$�>��@]�F�I�$�SFIW���BY����h���e�d��C����BŎMt�`�x�u�c-���z����q�IvqaRF�4����V\�E�V,�,H4l\�%,/�R/S1َd�#�yn3�A,@I�b�}���PH��@�H"bh�8��[�1ؿ*l��=�dvG۷�fR7��#�	�ܮ_Q�b�N	�[:��Mr��M}Ǿ*��oz9�,��/��|X��Z��~�dO&Rq��!v��a�&�U� ����;���U	��7�}��x�vm$������b�V�;iCؠ���X.�:��0^
�2�-JY�Bd~V�mY1�Y�k&_ha�ښ�O""�_����цq>�SoC �vz~m*�=7��_���u�Dy�|5	I`�i?Id���X��7Q�"�Xs���u~�o*/"_�b9�)˘�(�@�#D�D\%����3��3��Qhc >�kU�3�b�r�ܜ�m��o���+�HV�b�e�	�sL8�G�,X��M��"�͙>�(]Zb�d��,��4�>�^3�qW�?Y,|[�?Z�H7����^�I+B���(�6< ƣ�LP1(�A�B�7�y������T�Ok͎B�&�W-&�*T�)���w࿖�� �����)�@�K���۫�wؿ>G��jѫ�x~��J���b�'�lo�sl&��XG��d�*�؎���-��.�f�����rx��9I<W���ڴ4����]n	um�%�F��b�&������YM]�;����p�n�v��g1eF��&�5��8l�d���J�YәuQ��u�Ƙ�Hyu�͉�����Izx�Q쭳]�r���%��ƈ���pe���E�D�f	!�#��'�|�_�;�x{sy��0��Kl+2�֐(� ��j$�D�8���m���4a2?���vu�v&�`�X������YŜ�+�p��\|u��~��	,�޵����4�q�/��B�	8515`�uߠ�q��=��0l��O8+��T��\��O��Y��C;�2 J�-!Y��&2Ai�Y�y�L�Pe)Z&�c�9+������F7	�}a�)��T��Пx�N]�i1)����`+�'[���9��9�޵�@�o@�.h2e͛N
�ǲ��\�Y�E'P��<]�C�I!M{�A��0ܦ8�.
��>�N�a�Ùx}�~�8zW7���c.r+��/��/(��u�l_�4B8L�MZ�U(���0a���Ad2^E�
�A˃�S[�S��LKz�� N����	DqV�*Ң�@w>@p��$��x�����YN� K�7[��N�j��aL���T�@���s�WFI�V���>��0���(�Ho��sᇙI!~���4~���-�	�FGG�����s��tSG;��u�k�	Ǧ�k$ۙx�X5��8O׊��p���E0�H@6�<����Z|us�Ɓ�Aڥ���r��~#J��טX����p�3<A�_:�(���Cj����#�����x֣�P|��V�B�hA�i����\��G&;/��c$��|��
c�=�E�0ل���Z��e#�������S�Cr%ER��>�Fn��%����wy��I*e�f�L�׉��a��,{`�࣪D������I�a�4�+��R{!�m\���W����%�~����c�����y�U��__�f9���4�	8|"�J�q�h�(�V�b<R��{��Ό�*���q�!*ӿßi� '���&J��H���&&_EϠo�a��1KH�0�O��-T�w3$!��5���0�������x�"���F�h�dOg���*�:,NՄ�*�8�����L� im`�kX~D�>�&,�m�-p:�f�lC,*��Lk�����Og1�5��ai
�z�]��`��^��_Z��<B�s�n�K�����J>�9M>S.��9���4ԒG@��Q;xi�	0��i��� YS���h�)l5�=Ɖ���!�rRQd�������{{���qg�?��e��}�P�F]�؉�����ܒ�0��	N�)�ͦ��u�6���6�T9a۵h3j��ݒ��H��[�̠y_<-i8� �����Q�Tq��XC�\|j@㦴<a#N+�T�u[.aA�GC3��((�;p	�M�
���bK3M��(k4�����6N}JXP����u[t�%�b>��3�|0�0M�/�s�;Ĝ6�:u,{_�U��DD��P�liQ��DasU �k�e)�R�r��L;�5��?��e�b������xsur�λ�xu~ruz������~�id�Lu�̳�(���c���7\���)\�`Zy�ApS���ϧγ�xo����و	!��
c��c�;��8d3"X������Z��ɖ��\G���g�H%�0��Ă�(���W�E�Ψ��V(�ja�(G��d[�i2zv��IJ��|<�>�����5mO�Wg��w~��;��K�o	S�m `�J-�?�Zu3]�P�"�ro�wԾ{K�y�6Q�Y�>]-L駹�|��F����RA�tl���{Ke�e�k&�� �����6�?G�Q�#���m�6�Ӌ���?�����$�H�5e �e3t�v�ߙ�95�ז�c���q�m��;�:��bfR�w.Z�����y�p҃	9~�� .[�AB8,o��k
?�i�*Q��Z���G�D(���jCl۳�����e/{u�::�__�,cUƻ9���]��m�#E�I��
�C)%a��2���2�ڹ�v.��D�Ö��Oc�3Q��G-��➀�k}-Ѱ�_�sa7�����6/N��AX����\k%�q[�ۙ�$ذ���L#��D�q��Ӹ4��B�<��n逢�}�1r������6`�ns���^�Bz����w�QFo���@�ER3 \rk2��J�e��L��l2�N�����W�3�{�\�D���gʛC4�<�|�����CA*����g�CyvB�vq�6R��4�O��	�S�[����(��t8�t����E��3��je��9w�[Q`����\�R��͇u��m�fŢB(1�1��j��H(�H]���*�Fp���j^�.m'w��\Wɰ�Q+G�����qL!wԷI�����zk�ݣ��K˳1s�1�kt(�0�y-W5�T��@1�������ԫ������M�����j�q%���_�ZU`��O_oK$Z�A�X�e+�h�=L�1�OZ
_,J�o��v������
�,X���,d²�45���Ķ�Ͽ�||���
������� w�y�4ـ5=��i�����ZZ��vq0r�KR�)�^y�۰���Hn���Fî��1wm����}7}b!Z'�v��/��Q 6��Lo�8�!PΓ�f�c�<����-����^y�}�\�#�c��^X��S��n�����3C|�Dn78~��k��^(!��{���?�T�r������g�7�=9޸f�#��Zܮ��+��ϢS�BSP=����?aM-�)��
�β���k8M��D$���EG*�t>��܀#��?2�7}=3O��0����F���;�7��i���ʐ���k6�
����N�l��ZnZ���H���/j��`5�e�q,Ղ�9�@��k� ��O�-Q'87ABH�w	"��������7''���Q�q��َ�,p�H����.�Ta!75y#�����>k�?������ỵJ�0Z    k�r�K_[�~�)���O�0٫eJ��@(�G�Ts��bXWΠ^������|
��0�]�T�ni�c���������)|&����e�����D��0l�B(��!���#b�;o�[���(h�
�3ǅϨ^�OX��c�⏧.�ך�Vl�Ojs}����)v�2�s�5���D��8�yt�Ф1(���L�4x}�w��|GևpS>�Д���N����.z�w������{��1Ie��^��"��Jf���x4D��~���l�t 3+���5|!��+�� d�h�
�r_����B$�����W�ߓ��j�_;�-,�����Z!X�rv�U�2��Ȉ���^rn`�&AX$Q���$�O�-�o����n�324�;bS&#��A۞�3_��H��گ�gh;�]x�>q�NK�}��e�hk�eb��.
K�xŏ�g=�hL�ab�_��o� �p�ص'�~�i7zXK�Z�Qxh��!�@�iU�5��4�~~fÓ�0�Y�L��V��:�B�G�f�&|��`@�q���?�	�1�9�Xp|�`J��kn�eꑗ�9L��������Պ�U���*'0���1���kLb�)Y�+��[�.��)8���R�,�\Jz"��zCl]S�{hn=�g�lƄ�R��e�������7W!|���j��Ƅ��^l</��\��>jD�J�a5�p����M5��:�M�>s0�3��+Y�)`X��o��8�]�?�&ૃ]�< Y�<e�µ��O������QN~{rh��%�o4FDl�ɭ?}�8�Q�����b��6pM7o�[�:�H�)?���be������v��|[��P�ʂ/���G?� �(~�5X�9�넭U��Mb4�g�K�>FL�F�]��fe�F"�:�d����)�����Blm�z[���k�q\+(�^�9DDΛ�? U��:�@&�1־���Pu��()����"��_]��k��`�|��%��vh�0�v[��`P��țY�#�(��QeG>Z�ܢ�sv�@���O�#z`��<zZ��y�5�D����d�j?��1+�._�<x]�B_�[9�J����l�T����֙���z�����|���Q�k�ik�eR�HC�������dlD �"L�|���ō$e���0�OD�H2�ۋ���d+�rʹ(�E)!��v�m��B%�2额 Ⱥ�Ȳ@�YE%�/;�06뿋�ä�|"�����Cw��6����ɀh�b$�� >|�Z�"wU-کF�����2�yvǻ?l�k�.�r���qx�X0wlX!����W7|��+�-�u8H�%�%٣�@���lA	��"�a;pgGF�r��p8"q\Wn#Y���1��qŸn�,�?��=q���4��b[4�rT�BoX���#�f&���<��d��A��X3�_C4ܞu�b�n��s�5
#�=���������O�?\�z�bZ=~��l#��-�V*�)'2�ߗ�jI��O�-�T�Ġ���2�l��É6'��6^�K�L�T��f�/��^9 %&c\���lc�1H���'TP�^ܘI:���"&6�]xwO��ئ��Z�
���'�G�C<hgf��7�b��MQ�f���#�C���.F�a,��mQ����^�V�d�Hy��4Dm:��vР����=S����t���Z�P&���{�)�����g߿}�ᇁI����n��(@�ca���n��R˟�j.\����~��~�7N1�tؕDRrԈD��Γj@�a��O�`0~d9�fOe�k�����C�̓�m��ғ=�/�М��n|�r;�h��������װ]_
vFR�5}�5٦H� �R�F��'����^v�/�U��E�e����!ꘈΆ���\'r�������1�>($o�\�:|��en+���ġ�#4�����2�+���D"#�|��76i7-�D�2�ijV�?���|N-��Ǟ��\S���Z���:��Ӱ0��������n�ƙ�����cK��D�\�L�<�4Q~46p�-9���BI�(���hL�� ��G!���>YcKu�}�&F�U��A�f�����l�͞�G�)���ѹw��S�	��̬��2z>vq~v���90�
�0���WISd���f*��� 
[U5��FB�v1s��5S��8B�����x=���}�p4B���խ���:���h��f�BNRӘ�4D�&���&���J$H��q1�d�!�Z�r�|MFuؿ@|�w'gg���LC�����1��^e�I�^��sf�'�ME���w�(�^vNH�̞$���s̘O8_;��P�5W�q����tL�Mi[�+��:Q����B8#d�(2������e �O�����c��ĝ�h�������B�	>dg�2�ۚo�{�G�Xa=�T�e�E�2��1��8��f�ʗ�)E�a�6����`F®�j�p��q�p2/Яe��$� hQC,�)ϓ����~�xh��2���B�ʊA'R��pi[��R��-¢�������&Tל�z�)չdf�s�0�t�X�N�S������iʝZ��j����:����/x�c�o��&s��d���~h&hVŏءY'[9��!�"��C���_�#l�\��2�t���T��	��5�Q���b2#*N>����Y�ǈ�t���Xk�Ƙ!� ��Ȱ�xR���)͊빠�28�=Z��9�B{"vP[�k����Z��^��	\��B���i��� ��+2맪�{B��X��C4浍{=���J������I�.��oO�������m�0�m� vZg
ٗ|�����Ɯ��������9h3�wm�:q���EY��Cf%3��6��6l6��g���Ghh׼0)>��`p)�o�,�x�!���%�����Z��d�]l�4�툨�`�E]����^+R���X�^�="^I
�����޻,��d٢cܯ�t�dF@�v��1PbJ,I��RVV+�2�I��C*֨��NzX��u������# (&+��TҺZI���#b��~���|�'��yX_��Ou�X��CqF�k�i���ѰU﯋��R����d�x�
�aV�6/-�^~�Q�S��TC�a�v]�T�#Fu�W�u�!T�����Œ�ڐ���G��}�C�D�U-����	�a)� �����mZ����s��a�/�D��.n�`, ����8[�A���O��v�Է�����W?��@�ތ2zN��'!P>�%1/���P=�qt0Z�1��L@�c�uk��]LwG
����P�7<?ѲTy���?Dk��	� ��t�7�������ˣ#x�z��*o�%+rV`��5��%����y�e.�(��#����]y7�i�;jY�2/!���@U��(�t:(l�hc���S�F!~t;{b+/r�*2�E�rgYd�gl	��쀥8H�A�r ��S8�a��l�]ۼx���$mC����Fu�X��0�� �>��f�J,Ӝ|����/O�v�B�vrО�F7��dG�2�I��w���8g8�P��<_/f�\/������c����M�hc?��Y�zj�E�q8�G�*�=�@@���4�qlt\Zҭ����I�U���I��H�@{��!g=)��
��^��tIo�Ӆy,|�x��>k��Y1E�	>~X��M����~!�w|�����0���TSYm��MK9�e�8��Ո��� ����j����%�^����������?�h�?ej����I�������-l��ö��I� Y7ʹ������ ^7�:s����T�18�9ktC$�"pG@�(���9Y�)-���{!H�M?�����t6��a���ޛ����ɀ�k�=E9�ݍf�k���?�]�m�Z�x(>$���LJ�f����TLes��G�a�GR����N�U64�g��9)��X=}3Y��S���oX^QS"�Ci!��(�)*%��[��%\0n8�>��95c'�;Ey�~q    !�+,�Q+�NNbx��ӟ���7RO��q�6���+D�W��N�#T�`jQ+뽂Ƕ[��Oy>rLG"����ӹ];9z���i?{y��usP�5�F��#��з�͡�:�!�tJ7����b� ����D�*"�7������H���hX��9^R+^�O�6��>P���G��~�l��j&EU@<.zCO\7�����a񙍈��TT�O���5�=q�����ic�y��7c��g�?BI�T��������k㚘�V�*�u=�v윌/�SƔ���I.&e��ź�	x8Y��b��6*�VX�,-�	KiGb� ��
��9�^?��N[x8!
�Ύp���Y��9s`�̒�I�P�)]in��H��wS�nc���P>�0�Tz�19%�2����CtLތ���V6�k�6�Y�-_�O?4$��l:��^�v���p׿���F?R�X��a�-������O� Я��(W����|���8�<��!La�U�Lig�tO��JP�X_Ӷ4Rv��,�*U�H��'�s"�:� ��nO)�	yv�J4���ŬV�<�澥+L�2�t�Z�g�~�Ij�[,퓄�F���P�`+E�]�Gql�r�E΄|�G�(-jW����#t��3=�o&�IKB���-�?]г�w���}�����������.��[pL�{ۦTv���&8u����9DЕܾ�/T��-&8p�'%�l���-�]dX��	��/����Xxn�L��l����r2��0�n5�N������5ex�l�H�VZ%�rlU����|%����;�IN(�/�N��R������Q��.:Zz���:%vf�lά��u��AoK��%��K*A��G�M���?�yr�r?M�S�Ιګ
�č9e·��\0F�����̈�.���=q�=el������?�O��#��ы�Gz>~L�&�K�LA9'���_T~����1�m��}]/����L�O�M��1(�9�.�پ�
%58��%#�`��A�s�����c焊	ӫ������ϰ��m�0I��[(p4W�+�'��NgM�jҕ�Hj9K�DFt������>Sc�:�T�QQtӤxː�u9��������K���A�T���(XD�e�/�?r%�*c>�*9����}�a�
5��[���uT�᠘�t�8�E]�b�B�|m G��	4����uS`ݪ���Dũ'�z�����&H:H�چ�9r^��0-w�~$8�Q�(ʓ=�	��C���oz�Y|��?'�:��$��w,����^�x�1����Y≚���.�_�JTW����U��k`���:��.��7�|8�6b��e��6T-�ˈ$��hG��0�d�l���nK�����Z�㇇'^	�Xz�$��A���@��*��	������(a�<_-0����u'��t��tT�=�v'��z�Rq}C��(G�P�!�
\�<��0X+De�E����!���ᮇzi4����A��g�H_�Z� ��bp�%��xQL�״Y>��̒�,J}�D��h�;�$S"�p>kE��YY��!n��a� jo/��u��,�-�
���S����Ȕ쌶�Q���%�i�?9Z�j���)�g�N:KP,�h��g8�t�-���.J�ZL	�t	��(wۯ��j_��o��)������{!�e�׵�y��M?�`8��{���E��Cl�2	4����q��h���]�C�X4�[Y�T1xA�#Y��?_�g����9���1aua�$b��GI��j8Ӷ�-�>�r�^I�
NR^�'p74���gy���$�3[iCι��}~�0K��6�������Y|�3!!�Ƨ���mȖP�t�f�7���U�T�y�S��*$)u%��|�Z���xA�Ix+\JǑo
��Y����n}�R�O&O.'��]�ʸ�pAoED�ʡ*�-3��5k�g�C��!~,ߵ�������y���&��3H�vN9nk��F�:=�P�!����
��� 	O�;��ȥ��+��p|+K)�r�Tʑ��	zj=q���)$�2���9�����Bxܒ���_�ab���+�h��x�%��=bב�	���41<r#Zi����	:�~�D�
q�b�|��t�o���k�d������L�����T��$b^[�����4�����=J�i���HC�!QN��u���~��7���nUb�/�D8�䭚%XO�&ҋ�ͬ�p��O�@��?�#�r�Ȃ��H�%��&�s�T�t̀Wr(YYSZS�M����H$��B�(����5`�u�.7��-A�������#��kڤ��C~�j��q�j� ��iO2W#�PS7���D]hW�w%:`Fށ�q�槸�cv���b~EX�:G��.��l���>N
ң�|h��c�)1me;���qf���i����UY��Mq\�OK�R�.Y�t��Q��;&M�{�5���6,��c�T^ϑĺ��8�R�	�5�f�T�x篪���=���899NE(���sj����U�J{_��SK�#��?��w��X�f���ٻ�z��z1T�MK�xm���$��(P���{�r�$IJ���5t$��������0yB��s� �l��aC[��L��D�9fG�mA'#L)�Ӳ�/ω�0�#�0+��e���A��T�`MaK�>��'˕�"r�q}/B�4��d���zd#Gts�����e'ͅP�Qֹj�t&�9�[��NX�	Oߤ�ۤ.�&0��$U#�E���WG��H�������z�ZD��v��v*��ea��U�kBL�Һ�Ժ���)��l0�9U�z"��Ջ[T�m�2Z���۷���)�g�0��H�����n��y�g_pv2'�[�4�+���jX׺t&fT�fP�X�򈇸����;�ަ��~�[<�D���iQ���W�RY?z���c����ccO�u^w�Ֆ.���pv�=%"� ��j�3��I6� }��wGXX,�����E�ځۄ8�yS1�O�t7Te�WVJѥN)�2Cn���S���
�#+���{��=�oG�L�Ưǯ�G������|� �K���M~8�>��ZO/|�����m��:p�w}��׊T�w���̚a��G�����s�ߎ\I��&�L��&JP��i��ae������m�,Qˤm�]g8���@��	��U-{p��&��I*�S&���[�K���\KY#�G�����5�I�e��le�+��K���7����I�c���C���$�]�zke��%u��߻l)�.;fo|�'��>�̷T�l��v�N����
�)��
�_s�#���$t=�y\r�f�g�b��tҤK�A4�csѬ"����lv�s�W%(�k���� �o��R�oY?q��2����DN�2���
78�+ҥ�|4V�v؄
H5���X:\�G��@���mku\�g�FC#�Hj`��J[��v��<��D@���,�ҦVRuA��z��L�AV�C��V�0'!��|Ctsf7[_cLڡ���?|��2U>��ۓ;�����6�;�p����={��(����4��̢:D�#8�Z'~�w9�;�&����z�~���a�c���;�0-�:���d�\�Jv
:�� �^[!�D������D��Qy��m8��y'����� �jl�m����&��0�}>�G%�t)$߰��K�y���\�}����
Q������p���P�qE%�?�6�|\+A-f=q{��6��i�hu���t/�Y/x c�PL `�����J�&S xg�B�zX#ê�,�2e�秐T=�)�R�������_��1�ӂ~7_��|��/�>O���8��L/ô����:1��=R5�6U�ѵMW)QS�k'�cz�(`���bX�J���։�ޞѤv�G�T�V�%�07�L��a����%����R�/��CZ���}*Xa��ּE]��������)w#�e)P�a�����}�,�r�|�T久p��ya|�D��V    ��_�|����r�|�Z��1a��h�aW�%�1}"�2"�yWd��A�.bCU���+�.�WљO_N����Y�(���h��-�t"�d�oDX�Z�0�Y�Sѳ2�9/��=v�[�;[0^��^�=�v�Mn�`y��9���w�)6�ž=~�O�L��n��}�_m����R2����N'+��*�Bv����~1�X��S��!n�����P�R���:�r>r��F7�AR�I�(+yC#QC�U����O�~����
��*lYST��O��;{�G=�~E4ka���D4eچ��Ca��^��v&��L��mD�v��!�0_�;��}|dx�18��_��1��M�/J	�)ge�B�`�_����������(k��R�EP��~4�|H>�D*���{�/l�:��J�׊���b�PH���Ժ.ݯ94?oh,��8��L!xߤ�
6,l�s�e-dgs�3(h"�1V��^C��Bc�s-�1pMR4�~%��y^r� {��~i��s>>��!��z��Ε2n۲������B�HB��_x?��A;<RE��m}��7���}�}w5z�\�h��R�aY�B�օ�[gą��FRp�1=�٩�@ߝ��L��b��s�rW9�@��.��� ��;P��]�F�,��9�"�Q42��0ė}��Ԝ[��?����K,'?>_�}V�J��4j[i�}�]��H���\i:+z�7w4A��3�e�a�br)�|ڤ�c�Z�"D�=<�Yچ��|~�̖��	�<��% �`Ge+�6<�ڥD��qv��W~�%�9���?�m;�Ҿ��9v��c����.��di����<�&�3�G�~�1�JLW�ͨI?9�U[�J���զ[ m�,����S:��gӔ�88��><p�82���)�kn��F6%����a?�ަ7�}?=~��C���/�኶���6����+>0���T߽��K�XF�v��wXF*������k_c>&��5grα�L���u�u?u�W�z�vN�L�Ptcp�T�Ya��aC|٧^VF2S�nI�.kX�Nki�-�֢U�%�j2��D6���9����'����i�# ����1�&�n��S���'�Fٷ�i��k�c�̙/�]��4$}�����`{>��2��C{lsoX ���"~��\�AC������`]�FZ������oqe.[���oA�y����������#x�LR����frj��s���zu|r��t7%�� ��v��ˊY�"C��^p���Z;f �Ŕ��|�l�<���'�g���lr���_������s��@c�� �|t���R��˖/�����c���Pʵ�y�԰�2[�0+RQ���؎9i�1C��J����d�{ad�?)�K���%)B�\�!b�M�8�an��u���.����Z �Kr�mT����,y[��F3���x|���4{������x��֐�)�"��-e���j�bI�%ɇB�P&,���9{�?@�o��a2E��
|�]�b�H�g%��U!I0�a���\G����#?rLH� �Xu��w@-��z�غsgk���$��`��3���3d"����-ʻ/i��O��. 5bb�w��ї>vY�3�\R��%�q&�NQ����*¤h���qt#�hd���:��2����[*�f2MX��w����P�M~i�Հ+�C"�8�X�ѵ�%c�Znw�D��9�%��z"N�FA�Wg�Lߣ��ۓq�f|��	���#�6���ٛ�a��]!���>���ua�.���b=�/�O���"?�J��K�E��R�a%y�`��q�w�����ߪX����Ύ���R��L�q����٣~Q��?<�8YnB�����Z��5�s���oڴ��EN��7�d�!�D;OH�%Zw�	ܐ�oFIi�S��|>��|j�����Ӣ����z�ѣ�Z��Zǫ��>z؇`�
�<���0Dk=������]��"6*����N�����N��~{B�=��齯^<�$��Q�부�*$����Qv�K3,�gL׎^?0+=0+�¬TT�DU�]�.sl"ey��(�p�#�r�⺺�qN�2+�^�������ڢY�V���-��F�rf�b�?zXΗ�u�	�Wa�<zlg���4])�:@���a�&�_���&�"Ry
�6h�8�v�Q��i��(m 1$���)棰���025OD����8$�q�D�34��n�A�Um[��n����ί�����z�H��e#r2��48{�~Bwv� H��m�m�w�-/���Z�2��ޱ6� �x���a���>K�Y6[>M��w�?���_8�����mB���Ls�-hA؅Cǡ(Kk%���>T#��H�S��a!a��y[�P�RQm�O���=[b.��=ѱ�/W�������WE=,!r,��&w��n�v[+Y���݇.'S�*�Q;F��{5���r��C�"v+m�x�X
�mV Ǻ(C��)��_w=UڼRZ��;�U�H3r�-�"�����V�;������_O�t�CI��*�ql�k����5����ɧ�t�t����4_T�["�fd:�1���������{[S��]�n���M�����gQ���V��;�}loX��(fT�Ł�GT�BtYu��� �v*c�4���8۔0=�c����x�&��H��Yy���"�Ոh����H?Z^���h�ę�1�
uXl8����|>�ѐ@���1���uC��5[\����������.w��:�������]k���Q�D�w���ؗ��H�cW:��X��W��7�����=l���lD\9�x��};�2{�_X����` �UO�l�FT�<�j� *�䵰p��"�v{���e\'erpts�!:kᮽ3p��VBW�,b����@����2��L�- ���Q/x�'��m3_�l��^�~�i�R�
^/���]ҍ,������}~䲵�(�5AJ�1ו��+��~�1��e^0S�>���,WΪ��}sSfę�.�W�?�/s��C��W��9j@��\�2x�@�s?2[ZW2�v�1������cjՎ`@p<�����a�[����x��V2tg��b�5���������9[ז՚�I]�*���L�`�����I��C��:����Mu���[_t(��ܞ�4��g��ec��ϞE��������������_��}
R]v��10d��b�y+��(G0�dF�Z�պ�R���i�H���Cgd�9��U����.QDb>�,/;J�0�{�9
p�i]6�����+�k��o`_ox��>���,e��`ڪ]���w�Yy�?D��7��m@uq$���l �i����ƾ>��g�����SF�m���d�zp8���^\�3Yw��)`��)����(o#��<��_��.7��%�SX�jJ�Z�q�5�Ɵ/�,l�,�u𰉾��O*������
"wR׆3�	�j��!ח8��|DFD@������r}��߸�^!fp��w�D��L����ۍ�>i��¥��0v������;˞�~�WF���]�~����gX^���HJ��V�#���9,PD�����/`]\�//��&�V��������>�k�a�x��]��5�Z5��پ!#w�B�~���D ���i9.�GD���|MW���D,�x���^d�d/�~x���3�6�%nE�鄵]��3�F֡�Tn�3��$�
<zR@���N�����|"tB��u ;#�U5E�C7��ߛ=2=�%�$�������_�i���w��%8!�ɝ�ȶNN0z(`{�JL-�o{�0ǆN*=n���trI�%m�`W%�� ��+̃��"N<b,�=��2-�sH>UD�L��5q=lܢ�>M��cEŘ}������y��Z�,��3~�q�O�i)r9X�?D�g�**�7.���?gߞ~w��}v8~�
<��A����r��(W��U���\w^8]Y]K�kT����Kd�mtm_�"L��Ҋ?E?��t��p���V����$�v�ג�1_�
�\Ŗ7x����    � n�m6�%b��/G�8��L��MS��/��Zū	�fb��5����2�x����y���̝��M>�#?���iO(��B�f��^z�������ވQ�fe`j�&�����X�1lz���Z���:-�R��)�v6I��\9�7č	;\�<6���[�s��A�)�����񇷭�-���xD9:�dX"Jݶ�sc�P"aTe�F6���.���!�vo� J)<zw����4T����	�X�F>�5�G2�ȸN����KGE��áBMx����	{ 67��+5�$���Z��
����_�-6l�J�G�62{2���ɛ�~��-d�7��4��J�-�-D}~�@w{�G��s육ɿ=9~{��=�6&Vns
d��!&Z1��*!x�%l���6�f�/En.s�V���Wڢ��47�.�*!�2�S&F�������; >t��f���$��B�t�­!�M��ٺ�aB�GJ�T�K�����P��+��pV2+i�o�Vh��&�U�VI�~�blw<J����=|	�8�
c�����VW�Uy�]��QJN=�G$���|>�<��6�Of�GOz����7m���n1��m	s��!�=t����ն�����¿-|���s�Rʄ{WW�u��q?�5R��.7''9k!QΚ��IZ�=��Z�
;�P�M']#ܨ���9??~�2!㩇N�ǯ8�"��}$�J[k�����a̰��
<;}H%�~R��2��+�1����f��Ny�݌d�
�$>�0S$=����eY�D
Ԡn9,�$��  xx� j(��YUv�z|h%|�᎞���7�FA0����Ewk�s�ϻ�,������O�n�j1���]�K��:@24��>N
�W�E�#��cM����֒�d,��y��p�bFF�n�Xذ�ޘ27>0��#Ć1=�9�Çz��?�����r�\qڛ��rMc��6Iu�� ������ί�y��S?x�=��I�#��:L�X��7�0�����������&��7q�s�B�.ZW^_B�H'.t3<i�N�CF9�m9�E��N�߁��%v��.��]����%a�����Wȑ�-s��c�����ޚ0���(�,*���n���������u�b�z7O��"�bP{[����HR^���)`��PB"����k/�ݶ��𩷘W�`�p<[���
��RT�k��Is�˰����ѱ�/�[lCE�c�;� ��UQ�y�=?���f-Dt��b���zQ�e���58�p_f�%{��_�b�������}�v2��x��*&D���Mmof���EI0Jxo���zB�8=�̗���T?�|4��Wl�Q�xUּ{��y�J�M�!�{���ۜ����s"�� _��O+O	Z	����'7<�x���@�.禜,Go���6�B-�4�^$�a��ń�G�j�/�_2y��Jc���9q��z9���Y`$2��(i�\.�D��li�*�q�u��|2�_R��"4�ˀ=<ˍ�y��6�H3���|��+��T��7Ҋ�=�mO���A�R� Y�?�DU�My�r��d���� 5M�Q�<�����ac�ަ�Sq|���t�	
o���� ^oD��7�y�*�n��B�u��v�"��Un($�x�q��NYD����κH�q�!~����53�%�J��wXJlj��S����b�$I�o߰\���%���؂�@����8�4�w��F��U ~)�U�yN�	�pd�y!�f��2�`F8d�{�X!�̋�s�w�&�h>��EE����e��Ѣ�%�\�{B	ua�.�;%5S��R��'Qpi$u��X�g��S�Fp��^&5���3r%kI��p��(����A"�����;�`��B�>aaU�,�(Ԯ�*lw��9yP=�o��w��(��\J.j>�6GNa���a�Y(��۽OFڲ�BE��,R�Y�b���C��K#
�rO�Բ@Xnl���f���`>F��m��}B���|;���^�b�uڤl����ՙ�3�W�.;�TUK�a5�Z��AgM�"�b�>�\x�2�4��g��ٛ\�,v6��_����{��7���Tê��R����G���b2��O��s�X����+&⋑��r~q=lsT�׋d
�o���,�0��pvF�HM��mk�����So���k�nl�sN�p����ܮ�d�8n(�����j�D"��x��<]��ԅ��s�}�ˡ�#�C(�]Un��-�ƺ�P.BO�?B������/����f���9<=>���uv�r|�a��?{�-� wu��-�����K0�=��Y��R��Dh�o��N�~��↠"OtQ�*�옂�Z���@�*LZ��;�H��`����W�h
����acP���\V6��`��(vwh�#X��֞F��i_����^��|�t�����zv9Y��š�X.}���v`����^��E�-&��f�=/ �ϧ�7}��,���F+Qe6^w4�dY���g]v�kA�9	���a����x����N�f���ӿd���:z��t�ǃ˅}�V��2�˺��^��a�Tb�I:抁�hw�%v=Wٷ$�����?�AlY���kRX{��ei�H�b�&-�0%zoX�&�6�s"抏?�!��t���?�#�a�#��zR&�#����Ae�P��/��rT�6Nuռ!V(�9�����%`g��r��"�0�L��K�O vĄv�"H摹`�3�����&N�$�/糭+ϖT,�|��0M�?
]�0U�y����"��;�5�a��u���?-��E�a�ޓ�L��2�J!�5�:��,��;zvԬ-�0�E�ICt�Ѓ���m��z:��{;;��8����oO?=Ϣ��{tO��.}���n��(ɜj�7 q���Rò.��!X38~�D�0���ð�=���~|n)%�U%�g���d%\adg���bcƹ(s�!���nK�n���~x4>y�}{zt��e�ˉ����#��6�����@�Wt�l�v���n ���p��/D�H�b���
HroC�c2��Ԋ���6�j6Xaj�#g�{H~��D$�E������^��!}ζ)�s�*6�M?�?l�;�k��0D�:�����n@�X/r��Q�i���`��_�y��˙p4c�P��$V���ڊ��_gv�ו����K�*w9���#\x�z�h�$�(�C���!��2�r>�FAX�DXgglcJ�<����'�ܡ`��Y�>����O�ް��o {����� ����bOo������Y,��+V�I���u#¯�Y�=B��C�z�b�H͝7 �0���H��/Q�n��Y�.m՗[��M¶�"M(FrKp��V�"�����D�D����a�]>�Oh�۸�5RM,��6�]sR���U�^n��T������<��?D����z@�S읧)?���U�v��޼�p.�.,$X<��f%q��1�A,�p���op��H�RYi|ŝ����'�~�3(��p�2plc�3�\�y�P�ֆM�$6f������=�[9��(�vp�:ֈ�U"�t�����<8o���S�.X� �mS��TiC.tѵz.��Rf��.u4�0�oe�TuYZ��R�F.��0�UQzSL/?,����	� g]�!v^4T

30YL-E�X�Î$81�i)MԊ�a�����(|�QO�R�!�|�N�*�(����],mjƲe
�����BV]��T���	��2�=�Y8�R[��f�(s8\/��F���S���L�j�nR��yR��_��*���+I%����Uͻ��|�l���(�G/a�Ȟ�����'C�i�1=uTW�;<���(�2���a�~�BX�|��1~�����T��Aئ'3_�H����Y�S� �v;�|2R6��7�_�K--��RX6Ԝ%O.���%��x�۽Jq�V����v��ѱ��](�Yt*{dIoO��'ϏN�G�^�ON�oZFY4(�ѠnW�S�\U]x�I�0U��Ǥ�a    �JW-#hq'I�i�z��?���c��ӫ�Q�2R��Q]������?˖Ɇ��g?A����U�{^�&�g��:��"�+��O�QFS��`�ɖ��U89�4�z��bV�Nf�
�Q���u�V�
}����Kh�������o�^#�:��"Q�E����1Dف���\���)�^�/�����+k���"�TüȽr�U��vq��#���m�=ѱx���jKs�g����q�mT:P���ȅ��6Tue�UpL��(��;�AKi��w�
v��sI[�ur�� �ﴉ^� N1�1�L���S7`w���.$ϻ�ZHQ�e������	ؓ�~�rz<=�o�iq�o�O>잎��M<v���@�
�,�͸�M���$��M�t���M ��d�:NDZ:x�����|NMߍ��r��ZL�	#�����F�i?�p�ebbH��Vr�q�FI��5����h�[�*0�|c����5Y}���� ��fo���	�-�V�r���om���dE�8JRcY�+�0��#tl�3���M�)������O-�˃.�n1��ʭu����蘪F�0�U�89P.��sGө*ks���;*
k��u!�Г`��k`!Ϩ�!�`<잦�׊3L���|��S��䕨�n＆�=�a���p�i�%sZ��F-�b�!:��0xߕ��lq=;���o�����-��΅*��R1Q[^�N`�[�n�b2�`�u��0D��OcsJO"^'�9���e�3>D�l<"%!����B�/YV��}��'�'~����o�t+���Z�
�#A����T����Ρ��4���ا���T"�j�^��;�'�m�*.�9z�Z�RzpW�R�w��_���p9��W�B
��i�Qk|�^�5>T$�"�Yq-˖��C{˭NGMT��_#g.84�o�_�(tcV ��w#��<E�{LVc���v&N�t�16�FZ����Mꨥ^��9���
���4���DPdR��D���Іe&|F缟OiLV����h���섦�E��ۺ�:7�����R�QǠ�!~�nw����7]л��_��R�H��V�ݶV{4�edo&��(v=������QF}=�&]��H$�0�Mf������~�(��6�K���tQ#�A�iH�6�+�l��8�h#츔L��%fN��[_w$���"�x�I����7���Yu!mAe����R#ۻо��;�w�6$,���(|����fQ;�-{2��v�SR.���VL|�����G������J�J�I�߸$iQ�%���3��q霮��ޱG�?�r�2Q���#���	���*�x���C[h�r"���F��a�0��]s*8`]�D�6t�+�<�͝�D\C�9}i���Զ�oe]�/q�{��_T!<n)@��/�x!�RR�hWP"�^�oZd����!+�M�x��!KM�\�D�	3��)/�A���.���0^��,
�sܸɄ��(�O�O�����)����@.*�=L��*x�q����4�g�=�����i�����Y���9j��ջ�[�ǀS��������x�_"������t���,�bxn�@F[ll�_��e8���E��xBO�u�R�`�v��e���S�z$��e�\��G�ҧ&�Q��;xUi_a���d�����s��O�� �VeE]m�����d4�Xz_��j��胾�H�z�L�����|��ˁv���s�Ǵ��`�A`wF;�������D�k��J���C.��pO<��׳Kt�b¼��l_��wjLÈ��lǶ�:�C!k_:S���0�́�'+�5�?D�&">�ǐi�h�߽z>F�����qvz���Nԫp��9�oɫݱ�"��t]�O>;����]��-�	��4#�ߟh3F�G㉏����1m����̒��E
�x�}�nO�_j�	�\��Nf��ZX�GO(��'=:ƛ�u6����.����~u|���~v�GD�H�Q��b�-�x/R'�s�J��r�V�_\��aL�Lї��Uax�o�zԴS�0~� ��{�<,	L3R;?�?RV_Λ���=�N�3��%z������=�1����M���-�s�1�����Yƭ ��b�2$�H9e��gCt��p
%E Ë�NSݷ�,���o ��m�Md�d�9�R6�ؘbyi�=9�~Ɵ< �O�]S�^I)�u�����SD-��Ř��!:~ׯ���n؞X���Uά�l���Ee�,�Ju��	���j�si%��=�1�/���E�^�ֵ�e吻f�sG�p��Ji}Ó���r#��a��1|��� ��g~=�DڢG����i�b^�Ow��In]��p�
�<*�p�`B
]�y	�/���AC6���@NPr�������h�ɪe��F��DY�II��x�7'G�T�`����5�������.:���E�[�Az�4�O���"�A��)2c��>�\���~��|�Bq�!A�o�1�M�#t,q�J�7��${��	���-RR��g��^Gn������v�L�s���-�����~�{T�����hF�k�o��OtR�1�խ��:���0Ӌew��mB����M*�)C���� Y�"|�O?�h�E�Œ +�T�%Gc<o\X�(x��~����(�L�7������U-Ť��zy�T��U3;�|W�E�����w��	d���c�XMT�Y��~QA�/r"�����g����*-�O���Ѯ���f���n(&�:���������/��|���i�Z����?=ݻ5�/��-�����UX���e�.�/���D�a��`�)��2��"V�=LTi���U���Eѽv�[4�j]>r�mv���3|[D�%-������N=�����k	��|�츳�( m��P��`�=CtL�U��Ή�3�y؂���d1�a
*�`F�ZHc�2�)���E�;f�:�&	�gͬ�j$�
}Tϻ��jww*~�iqEYrb�×R�o�)�Q��yV�Y43�񬀏S���H�9��v�#��	�� �yn�t�jkl�8�mK��T�ZB���D�������!��1�{~��9޲\��}�����������5g��1�|�3T��(2Vr�7��")���(K���
�?�d0*g���Y�:-���谦6K�
��}�,���
�B�ї�D�u��'�O����)��>y�he]B�4T��������+!+��n�����F�)>������=���y�KbmD�������/���~��~�9�x���K�����3���aF�s_ѡXO�Ny��y�Qc51�$O�d�*�7���Jl?�F�2�V��lqSv$������z��Aߜ�:�������۷P�/{7~�*.y<����3wZ��!�Ƿ=�RÎ�^�K�,|��?|���,t
t��K��g�%�SS��p^�+��~���s_��6����ֻ���!�j����r'��b�Jm�d�]�ZK��FYE-4��=�׭�G�>Rt_�/�ߝf��?��	����?|wz�<�A�Pe�=Z$C�U�m�KV /JU{o�ت����XY�s)wp.�68&�HMڧ$Z�el��a�����j��K��h�4ZT�e�_t��W9�E]�`K��^�����a2����=]�m��c��W�٢.Pʹ{�ckɕ�A
q��&rc����!��6Tb5��-Ļ@�#����s����~��\I�vC�*ކz��Y�艜qK~`C|٧S)��ߠ.�L�
Qf+�C�]�|q����<\�/S y8Ga��?E#HIB|�s8�|u9�,L���?T�~u/(��Q�4�yqOHRЀ(�2Ј��"��*%���:���9b P���&�)��c��\4�*��D��$X`]pj�b:�)�ǆ�����MN�9eo�h�I�Y5���!��W����#xc5����M&���b�5+�&�!�5M���.�/b~Q5H�y���s��̗XҊw4��,�Q�����![>5t5�{�G    ��+��1����	G\YԴM1�" B���;�Sl�,m~����tRb_�H���~I�lo`i�?��A|��I������r�N.�'pR��G_�AY��K�B�(���-T�'�rF?<5L����Ծ�Z�ݵX���+��n���S�G��<Jr�0Dg����+�e�Wpk������ӿ��|xy��71�q�����鐳���~w��� �ro�m[z��}�U>�W5)K�y͇H��82%�kѱm�i�ɏ�a�[=�/P��UU�:�N#W�Y>E�\Q�z �|�V�� �;�׬���n�g�cK�-ax?�G��g��A�4����H�� dW	�x���,���ֽ�B�����b�)���t�/!�DL�9J{}"=��*�]��p��9.��,!(��<�9|��a-b=��Z���Rv?9�����ͱ�'�j�
�l!v�;��B��r�!~$9%�t�y4��=�>�Q�===~����i*e1M�oq�h��!Z�����xv���f���ZہAO�;Y�%~"1ŏ�A��F߾��q��Xv�ئ�w_�6�.$��Η�����%xK��Ё�i/���i��J?-����}_�K/	Q"�/G�	l���XcL��o����Ê[ut�Fx�
QGH�����O#u�f�ZSn!����<��h�nW&��;j�Rx�J,��|���\.M���a��n�s��C�,�-v���s|����O����Tb��0�6���L����_�E��F��9�d�7n�Tb��Gh7�5�1�\'����1�(��ic��n����W����Ǒ�����������D�Ĩ��T��Y9]cH������'7��FE��sp�!�9��M��런H����$��K���T�����f����S����g���ȭ/��>ɢ����+\n��kw�Y�d������i�/�ߌ_��2>��a����g��߰��E�䷼�[�N=bPa#[g���������ec};���:�Q��aۼ£.�%~��@�_�����u A2����+WT|_A_G��򒾒��1�p�\�"�^�������?b�+ �T��=��*u#!H�S�>.��@���fL����^�|߻��#���j�5`���uQ��bjQ�ڎy��qN|��#t���G�=b�_T���&�>y����$�*mX�����-*��r'!�����<VZ�����@UK���V��w�}�9�rܑ#x��lޱ2��^om�u]ùn,����E�_��e����~6�e��Y�/�-���g�w�0ĭ!w�E�;�W�	]�
]`I�L5,
oj^-�����d�������m�Zc8���x_�ҵ��O#��P��>�r.�Al˾
WW�RD@��
|��XE��$>� dsGS�5��!�C��I-�H�Gs���5�q��O+�/���� +���Y7=C�8��]a�賻���
���SN�����{�t+��u�o��7ٻ���8��dRd��~x�=�?ī&.�ϯh���������-�\xo�ѿ�~�e�!~}�r�cU�{Oe-u]���KTۺp#˵�t��0D�d��>(ǹ1����CUTeP�3[���/�� L�j��l��yΝ��,v�J
ڧ��
�=�}�;�W�2UyQԪ�Jm��ԥ����L=�nd�����C|Y_����V�,��aW����t��;�_o%z��Y�ŌHr����)�������PO��Q���Pᗩ#*��n�F4�d�[Re܄�H��gב��i^B~�OaA h�'+�BՇ5��8��ף���2�N��2r|��"�7����!=ބ���7<��h˙m�4�l&_��'9
L.�VH�J	��ɅnJ=8_p�=-\b��.��/�sb�Z)b�r�tW!�Ġ������.�S�h�ȈHi���@��5*fP�|���+���YP]	��
�k
s�]"���|�FIO�����Q�Ν�M��-6/�°��D�M^��M���#�)�M�a���{�qD��xa[4G[�,�����;���KYZ�Q��a!�_
^����+j��J�>�Pp[����E��_�z���Q���!��_QpY1+ˡ�j��]14�֎�R��A����u�h,p��I�d�X/���z�FK�+4��K"~��
���bp:[��9Ǘ}����x�D
�YXa���z��pemjY�mA�T#c�839�=�#O:���ūA����
�{�>#�]�H�)�������8	Ͷ��>�/�����w�_��������v����pp�Lاs�;"9�b��)����?D���3�.�C���/��6�UYX^kp�/�qi��e��;[�8�~�CH�\׾2�Ϧ��p�W�V[�W(���r�s�N���҇PUH�4m��^��;�c�v�����l/;y1�a��p�[<j:�Giک_���^	qD��Q(�KdOqKDdH���)¨��h���	����ْJ�|m��ދZ�Ci��}�}.�����
,UIe����!ns��ti�|2�ӣ�ً�o�Sht-ຣ)|~k�E�p*���;�Q�:X�5�(T8�v����/=��q)�Wj�k����3���N\��MH��a��A@;e�{��nθo	��؅>>y�}{z�C��2����K�h˺�6����*�*Lem���t�4|�bB�����_<N��*Ž�p�Q�ѧ�x��9D��TJ¢�Q���T�Jj�m8N��8�,�O��ѩDf�%��$͆��l����%����3qK�jQ7��#	J�\m?V��~��e�QJ��po����΂�J�k������������Ct���Yߵ:����G��\��*�"�ŭ�'w��&�(��ѳ�������dF������!�כ&1��H4�07I�k����2"��d�j�㨨�M<v0�n�L w�����䜤ȇJ��
�dz�>��/v�$�����/1a63���*����I���S��eHU`�A<�Y寗1d&np:��VT�HƬ��p�xn�����(r��:�^�-�������y�uF]/��2O��=�1fpUvU��σ[f�h߰w�nH�������-r_�Hpx[�G�K!}]��Zpن�
�Y)uI��%��d���/�S��w���G3snﱩ'����^l��&/
�+[u�K�1���#Õ�[~����lv�8����?�_g/�{=><�*c�����L\�咱��0����΃�4x:����`��i31��ܕ�=��r�����q.n��l����Pf������[	]um����S�QM^�(H�!:��~���1�%.�w!Qv��D��:�Wu;{�i��s��`s��m/k؍'-e� ,/�D��rX[����+�̜ݑ��!�����oD\��'�q�`X���=��W�Țj�s�ZH��8u�E���$���9��ݛ���oP�>�x��1L�(<���9Y�aʢt�47+WYkUU�
���7CQ�b
ð,������t�Wk�
ҹ��祕�UZ�Ӛ�`�� ^��#�t�(`��[I��U��1+��9팈�e�Ɗ�R�1��z>�}�����Ds:�"pW��A@@�����jݼG�a�q�
���8;�F�h��B�,zg�|�X��)�n��l���fG��~J 5̏|��Qm'��P��Ӳ�ہ�&`O�hx�9�(��!:�N��h���d1Ĳ}�=�g,ۏ�S�.�^"WU�焕Ci]�\%�,��R��2\::L{���Ϩ���j����x?Cc�-(���p���.�����*�dYhg!RHp�+��8_e��9l�)�w�0�Fkm�w�YB��]=!`��'B�yɼ��/�;���R�km�I�/j��Y��D'�!B�!Hq-q��-�~����%��(/�ɥ=C���5�FJ��Y���:_D|B)�H��4�պ�A���lM
���v��:    �+un�~	Y���$g����]���������b��9=~��C���/M�W$p\46!�V��[-Z>x��͓(ZIP��Y��⭌o����((&!j�.R�86��\�{���e(��=�ԟb�B��:�앋�� 	�ƍ���$��	L8i�T�7�g���TIH^�t�u�j�ٰ��������
5��
<_CtS�b�Lz{�U�����Kx+mS�HVpoL�Q{���%r7=����ǽ�2JT&ET$H��c"i�ք-���W	[-Jl�[ec��Ex��E��f��?-ω{j^�����[M����%մ&K�:;�[��6���_!-F6����3�ͥb��h�e(��!ˉ�I�z6�?����'���u/��_�TD�Y����`[��t=1s�$V��ҤV���8�\�IjN�u�*���[<*�M��&G���a�f�sU�B+�c����|n"D�ԍ{�!✈��3Y��KSFK���)?2���[
�ݸ�ݶbDiDe�r��*$ΕV��X��nt�(�,�ۻ��Y`�Т�93e�T)���v�nMj��-�
�7�5�eUD�tW�M:&wE�T���R��/G�Ƽ6����"������_�i��s��Kʇ4�B�;*�W�w(�����G4�9, ����֕%�7"l��	���H	�[���0��$;n|_@�pw�U�<&nȥ)�d��K�u�(�Ie5s�w��B�^o;���<@61R9ez�˞)�qh�j'�:���2��P��Y�� ������~6�м.��a���t#�P������������.�`O�m��B���m��ɱ�E�Wf٣7���?l�ϒjJ|S�o��hK�	y�H-	�(��7�P���Rf��O�T�������N�D�����@����D<����A}A��9)�0c�\Hc�ٽ���󂗨���!��#���NICt��}QfѤ���,�1�?���dGi��Q�ݲ���`9#w�jE���B��H�u��7\�:g����{L�NLv��R#P�@Ш�S��_� �/}�xm&�aQ+��n|8�~�,�j������J�MU+r�oLJ������_� �[��r7��?;�8�B��'_��C|�:]�������"��X0>de�F�T����:�Av�V����x�a?����'8�8h��;{K�a��S�B�����{�
�a�v����0#�Me�z��a�` �$�?�.�3����l�8~����/��ˣ����?e�rL�=�kD�[s�w���ͷ�{�9��� б��T:(���#/�'Vf�{�m��`��bAo�!����-��5�38�0y�C �>���V@��|��o�m�u=���QH ��c��2�\?s���<�L6V򪐸1n�tQQ� ��7J	-.?x�G�F3:�(����M�6)0,���2��kJkS�5bq���08gb_,�IRc+�n3q��(�c�`���X�w\����k���UO�M���w/Ƨ�`�"�!s{��n��� Z��n��~ޚm|pH?�Ǻ�=��0�h|�30`HP�$#�����E��$ĺ�HH��8��mo�S�mm�i=[���w�8D7�N���uW�U�QO	GNG�9"��!L$�ht��*q�7��H�$�[��JB$$$��K����4�<�2M�X�I��4����<�^X�����[:o$Xeeb�IŐ�ڢ�=��n��)&��ӊ[�<{"N
}I�U���ܗ�t�}����C=�[[3U!߁�`�*�B�>܃��B#��ֳ�#/J>4֕66h�k�v#~H�z�Vo��`ܭ�/�9��\l��8!(zܾ�/`ǌ�*���	>���w���C�=\�_����1�aN����/'�@�}��"l����l5�����:	6%>~֝c���<�4�y"h�Γr1�j�	��t��D�}5�Z��z��5='�{\E����r��5�:�o� �ʔ�l�k�ԣ�n�
JѮ��ǅQ�	�zZ����)�s^��
�P����w[nI�ǯ9O�����"]GTA��ZV�[�CrwOoLDG(Hl�����>�^����3�
 x��6鶻����x*PYYy������;^d�Ue)��%,;f☥=c2I%���в����D�峋����	�Z�0>;��I�!A����Z'�8>p ������n`��i&+V�gX��sEɲ�9��	^�&0�`��7~�R�
I��Xf��*7̉�!�:���k(ݿ���t����������t?7	M�w�̣����6 ��@W��n��<�|��%D��@�b���T��A5��1,Jj-��������C>�G�Z� P���YS\O�PG����֌Z�ҧ�B��a������c��8��
��_���Щ��n������
F�dH"�:!��,�}@´&��
o
F�b!�W��BT��Y�<w��Y�.����E��;�wjX�[#FzkC�.<XJ0Y���g?ո�?�|}q�H�v
a�Nx���z�xq�K��X����U��h��9�#?5��N ���,=���^�� (��#���K���p(�,0#�暁����A�{���Gp�Ғ:P��I�Q�X��Z��: �D�M|�� ����B�����eK�,T�mk��*��CZ�BhZmb�tO)�B� C�Ăm�>�҂k��O~���9yq�����U��9����"Sȹ++�ڴ#Y&ʮ�S.cfSn�����ʨ�X���c�	���@̈�F��֩e6�W{�
2|���;���7�M����kK�ũ&��Yi�-HL�c����un����9_��&�Js�D!�L~k��4K���KF��}���6��S�a4��x=Z<������e�"U�ž^�߭��6UfRU�C�;�iO��@���G�3"KE΍i��<��r��������|]�f�Fw��n4L����f��Pо�K�i��p �ZÚ��s�7ش���Rx������6�C�F'uG��r�&��8O�*+�`X�K�fP�����&@^S"�[j��ĉg�b��-�Y���fu�P��dT>MEU�2�m��sLJ�^�\�Paw�!���ڥ�8���������=w�[D�����T{�`�F�4��/M�U���\��	?Jd|��V���	'e�TҴR���f�!p���g������q*�h�9���`O�ا3(�"F�q��Rؤ�K�=�&���4h�
��Q�̏f�$fG�5�P��(C?�؟˓��;�P��0[z�s��J*-�)Zt}�5�s�vT�D�r����,�.��<���醆hbX[O=����8?�X�T�8n�+v��{n�O��`��e�H b3����d!�Yf�-�J���"P@`�;����cG���5��gp����*/�Y�%l�=4�8Q���}�d�8E�cN5�|�FHN�1p������������D��7X��.�B	=�B�lb�@	O�3 t�i�'����V[�i�f䚧UiL��h灟�b�����m
ךt�����Jk���m�>�Fiϲʦ�F��Hե+���%���ke���#����/���B֮.��;F������� � K�Sw���2#���n�P�-u�nλU&��ڇ���.� B�-���|R��p�H�R�e0���"��w�	UF�^��� ��g�'�*l�ɂ��o����<6xG�B�k��1� ZM�{z;F7B���Q�� �?�N���!u�I7���:U�����Z\�b��ʩ�䦲Y�����o���� C�Dv3Jx[Pd�ד���r�_<>K��z��yy��\�z�f�d)&���Ĵ`�,�%�U�'�,�J�g6�������J�y��rXIS����i׀:K5`s��gDŢz&�Ø����S�>gi��-+�)��FJ��gL��s�$ɼ*���X8VZe6�dJ���J��x�!~;��Y(�vɵ}�y�_ah�,�B�ۄ{�`�"}Τ6 ���Q�    �(vE�ݟ�;���,�Y�|�
���R2���X�o�:�FP4}�����2�m��\�[Y���<cQZ!�c�;����~��Jt�}ɜۤM$v��XH0��x���񻖙Թ��-vpC���>�Dq�۬�80Rx�?���!>*��A��OLp �6o������zu]⤪rԢ��r�*ǳ�N�d�}b[yo���=��nW�|Zқ��|[�DQ�(��
ۈ-KKi�,q��ʥ|�	���d*�4"�������7���nwK���ū��D��x�rwƤw�4V���J�u@��E���(^�R�bE��
ki9�����>��L�� �N�~�!KDC�C�����IHd@|��a������2t�Sqh[v�<��-xc�%��D�bnJU�Z��i��x�^08R���\��������������O�<�S%���z�s�3.�|���b#`�G����� C|��PxU��P�y��1�5��yp��Q��j�eKպ(d�����6�a��@d�R�Y�`�ֆ��;be�*��E�'^�Ӯ����YF�=��c�9�)se}��DK��g`P��i���Dも�b�xή�Jl� �j#L� Pz�0�"�/��h\������,L�Im�Eι��ƃ����%>�C�xa��T�1���.��i�;�.�
Ξ?T��K�h�(\���/W8�'�d�l�+8�
nj��p��iZ�,�GƗ��x���T�3�Ҕ�� C�$�>O�
T��i�Tf�G�5����r�����j�Ȱ�k�ljsǷ�.LO�� �9�-��}�Lwl���s�)��$Ȃ���6���U���d�\�3�'�&@0Ċ�������2e̊�Wy�e9X��\�?���ΐҔVޮ?��Y&�J�{2`L�^�u����;e�s �NE��틸�/���ف\�-K���+]k��n)A�U��p��n{Bd�
����3�����#��e����˓g�PyI(NsĠ����~iX#�\WƔ^8ŬÚ-�j��9�>�*&��v���Vq���� eY�U�`a����ce���pN��v�!¤�j,��U[����8�˶T(���*W��Jy�e_����(�$,�U��?�v�&�Z���&�m�~5�J,
a�b>���G��ΛP�I�X&��������o�	�"��[�(���1�I"S�+U0$Z$�A&+��ɕh��h,cƌ��:�-I�+$��!���}��Y?�8;9%=��D
w�*[��sP՜�U{ij���l���?2�.ݵs�=i2��eΪ�����?�u0}���*�'D���J�M>Z�|`R�|0Q#�4PQ�`|i�����q=���p��\�a��*~Za����T�&�]YN&ݝP�m���j
K���c�؍)o�G�\M�3,�v�4[��+���$��k'c���3��wľ���>�<c�Hlr����w
+l�ҍu9���ڈ�4��X���	M�����Y�f0���n�2J&�KF��F�Ϸ�����R`�#�ꄋ��Bj�\Q
UTh���p�\�?�.ʇX�2�<�`]���>o(��^���ڠ�v��X�q�)+��5�C�ũo�n�N�6F�Ps[��P#Zg��&~���C�^���1��s�䪅�������k?�!�,��Nnj�Rp�H�~^�����jM�q���׋G�T�2DFk'R�U���9� 1	Fi^�"7��B�:E�%��Y�Y�%�v32C9r�bz��������]"a������-��v�W����Tif+i��q���j��Rzc[|V\jt6��SH�\�
�l�N�f	CX&"3��,��`��fŁ�՜�K�e�u�1F��#����]
�W%Kc�9��N�d�y���c8|��
�2׃���v���b�K<R��w��ؕ�0&A5q ��z��ۚLP�RX}� H�5a�%�"�!Fm:�FI�TI�z9�D�X�1��+è�. .B��T�㇔� K�	L�\N��^T}�e�olq=A㶦��-�ʥ�.�j#�>��a�Un!�1�f���W�����-�`����,N��C�ic��� C���*R�aiY����%�T5F�p^-ӫV)D��J��ڧF��p5���V��,3g��kЏ���/	[�[�8Ȃ�=<�;�RL]8�Y8uW�V	�:'*�"��X�c&z�������h6B�*����@Ja}
��M�<8�L����i����`L_��O1ᆵcx�e�	��9uP�&U%�7�c�P�!���]?��2�M�eBMR��\+Y�Yg��̸4փE�7�5��R�Xe{�!���VX�d�4�Sn�����Y4RWS�0�co�0e�}�������\�%��W�4 �q^g�ts�2�W����ļ���z\��R�� C����L�A��2�fRSs s�C����[�&�9����� ��٪����#�\ڃ��y(����7o�[6�>��ǉl
Uhf��X��?9U6�d��q��J�C�� C:��g�Nەp�k8]��b6�7�s�5'�?w��.n1\y�Yix*���o��)]t+S)c�E�֒o�a����E���hE~�"?ᔪ�7\(�h�� �+y�%�iQ�Vi�H�vVv�P��gy�6��\`��J�E!�3eE���6����W?�ZrII����~MN�z�ӕpk�\[f���t�\H.x���t���|r5u�c7�vɔ�& S��B�
a��%�Hr_G�}I-@��<��R���"J��K��%F]�2[���W��\�l�6'����e�)֎��g�E�?,�%k [Ɍ`k6E[��{��o�וֹ�@a�6j�l����n�-_�,�T��%L��MF�іl�+D������Ƴt������*vs�e�n�.S�.�V���*3e^���{g�fAM�fƆN�"L���P�������2���q����, �?t�L�:`�:��#-ﶪmmV���D}L��tAo�)�
�*uoE���h&��^�/h	"��\g��������Y�-`�+��;c|��P`\����x7�
g�ε,Ҏ�Ju^�w�:� T�<�1�"o���y]��
����yY�RK`.V+u��2��Rm�.9X�iF���W��7.�*h�L�R�si8$�b��Es1�]���#�M�t(��]-hؿ�E�x�P�3�IE���#���G�Q���_��ڔȢ��|B��jc�W��+F58��`�`���E��F]��R���u�u��X�[�n@��	脐3b��Ѡy?:z�[�XgM�o�s2���2I��6Gj��]R�oe��T���n�䨍KJ�AL�Ɗ��ɝ��cAϤx���،w:h8N¹rM`��m��oÛe�. A�ɸ���(�1���d��U�t�{?��^r��σ��w&Y0�`>m�>d���͉��O�$�������pwM`<P�n�%�~ڡ����N�xE��oQ�c,9�݂���t��)7�ɐ������:�,v�!ڡ����9��v�pG�.�/��&/�O_��Fq/�H,�63�Y�?vG��eJ�yŚ��C�ø.�9pK4�#�S��|��R���Ȗ�i�m.X^X�[����e^g��fe�Rl��u/E�ih)��+�T;,�	����Ë��V�S��aME0�3��N*�4��5]��k���[�����'X�I~=x�� u�#y��H� �S'0WA�NIWґb��Æ��h�L��%U�bD#�|� wF,�6��
�l��'Tw`	?��!�I�,��h�,.����VW��:?�?N��CDJ�G�fs��)^�
�J�f`�K�UH0��<��fV˞�J�,�
��%�j��p>�.�&��ۚ*��I��g߿x���Er~��l�~X��M#wʋ��M�NOPx�D����,(tl0X0�]��$�B�2�9y��?�o�(@7�k�Q�y39��:���ۥ���kt&/�}� �@�,�GI&���)>aF M    ѭ�WP�M�&~���������ǁ��hB�Z���_����v�Pc��n��Ќ#T
�[ `Q[ֱ��y�fh6íaC��-\�ؘ!�H�#�S��g;r7Ƹ���4��&\b�pF"Y�������N�֛�v:�]/�ҥ\��{$�T\��ݯ��(�̴)%Z0Ċ���'^�y��/{l���W��7��(���7D�K�4�e�!wm��*~ۼ; ���]Cs��"�H���4g���*�r8|�l�ʀ�c��Q�&��5��?�y�*�t�{�$?��O�Do�v-�l���O&ē9!#*p���ȇҹpH����}������c�^]s�|#��0N��G*���uъV
~�Z���|���;M��ѣ�����S�_��)�	V`Y+� �*���$LM��q|�5	kU����ulm��*2r�o>A�;�n�(�Y�2T�d7�����L`P80��𴩕�#�>e���so��?��!��-=�)WaIf��oH��x+Bl�ބ��x�24���r�Cf�w�ٛ;�<��[O�~����Pe�z��F���H�3+��.�(�ְJ��*�n`�A\�1�9��#���F�� �U��I����O�^a���i�M�oTCjD3��z�z��b	w� �X�[���E	�j��MfQ(Sf�X2�2�u!+E�R��a���*Ц�?��y���@��-%���ᥕ�ln?
�����Bio��뢀������Z�l��3�hE0��G�^T����jYC���*/��܈�D�V��O|<��B������2��-�cI�����n��FC�����(�5���m��vZ�c���q!,��9%ܢ�~\'���#���66ك�!�\��[&A�羸O@#�+ߡeNe�G c��`:#@�����B:i�z��72�!���H�j��_� �lN�~���{@���S����3m��ћ���XfM6��y�Vq-��d�G�����x�o)�\�Åm�&��$~�����ݝ����J���ʈ�7<w2���U6���1�P�b|��}�^�A���LG�I����I���3��_|zN���ϊ1A�����9�NrMm���ԃs�YOՄ���L:����*E3Iؚ�½�����+D��()v1�6�#�$O����8�0!��C�(%�ηun�`�x(��G��O�2���
k@A���������Wn2�3t�0�3;w�p<ͮ��i�A�C,���э�#|����q�Nnu���#�O�f�z�I��ݶ �B�`��XF}`gQ������D��r�v���������_��֘1�]�a���5@�����_�'Br��l�$B���iAOOA�Ɓ�~�}J���Z�`�R���
����|��UB�t]t��I���]��&\�f"�|C��}Gh����/0hW��4�H�}��)y����i'�g(t��p�����n=}w�oݛ�߀�j�\��Pt+�
^v�(&�
j�s�t��3�J)Q��+f�6��Wd���gU���*�rM�f��J�=���
_��U�a(;5�JsA��
z|��
�a��:破"�׋��>�3�HY7��&ҳ�{�0�����	U�c�˃ag�6���m�q�����Z�����Ŗ|��	&m����%�ݎ2L����u�_��Ӌ�y'�4����m7p "}C�����V���������� �4�j*�*��N^<yA�rW�a��Jc�!jc1,��*�	�"�|�)ީ�+�
�5����j��9��E�5%���b�!Z��m�\��������/�[Y %�>��+��*���W5���UWVFKkmj��B��ȣ[�Mk{p=[��;a�R ���&�5��Ƿt���'LqG[o���<�n�Y�v�
��Фr��L��1]4A�*$s8jAA���#s1me�(��K��b��[:��1�B�*�is�*�_C$'��b����������c����*���B��c�g�`�V�ރ�����=$1hH�K.�L����,c=S�n���@5h��]3	?PC=�6Y���$�,�_�&Z>S�Y�l��Դ�D�'& ��l$��C������6Km�)n����SШ�O?`t*<}%�k3�9�����*<����R`Ur~h����wP@�B^�볕�(+��,��fV�Z#����� C��,8����s�I�kE�]f@�8/�tY�m���^�2]2�^�ŵ���F��6��`��)�O��R@�RQgIv���Yc��@�Ĉ���5���B�B��`s�@@��jU(H�8V��d�������S�,�T�5�,C>Ye���U�!�y�PX���FlaN��֚ʡ�������aB�w;�[?Z6�F5j~R\[U=!}����m��pa�%</�[!KY��܃/�s�����c���*Ӡ5��yb�!Z2�%���В�fe(�ݪu�ŖDC���N��:ڵ��NeU���Rڂf����m�2U��6E!��E�u!���
ۨ�,3,P<�?�)���*H ���Ȩ��x)��Ø�O��G�f�쭟'��+X�������)
1Q	Ȍr�$�Oނ��`M�m�����.+��(�L���}��	����� �E�C�_liX8���#�R�
�bQ,B��l�x��B�(�0�}�U�T�D?��)^3�J�,����"TǒK��HF>\9"�'Ӳ.��)>��i�Y��dL���+�+��Zgx�"�y�\[�	�p�M/ا�N���X���m��A��8��$?�>=}���q��9X�8 �o�q��@U��I��o��%�z���?r��T6"���v�
&=��ג���wm�f��P-lj��Ѭ��U&�������z�;����p����ٕ>@u���ɹ��=x�@�|2�6R�<j�zF��}�,����O��t�dxu�%��L�L�Mj�ZO~Z:Z�|.���+C�-|��.B�Ա��������X��7��(�g+�@���s�.�`/a�z%j����Ҹ�W�e
��=2����a��
s�eT��*�i�2]���Z٥�Ʌ֌�ج�`a���6.���>b[��j���u	r���O����+,���k��'o(�Hk9yv.����R���o�a�\`�g�7M^��˲B���*� p�̻�x�)^r������c!��$�"�Z��4Rޞѳ����X�z��-O0��n�����qZ��2�M&��ⱒWv�z0��u�W���;#tBџ����οH)
�I,�?0�a�4ݪr���R�i���j�<�
��=FK���t6����f��j\��Y]c��Ig���C���<,�a�����{�T������8u��)�%ciӶo[D�T	8%��2�V�	��E�h��Ǭ�+����&qԁ�ھ��D�&����U��jJ}2��Ȁ�w���h{޻Xc�� S]� +�{���֏n8��|�<Nk�x����b]2lUH_V��n͠�y���Y荾�-@쁗���Zg��F\;*�0��ӳ�����go��7���g�o:��"��g ��宝U�U�W*U��{T�=*�3�"Jn�P���+'K)]�|�Ҡ�,������D���F�Ԏf�/��xre= 枘fGbW�(2��D3Yآ ��op=�E#�Dɬ������1ۑ�ƲT�-].A��2ئ�`�XAiX�\+*��Һ���^�>F�R��,SO�����23�:4����bGC�}`�/"LX:E��&�n�]e\�7�r��AkU���1�>[[qW����-8����NC�� C� ��]�ZVI簡����ͱ�+���*��L]GZE�'̌��޺_��wV��0��Q�+`����2�`�jM={��%14&���/�$��S%:䙃mT��
�b�Qg�fcz
nֿ�WII��i^��
; ϐ���5�m���}b�    *��f��0Ns0�j�	vu?`e�Je����V�C4X��剃+��dH�nL��K����m���"5���nI�R�p�:����'�#;�=Q�=Q�G����K�Ă�ڤ\W�'�6�b��nK�*��Ǚi���h��s_��?��н����X���?��%'dL�R��{�P��F�޹�|-*f��::�#��06Qj��1�z�T�����n1�qs�A�i�/Es<��l0�"3}�@^�3L�m�f�#J��6�y�~>����GX�s��I����>=y�3�3�GC�� C��:�u0�[;�����ŋ����Zc��1e�C��Zp6��hQ�Q	��yu�b'�H�8�+7�}�����$9{�䬿���?dl��l���'�\޸A�i���{����̏jqJ��j5"��R���d���@��喤Q�cA��R>���dB<�r������?<�Г�k4\>� ;9{rz��x���i�[�ӽ��É �)��d�R.�P��v�̈́Gb��\h���L;�=�Z~�E�B*���O��SgD�j�	!T��r8I`�U�%��;>�4�R�>�����~8��Lz�БN���"����:��r�B� �[��V������0���5k{2�S��>i�zK��=U�}��Z�E�����Q��y��`�!��lй4�y�:5�����@B��"ġ�|4�ݠ���f2��	{�E�W�e:��xD)�G ��G0�4 �;Of̹�!��5�I�ݬZ8�0�O�p��A/����c�6�<��l�[�1����5�d�/��r�j�{��:Qs��,x��xb�!�� m�Ϋ����b8����z5��߿�|u��W`m�L�k��[��\X���Vj#s�H�ں�R�	���
9�+�(f�{��gl�/����h�}�p��4׊���L���0^�����+�ΉzK��8�0�.f��S�a��Jo����9[+�v�Ԋ�,�M��J��>�Ȍ?׫/�@:���d�u�ف��x`���D�a��e�[Io�c����i�8��#�l���ڎ|�y�|q���YƤ]�M0sW*l��%v���s7��k	>$>�N 18�b8� ���B��P��̷.�w`g󘹘͢׊��0:8��'�:`���`�7��R��(����"}K�
P��7O���c~J�'���_��ca{����ђ����N�Q�8�`�?�_>;?[d�Æ���cG:��z�޹q��7y��ڿs�{ؼ�o��(�����38�ɜ�����1�=!s��se5@���ZP9G菘��X�Y�MC�� 7#�)c�RD�L��b2�N���;�ј$��tra?[��( mS�>B?'�E��uPx�M��Ku�����i�bX&26��N�lh8z�)��(w ���&X����T�r^�vO��n��) f<��I��	��������bT���|v����2A������'����k5�	7�u�.�fҧUe۩D'5�ͦ����{������H3^U�ץ	�\��Y\l��c�z\tN���X�P_¹p27��}�V���2�_�������n��3�9s����4�I1��-��,����/aJ��MQ�(Q[���`���U%f>��@����
�֟��U�)M��:fA�m�2�)ڀb�	��A8�xΪ�/[Z��mQ	W������oۚ~^l��in�
Ë��.��E.�CSᨱ&�[��ٍ_�*9�p���XB�銜{Wz%Y�]����l�"�qS��|�~�RkMA��m����wY^��QE%��Ha��w�r���ɗ�a��{��һ!��&䤈�GerG�XN�ka3����j�I1)��Y��"[ˆH,��Y�� 78���$T�5�	|)yK	� ��Դ�M��s���L������Ov�#A6����p��Yey�	]����ȭz��SBn�^���b���Z�іLw]UULyj�\īc�zp�e*2�=�'���-<��'u�����|6���
x��Q*�H��~Eq>bs�x��&{��$�8�>g<R�`���|�ZH��}���W���x���9y���\���sEQ����>�v�@�s��9��h�(&?���~$W�y0��� D����6N3�E��|R�����
Qw�`#��0���e��n���[�d��n��y�b�[%}���$����k��ijF��� x9�E��'pc���O�C���h13�v6��$��������գ�#z��l5�,�ԥ��~y�uWIW��0}�5<=�'%((B�`����M�X����D>���m�"ǂ�XI�c�WK�ߡ�'�2?\��f[��CuF5o��'��R���k������v	�@:k���{
�Q�k�8@�fX�Nu�ɂ�KM!(��d��#���l�~�ȑ��z���(��58��pB�q#>7t��x��tD��:9ouܤ�����;*#W�Խ' 9�����A�)Kre���jT��z;�W��"D���1�*� C�����j�^Ӈ�;�u0}�ؤ���5�W��_�F���w���R�`�MkPT����b�#��R����޺�%������%F��^U4,j�#p�g u 15��77�F��|X����@I�K.�W
�������b�C�OGR:�c�M:T-�>�ab1�*!�+q��e�c%q��8��(f�FM8EByU�"7� �7�ܣ0�6�*W����r�J!��̪����vUD3�j5�Y�#i���?�����m�DtG����?Gz�%�#qј��U�G��τeH��\����_(Yۛ2S�D���I *�7B�P�k���(�w���?ߒYs�̒m+ǵ#3���䔠�K�%<����%'�rB`k��Q�cp���o�
���ҧc���8�G7��iC7��Ia�u�MV���<�i.*�6q )�n���C�9���v
�0��kʀW�ː3������[Z*d����� �0y�ܽ-���q5Ya�N�1zW�|�����$sH�,�A�.�[2��! ˈ?G��Y[!Ԡqi`�V@(��c38�������~��n1{y$oQEYq]��і�73�^l�a��h�{����z����!zOz4��䇓��^D��U��/2Ky���`^���6�'Ks0Vr�m�3]�[C� !	f�^�+�`P���a���b<�cڽ%�Y�W~���Y4I����EL@�!O�^��E瑏�P=��	i7�uG&V��)�~Y	KV���T�M�:G�������o�!Z��6�{����{&�������wbjn�H�]�wvnԅÜA�ؓ��p�04�����F�RZ�����}�����x͒�8p��/4 �C���G׏肿L�i6�~���[^1ۺo�J�O��+����ٖ��=.����v&w��s�}O���!���j�������� ��#�٣8'S���
������kX���$�h}�+��n(�g�N�b� M�#�)�3����,Z�?S�����<�Q�,�`�\�����Ͱ�t}̨ş�
�g����yՄS*��|��m%�)�����x�o67�	��[D)Yn�Ķ(U��J�K�Km�-r�{�тS� C���[���x�<p� o�S���N�?�8@�����٪q.�|9���H��_���%�ѳ�<S�
��f��G���ݚ^6�<����oLC��[٠�n�����)E'"�b ���ԓ�`2�6���;�lκ���zxJ"������Ev�t2�2Ll�}H�OŦ��(ڛL�60�y'�Ȅ�mxa�������$�ђ?��C������'�����/����/�'�W��Jro�`�?w���?���
s�tU5�����s�>|��lAYa��f2���
��c�%'+K���o�ԏ�84�)�@������G�d�+�A_�$A���z7C6�p�+�    �G�Q+{ۺ�x's�fc,׬������	�b���bߑ�?��]q[`��q2�acD��:�_<�(uY3��$7��X à��~EW�U��rp<��m�-]�;�����P������tV�_�2W�����$�RS�Bl��w� �6�5D�z��'��CT���?�T�ءm�4=�^3��9��> ��6=�� t�t0����#�Ѡg��:�]�g�A��'T!1�脚���4�_�u~QU����1�>c�ܸ��ਜ6P�2�Y�I�w��� �]��p7'���z�&/�OO�T,���]*���:���,�#+��g�+$�XP�'����p�.F�yL-V?
r1פ�;I\9��Ʈ@�1���5?ǔ�o��>H3'�}�F�]5�/�D)�WL��J4p���̇�:eX�N4���ۘB�8�n>�L��<�d1,��8`28?��##
|��<���_F�n\AĢ�^r9X�+��*�ќ�,�0�a\�h��@?S�K��I�LcYF�@�hi�'Z�-�,C}Ň�K.��-{���C�X�ْ�р����I�c�J> +�9S�����Gh�(a�u��4�I�)�D�L�!�{k�[���K�a�#���́�Y�D�"N�eH�B�
'�I��S�ҋ%X��ĲV7�@B�bL�	m�qR���Զ71l����^T:�#��b]_!u�/�/��*Ef�j:V0D��ĥs�\b��1>�N�O@�?yv��e��g��?����'�]�.ߜ�?���ɳNx|>@�LI8�&S0�Q�<sS�<�v����q�v/�͢Z��N/
�ZTX�%�7_�q2?Ϳ��3��#��:4;\�d����axpgb��A���3h7щYP~�P�����QQ�ʖC/b��J�K��H�d��
k+�a�H�3�:�ђ��ntM3?yuq���N��_�<{�nwM6��h�H{�DqY2#��r�lJ~�nj*mYZ(S�?c��Y�֬.�M�D{_q��̯�i�,�LG��G��7�����K��*͙�nخ4�.�̳������.�3ͪҁ�-�-ؚ@���~I��;����j]0z�M�]]%��0��-������h�?�y{�q��r�N�uY&5Y�R�v%9l��F�3�E���/�@��Y�K�HVmDިc�-L��ÃVuT�t�Vm�<A����q���! x���O&J�Bh8�tơ����`�	v��LCHv�{#���W5�����ޘ���u"k�_�����ǽ[�" _���2�1��F���|�Mu��Η����o�עs�[�Be��/4�D����VEo�ܑ�S�>6��Kl=��)�2�30�ìЊ��i��$ �B���@��G4�_�1nn���]��J�uqy
�!-LVmP~�c��˘$��sz���;��)?�8{�<9�|�
ϗ��N��M ��h|����Z�J`��i*DW�iUcPR��ږY�l!�ˀ�{q�O.�h �� _q�0�\v�Q
Q|��L_c������iA������+��Y�ub���Nߣ�_.H5�-�l�A�'I9@ ��K=�V:�1hz�!���f䑊	BO����nP��D�G�Gn:u�p��,>�_�XBum��� �b�:����$+Dv�
���d��0K���#4G ��oW�d���`���ԯ�x�
G���ێ�=V�EDI��m=#B`��]��܇�-�׸����>��`�f7XY�[,�H+���8p���l[Lm��9�K����k<��\�*�=
�&r��a�s0�i�f'7�Eqj+1���h?~O��"�&�`��"Zu���/{�`����y���+������M"n�׫���@���Tl����f�,P��*g'��$O.~��V4uO,t"��ܺ����y]�b��R{�R��OR��O�wtӚ����4VZ�;��%X@p�wM��� �8	��C���/R��x`�Ќ7��.�w!�>OK�K*p�<c~���	��&�������lQS�,m�X�
[�®v�1�:Ii���0DK��6#�'�!|P�HnlQخ��S�<��Ia�������=h�G��R�Zk\�Y^i��(�"C��,52��+x.��)�j��,3�5yis�Ԡ��ɷ�Mrxd
V}]�%vp6�
��5�]hT�\�M`��e��F�u
��B�I+Y^�����42�ΥU��}��>�c�-c\3��uq�2�d��4]�9�b�FH.%0��D�
�1���(K�v�L��eU�$ g��#տ�]��.u�KVip�A�u|�i���T�u��\�2��)F9
%����e�!Z&;�f�z�a��6���~��3��[���\K�;�di̓�R$90�4y�|���o�n�٦(�`|3f��-�;�(�;z�Y��ݲ��e7&��Ψ�wFU��o`b�y�.3��s�yi���1m{Rs�)�p�!V��(�BwT~����ѐ�[����N�0<M+l��л�Λ��Ҋ��UU��{!һe=�$a/`��%�u7}6kx7�{v�?	����*�>m���
���8S.�-#�[��=m��D[p�!Z����n��W*D�jM����b����P���ԛ�(�隣Lqx�}?��je��!�齡�z���4�P�����/	�S.�pϝ'S�����'�h���QJ[	˱b�ⵊ+t7�X�=V��eG�Jb?�s7��'n�Y��Y����9T�;���u2u?���,K[P�а��J�(f��Gy�(��5����JL���"�Y���j:)(U8��U�D4�T'4�;�z	׫�
�0շZ��M�H�Ȼђ�3rk��({�����Q*�{thS��P�h�ϋ������X�@�C:�X�J���|�pT��S��Ⲙ̒)%����ld7UD�;	>Y�)��Hs�M%��-3�ʵ�$�J�2�<{������e�tQ����^]$O�/���y�@�bc�;p�VW����bu��+T��\F���'��:�*B<�����ы��>�\-R}���_#��9�pÀ�.��\R-��?o#��58[�d&�m�\v�d��e%R��>%E��̭��`Z��{.��"�|���c}81Y�u �8���
n:<ٔꇻ���Z���(W�W�+���z�&���O�D�+����F�1�7E&*�)���̨!X���"��X9�~�����x���_/R��I1�mu>����K�3�F�K�Ee��XI�5�H&�ɰ_��d��C�a�T�l3אL��[-Z���\uaS��b*%�־�iZ�Wfi�!�<�k7,x8�X^ �[ ǉpA��v��u�Tɢ�L鈂�^z#pz �
��}����>[P�>�b]d�J*[�R���1��R8E�2���=�J�y[��+�@�x,Ik�l�u�<+0oc��M�0*�/8��'�r�x�y�����z<�T�������{e)�y�E;���Qq�m�QV�1���'����G���[0���������OQQ�e-C+�ЩoA$�l�]u�Tp�"�tT�����f2w�'�p2��@Dz��^+��fTU�G���cE��X�M&���E�]%�K��f����8q���ؒ�P�xz���!~����R��,��]�V��ȇ+G��r�aNO)0���*M7�(J�]Im��Z��tC��zՐ��2E�H`��&e[*<��s����?�O����?u���D��	���;����7<P���w�*SȢ�q��}��
\�D�5��������ӭ�7�p��VPM�m�3/��l�<˜���U��b�2�	� ���b}�����k2��?��?>kӶ>���������X��t���ʊ�$z�ڭ!��]�W�徒�)ViO
e%���P�/�m�2MmE�͓���a�lXn9��:TBޓV1�C'�����l�*8n�d1�UmrU��L�@���p���� ��˥]"gU��ܳ6>�&܀�"̆&���    `�3O�a_i����[_�s��ᕆ#\�BV�4�O/���p�]7Vd���xl�ܓ��{�VD��/$��>5�E�1�es����q��<:/;Xtb��S���E+����}e��*Rix^I%VNv��m���B���X�쿧9�� T�u�2H}弎��U�a��9��2\W��¡�y�է���G���!�q���߆$]�Z��69�!i243|0�Dň��6H+��a>�v>g ogu
���m����'0ņ�kȣ|��W�����'��ؔ�8݆j��uX0\56����@��#�)�[��Eh�'�M���%
�;u$��77xxf��6�uL�>�Ƕ(�GM���Fkjp��yFg}��y�]aT>$X�&%(�X]{,YO�LJ�R:��=�7�H$Mk������������	��Sf �w��榦�vS���wN�5��v�cB�ؒ*��؍�Ʌ{߁�%��2ky�A��dڤ,�O�ms�S��QvC4U'�qD��Ũݲ�	`��OH��6b��5E��CL��0��w7�r�1��B.gv���ͮ�S"8����� w#�暲<���oy�)Z���F�����mWإ� ���'�d\�C�e��Ϙ���b��`0�]��8�����=umk�=�0�֯k$n�rx��Ї�6Ҷ��R2�{�?H����{�[���$��tpE9��d4Fp�K��Y�A-�z�|� �{�
ɹ���ؖ�0�W�H�[١�����P+����g�/�@+��Wɋ�d�W����K�or��)y����i'�j h���2[���R���
�g�)��9�!�M+�U�5�����'�����J�Ȋ���̩	�*��)i�W���u��w%ˬԲb5��5��>bG�����v��MB���=w0feYz����;*-�*S��h� ��w��/���ʩ��1B�uO[�����?�~b��^��sg� !������)���O��Ĭ�G�ߪT{:�d�'��yE/��Z��`�ohG��"I������4Q�T2�X�B�"/r.�-�az�H��q� C�2�|ِ�ѷ�Ǚ/Q������1qq%�M��i�k�D(���F���<p;IڷW��i�\J�+,O^����Wi^9�2��q�z�6:D30D6�)��+oƎٲ��dRR��d��`w���OUYU��y��diHԊ:���ɴR�Rw·�^��V�n�I0��i%�3L�����c�Vp��������dG�����pm_�Xm����+��Rhn�.��޸��*+2!���Ȓ���%t�9�w[M+��t݃Ĭ4UY��mm��*7��̊�Vlp�g�%1X��'T����	J�톒j:�F�a�����됆��� a��\��Xwg���<��<��W:A�gv�g�!a�#x�hS��[N&�ۆ�k$���m]_�?$�xYݍ_	��6������c�������&���n�Qõ����
�������t�P��Ǫؤ�6��bʦ����em�شˌ�V�Ԫڔb�������U0��j�f0g2N�-YˣU49\�:�����G��Nʜgh�51J���D���̋o�L��q���E��V�n��m�M^蕅�0�'y/�0��=���u7�q��L(cW��C�I����t��с9�@W:�VLl¸3l�!�t�m?�#�,��q�&~:!�� -!e:��Լ!���q�jȫ�"Χ6�ՠ�:�r�؉��n�yDؑ��}CS��_���9��u�$ /���e�s�~o��c0n&�̞�BP��-<�ҿ�`����ˁ����)qH}7w>fq׼#��8kj��᧰*�N_��xl&o�8|�̔���s��1��pi8�5�07�0Z;�*�0U����QaҼp�qZ�U$L대�)�S"x�!����׫[������.ޜ>IB���P��[��r)X%Y[O�T���r�w���x������ 7�y��y�nܭ�\���L�3���p�1�,D?<_`�ۀN�����M:�v�*֨����5y���J�B�-Wu,��"{����n^"��7�]�4�ذ������/�d�������Dt��6�����|�4By��~t�Ɋ
��i����־���a���y]�����I?�g���$���2ߊ}X�:oj����t������_5�-�Jp�p�X�̵��2_7U"�ҁ�Z��L�LwEes!*n5����?�	���<�cJ����T�H~�ܫ��$|�����S�RfSV���5��"�c��Ҋ>�GD|�%>ߎ�5&�(�X�����<����\{[iZ�m��GO63����O��v���"��Q_��;Ďڌ"��S��XSC��h#�'x�C�|�G���;
<xp`�%O��k�{7�f7!V�oc;��e�����kp��&��0�p�qO���E��u�wF3 ���Hp3r8�b������F\�r�B,���� ��"����g+��&|��f�n�"-%�
���u&�Y�v���t��(�p�"�]��KdZ��y3�6Dןsa6�H
�5�%4��Q_���͇8��-���҉�76+^}F��o�R�&ݚ�����T�~��3�
{FZ�~����n�
i�V#q��O/.���q���!<�*�� [gⷷ�U$��Z)�����ps�)B�����f�9@�&�O��(˪��]e���d���+D�r�tE��	Iй���f���m�������n[�ֲ��S�%�JI�����_)�eWAK��&�A�l����%i��2���C��C�p7LE-NzU�t#k�if���)�~FaӠu_x���"�%du���8�O3<e��{�����p�6 8����������J�� �<��l��AZY�d�E&ꤽ])S'�1&fm-�µd*���#�FqB���� _�6^��!���y٪)�[Ǭn��֫ȗ���{�}������� *i�	�X��*���gM&>]%��[��礒d&6U5�&��b�B�>��mֹ���{��{��Ұ?M�`?Ê�d��-��𯱀-|�ABj��h�o=9���DmP�u(���nl}�PQ2�з.��J��/��M��@��-�Б�[e����5j*���J	^j���ڢ�D/���������b��!o���<yp���e����%At��,Dk�{����4�~��Gg����;L.�
r��9�A����N/.�	�(:�^�rB�,��(B�шB�Aa�4�}���.�4�����?B'���e��'E�7F�U7=	�&�\��o%���_Y2��*������wST)���7$��_���+=tNb0�QG��x�y�@�Ј?D耤D1��q���Gd�[��ҹ�Q� M�� �5��6��:�\��\df賬f��.�Jh�BfN��3�d6���M��s��K��R����/.^�I^]�_>=]�6�{F�℠[��,e��m��X}�b?�{�IQg�A���$��6K��:),>ϼ2k���[�����)��Ո�`��ط�'4ד��p�0 ���*/4I��s��y�d�~0{>$-�lf�,�!z�VG���f����tV�y&Z��ټ��<G2_�U��0*sL��D�ݼ��a�
�z���RR��:��'g�Ϣ�M�)O/x�Ӌ4�J7;��'�3���q�y��(~�r��l�n���k��� ���.��MD#;D������W��x԰\�H�i2(}Ɏ����Tp�E�m�ޢkX�j��
5L�ѧ��w���n,kh~H⊡v4��;.��szSt�^�a���F~4	��PU�>�C�5�@�id,,�ao?�{DE��yOh�Χx�[�s�6����@��iG�oJOP|�6;}���E�b-�bB�)߈��df:$z]Ēò�5��L~��d�)Ҝ4~���,j�▼�`�p%_�!�w6H^M�є��շ�O�E��>?��?�� �Z|�n䎒��>�C�Ïȗ�Y�@�����v
An� #  {�ͩU#K�7��f8���'+����HG��v,P�[4�ù �F��a�u�;?��`�mK�)�6&���30}|��E�*+UYI��N�k��@�LOd,�B�%�X*Q�րٞ��Gi�o~xqyF��Sp8_`}D���?:�N�ӤsY�X���,[���yWc�1\t�x���e|)�7~���l6(:�.��_��$g/�����ֿVLơY]�܌��ҧ��,7�s9�/J�b���� 89��¸m�+>��}����l���� ��=�lF �WT�A��!j��I�8�'K[�����!m�!v��8� n�Gٛ������r��i&���>�&�7��x����-�u7�O pll
��2�2D[�^�A�iG�w;C13_�z��ǍJ�	��bȥ���<�˺���raӺa�7����f�b-v��e�*Qi�W�fv헥��������
�����A�R�d�5�e������g���u�|0Oރ��XrR�����D.����p��mAl)�A� �1��@�·C�v-ۋ������!�R(��y�����\���C���6�N�S%�5ur��<�L#��Sè،&0O������	����#[4�8�Zr����n�d)�����7}F����6�	���[�@�i;�s������Q��� C���[Ю��0��K<z'�/F�kt�ꦐB��iS�Lw��Gǫ����ɴ$��n(J��h����/������ߒ���k8��.o�A��-!�����+N�d�wcX��ɻ�@<B�'��׻�֩stN|�qw�mUPK�g{�vx�0$h|��0�E��^��cg�q�1�g<v#0�"�=d�����X�*y�v�co7D�O.lMJ�"N8i�J�c `r�C��<��G��j�vN�lf@��gi�3\f!q�!ڱ��r�����IBd8E�qːK	�ʎ1���=�Z��9m�z�x�8�yWT�̤`V�|mq����<��0��%_--v�����m���R�nnla��N��l���o��F[���J�M1PV�yQ1�V�]{�X`�?�1�ێҠ����%�����a�t�LQJ0�Us������nE^N�p 6�x�b[��vu��wFA����_�y4,�c�rA��7�Jw�4�'X�6@f*F�
��0)�ecO��$0��] v��	@��yJZQ(ߑ�k$�G�Gn:u�p��,>�_��FE��a�U�x���������V�K3�K�nʨ�C�J��?B#�zrJ#�3&�ì��8�|��(��L�t.X)B���F�G��}|�'����U�+ˍ��4�9��g
ib��\,`�����L��ם7��k|q�z27��|��^��ȂM��q�������)Q��QyH�daw�����u1�<r>Ĝ�lq���Q'�2&If؅���&#��1��e2�)/���p�6��2�Vn*\Y�+c�w ,ҺO��]��s�*k[��0jH�@ �������)���	9�8��%��N�b��m�F[nv�(K���_���t8��      �      x���[��:�-��jE�߰� ���������9eM9�.�VE��3�| ��z�o>�~����H��>��ه�}[z,I��G�\��ʹ�E�ݘ���������8ɐ�Y���������㝼'�?H�@���Sk��$��⭹��j�1�������[Kq�z�1�F�9�[�`�|��p+�d�#�-���bzv�'�2��3��_����g��3;�:�DLM����I�ٺ�Qס��'G��pPs���Ӡ�l>�!��>�/y�x6+s���l�O��ܙ�	�.15+����+ٞ�7�3�n�5�rȹz��2Z�E�D�`���2KX��L�����������N�.15-��#�u��5p�n��G�oŹΒ��%.��
�ρ���$Th��D{2-S����a�ׄ�cX�h\���@�������A,��y��q��)Nn����\����3����dh	�T�ΰ>�ڙ���韉wg,qZ���"��ŧ�;/��J6��[4�>nޥ|(��]j����QsD8�L��Kg�h�u�/�?����p����;Eaw���8|yrЀ�<����[�)�#Ӄ(5w�gLf��n:��)��0�Ƥ�ϙ��69��S�"�y��F��qv��8��qs#7n��+i�Rzϑ�Di�L)U��ε��^5��8�B8:�D|�]��`uXq����r�U(��}�4`��B�s�Qjn9B�yO�e�u���<�k��z�"�v˶�ۼ�MQ�,@݃C��KK� ���A����������g9�,S�?@��Qٻ$++>�^��V�-�\2�� \hX����jS{1�~�dH��1Lu��i ?�(3�x��9{gIV�p���I��NK�-H_�����n�jY����1Ct$R����FZ,�Z�����jZ%�V�z���i�_���'2I�i�3�A8>P�މ� K��%s$�y�dll�q�b��S֥���Yuf�">7��P�K�a��{�a�(EJQjkv�xq�����+q��T�L1��jP��.ة눾��ZIF��'${�_�F��)cBRk�㑨�d)�D���	�a<'b��]Ѯ�N	�Z鵯�1<���9�P(���\|h�3G�\j��k�Y��?��X�jҘ�����^Ĝ׼`����y[��Lº`�bRЪ[Zb�s�#Q`�mK	�?݈�M�aݣ/�g��8�e5�ߋ���*����_�����G�F6�\X
t]�؏DV�'=5 8vg�v��u� �m�ɺU�~/bn^H~�%����'G��v�FY`�����(Ҹ�aC_����<�i�휺�+�@�Դl�;D�s����Y�7?���koKs;��!
���$��a9�%Lq�:�8 !��/+T�@��^���f���e@x#�'��ڒ	ő�D����C��6�)��?���=R���*��E�Y�m ;��w߄�n� H�Q(X|��%*��71y��O���1��%~L��"�e��X��ݪ����i?p*a��-C�1 �;�R�%.-���c^�;ӷS����蟊"�7�����N���˪m�P���)�W��Ez54��V���W�!�g�e�w��N��<�jC.1����bJu�<�*% } �SϽD��,��� �6-If5�g*w��eP��� �~���1��~u�����o򃡗ܟ�n�ċ1����x�D���N���v:+3���tH6$g֥�@Ĝu��o�Z�II����p`�c���[�v�H�˰pT��Z:��s��C�柃n��Dϫb�^��NI�K�
e�u���5r�c�} ��K��V�H�]��T�=��l�L1����}wO �ۍ�"�&�w���j�#�����,ap~Zr�ԥ5�8�Hd]�bs6��eS�G7�y������:@�u�/1w/�p�S�4��pz�ǔoÕ�
��o҈�Z�����1����d�q?���"Cw(=��|/��}���G�	�Nk�Gu��E���r$��FۄBr:%S��������G\�N����.F�9�����ű�h�D�h�B1�5�3�?��:"+��B�-}��ɻw���푿2U�0�WB��"c��a��!-:�����ټL��:�/�;���kh����n^:�$&���,��}��4��]:��^��UW�`z+��§��)��A�Y�B���S�e�����mt��s�����|�Ad-�N�m#��H��R�BƖZ>S.S�e���3S[l�sp�^`�К~�yխ�#�[�I<q�%�!ʣQ�>V�߅��4ϱ��ɒ��Dpp�1] b��m��z�e��zƋ%q�; KJ�Lqfu!_� %�(෷���������&���jY��05)L�{���ۖ�b�<=��ᥳ�A�/ŵ(=ёn|�J�8��4D9�z��s�\�bpq���$�ݽs���]?Z��>�M�+K���&-��0ҏDe��;nf<C�d�����L������'����v�&�:V���Q\����%t�H��Pt�y#��2K�|x�������)νoG��Z���fG.�i�m6_��#-6@˳J�$�_j��ڏD�G�d|�ZY������ƣ-Ai�W]��.nw-Gݙ-��<��<�[p�m�Ǒ \�hnD�G"7 Z`9�2��3=Ż��G����;�.1e�#�6��l�3�N ��m��R]��j`��Y��Q������9���V�ռ�`�d�@���NJ�Aya%Z|�ހ!$1#���:�ՙ{%
,�e��87ź_i֌?����a՗���k��B�x|�X"��x����Kv]��+�+&������M�����;�&��?�1] ��!�:|����f�c)��7��mG�:�ah ��n�a�)�݈օ&ww���] b��F)F�$��/JԐ�#��"5��.�" ��)F��r��a��uD �P���)�1�Y^�n{.%G|�� 땷&uZ�GKV_k*T���k��\X�3�2ŹSZ�������ۯE�M�..g��U=Ӝ��Q_�t.��aXXj��ǛO��*�:<l�X��'��Y���.!8̱�S�x�"&��o�dM̺E�T�`ə����7j�>/D��nk)�{}s��Xwk$f�&��hl�n@���)r]��6(��э��<S�­��#�H$nD#]�q�|�]9�q��I3Dۉcڂ�ߋ�Ӹ�w���n�|�Tk j�K��հ�
Oj�H�Jk�7;����܏���P�C��mD���*�kŎ��;X�b��~�!Y����Dih�W,�x<׷S��a8Q/E9Q܂G��T��hŅ�f�>u��z|j��#�u� ��!*��c�"�%���8_SD)��J�%̫a�@�d�wR�˝Yt�s2��8%�->Y쐠V��(�&r�t��3];�zX�rw΄���"&m��us(��Q�J�YF�n�R���b���ȍ1z�bG�?��Oq��̚`m��!�@�\8a�{��M�/A�Rj�vc�� ���t$讜[��V��<�h�a��&n�a��V�5oV��	"��&���1L shb�Dc�AY`bO���aH�/����
.1��lw�� ��������p�H�p��#�%�.B2�Y�ӌ�)�ÈD�NoZS����a>?@S���(�
ݮO�1���N؞H�1�Ɩ�_u͞�܍��+P��A����É�_�#���'�޷��(��0�%��ͮ���·��唡��v��~@៱�(ݣ���D|�O��2�����*��V�"��|�%��Z�H�'��\�o��aR&Y_i�5ق���s�@�Ǚ�L�zZ��s!�Z��{���X�R~ّ�E_m5�,ޞ�)�?��a���������N���>a��͹ ��{cM��p��h�ӑH� qV�(�p8u
gX_��% `;X�(�"�nU�Djz��j��Z���&�#��p.h��1��l��(a3�H�IOS��'@K��=P�[R�    ">Lz��l�/�!�1�h��+�wA�,��NY�˼!�� ���,���b5�Yo�p�m��R��"�0��̲�_��>2?�p9I�.(�?:,�mP\�H�� 	\m�a���N��b��sw!�MY^ b�}���h�"��+���2���+�R���%��7"f��K�g
w��G[�g^�ɻ������y	dKN,]�V9�>�s�M�Wj�K�Q*9�#����%�V�=�)��Z��(nk}��O=��iN���g8�%U-���;jKq=G��#L���P��LO�S�X_L�ߢEP�[��"&�S����p�̾PPJ�nT�t��,��{(�Q�H���E�4�g�������Ŭ������{�X��d���&�8��������R���J����͊��H���Rz�o�2iߋ�47�9��G������|: �2(�I�Dv4@k��o.ߧX�<a7�����󽈏/�}qΎ���^��W��XRuc�X��%J�3�p��gO�S���P,�C�2��0�V��H7������0)���)��$���H�ֈ�G��M�8&龜z�S���`>����>��D���Ⱦ�'y���O��ye���HݐW�^�h=t����6��$���0تP��q�G�)�5������������m���J�zH��rڟ�<x0F���CY����Cp��2�����.�[-�����*#j"T�#� �����z9}�;�{�_Iǔ��͉�@��fy�`<E����N��pH������˒+g91������'�S�����4{�>ʖ�s����c��\�}v��"\ ���*����֏D�E��mMu���S7�{�Z8��n	�_K����eP�ܽ�mZ���p� ����H���b��R3�HT��X/#����'�3��j�Y�[�q��qߋ�t�����	�n�g)و���,�ײ�a�a}g�JJ�G�=�;+w�^�X�9����[�q�ȹ@��)ڕ(>���(��y�Ȕn�l#�o�⫣���ݩe�Jj�Z,���S�)N����� ��=��T��J���7��#n1ʧ�����# V(b�Ts$R#.5�WX�g��xj!�[X��F^/1w�#�2K�z׆�ٿ�4}�ٓC��b.��L�Q3p�%4�9M.��=X�!���+���ZĤ�5�z�M�ݼ��y�곃汋Vk��#Q�d�Wၖ�ΰ���fG�
��#���{	s��w!��de���<Ob��J'�1�����ؘX֨�Qs�*�D�8l6���X_�D^���3q���@�$����\R_o�9ᅃ֩Q8c(h��l�á�A��e��#����Ϧe��uL!j��w��Z_ b��_K�):L���2�ha���Mo-��z�9��;�ahȻG�S��#��б]%~/��Gξz��m��ļ<KP-��X|�w�{"7<|p �3�
:ϥ��}�n-�4�E�RY�1��.Q������U�p��Ӫ}kS\F㨕����d�u8�%�>��1�7���X	n�>��z�W����R�+�ho?�0��wg0q9��d�b��:`p?\�Ck�T��܇���T z��l�����q%m�߳���O-�����>�b��콇k��D�Jm8���467��������wwb������E|��@��a:%��L`�Фp�3o�t��~�
�^�����N��K<�rS��i�g- w�K���{���h�/��-p����7�鈷2��[.�-�9����5L�X}�Z�q�u����ݝ[���%��w%a��;-6�#)�(5X 3Z7^s�$Q���!*�W�;���q�X����Pp�@"a+l|���㸎��]˰��f���%P����85���+Q(~��s�o��#Ҋ�w}�g�j��N��b��2�31�H�� VZ8�q�z<9l�l}��o.˦X�f�C�%��|���_��d��}�͢���VdfgZ��R9�&Zr�~���>һ4��gLFS�%l�� +!�j��$�7MbI�V���z��v�,�J��V�k����yv��8w�#}�c�=J�G��DL�ͻ��>�Ҵ�鮤y�ꆫ>ۨ%�ג�V�D@x��/���2������q~��VH�k�d�����R4�%��M����M���/�u	`��+^�h�)ֿ��|�tY���X�t���B��l�¹�b��c� [h����G�>�����;��5ź3!QS��]��c�/1���7�b���+�`��7�9�&�z^7B `�G"�Z̡m�Nk�Lq��B���&ݭ�~/�����j��"�g�}�a�s�G��� �/Q��k���y/��W��������D|�� �e�Z��?�1�)v$�F$�,�1,�|$J�W�?�]��2ź�ޡ�.�%�J�\ �(�浪���(K����F�4þh�2�X��%�Ռ�]�iש)ֽ�\�#�tG�AVv����]u�0,��?<tm�1����屴P� �H�J$%���d�yv��a���6�>�^��_K�47��g`��ʽ�hC��/@�sM�hU�W���J�W���y���ݯO� ��FZ���V�Wkb8��c!�����S&H^lmA��G�08q�F/�NU��a��.�u�Q�D|�jk�C^�XH�rj�W�=��f�9�!2Ji����)�?��U�{6��^ćS"�
�5���E��Nk���^���H0�����.�v����]ț�^m] �S�"����'��d�L7áW��D���r�?D��3P����q^�f��uHV�\ÏFߋ�ĳ�&y@��m{���C{��`9ZFq�����5l�ц�myW�b���߉��UK^ �c�"�O��_�\����U� �n_�G�0I������9��J[�-?�.���]���w}����}�n��|�Q�"݊��:���|>W�S�D��-����%��ݦ�y�� �U�i4�"�J��:24׎�H�n�X�q���:�a�O|\�hn��r|/��7��
�����"r�;ك���P�����G�@�M������O�Ͱ�H�}�%ĭy�"&�����h8���EHT�Y��#��"�5K\�Du�d����F�N�����@�)m����X���n�Z����;��`Bv�H��j=�z$�_15}�p��=ù[i-������=�ٿ1�������y��u��p�R��Y2����ꑨ�*e��������g��UG��g�k�>n��dk�&�#��o���c�!u�\/�X2�.~V8g�vQ4���o���^%h�\M�N��m�տ�h��¨;MV��\�n��oq���������>s)�i�b=hJm�q����+�Oc[�6�����F�UO)�sZ�H��<ӈ�^D�S�<��gD�*�������,�8��5�<�P��Ơ%�wpB�ͪw���s)j!wZyr����zq��W�q�����]�NLZ��8�ڜ'�_�㑖��6[�#�g!ͬ�ŝT����Dw�粽�@ħ�;��FO-޳㻇S���^��T�6� �s$�ÃD�#`����S����F��9�m�/��{w��3`���� ��܊��j��i�W"S ,����O��aDNc���vA񽄏��ޱ_m�3��0�H�i�R`ƅ#���LqΥ��5��b}U��-l��[��).�?��@m8���`�0R�D�FT�M!U:Q�.:�G/��M�`=xtk�c6m��.�񴘞���w�����z���$YLg+��[]��}���Nſ��)�Ø���0�d����kOKw-z}`���D��?OZ�BD�8���2G"�?2�R�y3-S��a��
[%�D|<-0ɞ|}Ap�ˍF���@�K�%���GQ�n�3<"5l�p��#b�_����R�w��{�D|�c\�8ؽ���Y����H������;h��0��)�!�/���_��x�X}vjd��35������;NzXj(���$�p�:��*�0�fZ�X_Ǥ����U���] ��iIN�K�}35[�r�97�h<��+�7,�m     %�u��XcJjB(���e_ ��i��-����Z�IBp�ڴTm�Q6��w���4�+oz3-S��c�{����M.�񴸪����[�-"��7��>*8F�,.AZ�{�Ԃ6El��wVh��0��J�^�o)���xZZ���Z9�<g�)��H�xK"K��l��D.Cα�ӛ�S��G_�e5m�[om�/1Y�r���2`R���g�&i&����F�E$t2�z�M����X7H�Ŝ���b�Yk^��d���oO�/1�{+� 8��}�*����󨥘��"�{�-s$�_�i�FwO{��p�Ƥ]PI�pk%�Ǵ|/bn��6�a{����;d��j6�i�ݴ7�uG���Ĕ�����~���0��V��_�{����`��G�*<oZ\�������އ��9P��J�\-ĕS�r�O�8��l�U���rz�g|+��]C
��[���K��QJ�*x�D��^m����hmf�Z���c�;�Q����kce�x�q{�r����o~�OJ�k;��
xm�3�m��Hᖂ�#Qtnd��H��9�o3���ݹhw�ߋ�l��Jj�W����,I�\�������YF,�H�c���g����ο#b R�[F�">=9.�J5i��'}6���xy+Uk$�&ȕ��z%*C��m����,49���PEc��n���/1�Vy�迴g\��h����jd��b���R����R�D�s�z��������qx�t2&nc�@�ǯ����C�ݳ���U̠6�H)#,��iي���n.T��pݦXϚH-��+�G���E�u�=���S\}�����[+b��ՅlFs[DŹ�a�����!Lq�Ղ���Z\�mey��iB�p�s��2� 0���"�^-�ڸ�x$Jl�v?WP��WA�b=,�
�|"�]_ bnVve���r�p|�k�����!�;�	N��v�]<�h�d��۾�y*��Z�kKњ�����j�@�\��m^��b���G��G��@�!���EF2�n�lO��Ԯڽ����!���I�D�U1�@ć@�܆ڠ��H�6�n�tCi`t��Ԓ9�a= O4��O�*S�{��ƍw�ڮq�o�^�d%�] !u[5��=i�4�B?9.����#;"�&���=r9��g�1�������{g�_R����޳ ��[-�&�9J��I$���F��ŧ��fLq����d�@vU�����ߺ�7�Bj�ϋm���w�_ӣW]�}cX�9��ظ�EcqgFh�s7"���k�!Fn��ߋ����L�V�V��uд[��V�g}�V��X �DPH�'s�ڷ�����)i�#�@n����<@��6�������TM�J�6p~؇��0�b�����v��7�<3���f�3Y'kd��v��7�����D��n�k`6gW��#Q(0P�z)
�Ow��aD��3��~�">�)�K�}��3��ky>�Y"?X.����DG��:�v�568K|�k�X_��f�8���_ brZ~�-��u��3�W�>���x�I�䲆a^�|���A���7�l�XV5��tBL�R_ ��Z��9잘wk\�MCt�ĥ:k�ی�ȏ>�Ѥ�~Ğb<���^����u��^ħ����byup��vV�zO� �T��(;�>���X�����xB�G����[|�[	�樇�H�h �DN��c1HY4�E��+Q����Νmn	�eϦX�?�q�t�´q�@�\�O{��������".�T�� <���H�
~�>!`�t�M���~�Y�m�/1�Y�o0;}/`VU�� �^��9�¡M.�������)��ל�U�,�-�g8_�dP�zN�q��{s��~'%��s�[~o�P`��9x�7��l�0���@Ks5�n�w��
�S��!m�Ek���n��w���3����PL��s��X0M��K������ ����H�}����>����ܯ���/ 0&uC�`��"�BN�7p$���wH ���|%��+��L'I�^�z�<z�����������a��a������?]I4wT������E
�h���3ǮF�C���'q��rVc~��u��4������"&ö�%��z�~�ݛ�oHU�9!�-��VV��J7=ѐR�o*�L��Yjo�7�5�.�qE����la���b��j^�8�j�&|%�A��)��y�����b�k���Y��">r�f���TB��{��X�a��x���+�)���#�3o���iixoȬ#�@���ɘ�o�{���ْ��1 WJ���������^�J�0a���yU�)�?�?�;6�������9�z�{�R����FՆRR[G�,�H�
Lzo&�����aD�:; �U �^ħ�J,��~��f�oZ������{R;�Dģ&i��xx��`>�<s�j��V�@�d�}�E�0�ַ=�0�8<����Ң�u$���'xLC���v��a��v<u��W��K����ݬ�w؄{l[D�I�E�fR�j��G����2� ��f(�۠	�25k�Ni�{���y�Te�Zi����;��=���p�"���s�y އ!���R�fr��^�`�4�i��uP^+ݹddsd.1W�&��~��ZT�k�kMA��������р��&��J]��Ɲ��^�^K�lס�K��+�G̵���ϝ��mzmMRqKe���1{F-i�°� c.��=�bݻ��Q�0>l�������7�04SuMHY����ʡ)��/�rjZZ��;nX�
X�[e��	�k�mk��-�K�t������b$�n���\��=��i��"6T����7�M�XDo���{�P�ߋ����1���4?�r� ��c�a(�E`���u�>]����
�KS��*�����	���ҿ���z���<ߋ��1v2H֋��\�Q�Mە���q�6|ƌ}����#,wnҒ5mIg�AS��C�^�,�H���V��R��9#%F���O^H�(�+.�b��V�x~���H�T*@Q�,�2��|�Ck&Ŧ�N1�G2�"��m�����=�@16�$)b�������I�1 ��P�B�?�{�>��j<T#�ݮe׋��E�&�o��ƭQѴ*�$�ԵN e�/.���^ڽAb�W^k/�6 ��|5~�V���^Ĝ��C�l��j�g'%��ɖ��D���e{��J$���p1�t��܏h}�X����N���O��Xm�����X��`�"6d������ε��7e��u@V���Ox{2���O'�\a;�9�?E���4��,�3�\
#�x$Ҭ=	�������-��~H^�Ds'q+¸@ĤG���p�Y�v��r&1ܬ�7SN�jd��+F5�+�cmk�0FZ�9�b�J�c�\�h��~����w6�QmC����ZҖC�
`a�}q̶��D2*<ա�К�^=��)����?�>&}d�_ bN�688,?]cZ�����?E�9P��(��x��?�����!Ֆ� 6b��.�ߋ��9�S/�k���u"T��(��){�(�����+�s��M�zEuޙz�u�R-���0����"&�e�_�ȹk����`m�388�<ڢU˭:��%����C�����X�����9~�U��F��1��nF����F����Z{�c�PK�%��h��(:��pMK-����Ϡ�o�j�II[�sI	�{�aF �#̈́�yeR�����p7:V�lI:�a����5t��>��{�[�N�=��3�DLޓ��~�Tႉ*5~��V��A��e�dJ݇X�DŗZ��X�9&L��O�hq�w�߲��1w��K4�P{�B�=<����D6�KiC�e#�n��H�)1e�01����X�Z3�[��IKm�=ߋ��h�O��л���gm�J��)�`�V���;l�?D2Yʔ����"`3�{�`���Öx?+��@�\.�nZ��Ō{$M�V!��r5�J�fu����y�0���Mw��}��Ě��-��{	�v]ޣ�h��Ь�6�'s��Ԟ�¾S��b�1�8�޸�0��x�L��ufZ�    ?@~Ϧ.1�v��5G�Y�g���b�9�[7N4�	�׶�Y��D��L!�'L�Y`n�s��I!���l���/1��9.���#��SN
瘆�������怪��#9)���:�?���ܯ4)�0k�`��/��3xI9�5[�����ONb�}���H���G�o�t�������+�0ڟ�NV��h��">�����E�@*���6F0��S�{D�6��&C؜��<��jD<i!<��l�.�}��O�P<8G���M���K̮�L�{o �����or</������£����%L*��n�
�T��wOZ�,a�6�A�-�r3>�#��6��] ��>Mq�ɦ5u�:��Rzߋ����cVҨ�ؼ�hh�T[�&-�~Yjj� �D˕]	9�Xs^ap��Ϙ��S��uZ�1g�wG��H��E���E�pj�1��4n�'y%��)�4ԋ=-�7����jZ��֕�^�'�����^LoM!��Ɋ�����Z5�����2�#������7�2���4�� ��^!~-��y��xx�
	~r����P�'_�>��g��{>0�Y;��4ыțG�S�{��5JS�u~+ ���ɗ���=��X�z��^{���Ⱦz`)p��n�(��R���7z�uH{�X�����] �c7,[S�>,h�	m�h���u_�Yz��Jԡ��sY;���\N���y>��}/��%��=��[
јru5���g^=�p$���$H\��2���Ԭ��ĄGa�D|�]\�!E��[�z�B-8�ڱfq��p<�n�!~�,|��n��Ϙ(�'������N�E-�p�_�"��Tp��'h����G��*���c7Z���������o�$���J���?����|���:���5���3���[J�)��DXGߌ�Z�y�r�X�D��] L�^�~/�s���M=��=.�E�w��?����u�����k��d�v�V�b<�4���E���/�a��Rl�^���ګ�� ��F��<r����^{��0�4�?�y���m6eZo�1YZo��С�rXu�3��%�qiB&�M����!߄�DR �Zv�7h��uL4-�+)m�A��?,w)���G�$�[]+�A�
Õۚ��B�]}lY~c�'Y��J�䉶4�D|n�Mw�sXo�v�0�k[k��nч�9$�C_�1z�v�_�X�Z3# ��/��~�&4��~^J�Z��	�|m�Oo�oO�ŏ¶U��7�e��0(Owdz4��@�����-���Q�����‱�UHj/�#��W�PB*�M�e��Ϡ ������\�h����fJ�oi��xЕ�?M�U��<[i�w[ύ��aH�%�p;�V��{�؁��}Q.شءA�u��ء���#Q-^S5��|V�8_��fy1�ǽ�">��s��9>�3�ksc�Ik��B����I�"D�{��_$o�Ps�/c�jGF�5��@�窅�ϣ��ߡ6 �d�[jMbNĮ4s$�a�q�o���0�YiX�y܊ \ ��>��S��:$lL����֑1{fz�2�B�]��o~��X�����p��-_ �s�Tb��#$܀��i���U��zJ�����xp���y��0(����P�ʫ\ �c�9n��d�M������C�#�%&;�H�HT\5�&�u*O5��1,+p�ݺ�/�c�gJ�)u�E�h�4K���$mq��^|%��58ܧfh��0$�y��b����I�n�-9=C���R��I���#�s�W��;�ߚ}c�&Yc��5�K�`�>9�^�\ �s3���n���bZ���s�N��p�����^-\�f�cUOCP3��Z�� lI���K�}i�G�f�_��NKN՘�psNr�6��`��Zj;�7��ֿ����uq;F_����P��Qw�^7����Pឦ� T�^�r����<7sߞ�<�)irW�>ȶ[���qt;i�r��� (��!n�G�Ɲ!Prc��X����׈�">��޷�����3C"W�he-�D�a�؆�M�+Qe��F��kO���~L^�u0�p�f\/1WXn�[F���m�ڡ0l�Q*��s�j>��
'�3���D�[g[�+N�cZ�5��~L�����Α����s�e���{}(T�	l�-Gޢ����J&�Ȇ�2y���C�)�ݘԊ�V��.n���K��İC�*��7��m|�D���~����p�s�eM09W�S��ϗCܺ�^ �c��$X3��W�%s�^>�:8�<��s
�T�p������߀�I֗1A30�I��{���!�Ek�UmI�%x�w�hL=�^�����H�
�0'=��|�Lq�Ǵv���.O�6���x���d��?�#���ȍ�1ZiMŽ%L(��u�,����gLi�ɣ~��=���0�Wv�С�Y�3	J]u�CKY��yi��a�*�>mt0�y�8ӶS��!��2�9��xJ+�@Ĝ�������hb��\�:����ː�/�̑HX3�5M�=��S���?X�!�ǰ�����J�����F�L(H�-�e$Bpr$j�w��(�w�2��wP����"��y�9�8^>��
y�ĆY��B][=��Z(�w�2��gP��n��y����Z�]]"���
��A�V�X�ܤ���(C4(�at^�^WM��k���[u�D�͋�,��`��4E���,��Rs	�G?�2���g�y1��2��wP|�Ĳ�!�@�ܼ�ݼhM\(�u^��t��kg`3J#�%�<ȇx$�k������)����?}|I�!��/arRvYP޵��Ʉ�3���ž��M$@�E�B�`�Vb���&�\O@Z�}[����H����$k2wڙ`Kl�^Ĝ�ުo>�RM�9<��0ij+�ʒ�|dp?�H䊇���s�7Jw�u���yT�ˌ` ֶ^�ߋ�\��2�
Nn�Op��s㢉?}їƕ�_��Cn0a�?m�1��3(Y��i���	[I�D������ �Z��L�M�!o4"�B��:��cm@AG��Z	)�]�i��)�=~�����;{����D�9[��uM���)?�]g�8��ArkN��G_C�KT��B}w��X_��Mk� 	�5(�@����G�!�b����Y��iV��R���u�p󕈀l��4A�<��b��u��b�F��/��y�"w]K��|��bnc$,I���~�K�X���Y}��l~�u�X��I�TDC[c�D|�]���?Z|��jI4�ip�`Lo�H�X|2����S�9�à<�4��u��ϣQmT�#m�,��zm�tM�-�6��h�#�(���֪y�^�X����-E�bXݚ�����k}5E�hi�f+�r�P�.891[�T�&o��$�A_�	��S�ڰ~/��zO�Bq��I���eh9x�lCKK�5���s���f�<r9�y��fĊw[��D|����yԽ:�̭��ҧM�*��S��~ �7�����Z�9�G>��G-hs̴�֯LF.����\��|"H��6 �zp��f���_"l�
��}������+s�o����Z�^ �c�<b����oj�k��c�R�9�]_�b)�<�h���֝�b=�I����-�����vN���xg_���3 �lϭ{g�X�����qd���[M�=m::�z��m�+!�͊\ bn^�MGS�B�Q�R�	�>!�\��{j5k��#�u��"��yݹ֟���D�i��D�QP�s�Z�n�� w�����T�Y�w�/�����s���W"��@&�+�p�r�X��
���}��^�ܼ�]��#�fݤ��y${K0O���/՗ܽV��G"rn�bI���N�'ΰ�o{�^84F9���t�\ꅙ/Z�1���xX��kĵ-��ƹ�#Q��^�,1����} i���HK٬0�{��v������g�imh[5�>�F���n[�H4�)�LַN�M���!�׆�5�u/17/$�y)��fF���*kE�"�D&ؤ)�
�c�D�I T�V?<ӻS��C���@D|t: a  �^�d�{�w��kq�]b@�a��1G��6��� �(;vY����޹�8��'�@�(�q�����!�?�T��e�3�U��\� 3\�%·OM��W�Xr
#�a�s-2ù_i^u򝭗��">��Bw-i���s�����Ѱ��,�חR�5WY��ͼ��b|S��!m}?�ݒV���P_����M2��7�c[���̍K��P�vє�޸�?D ��Q�p8�j�)�ݘ�դ@�w��(bt�����~�TS�����nqd��o2�WCM�޼Ϥ�6T�x'���Y����a��&'�D�D����}.�X-�}��K�ܜ�m��S��i�j�1����ঙv샔����.<:F3�{��:{�h�V��{sٹ��܀c�4�����``��a%X-�>h �@�����]|�@|��gH��V�gD�1R|T��Z�����P�t��Gqx�ء.2�6ܦ�F�^��W"͏/,pg]_Ȟ�9�ߥ��(+F��ּ��EL�-w��6�[���Jy���_#����ֆfS���O:�q���}�٦��;ùS��3��v�ڻ�?�G\ bnb#�
��5�+���uc~�l�0���h�h�+ѳd�jjq�G�e�w�Nd�uw
��RZK�&7�y���0&�y����j(%�c�]�%���/�52g��:vK#�'x�A���o<'�Ͷ#Ɯf(@���4�;��5�9�-��s�1���o1ڭ��giZ�G*%������k�H��]J���o�����{-	��@�[��W��;I�l'I7S�m����������vp�nk����S��l�ǚ��\O�O1��i�mk�!�D�[s������������)      �   #  x���;O1�9�)���l���R*�ЇZ�.�P����/�:�PXN��'��Ԗ�x�Y�X�N�Fm�����&��vo�����ջ��\uiRoW��Y�1��`%��4���=0���tuB�9ڙ ��U
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
iY���;�aZ"�y�)�X���q��K�����.���H��8���A�H�Y�jؐ @��4�2�U%�2�B���|߇�l�4O0����{�
[�t{��e�2��V')�D�u�!l�����FY�ܳ+��M���}���c3Ah7'K��'6DM� W ��l����JE����D.��q���uסX�G������$���=����s��W����������9�~���{�W���A荚���y�=����&U�b����
f������������_���Zp}��������Ͽ����������?�����_2��4Z紧��Xycpa�S>��.��$.�K%�¶���J�$_�2�wS��Q�ʥ=��2Hm��2����XP��t�� �DT����)��_�N���$EPv����깤^��yaȃuT��F��zX�����y�):�Vw�C��1�&6��{̣�T%H�cN'��[�Q@�+���ڔ���׈�b���+����U6�F�%8L��\ڥR��/o5�$e��L�)A���{X�L? �M)��\�bS؝�I[�j�S�&Stz�J��L��|�v���A��*���q�ܜ�)��xE)�B����.6�+ 4�-d�=��$�	��b�0^�Y�錞p�@�� aڡrq���%�v�x&�a ]ub�l���q��� �<y���C~bVs��&H�<��.6�ıA��.�]�!OS(��	�w&�vZՕxy�j���[�H;���)��y�d�z? �M��漃��0&��F� /S��Eg���0Y'4�sfƋM���I��s{����H�2Hk��Ɔ��ӧ�=}>T(w��@5E�,�UJ�5/�altls�3+Uj�֬��n���iJ�'?X��6? �M��IՋx<��*�?C�{����8)�_���6]>�S��ņTU	S.���o��.S������~@��-��!I ��͒���ើ��)�B���~ya�	+@3�Q<4V��������S|��'�y����0i`H)��N����B�	6�#���982����H���}֭�L�h˨������֪��Av�9�d�R݀�-���l�j�| �S0�}�;�ɽǆ����T%�)�^C���41���Њ:��������b�Mp����:��ݞ��*$�"��{�Ӏ����Jo��Z��u,�
�H�^ ��0Ĕţ�w���N��RH6Z���x~�T��-���0v��p�\�랧0c8ں_���N��z�,{~I��BؤҞ�'_l*�#��+��펩s/S�]����q�Z���6u�Q#���m9�y�"�Bo���?!���~^JLGi^@��;�ćS��T���@��s���&�Ԡq�8P|ÖZMamx�����A������4�;���C�3�'K$<ĵ.�OS�Rp:���M��Kʃ|R��-l�ĉS<�-6�| �VGo!� ��T���$T���K�%Q���!������7.U
���"�=u�Z��Υ�7m�f�J:I����pȟ,9��-'OOSB���63��R?���͗���o�* �
{|�i���2���T���6�����.D�)����Y-a�z9��'��ex��ܩ_*���e�V�����):�P�׺�2o���*�Sc�Ŧ�_��:vL(x��$�9X:�@0�1��+�ܬ���2��١��D��#j��҉�'��6ʰ�>�Uq��$���$���c���:�W�D�k���� �s��l.m�6�!~9�
C[�6�q�S\��u��ȀifSs:<���h��yA�2%8�E�a�C��r�q�$�h�{��Ԕ� I k���i0�0���Kݢ ��{N�>g�S?���'IN���|aZ�Nr�4����
�>� �w�48Pt~��¨Jg�F_��Ke��ږ�b5�k�3q����Oӛ�M�YE�k���0�4xظ�v�i
�Ë�Yui�fXϭ��>��D�!��aO�yZ�>��[�O�rK6ӹ2�[� ��>�r c�[z�Ԕ3�%��x�a��`Ĕ&6���C���QEv���W�����A�P���������u<A�� lc�tI��k�P�&z@�<��-��Ԟ�b�v�G;�CP��Ξ? Lr�HZ��6a��\EY)|�to<M�^G��I��I�l��w#���2T��Fء��4%��n��Z_�'�)N{�F�w����#�.�+��v�!m�s@�2��B�Ы܅6�]�5��wC��T9�����r�%/����B�4���Ԏ:�$ֹRH{ِv`-x�;#�����X	��׼�1��eJ|��[�0�zk=LL(�(x�VR���:rLa���Ha#6̻�:�Crj�wI�6䛓)�%�+�!lh��y�eL툃��ݕ�7�/S�!�:�d�w&X���ymJn:קՑ�|�}C�y�"��v+�wFNp��kSȦPU�P��1_��(�����Bؔ(���A�}��K��7��L�������{ͪۥ��_'i�K��Ȳe��Y���M���X�56&a< �l�G��N��c��ݜ��� n�D���������~N�]�v��6�֜�8���HVjۅ��;S}nVE'6>V��Y@*cSV㿆�{���WټC�ʭJ�V'69Kj��*��m.S@�E��d-���0�!r�4�Im��%��G��Ӽ����s+zJw�'�#}�i�H�V�c���6Tj�)^��Ҭ�;�Q��i���M)����b�9�=O/S�a����t��-?��Ŧ5wH@r���{r���`!���y���=G87�Q�OP��=�˔�#T���aF�\�����B^	�Q�#�����i�S��d����T�������ɪ��C�]\��9�v�$�/u�g}�)|\��}�m����)����y�{��������5_�W���#&�g��	��0�c쮥�M�C���������=#��m�!L+RRG{~7x�rr;2h�$�1��4��X���G�a�ӆ�8�!���ڔ��^���GD+/:� Lϥ:�~b��1��Q(K��?�)*!�Ľ�f? �p1�|�C�vT=OO���u�wQ/���aE���[�8�顯�)�a%��:����S�A�	�{�&tv���l���ٰ��=�]Y�*$K��WS� L���⤉��;��IV��	R/S��[z�~aR���yn{��+��
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
����x#��(�v��:O~�w���3㊲��ɥ���=s�CvZ�5�xiޕـ?GSH���)ra���0�M�R�E�� o�7p���)���).y.�m������r(y�}l�N�܊6��iu����89��c�����l��Z��'�	bm��\��Ŧ"AI�6������=òx�0!S����M��������g�t��(IɊ���I�;���_��|FT(�L\�J��uhm�^��U6�FR��y���2Ijs�1�u�ڠT�Oչe/�a���Ҽ69b}*����w�C��6���%�;��E{j�{�SSR���쾬����`�W��a)�#=�΋M�&;�WW�6�7����1�����0{�}�!I���=8���nd����r��ar��R������y�U�nOw�iJ�28��@HE�s�:�a��xh��Յ���S�&���%�g��F�q4����ݦ�J%��lw�׼L��wl�7l&�o�vm��4�    �a�u����9}B�6���Bz���|ݰ�_Rq-y��چ:�z�����}wojw)���S�xup�c��˔���6k!����xí��o_l��\��9`۰Ӟ���^���G77mZ	t�޼�����Cr1W��^��Ч��;B���(���8*�-�Z��1%h�lpqFq%缃6CUR��&��ģ�
���d�^r������^���>`\}�`���e/���3}��!�����4f�}�v�Bւ~:��r�Ao�"E#ƴ��ra���zv��k�mL����gl������j���A�A��gw��qe5��PXG{�6�G�)��[� ��s�A�T�خ}�d��jR��0g��ǎ���)�j*/%cXQ漃0M*KF=�~�a�@��G��Nm���9~S�ƴ�q�A�XU��k�،�8Z&�����i�)ׂ1���;�U�řؔ��pP���Җ��) ���A�Abڳ5��B9�*d�-���Gr.�����#��?�����_�L^�<�������_������{�������JjJ뗺
o� �"Mvކ(I�>0��ܴp�Ut�m\�qaSG4o�&]+�IF��ǆ/S�N]�yaF'߇�C~��% �����'�9M��E3ڥ���T�������.�I�[�g�)��F�o-[�G���~@��K�0�̆�N6��3me�7�H+��w&�<|��N���pR�D��h�I$a��A:���I�.�'.�,��
�[8m�.�H��A�X�����9�4J%Y�~�ʀδ���;��|
\Qy���v�"�[�U��@����z�)����>�͒�4��aA���8*H4���i�|�	�ۅ��;cG(����&6T ����ˆ��2%�(�gv�`bK��Ʌ��ZE�qXN����&.pf�D�W�p� L# ��abS�|�z�ѝ�w4��J@ ���0���~*���)+�,߿l7gk(���4%z�x�կ���A���y��)�sV�	�T߻؀��[�W���)#W��h��Zx��ڎ���P���"�����B�Fm x�)���E�p�-츤~�rN�ėW=� ��`U��ņ���PZ"��fw4�=M=�	�������vD���k�k�xx�n�&}���)�߰�!�Pz�K����=kN	��簍M<�d%C_y�s�b�����.I����݆�����^lX���6�%M�׆��r�t�;��)��Ǵ�L�¤VG}�5���ɶ:R�q��4%�99�k�����E;��Aj�1A̼'�z_�g`�\�l> Lצa��fb��� ��&6���$X,�n�A�O�B̟;��t�0���ð�t�7��@W}�A�<��7�P�Q�mq}`ܔC��x'��"���az.��|(�� 5�E,!ia�׳!��aAoe�7���w�D[��<��uER��F��8�A�XL����REp!lbv;��a�<�j�n�):y��´�h�<�)���rFG���|���A�ޕV�;a�%��T������A��3�Q�L!������J&�Y'�ׅ[`��	3���8�i�9U�QX�#��0q8v�olX�U�����X˶��4-���� ��*�'��Ķ
��7ȡoy�+����j+�w+'�wZ���\��.�c������)�<nAm<_e�aB�ڡ��g����"�������DU�˰2B���%��F�Ȗ�PϨ���|�"�V�����A�ҷib���<�	�x�C �iʩ�'?�����r��=4�/�i��õ�m�p&@�E̐�ć�;Z�g�ƍ�u4���+�3v�P��6�)��	�J������=K{�)Aؤ!��C�rm����)��+�6w��m��o6RR�g7ʎ���M�%[_9ḃ0�(4��f6�����rp�T_���,���a|�JVe�_lhD~A,�Z�-��iJ�G�:�'���p�~�PQ�<چ��Ӑ`O��]i���0�������� �UG-}���e��R
���	��V�6��Ć����(�)L�R��	aB���0{ ��NcߤDc�cP�e���ȿ`���0Q/	B�c������G�n'�&@ī>���iD��"'�v�4@��`�N����G���;�S��Iɵ#k��܎a�/ST�"-�]��0=Y��Z@�;8:��r:5T�z6�Gz@�Xou>�B�v!54�q���f���J9����2�=-ś;�iQU_��y�Db+R�ᆻ���l��W�`� L̽��ibõ�1t����7ܬ�LI��RZ�!��0�
dЌ3_cINqH��S��-ϿYύ���I-�p*xa�����4���Ѝ�(�7�),TDtm�}@)kB�<���5�V�y_G�uC�|��3=�Lj��;���t=�P6׳�"��K��!ls�"�>9�<�������M�y�Lil���۾���A��R_��F��a���쿺��Z<,xۉGhu���i�j���b�+��w&H�.ՉMf�G/!:�S�v���L�����]��	I����ʊ�1����0��I��������D�N�|��J�ӎ��OST��KO�>�d��,�y�б�@)Uyl8��	�@y����0��I�3�KIxt��r;�=M⎤|Zf�aT7���F;���"�衱CJ�e
�L�%i�;�I5+ܼ6�y��s��������)A�8�_����n���8V1�@ն���PE�L���$�}!�Ӆp�����:��|8%V";v��d��
|6-��ф;#�'��6��`�Q�pR&8������F�4l�B�{]kQ�&�z҂��F?Z�y�N{*�C|��xe(���Ԣ8�4���Ͽ��z��w�^�h�1�Uџ��qf���G��/��u�	����8�:�Ku�'����ꕠ��+ވ��6Te�Zv�M�M8��l~@�Vr����&�\���-z�e�-���)�����u63�i������bC�ۑ��`�&)�6�ᇾe\�!��0m ��uf�\��GI�Cޒ٨)g�E�C\h��0=خ�3��!��S�K�����ՑK������b��r9 ���|R[N8�LI�"�U��B�DJy��7������!%��%m��Ԕ����ټC�]J���M�:Bn���*�-�ڗ)��C��3�O#9'ó�����8�PR=:N{N������U��u63�!I_zq���������Cn[�9��Y�0Z��v���=��Ol�5{�)�8@"螬S����Kä� ��s�]w^��+�#Z�%���O/��9�k��-�f6E��J��ɶ������VD;� �@B���Bӡk��J�������i{<��Qw�Մ�m..y��fA��T����%z�`iET�B�dן�jIHU��wO�eI	���z>,�F�B���b�AX��L���!_Q���o"�Lq�8���2�waSS����A��(q&�ޒ�}=�m�6�X�p�~a�:�l�OX��ְa��˔h),�)�B�f}��۷�&��0=�^�뫛oS�N�Å��[��(ͦ76%�_�[3�����IuT��|}a��������,6&�m�}��l
ʾ^v�o�՚$}�=ZI=r�E�]�0��˒sB
�Y��|�|aZ��S������ d�7�%�M��VF-�B��"5�ϙ ��;Ri^~�b�� �����-��h��u�k(����,ܰnW����Q����	�gY��9�)6�����6�MH�����[a��6��&�ڏ��)n���T[��ia��-�Q1N<�S�0��$��1��˔�X9��,�����g}ݫEU,�D�5��B_��>����_"yq��a��_����5�2`CW���+>
~Ae����sNU�~����
�*L�~C��Ӕ�*ׂ����B��b��rf�ØFjU�hJ�Y���8,�A�B[��՜k�zE8�dД�s��_���$���6Iɦ��[�    ��}�Ŧ�R�A�2�o�_��tc� k^��8
��Nl�;"��6�����M�"RXxqa�W�{z�+��u�xSS�{�o�6a���+��n!�:Z��O/6��i��o�=9tR~tF/.����0Ԃ��h^�t�j��BR���lNS@g�y�����r}��Ǘ�Ρj�]�8R;�ǩ)���D�yZ��> ��z�s����`/I��=�a�촧)��,U��N��0��w3���-E�Rf�bC�L��xA��u@)��a	?8�|MRo����y~��gK�o�|#✘u����PV���Q֥��}�/K�}x���j��P�#�:�)��%Q�,}6E��)�Ib����aHJ�PT�f��*)� �T6�'��V$�;�0`�B��e}ıq�~�>;�q�܂V�-�a���cAױ$E�j��7�\�6Eg� -��B}|�?#'iA�P}��ܸ6.IJ���OF#$��p,/�~}}Ӡ��gT��s��ڲ ��yv-r~@�>{
�R����B�З6�5p�����P��kӼ?5m���v�9OS��t1��[�[#�>30��)J]�Q�6�>=MQY 	�k>��xr�=�76 G]՚�ε�2+2-��B�d{ê��Ž^z���RrvqxiK��J�����DqA,�¤���Ll�S>*J&�\"۶�6OS$�'���N��0��В*%��09���5I9wt�Q�'~A���G�j;��k�E���fuT����De4,���aГ����.��0U ,�����2%=�/�⫙!���Z�	��}���X�p,��遫#=>NR���x�A��lHߩ��H��G>4/I�ۑA�L��ѧ��[c{��4��CO�<$jR��k�W��h���8�6�T{x�!���)t�^o�;_���өM'iw��~�%�fC>H)���6�����)���q%���0k*e}���Ӹ���0���w�)��Ga����0�gɑ����u��a!IF.�ݐ	��<G�8�����B��|t��i���<{�d��0-�#�B(5T]�"���âd.�Wr�˔��<Ww�c��\?��M���K�Bͥs{�M��W��~�63���(�Q'6}4j�|�1�˔���ha��-���%>��M�G8<�r�p��2%�dT����0������\
�ƣ�X\�-��A�R#0��K�C�:��J.������͐U#ӟ�j-[f���°R�y��/-5��j:�0�����OS���*J�F��~֤���;'��,k��=�ك�O"<�˷���> w�e�&6e�"��l4���A��}^�x�u�-��![C�ِkp@-�0m��_�ćj/̋��6�밢�틒J���e�m��L�܋W�� L��%K���)�$Fn�T>b��>,��0n�B��%/��F��#Zo��7��ͦ�;Z��0◭�ڇ�͆s�8l/[ـ
:1.���A��ضymJM�hШ�����ɔm�e�!l*p�y�i^
�Zz���3l�W�6Eܫ�֪�a3<�76���$����a���dJ�..h�B����ol���i(����/S��Wb�Ҳ�~�6�d��g/`���r!��3��iOS�C��Ǜw�Q~������/�������L��Wk3A}�]�{c�#M|Ci�A�0��|x�+�:w¦��1̹�e/�3��o�Z|����z��W��o!�$�!�Y'7�ߍ]ƥ����2%D\ꊸ�0=��)�y�b����J�;:�h�âu������Q{%�֦�C�q9�/@'S DZ��ua��m�i��n�$�8z%J���fG{M��T�l��O�ҹ0牋�U}�;8���g�]�G�G�"�0*��<�y��'8���s��qe���޹��ҷ�f�&�gbS ��]A2��æ��2EG��� ��0����$�wZ���#�oweO��s�Sx`�$}�?@���4�IX���},iO��4%>t0�J��G�{����#�Qم@��4T!Q�q�"�'�p	�OM�UX:,d��$x�5�%u:�ȼ LJ�S���z���U�5.�����ќ�r��m�_P��6Ȯ�g�/6.K���Zi6�-g/S��w|���v=��߿THs�z�>Z�$�[�������4�T�u���0���*�lt��M���B�l�� n����T��b�׆��7��F��o[�T1�,�R���05�]x[hNvZf[�������2$�kW�b:�F��K�yR<sGȎ6�(��$<�%,��Oa�l�Y�]l�����K(��m_h �3.L�0�q�ξy����%7�91n�h�L������F� L]��p���҃�R0���q��H+�Jo!LƄ~���2�^B�t�a�r�m�it6�9���,/���0e8�ib#��EmD'1gOp��z_й��0~���&�N�xz�a����R	{��B�NR�����HICՍ0��5�^#��K�a�L	g� �%k>�Bؠ&�~bS|��h��<���}�1���;�J.��6��8/|�N�ǧ=M�����ua�m*�(����_^ �hstL�d�=�-@:ީ������d�#����%Goţ�v@��7��e��v����d��r�ye
舯�F�ٱ#�L�H�%��Wl^��-���P(N� 7̒�2�4aL֥�J��Xy���xM&��)�[t�6�YQS��`5�˿d���B�`�����K�@�Z�=�PT}�����7l&�\�Q�>�ņ���%��a�и�Lq*W��]��	�]���b#u�fi�Ź�q������/tav�-�	ds�4�Mi��w#�dɣˆ�f2�A� ~��a�@�z�V���b�*G�,N�����RL��8�J^sa�{I�[����� �s��Ǳg�=M��%^�F2N[�{�ﵡ�*���(ռ��i
k��V��B}!l��/��llЗ������v�)N��Kq����kS�U�:V�!�ZK�v�4��j6�����	I�g��dcly4��y�ɠ/SHc�����0��Ku^���u{��y쉞�)�	'rK7�w�&4����l�R�E�u�d
���߱yA� Y��'6%ռN���x��2�6�J���p��i�"@R�Fɥ�+C�/�&�B���g�BG<� ɔ��P�8M��6ٰ�4? $����'6�&<2J�&��cW�y�SXꀾ�0����&6m>�(�jI��]Y�Ϟ$'Y�~@b�cf�C�����R}�t*p��H�����Tɓ�$0�w��P���]=S��)����!l��?o��wZ���$^���l�d�Z��0���>��4(/nm�R�r&�B�d��k�C �\랉!�9��L���/�fB0�vT��y��f�Ԥ�v䚫۸�^�ĐҊ����9)-�̦Ð���+Z���8���Ճ�_�yA��nl<٤�}�P<ڐo�z+�v՝!�5� �Ɗ���I��V�$_R�l�/T&S��n�� L)E�J��1�D�X|�>�Mw�)�����¦S��絩��8��e�d��)����+/T� L���<�֦=}ꡦ$.6hZ�L��o��B�t�afc�-P�$i�e��=<��rGxa��)�17%`���zl���w�K�W�l� $K�ɧT��Y(�sF�jJ|8tiE���j<_����)�����<4�@Ƴ�"�B�資Fo�ӓN��͛�'Sb�+B�7:3�{L�������T7a�싗%�p�}.��? �M<�.~�Q�1������m���i�������	��J��Ԭݺ6*|����A�t���}&g���2v�@O�D����3�(�:�hb�'�� f_w�o�)ڎ�}\=��!lb�o�s��2
Ke��R�ʆun�o6�a�Έ������q0���(Ա�D@L��!�{\y�y!l:K3�9�|x,����w�N�Ġ�@�b�0#I��ݜqf��*�ީk�wݩ�)��A�%� � \   F	�jh}�N�&`���Ư�{I}�W4�� �@��6���Aʗ�ڰ�m��<HY���w3�;����$PuXנ)��ε	����;#I�me�l�:��Bo���뮻�������.v~@���[���T�uCGcU��Vu����6K��x)���?�M���3��k��e���,ӯ�f�0R"S�n�i`�촐0��c2�dJBt+ڃw��qvs���3p8$�!n���[|���@xI%�-����#q}�Rr�z3��|ܲ2_���շ�K���@�O%��)��X�8�d������B�$|�ڿ�&"KVӠ'@�@��h/S0J»;?!��GO��6$U��.�)�u[�ѾL��;Z;���6RES��d�|��ӊE�K��t<M	V���Z��'��I��n�h���	lO9�mk5a���Z��'���CγЋA��#�ZH�ǖ��eJ|8H�Wl&y؂�-��c-9��o/SPs�-�;sB����)]�s��Z�;f{�L!���u	|B��1g�s���͠m��,l��USҟ�=d_���;a�lq�f/P���DNҗ�{�ԾL�O�$B,��~B�e����f<������&>��kWj�e�F}�����z�|8ضTj_�H����8��v�4�1�ɫ�����͞BM1���o¥DW�vq�:�2�h]��Eܪua=?{�0���N�o6x��$9�Z��V�i���!��;�C	�ξ���P���R�H³�MB�W4k� �4����H�b/6W�h[]��t2x䵳�Oa�N��o6��hsr���-'�_������/��a�z�㽂��l�7G���k�i��& ax�hz��FЬ�s�F�&��9���� �� ���h�US,���̇h����Yp>��������o���[��< �����/<�q�¿�#������?��Ŵ��������a$ӑ���*S�ʡHfT��qK'���
���~���B�����|���Z����L	���M�'��%�y�Yů\fLi��K^��C�<���B��L�rD���w١=�1:���	a2)���t:�j^6d_��1k�2�#"Ƶ �&���[^�� jB,��;M��X����0V7�g^w�]�;tzQv�î��P�5���s��c��)�76��J�Dd��SJ^��',ޕVw�c��ˮ�����;H�J��s����]��i�w�F_��ym
<z�΍��]�;���R~�f�06N��Up��-]�Mh|iY 4rI���?���?��?�?���6���������/��[���������������ui������)>!��X2��X����/R��=)�;o�a�� � �X�6� /.�jJ���j|���.KB`)�~E�a���#�+C�Q>.q}��|b��DEaO�> ���w����M����r�/S�N��V<|@�>��3�hkq*�.�Ӟf�/S�Cua�>!��U��M���l;� P�uD�� �2=�6���yD6��! $bQ���ӆ�eJ��?���������z�4��8x��hlJP/S�,g�J������3�r�a�E�����0"��@�;S�f��o�&8�b�����4#~�B	|K#@� L�åN6�T��)(�R�{�Q�ء�V:Wz�	�'�	E��&6��aH�q�%�ɜLI��֢��QF��0��0D�ű��-��OSd�H���X�`�枩�y�e��M��E����Χ%z2ca�*����c��ąQ�      �      x�ԝ���'��׹����1��|s�:�k��tʯT֤�ș��ޫv�S|<6`��-h�^2� 8��({�QT����q�5۠�뇀x�=G�=~ � ���p�#������R�����2��_����G�?���?a�������|�!,V�0}���P�0i��������?�Y{�oඁz�O���rSP,��6]�{[`A
��²=m�� ����� ����1pX@�6�E!Ha��p����!*U�Z�#�Jn
x������Z�m�� �K��R���������u`QP<���!I_mV�;l���_3��*�W���_��������j=��I������a�Ϫ�6Oo�U�@�c���E����~�jmh1�������-���E�155���~`����2c87����5��jY�L�1h��1ݺpUZ���A��fp��eNT�VK�:bzn��~��H�8���������r���a-�H%5�Y��x�̹�y�r����V�ajvVg�=!�*jiӵ��6�C�hȐ�o�|\OEe���	�eQa���:���ҹ�R���g�,A��Z��ΚA�uQqU6�)�<Ǣ�Cj_T�1mߑjZ� �'�F%���ze�ѱ� ���x��挱�꣫�8Ak��ƨ��V�b��M;!�1��p=�kyWYJ�ى��5~���'�� ���˯�Ùv���2��%�N-"1K��q��kް2�!��F���r�����v��N���^�c�o)�?�`�����^��}ܵ?��o�?��&�M5�]{a�kd�1�[��O3��`w��Y�U!��o��?��I��~@����Z�������A]�\�epn�l
��-[���N��xi��m����W�q��GPZ�����	BHm�m�?�!�u�^�!�VŦ�N��P��m��)�/���C�2ܼxtu�����CjYl��'�*�A��D!��E)�^�oV��v�kYBj]�M�C�,-�Ԅ��_��!T./'��`C�qtt8��'z���Ay��A���Q�DR)|N�e����W�qC�i�� �5��/���CPD׾�n�q�QzBjc�����6:
o�	�����<Ah��\0�1�B�A8�K)���^Bjc�p�����Y|	E�Rc������cF���;W�e-r����C�RcoV^��Q�Jk�Ee)�1�>���#�7H��3K����^���w�(��������\O �;'�Is�ϮC_��;`n�Qo�1?����!�W�m)��b��f`ݴȶ�!ѹ��PfFu!$��w��8bjjD����k�ʘ3ƀS3���A3a%�9����3h��雷L��ΒI͠ssᣊ,{�e,�������u�@:6�6��1#5Us���ua7ltTRC��w�A��uC�Q�Mq܅�A���V��!@jU�e��i���ejBjW�(�e��s"���4��#���Y��`��W��4:'����]O�7jBh�3!���)ݷ�i)}/�1!�/�A�努�*�C��BH-�s�O�<�joK����q�InN ��}�UZ3�6�y�oAv��8�"��'Lm�w
\.�TU���Ι�9S��m����:S?�%S��71V2�^ h��������i��>E8#R��%�}ݤ�a7��(��ƨ]įb��n>A��Q',71�PA�)B���U9��\u>wv���ƨ{T;(U.|�=Tb�o����\���]΀;-!�6��_���Aw��L�J�u�.j���T����~��<���i#� S3����)���U���J�=J͠U�ZS(�cjjw����V��pjC����I����-5�;�}��J�a��7j�=I�`�WţO��'�
�9��fp�?��2��X�1#3�]���t��8YK����(����\GBHm������kN�	#h��Z7���\��	�Cti�Ԯ������r�A�=!�,�~�k��E�&�A�mq��/����^rZ�!�.�U�A(z�*����Kdj_�۪s�r��*Dͥ��m�Z���2�v�zBjc<�/7��W�=�`�������,c�Ӆ�E!�6�S�?�}�T�cl�Q���Y|�A���T;=h���O���Ҳ1������R��n8�О��	����N��I���y����lV�>�z�q�������z��r�Lj3�6F+��	]ڠ>�BBHm�����ږ�k�k�b0�@���j�N�����%81Rjc���p��0z�OO0���������̏�-ļ���Z�\���1����f�I���}��fpu�W��Ds=ߺR�gPS3X��y�]a�����ӅU�K�p�gc�3�p�)V3�?�.~��HjX�[��k�w�AÒ����][���bFj��1���U�0�AG*�!��ZM��Fi%�8BfS�/_tq�<�ܹW�'dV��Y엢�RB��B�슽�/��J4KE�2��2�b/{o�K�Zp\Q����{���',��X׌N��u���'�S�Y��sBj_|9�ltn��+�H-�w��߁6�gw�������S:K���F�QY���b>��Z�8���%S#���aQ�0(C������>�R���HYI��4�6F�/G���x�v�P�=!�1��>�ΊGN_�fBHm�X�?�7������W1R#"�j	��U�)�G��ƈt�˽�Qt�%�m��ƈ<�)�!���%��A���}i)��(k�"A��q��l蝹�	BHm��/�O�����ߪ�6�r�U����NuZ[��.������1���*�+4[78 m�c@�����i׽��Sz�AM̀�r]e���`����w��p\w��?��Zjm�������(���� I͠�@�����3fpN�Lخ����M�c0R3��Of�n�z��X�����\Q��:��`BjS$��'�e�� ���Z+���e�6>�9-�ː�+5_�����Cr�R�b��{B}����u!���*��RD+���h3:1���:�W�i��4��U	R�b՗:sG���x��(���X�</ɔQ�}m�!�1ަ�˴��H'3J���a��袭�J�'FLm�L�o7����wp8`jcd~y3��|y@J&T0�1��e���C8kL� ����C�'�ơ���E!�6F~��(r0��wߧ!�6F>]^�Kn��*�a	BHm��T���-��K�Rc���nw8,2��(Sc��oF��vB��D�������d��M�ÁRc�F�'�˖9?Qd볿���w���l�x^MN�`����2���b05�����Z�Z��b��fp�Wh��j��=v�1��H!v�W7���2���f ǿ�R���c��f@�Ao�@�:-8'Jj,^���߶��fS~Ϡ�f�ԗ�y�[E������/���<�L�-�H%5�9|��N�l;:� �Ԧ(k��Z����J�G�VE9�?~Gֵ��Zpy�Ԯ�K+.f8D�~bl���Z;�邆���Ӭ�A�m��*�l���� 	3�����ܻ*è�?�a#R��|Ɉ�ȭ/�(��Z{�~3����i%�PJm�}.�ژ�y2y�hF)�1�0�ގ/��y��'Lm�7X���r�'���fLm�ݎ"�j�6i�S�q|]b:��]6���!�1��A�N��7z��%Lm��Zu���8��5!�1�6ѯ��e���6�ѫ7F���Pa�����8f�4�ݯ�;gB0����q������qa�`�#�6Ʊ�_��ϣ�r��BAm���8��n��5��ş�{�C�oM1�r��3��!y�r��;��n\@�d��`j��E[�ڑY�B���fPi�,��v�
��c��f�櫕w�ET��d���0��"W���J����F�Q�$B�pv#�1�����p��M�l� ������,�y������Nm������\�d����?Ӯ�:b[\�BHm�
�+T#�5���kBH��J�n8�SHbt{+!�vE��4�bY���� �eQ���    .kn����4jBj[�ξ}[�Ƹ��`BH��:��RP&>jGChH틪�ܞ��6�u��(��¨������)��B�=� ��ƨF˵O��N L�	��W9ǅz���Q�=� ��Ƹp��b�^N9 �AY���x��8c|jfP�}@	z�6�u�ȿK��c���6�%�Ȣ�&��Ӌ���`����n`���d Bjc\Z�M��Z��)�����Z�r��+ԧl��6�u��E�D-{�hOHm���7�a�������o��q�~y:ۤ�V�ˢR��I�mw�L$��s/x�9�_����k5Y?�GÒ�oސ������L�@�<[ ���1����_�����+155�)/��#J�W;885�>�0��O���g�R3��W�_R�o����� I��Ŀ�q[uc	0��zfp�4�j�F��~0R3��n>`b���u�I�#��j����s\M�l��(�6��ȧ��K��|�R���/ �8���5�� �Ԯx��7�ƍ�Gy�BH-�G�/�����J�(�Զx��>к�J]A[�Ժx��;�,u.�2%!�/Zi���H��=!�0�?�6���ƭp�R�����uP����(�6F�1\~�~S�<�~
�R�]C�[�R���)h���m�߇�m7�����ꀩ���*�����=����m5�(���-�L3cjc���'��dɴeAc���h�| �RW�wҌN���qhǿ+��Z�*���G�����͔K�L�afc���o�b��ϧ �o�������$�z����'Pfc�7}y3���e�~B��!�'૶�Cv�4~�����z�hy���@1���._l�K�rU�t�J�`��p���S/"���f`�=�bkZ&Z�gf eo@z�ö��O�1h���S	��O�Y�h�1��*�Y�,�)�c�S3�=�	+���s�1����Rp��t^[�8RIa�|�<YV)jD#�0@jS����W��q���NBjU�՛ϴ[-wm@6N����\��v��܏@BH-�`�j"$�6��RA�ma��Gl�S�z|��F ��E|*�c	k.nʈ�Ծ��\����ϳqEW����UCi�6V���R#���T*�T�>$=ajc�Y�'��ҮF��%Lm�w%�w�﷙����0�1����=J%��kjcD�K��&�)\.�`�����8SNߕ�ٗ
BHm���B1 ��ʢ���6Fz��p=�٧�1��`쀩����p�)�۔�	���d�k�!=�7ڸ��6F�9�ECk�]��5Jm��/ׂ����{���s�6F�ŷOm"M�(�s֮݃/�X��PB�?��7�p�?��t\a��l�L�^���:���Zc(7�O��27��157Z���~O:�sO> �sC��vQ������Ah�!,�D.��Uڐ�'�����r�	�a���M B�a
� J�z��?gpN�!,�#��΢�zz�E�����(Rp�x�h��vƧ��˾��S���[�Bnid ?7NYx��F)��+�R3��nh�gp����ȵGAUnp5讕�y!�7r{y)�h��Ҍ!荐[YL�8�Рށ�#H!�9���p��_N�Ae�Bnud�>�B9�`�=�Q�Bnw�kG/Ǽ��9�].1�c��|F�U�e�6�r�c����k/g4�tgG���}4�pI��+H!�;��#g��JS:�}��(�v��/kġ�k�QJ	�0�;6y)�lw��7��iѾ�����/������&�q�v�6�����	hM>�F(�vǶ���anP�$�a4��ݱ��*`d�N�����r�c���*�6#���D�Bnw�>��yx�c�qG���{�!)�ѳa�!P�I���
�;sC�/oF��s��9��@�!��nRP��h�!�cjn����i�r�{�c1��8�-(�k����3�冠]|�!��Q���1��&_�Q��_b|� ���Q�C�}��}Ͼ���6�Sf���	��U冒� 9w������Ub��ո=�����aP���g)�� 2(������Ϗ?����_B�3�����Ұ��AG��<����]�ٞJ����0���ڼC6�a� � S3�
���1m"D��,ƀR3 �c���-k���٢�����+J�4o��	|�S�;ĀS3X����uWV�1-5��ŭzF(���Hj�m7��0�r��`?��]m^�D�m\Gj�-�@d�R��Y��TRC8ǋ�~� o]�� �MKau���� �cׯ�2�"XZ9s{�C	.�������Fc��p�,�X��c�g�Z��O����4.nNϖ��5���Y��n>*ok�ױ�cf_�2�q�X����jk��p�,�X�4Dӡ�{��l�� d6F,z�["Y�!���h���˞�A�V�w)�c0�����H\�L���7���S#�Enu��Ш\"1�1rw�y�����Bjc�a��{�uN�5:R#p�'��Ժ���0�1B{n��Ej�ZNo�ў����dY��]uG=!�1�8�A��LW�;:1�6FP&�>��۱֭��6FX���;y^ܫ3K������ԃ��*O`�|�5�~�?���I�㋘�R]R�~o܅���A���9���%��@K�@h~#Ҡ�������B=���,ȳ�?"�sChM�1[y>X(8Zn�	|zM�-1&<� �!��{wصPp8���yVٝ�9R�[\"Gnk����UK�-(K%7���kW�	�)$wF;��GL�2���rK#�0�� oWx�1J!�5M��j��T}��Crk#q�{qE&-8|���t��Cumc�Uh���[�Or�Z��z�)P����i�P�g�|{�Y��#r�#�쮁Bת�]$�E)�vG�t�Jy��^kk�xs�#��GĹ3&S�-���o�pT��Aoe�A
�ݱ}j�[;R�Op����XI����q�Q�+%�v�Z�\�6�ɬ�[0����X��[#���m7�\'H!�;V�~�����X)cE���X�K4%ZQǮCW0눹ݱ�k>�X
3�Uvt^��u���T-����v�zg��]�},�^��#%v�%����}Ug�Ve��7T�x( �j
��0�Z���.��k��θC��V�����Rg�����e>�~kR�]x�ˍ�\��z��N�/�+/�Q��a{��;&�A
�K/���U"�w��6
��k/����"u���#.A
��/����%wJ حUR�]}��"���	�ޝdFg���n���(v�>�L%8/`nw�$i��}LDAk���8�ˈ`�Nu,Y�0�;��2"�N��춢}!�;�N�������zV�Bnw��[)��*"2Ţr��>�D���!�4X�s������*�lZσIA
��qX�oa����j�,�v�	�_���e�Ӣŭs��$�kD���T>\�E\)�;κ��&�^f�>���v���W�d�QU�=~������O�qI��4�B���wZ�嬡�W�sC���F=����[c(7�]�˳�z���3A��PsC0�o+6���J�NA��kߢ}W�֨p�Ah�!P󙅥�d��YpN��X��ә|f��!�� ݿ��l�a�U18Fn㊂��z�W��dP�Jn
*�5�l�N�wR�팺[wS��r?T��� �4���[RTa�K�)���QH}�S�rk㢱\ �d�TQ��F�퍋�p)&&�J}�O8��-�K�tVL���۴�J���h�A�.ݶ��\f�Bnu\�>����ZTI��cnw���VʣЭ��T_�r����@S,���� ���ocܱ�qT�Ǧ�;bnw܄��2Q��K�1�;>ӂ��r��V)Mabwl����?x��~hj�܈z����+����9��!I_mV@��v���@�U���Y���|[PG5d��9����:��ָ�������AhԹ]��&Q�(5�Ym�"���d�Y!�憠�z���A2��<�SC���ӽ�C� ���\�6�~
t{    !Hj�l�z´]����bzj�o�A�}��2w�A#7��q�_ �^�J�Jz¿U;�A?'�~�%9:�y>#RCXu8��P�ѭE|>�-!��s��
�����)A��Y̼��`j[����BuM�1��N������X�A��`<��sh�^�pjF/���F��͙`?h�us�]�w�����*��_�D�G�������1`!����9q�f��9���a뮏\��TRC�N�,��y.�F!�6ŅV]�D�E�Q�w[A�UqQ?n8����rC��Ԯ�<� (�����BH-��ޯ��i�n�d��� �mqq���QG��grBj]\||�d��
�.T%��M����pgG[ў�[�y��%]�w����e��	�Hg)L��`F)�1��7���U���	����~Ng��}f���v`0����q4s�C�*:�8:81bnc��9YZD����F0ӎ��qu=��v���,щ1�1j�Tx�ٴN�A��Qw}9����	��q��2���V��"1�1����"1N{��� �6�=�Q�bP�)I�+8(�1���jU��q])�	���4�q�Tq������˟b�Zi�RyfPf��F5nl֬���`�gt:�a�kR�1����ü͒�]�8Ơ�f ].��N�� �5ƀS3�����4�<���c�r3����5�x�_�c��b$5����-ZЬÂkc��`��Ny� Qj�;�Fj�-�4y7���t���$����2�%!�)n~9���߈j�4ȭ�M^�X��A��8%!�+J�/��ss�s�E�-�2�Ɠ��=�4����%9�c�B
/
Bȭ�}��'���� ����׾*�4)ˉ����8A^�x��Ԗ�� r��#�7�ܽ�� 1�1je�	�Ԓ�"T8>anc�-nb,b��~.���6�%>�t'�^�j��6cnc��oA�
���XmBnc���ғ`?�&��1�147'Ly^��]a����?/ѻ#���'׉n��6�g{�A���(�2�cjc<��O�-�k�^{BHm��F��ъ<�i��6��K���C�w�`R�R�z��k�Y���.�y�9p�[��6>�֞��yh�A� <�5�`j�����1o?�Ud�Pn�}j����c�����S{��xc��b85.ޓ��1?O������� 
��6b$5�F��AQ���Cѭ1=7���Jk̊��V��H�@�;�T���?a��`�w�=yh�}!!�)��!�����f�'�VŁ>�ƺa[_�����]q,�P:Z�2�9!�,��z��hc�;
!�-���}���J	FN�[u��l��N�)J���z_�V�J���sBna\����n!a�`� ��q��<y�6M7�����q��ڇ*�rF�581bnc<}�;�
N����,m������m��{B��(�vBjc�R��	�n���.�L'`jc������"[OBjc4�~U�#�sP�0�1V_Z��`,<���5Lm������lP�uGDtbLm�F}��=)w��6{p�-�1Z��%(]S�8v	�	����%��	3�N��	V�~9�(��h6?�pb�R����?��g���3���K�M�U�8�5ƀr3Pq�vJ���[���jj�r2���Z����_dM�v���Zj���u���+|_��=I�`��|�(�hk�9��f���rE�kn�1#5�Y}����RF�O���p�UP�=h�k�K��MQ�����X��w� �*>�"��>����a��ir��R��_��;#���#@nYܭ�}X�\s��6��wbx�<Emr����Bѹ�<aUT!�/Z���#����%�:�F��A(�f���!d6�ZJ[.zZ���pi�����X��KFPQ�<r4!�1^c9O��t�ϛ����|��U�/ �A}!d6����*��{�FBfc��.�~u����q%�!d6�Z*�j	ո�Z���(���x!Ls��\]|����
f6�Z���H����}� ���x!v=�I�����'`ncl�s��ƙ���.����5�f��N�XP�(�1��K�ڸ݀o<���|?��ﻭ�{>��������A�ZW��>Y05�~������4�1����.m�Q:�cPS3���� �I+ܚ6
2����۾�du�O�� �����T��"՞��1��V!�Rbz2	�O����s3���R=]���jt��H�`��`|N�� %7��]G��V�
��Q��ܦx����o˽/�;[� �ܪx̧��۶X�S�vE��`���~P{��R�"��!��`]gl�A�m�ė���`��܈��Ժ���oU����y4!�/��
z�i�v�u��RR#PAy�R9':R#��Ȓ"���j3J��*�<�ʕ��WBHm�O%n�>�sj�3�͘����#:��`��0�1BqلF|�%�G�rcStƸ�SC�j;�	����b�N`g�&Q��Q�K�Ec0��]rc��6���u�ӣ�Cnc���+�=���EW���8f{9���Z��}
0����g����0d�)!�͔��t71���o���`��p�ˇ��rp�x�'f0�j��O_�Dc��,���>V�]�-ƀr3X>����!�����v×�b��J;{�����%v:�������i��vS���1����~��b�;=E����f����:�Y|~���=�����S؀�^�$���TRC ���&�|�@� �Ԧ�0�If%il4�Ġ%AjUD���^=��F��7����?�=���Y��4B BjYD_XKH���<%�8@j[�Z|���\����WBj]Ī>�޲�N��������t겡��hOH-����W��^K��� rc��i��w,��*�Q�m�R|�c��=s�L_c�(��*�hO�m�����S{��}�K�@�m�}��-`�*�A��q4_Ae��np[��sBnc�+� 5�`�s���	t=��¤���}��v������f�m��|��N[�9�OL5cnc\\]f�
��}��͈��6��yP�sڨ�����n��H���=��{����9+�;pz�񼖛��������P��`j�Y�I�\}�{�Pn����k�g��`�A�̀Je���l���c��l�5�:4g?�bZj�rzS��w*b_C�=I� ��.Ff�wy
�Ğ���~����K���H̀p����(��c~��䆰��m܆T.������P�T�臎�!�VE���\�i��������d̪M�fpm�ܲ��������#!�-�SܜpMQX�򍟂r�H{Q��<��8�r�b/���E��
1�'��>}���7�����L��gf\��WA���8�ߑ/7��ǞGn��E�m�����]�p��J0~���8�oF���I�'
!�1��O����ϵ��,anc\�O�ٳ��y��E�m�K��t?��%�r����5�<YΧLwBnc�ǟ�3�zc
S�hO�m�G|i�-8`(6�������K_2{e�� �r�M�2f�O=�k��P�Rc-�W��UQ���9�XK�FU��E6��#1(�^0���p�`n���`��ß�S~πR3@��S����#��Q�=����2?����؆�pj����nF�Z)�G�AK͠�/>�MQ���Vp>��^n�NA�����~Ϡ�f��E�h_3��O�1#7�3������g���к߂TkU������MQ��=��K$!�*��].�@��5	r�b�͟XS�U;�� �ܲx���	�VoVve*A�mq��7���޲
J�uq�v=a?�@�~ �̐���K�A\w��Q$GW��¨2^�#�6�����?�� זzH��Rnc\�S��]�)���S	����ങ�I���K$�6ƽ��%����,Yt8�6�ӎ?�Ac�3G��Hs���Ӌ�,��f�m�6�k��~�\��o�     �6F.T��@ ���pHm�\��AV:S��S#C+.�Zd{�F�L�ajcd���R�@�]�B�����o�6w[���ٌ�R#SE�P� r-�D+��ɶ����4x��C��� Jh�UI�k`�Pe�W�hw�2��B��P�p�Zu�N�����/c�ա���K�U�=���/AYHH�Z�bZr/���*��k�oE��C�����Y�4�Q	��B��k�rj+���HA���.<��c�������¨�!��x�	H����.�4�p��=��#�K�_Vh�T$��#�A
ɭQ�'V����|��_�Brm��R��r��(�ΐ�W��u)���r�A
��q����gʪ�]#����ֈmw��=p��
���JZ���,}����Ϝ��-��؎b0����h���lj��by`gGL}A�bRhw�v�ݱ��N!ͺ�a�+8;bnwlP�Q�}A��*��숹ݱ� !���ٛs�cC�I���>t�m��.A��$G�[R�����*WI���v�v�F�_��zp�ޡc0����ت���[xl� �������-�B���6e��펍�R��˹�A>�x�$цڬI_�z��Z;.��*e�6h߃}����!_�Q�*�թ:b(9��dU�Z�5� ���,��F�Z�)�N1�� _�����,��[���Zrk��QD��Sk�{���$7���U�Buc�!e��ГC���ԬA�o���C�!h�/���V»n��'<��)�x�9�ept�h�+H!�3.��=�m�@� ��Ҹٿ���ϑ�
�=������Ϩ�gV����5Brm<�zY0Pj<�?G�Bro4�W���O���':;&G{)��r�^'�R)�6GyJ���
ȸ�o�� ���(e���B����������wG���=��9rL��Qع#*���uF�	s����IW��7i�J�Bnw���R.�8H�\G�����?��dp�6�GtD�vG������h�1�;
{� wv�(���(�ӻy�
3Ikј����.�Z�S�o�Ύ�ݱ-v��'�ҹ�	RH��/�k�t����	���{y)�c��I�܏�J�}�9Gc>�NW�D���+�`u��{La4vCH���.N&�`��ꐡO�A��n��iim([�*CB�A�?�d.�W�89�U0[�x���bZn�e?f�ɝY`�I��S˔�Xr������oOO�1�{ApN�!�?��\{_q��B�AY*�)��GR���$wF����&��s�i)$�F;��;��5���r[c/���4aj��f� �6v(���smx�l#EAno�0����z^a�A
�ű#���[��RΘ&A
�ͱ�Kre�>�6�zPȭ��Z�e�e�ƥj�Bnw�d���s߼��g����ݱ��GD���r?Sv0����ؙ�#Z(u�F{��A� ������m�N<�=�$J!�;�>}9K[��S񘃳#&wGA�@s��9�h���(꣩N�P56�Ɣ�����D�o�)G������<��X�r����x9�1tl���`����$�[>��	ԃ[s��qn�o��Ǻ?#H!�;X��%�H�)Fer�?���󡦶[�z�|>����ۿ�;r}���"���
�Q��^��c���Y�C~����<	�.�L�`��_���p;JW�~@��P�D��epL9Ơ�f�y���y5N��-�85�8m�2�s���bZf�\?XTv٬��c ������Ӽq�z-�t���S3����U0���VcFjm��k�P���v��-�H%5�ޖ�Pki���� �Ԧx����G$�4�m=�R����<vkh�2�H튶����VVSk��RˢY��1�A�mq�+J.j(��/��Ȭ�����9AVԐ�=!�/�qÁ��Yj��	��q�ӷ��(v�:ZBfc�7T&g���<��ψF���w��	�P��̓�����q�k�nN��d&����wY��؁+����BBfc���2�FFcP����7\1rc7B\宓�fLm��;�H+�����hnAH������Y]���Y ��1�T���R���\O��F�A�������MA���a�O���^�)\")�1��<�k��X�@?>b��=t��:��384�&���7�A������JK	Ve���(3��]�6>��ͅ155�>� t'�n�N͠�m�r�M�+�����A����J�z�.�` �t��;ԟZJ��M�`�S3�ݺpM�.�箑=�`�f��o<mw��W!������ϥT)ZZ���BHm�he��ۆPA�U�����Z��W?TH튄�ܼ�s�k���Z���z���6��fHm�ċ]���7�AS�ԺH�|jq<�:�(�!��E/����M��k�R#MU����*��9!�1Ғ� A�lbZ3�6F:؝'�z>�;��6F�]]O�v�WA��Lm��9Y"Z��TA����+��V�I<k�T$!�1�j�X��z�eC�):1�6����wy%�g�Z�[�'�6Ƨv�KRe�soZ������,>��v=v����Sc��{ƥ-=M�=!�1�=��A�~ڠ��9�Rc��_N�/�Q䍣j0�F������ݖT.���f�����C*�Z�3	����.O�ڠ'� S3����dm�hv#�J͠57Z�Sop���155��w���t���
2��ƒ�SJ��葃c�R3PA��=�s�,�c �l,�h?�	Zt6�����Y�%��O�OIR,1#3�V~y�sR.��a�:RIa�2����!�)6zY���Zw����Z�u_F��B�j;�����o_3���'D!�����nrs�=C�QǊ��m��I>r��Ӟ��ǂR�b[�Pe��{P �/�Ӻ�	�wNؤ��� ���(�Q^��[c�e������hj�T��`F)�1���3�kPvM������6���dG^��hm�=S�4��bJ<���ꀩ�Q�����?��M�A��Q�����ܜl+(K��e�ϩt��甎��!�1�>��P��6�l;!�1�u�	w� X�wkBjc�@�D5�uv0�������K�h)]���AO�����2�9h��*��`O���؛�e�E�"5�O�[m�Թ��7z�b?�}ȼ�K����#[��f0�|;ڎ���Fc@�h�'3��9�Oł���f����R�J�W1�N���/�X��e��1h��2�߀3�F��F����f�/5��]qX��5�zj����8��c��g0R3`=�y&t�\�F�@IA��S<��9��R���r����L��)���Z���8�ښ�]�E�CjW�yG��8^U�!�,�>��78��j�BHm���P������S��ή'����:hBj_�D��G{�f*X�R�d��A�f�X��LwBjc��>Ɍd�h=�8���6�9�?��"0��A��q΍.�Zθm����璷�Z��ڋG0����q��̊�,��e	S��k�*V��)d��������p�`���Q���R��2�!��������1�F�kѦo� ��ƨM�i^>C7XtbLm�ڛ��ڼ�j�G��R��0�?�k�)C�a�`O��ƨ�K�M���Sxꁠz�󙝰٦��ϭؼ����B�4l�c05��\�p�A�SspW�1���oޡ]&0t�5Ơ�f��^
���şI��3��j���>���Ή1h�46�.�ԉ��9��Hj�{_ǨJUٕ�sbO�`��l�b�}u�����՟R�]qЙ"t���.�%x���v��L{ BjS\���ϯ�Q�ϫ�AS�Ԫ���p �i�ZspJ�Ԯ���$�Y䮜�E�R���&��9��$�WBj[�ܼ-�;O��p�M	R���H���K��sBj_��嵫�ϱZ��G�R��o<!��,k��R�^�o<�g�    �O�`VS��Ǘ]dٍ��ީ!!�1n[�O�?u����-A�����]����Pΐ;T�R�!<n�<���
E���x��E�T��\�蜐�O��&�"\x�Ң�!�1�#��=���N[x8�6�3��`��ʧ�Ͷcjc<�~��da�s��ў���旃��&d��o����[jc<V���F��EJ0�F��ъ�(��9�l.�Ϯ�����@bg1���ќ�N�NXԥ�|ޔ�L͠���r�	����1�����m��B�O�AM�@���J � 2pj���J��#���.�������>F����p�HjK�˝��D����3���:E�Q5�]Fb�2׼iuRr���#������ǚT�GW	N���O�1܌Д�h���2��)\}9%�Eg��}�& !�+��^���o�Z�-B�,����o74[�	��l!d��S&هN[�q��cBf]<eqa��UNǩQ�}��f4����b4��YO��k��ب��A�����>��	�U�q[�(�6F �K�6��0�0:`jc��}^�
bQ��A����["���}�>��4�6F��[����׾�Q$�6F���"�*�N����6F��}��g�j��}%7 ��U�vɚ����uz.�@ ��4�!�o:���FlE�od�ۮ�]Y߳��%Rjc�M���e�M��":R#��3K�07�{]R#��%��d�,�5!�1"��� \��^u��(�1�*R~adƍ��Q����R�ZAm� �y�sh����p��18/{���]:��Nc����������x�Oo� J�`���C���155�����b�]x�n���ef@��=c<�J38zjW�ef+u��?��85�>ͼIy�ġ�bFj|q1dB�[�炤f��F3��Pϰ�(�!�Pt�y�%!�)�$�d���-:�9!�*�n{��puD.���i���x�Ҡ7�Q�e�Չ�G�w�3W�#(	��k��̓m3+آkBj]�8�o�@k��ťFw�ԾX+U����Y҃Rcm����-Z�~޹D �6��_��1m���V4����|��f�l7�����6ƪ�}��c�s"����R�}�몦7x��tHm��\9��}cX-'�;`jcl�����|����Q$�6��|��ɲk-
!�16j����8�Lm�Lm��@M����R-:Rc�Z|<�:K��ztaLm�m����|���"�ω|��-�1�	_�=i?�����#�Rc�/o=@�/�v���'4]�������ul|o�Gb[�����g���c��X_n�\W�����F�1��A�o���/���n+Ơ�f���V���ZWߟ��w-5���G�d$�:Np��:�RBŘd-Y͂��f�{��;����y��c0R3��o�]]^[��pp=����\���6]���q %5����dXƝw(`BjS����#?��ڮ(YtU�Ԫȥ�Kʢ7pjP�~��D �vEF��+��=!�`� �e�I�#�ǤW��R�"���Riณ"�0��Ef�[���<��1>Bj_����N�\jxMH-�<;���\Q��x���y���b�l��S0�����{��̓m����M��6F��_A6*mQ���s���@w�T�u�i���� �6Ɓ��-�]�.u����G��p�ag6me�	��G'�T��st�,ajc�e:�u¤����H��ɂl���&�a���8��j	:^��Z�s7# !�1�u��iw���w�)�1�#��P����+
A��Q
��ZFw(�9��d��*���PU�e7������I��Z6p)c�����ǻ�k�3ƀR3h�?Ox���S�s��f�ß�3��D�_���d���h�nuޥ�����2��h;w��K��f�a��,�@��R�k�H��,_���>Y�c��df0�ԢR׻m�����]�]�R����Hm�����H�l�C�}�� �Ԫ8ې/� ��`pI�Ԯ8���0*
��ϳ� �Բ8��<�*�U��JA�mq��w�M��P�?�'#R��\_�a� �p-Â!4���yh}�z&��ֲ6�kBja�v|������A)
!�1*ȗKk�b�+�`F)�1*}��o3&��t
�6F����<j��kEsJ����r�7�'�rv0���ƨ���{��� p��,ajcT9^���9H�.���Quɗ(r���T\�+�6F����.�	�k4�.���Q��02�­0M��	��q��/��q��`kZ0����q!��&���v:���6�U�w�v}��"VjBjc\��P����=~B�Ֆ�G��Z�>w����B`E�c��pn��c07i_�fܟ�q$��V冠�KK1�9k��=�憰ti
	K����rC8}wm����=czj�N�/���k��1�l����6��>(a�p�e7�5��D�c$7����L����"4N�� 5�R��1�j�����P��{����Jws��s���[��x�� � �S�R�m�{��f�^"���Eׅ�ڸO�u(�2��O�3"�7��>�b}I�]�r����i����n�pt��m��z�?�'Q��4Gȭ��m���ƈ�� �G�v���gD�SJ}�{k0�����H�?�M�8��� ���x��P�A 4�o��gm�]h����Ѓք���gJ����\��=����T߻N2���D�Bnw4,ӭ�u�	��Z�vG#�.�l�U�zS���0�;ZcX�_�m�L�cnw4F�t�J����.W�Bnw������jڿk^+�SRnw�9�Cɻ?؞�s�'H!�;ښ��T��h�W��su�֗�L��R�NH��<@b�7!�2*�����!X�Q�s&�6��0ΌA��`z}��,(�H��PsC����>SYc��PcZn������s0�QNB��ksc'Y<�Y`����!����TW}�l� ��&��G���*�Sf�w��.vA�f9@ GGpMx��)��';m!"�� ��ъ}���P�y�
R�-�P�7g�2�]@wpm�����v��:4Y{|Jz(��F���L*!4���{�Bno����������r�#p>�bV�e�q���A@��g�m�̨/�VG����^��=���*r�#,����"�-�������N����bk�1�������N��
�i�������^ث��N������#��Y��Yp����D_g���5:r��ϑ������Ϙ�q4<	:��sc�Z�vG���?Z�<�F��AcnwDUrc�p��P��5�vG��_U��
t[A_�������uⵃ{�vG��3n��V���*��ߤхL�&z���/Q6�_{�%N�P'|鵻H����%� ��7�AT���q��w�576�H�U���F�XvB��F�_n������O�9 �熠���l*�����A��6����;F��"GnG}��C����"(ARC�E�T� ��_u��,����2��R��)�v�z��'�x����W�A
����	�,o�0�K�Bnk�\����r�������G�[����Am���X��1���	z��r�c]���Id�,`�R�m��T_�q��6<'J!�:V;ӯ6�)M1�v�B�:���4���f4�c�펍�\�a�ҹo=���[#�s\�7�L�,�v���K]6�i�(��5anwlC|��*���9:r�c�՗r���o7�#�=s�c��[�+�V�������۞�.�r����-H!�;6�ۍRچ4W�L*�;�7�]4Ų�n�SK�Bnw���sU��z�ߡ<��펽��ȣ��]Ҭ3n���!R�Tg��	o��$:�����hh���g���G����� ���V����?���w;S��+zh�_�#~�]�AK�e �`j��I���<�c`�૷c@��=��y�P�H�2Z�AM��TvsA�[� ��������vdL��1=5�˭w��c�.m�pn���i��W������}�А}�    �c ���ȍ�e��th`��0�m�w2T�5�:Q�M����^pm�����Z+�-��?��*�Zp�	BH�t{\PV2�R�bE@'	J��U�ǟ���+��v�n�@�ȸ-!�.VTv�gֱ��&�.Bj_�T>�&���m�Z*�<�Rc��������� z�	����D�����]A�$�6�
ե.���*{��������v�� �&�	��������q/
n�����J\n �t4�M����zs#���9O�|!�6ƦÍ�y�ڴ�1�1�r\��X��e�*AY������_��1R��o�7:�A�m�]��*���g�.�����q�z��C�3K����	�|	�#!xK���͏�MPul6Пݡ���ϙ)c�R�C 1�1}$=��y���7��;L�@��8g+�<ʻ�c@��wf��<R�i]��A��`ye�WC���Z����&xc~�ϸƸ6�����A��7�\97�ACQԹV[�bFj
�MQ��!2Hn�m5�;�3��_k�����ҵ�EF�-�(BnS\(�;�*جҰ �ܪ�ؾD�Pm�ў#!�+����Q{ٶ5NBnY��� <��9}@�m����٪T�h|a̭��7���d��hx$���w�䝹��P^n-!�0���y��Mc�:M�r��ޚ+��Ít��5cnc4��v���hT���6F�ˉ<Jk�p�hn1�1�f@-�rm�`?ё��[Q��O�'=Sc0aʞ���,ajcl�_^�h��t�{BHm������,��Fݬ���b��։��':RcC��(X��	�M������o9F�Y]�����6�;����NԚ��i�(�����֗�ig�q���������k[��k��Am�4�ՊP[�ڪ1���V�"TkE�N8b(5���z��{���ȗ�����/Ǩ��M�����E�z�E�W�8Ơ�f�	�a�
�L)����87��-iZ���;!bFn{������`O�Hj�ǿn�#��u�ipo���0� �u��g�DE1�)�!g�wI�e��'RBnU�o�թ�e��cLw9i���"��T
@�-��o�n�L���7!�E!�B�N+:1
!�.�7�n���=�E��E9�o3[�m�=�r�$_h�2ú��)�!�6�)>z�dw,>&�s�<��Lѽ�~J� �6F���p*I�yç���U��	�d0���O� ��ƨ����w`��sBnc\����x}��<��
�6ƥ�F(��3��h^	s�.��ܳ�H��$�0�6����b7��Ht$�6�}��h3U�������-�l��^58(�1�1�tXl�h(-�&Pnc�/ѱEC�\��`������q�����ep^�3�ƺ�*(�+� 33��GBD�ީ �b(7��.�~�!j��w�A��`��*���N��Cp�� }�����O�B5Ơ�f0��X{mQ�LZ'ƀs3��,��`���h�������b�\���i�_HnÿnXd�2谿!��TrC���Lg?�mA�M���oE_%�q��ڃr�"Ao������ �]���ۛ
w>�s6:r�b%p�\l����.� �ܶXGu����ДiA�u���K�&&�AR�r�b��̥��� ���t�-�M|��M���cQ���~���ZB��ΐ`F)�1��/�T����n�t
�6ƾ|�^{����0�12�y��Ǻ��1�r#��T����]�[$�6F^>�2��^��(���8�ן�;c��{�.���q�o�+�[��{$�����	�P��kGO�r�T_i��]kD]G��!�1�A�G'+�N�)�1��/Yg�y��>��m��}>a��.s�2>��g�ǵ���U��59j�,_���:зt��w���f�䥹�9V�Zkp��f0|FiϭR�V�1��l��� }5�f�1h��/��C��k�*s�A�̀�l�����\87�e����mLZ�1#5���U�ԫ�<�~b���f0ȭ�pk����䆰}��;x)�z#� �ܦxP}�+å��N��r��a=��OɈ �ܮx6��;zG��ז8芐[}�ͥ����؎�	�m�X���a�,$X�tn]�����:��S�����R�"���a�YӅ���3Cja|�/��w�ج$<��Hm���ڗN�sl��[$�6F�r}�h��]�i����0|�~#lZ	�f�0�12l��\�a��L�`jcd$� ���o�W!�6FF�o䷮��{t:�6F&��ѨmV���4FLm�L�o��ںtd�M Bnc$U�����ҐV>�rc-ǿ�֎���S�< !�1�o-���N��
�	����7��.����1RnclͿn��D���ܾ�mTF#�[��tM��`�6Gw�])�J��f`����0����(5�^���.,�olcPs3���i�h��J��A���|��MV�O6�1�pc�][N;�� ��`�4��3\�ʌ1�ؗ����q�;MF���f0���e97r���<p����
Շ�*t^�r���ZdZ��qC� �ܪ(_J	ݵR�)��� �]Q��hr=Y��"����['��oͶ��/�� �-N��j֐�+=��[��o�7����r0��ܾ���-+���`Bna�^�߾�Yg/�@���u���a�9�d�r��%�@c��^G�1�1��~#���b�B�m������ȉ{7�+�X��Ƹ���Ե>R&HP�0�1�M���R1@Z/�Ps������T����6�3Я	<�ߵ��Ci�m��KO����m�`�����?�k{R[�s�}�"'�:k��;�;Pnc�/Qdc-]g�[��D��q���t0�S�F�7�� �9CS޵�B�N�93��F�ZN+�N��3���}�����a�Pj�%�4m�f=��������%�{I�4z��A���|��h]7��Ն����~9�����kPp=��d�q�7n���n��3�_u�eQ��:��Ì���Z��~I�� %75_L����V.��+�kM����ܪXٟ�VC�5N�Ղr�b�R�V��E�}�� ����й�"b��`��m����
ҍ�2kBn]l�|!V\l��}����ox�� i�v�W�A_����՗�-��MsSt:�6F�s(��^[p:`ncd�3��,���������m�W�;J��>%#r�h�A >�Bl#;`nc��ٓt)�w�.����G��a���� s0v���(m9c�,�]p����!�1��O�&S9�����g��!O<#�0�6���86������Ҙ����֔j�k��+h������u���
��d3�6��C������o&��t����������?#3��߇���r��<j��f�j��S���J\D9ƀr3�rW��r�
8%Ơ�fp��A}�➓�s��f�{�=]����3��˯zn�k�ҨZ����8���F�S���Ӏ���A��X��K�b���f���J08k����kG*�!�Z��(��r!�6Ż	|y�T�HѨ!@nU�e���L��r���HH�r�BS��+tց��Z����Lu������E)�g6����p_��Z�
��̋��7|���D�w�}Q��򛍹(Zƌ����(�|�DJm��	��Q��'�_���Z�l
�6F�����s֬��0�w��Qp�k	S	u��L�����(�s}�|W�TP�0�1Ҩ_�%s�`�jf�1�1җ���ҨPK�Q���~�)O�� Tn����.��HZ_�>�Bnc��_U"�����9<rc��eI�<�gm��|�6�6|��ww��sz�(�1�/�1���7�hu�͔�{����jaգ�N^�J�E�?��!��df0�odA�����D�w���kh�,����)SǊ1���\�6Z%�>M157�U�2�΍�`�׃��� v���6����zn�?z�W�|���Y�1��V�w��HV�^{p_����]��`�1    b$7�����"�d�{#��Nw�š�^G���'}��w�[qMZ�Ur���K��W����WB��s�'���^��hܔ[��0_�ƻo.��A�mQ��i��?����[ Bn]\_�G����2�	�}q5"�i[%�s� ��¸Կ�;�u�K Bnc��˒�]�d��m��7���� ��Ƹ���pc��
��ё��ϗ���k';�JBnc<�g�#��ut:�6ƣ_�*i9S�'�ׄ��h�WZS����� ���h}}��'�6�u�Ҙ��n��������9(A��q�ە��<v���8˗�&�J] �#�R�,�z,�SƊBHm��/<x-��.�S�v��rW�Z#h�w��oNa���U�?��� L������R�� �rC��nw`�"�.�u� ����ͽ��im�s
�;�������L2A�zn�}��aƽ\cFNa�Θ@W��t��cFn�:�Z��oǫ�!Hr�g���=jo\.��Nw��җR�i"QeL�w���O�
�1��\��B�r�0V�tPHn��|be��G$h��\{�����m��EgDro��o�Ӱϋ`�h����n�0�X[���͑���@V۞6O�/PH���%�,��J�0������Ѩ��)
A����8��}Dt΁��5������g��a�]	-�G`rw�>l*`Z�r�Brw�*nF�B�"������E��ͭRY�-H!�;�9�9��5n��h�����Kp�!:j��0�;N��@�*���=�S&wG-���0����o�����_���ڨ�����\rwT%7^�U�"��NI��q�?�9?_��Ϳ�������V�Z^e��f 3�u���X��Z&��}��N:��]��X~�@�!lR�Q����t�O���!���H�&�F�E��CK�4�FN�5�)�Apa�!�Uf�����	B�������&�½��H�!l�mQ��l�}���ȿ���pU�[��T�S�Q8
����i���m�;����*n�2N�Bni�Ҋ?�g�������Q���i�t�1�%H!�6j1ٵ��Q��%� ��ި;�ӻX4<�r����*��k]7�Z':r����/�Ȭ.����@
r���6����EK�F}!�;*��g$D`��wJ��Je�W�{�ac)��J���dѹP�E�Brw|�5���kk����ki�@�\}���)$w�ʾ���'�
�~>����c]�QX�:��>crwlؾTQ��׵�(�����wԬ���wt]H�m}�n��
�]��c�/��k	���M��:��5%wG?օs��x�Ĕ��^^dm����f���m��m]�#M�C��v�O���
�U�A��Ɲ�>Ѥ}�ܧ � ��ė(kƫ�^G��ВC0_�Km�vu	@9�� �:�p�}�B�����C����Q=¹aup$������D]]Ϭ'�&Hn���q����?���tx��)��V�TRc��|���8����<�2yxi�Bri��kS!�39���d�Brk�	_�25^�L��5BrmT󅞉i��Φ=:�{�>�����.*A
��q���4����%H!�9.�܃��ʾä)$W�]��}�g
�W�t#PH�[�_a�g��n昒���Sj��(k�#0�;���Q����|crw<˿�J��iD������7�Z��'�>��L�W݌UPhSJ�������w	Y7��{��R��Bnw\��6!]��2Y���펫t�r��[�f�\�v�U��5�bE8��R�q�v��;��G-{��NI��q����dS���Dp����8�֮�b��.
ָ/Z��y?t���дQ��*����_��*�?��������#��g����������?w����G�0���ߟ��:�C��[��f0�1 ��iYVb(5���t��yHע�h�A��`�������������:����m.���'k�1��Vd�Y^��3F+�c85���ܭ���N�/��Gn�������d�I�`���Q�y�u��B���k�vl�rZB�m�cU�*��/b���� �UQh{E�b�7�� �ܮ(�n$���m겂rˢ8a:&��� �ܶ8ks�׭V>�XAS�ܺ8E�H�z����A����5�0�ʒ�<��!�0j=nal�zk �` 	���n$���[y��,ancT������3�Z8���W���Ϛ�l�����m�k�_l,�t����q�t�����}Y� ��Ƹ�v� 6t��L�r����x)�JG��������������`qBnc<���^N��p0ӌ���(�� 7���Y�r�|	��������h���	=gf*ӂ�4�6��Ι��}lB+�
���:�����q���֐�A��������@�_��T�y��J����v���w-���jn��9�n�}�B��@�?�#E��B��czjXاXYT�d�����AemGG7�c0r3��s�\���*��DÌ��RBF\��<S��TrC�>n�ɪ1L�m!�6E���CHJ���� �ܪX�����*n��k���e��N���[��g速��:�Ճr�b沸5��{twȭ��}� z�!*A�}���C7^gHO����a���7��u�� ���ػ����wA�/�������� ���j��)80�1�ۼD:x���XA����� �V���*Yt$�6F^^��:�t[���~I���%��$Ebncln���I{\�����~����n.�.�_3�u!�6F��� ���b�ѓ���(��]m�"&U0�1�F7���f1+5�&Pnc�ؽ6+�Q�w�A��q��'l#�9��FB��_Kh:��?���G�Ŧe��8�:J�NT$� s3��O�*
�i��f����E-�Z�AM�`�����0x7��s��f0�}�aбy� ������$��+�5z�;ƀS3��gS�ޥ=��cFnӟ�]�	ޅ!�@r3���m��h�SБJj��k	�}6nRl'�6ţ~wD+gV��)j˹Uъ������\ �+Z�	�cPp�eZt$�E��o(�?9�
3���V�8S�Y�r�� �.��ɅГ���}�BH틭��5�T��QZ�Rc���pVnt�JBjclЫ[����	��6��|9�dۓKo�fLm��=wG�v��*���~-(Դݽ��	������Jch��Sc�v�<p�w��>t� ���H��ߙ�}�sc���[h�r��OA�������'���X�D0�e�����]|)��ɬ͂rc+��R>�+H<�m���k	�`��ڈB�6�f�di��.��g$��|Jz�KdB��NˠWS��˰�>����`�w����+�����K�����O�������JD���>j�A��`v��^}�ߝ\{n6ݾ`\��k�pj��K3Uk�Na΅����>�~�S9�6ǁ�f`�u��w��JAPRC���7��X��!�)��O<��~-�?��r������;���p�r����A�jmz'��N BnY���R0�Yp7H�m�Z��~3��'�]�r뢎�T��Z �u�]�r��n������3��-2�0.B7�Vi��NkA��q��˹���G�
f�r�ھ�͸���K�ѴZnc�鴹�O��N�\�6�=���O��� �r�>Ϳ������	���};N�[����m�G|��jK��{8v���x�o��Sh��*ge	s����7F�5_���M�?�&�J��Kt:�6�^����7vע���H���..���55��� ;Pjc�P���E���٨�'����RW����W{ݱ���S����n�
��ZJ���@��0R�1�����Z����157���������1-7��۞�U��a�g�3�����"e��f���צ^�(m�!1#7����    � ��A?��*�F^�a�(QG*�!��#?L'�W:#,��M�._~s[�e�ܭWȭ����p� `BP�!�+��%����7���[����bF�n�8f0h�ܶ���/���BF]�AS�ܺx��W��R�a�49
@��}�g_��6�m�Z@�-����qY4�@>w3r#�pg.fUw�&)�Q�m�||j�(߉�}�h����q��r	����$jA��qH�kI�KXZ&�0�1�#_�*���]qR0����(��~m{���ְ���6F; �~�z�P��ż,uuN�S>O r㬾BuՃЕ������t�ҥ���2�r�<�7��-��SH�k�6F%��y_ǄQ��Q���J6�mݧ��:ѷ�S"�휹�x]��2x�y]bI�4س ���� s3�R��3�����`�>�H�T��;8�Π�f�ѷlFdp�?�m~g�r3`_d��:�P����w=7��O!�]������~g��\3�W��]k��zp.���Ė����q S��2��Nw~�Z�[�7���`u�ɰ���'w��@�m����	�ᴣs��-�VE��3�����:A�]�˗ZB����j��=��BjY�2���Ax�5m� �Զ���}_!���aæ�u���R:��w쀃�R�"�d�	���݉w��	�������Oi�ǂR#c����ґ��e	S#��nw �����Lm�L������ypV�A��������4[U�����6F���K��z��*anc��]��u���0�1���ouҨ� 
sc����(��K�]sc#s���f�6щB�m�W�H�����sN�{�;���خ!�|B�gZ%�,Qnc��_d-�6,#<�D+�6Ʈ^���I��"?��<���N�Z�}��É�&H��e�Ub07����E����>�΀r3P�t뚵���X�AM�`M���*k�3h�|i�9��1-8zn�'���-���j�N�@���Y���"58Fn���p���6,�@r3���2�U����#��&}���\���[VBnS��W�
}��=��r��ܾ5jS�S��)уr�����������Fp�ܲ��_]�f�gK���� �ܶ��g��.���kBn]\��\�F�Uk�[2" !�/.�E�K=Ӓ*{!��u����Cs���}�r�&s�Ӽ�̃�)��	s�_n�5D�!�����9��"gl��-s�����k��nmE�s�v[d��K�;�����x�<E=��B���if�m�VŇҺ�]/��*�|�6F�ݷG�Y_ef�=�R�(ŗ�ߦT�P��'O��q�拇��ځ^(:R�(Z���m�L�QjcP|S�a�����3!�1���7�Bk��y@������qf+W����`�}�f|�,F_1����;:W!M���N��fp?�93�9i�]ό1��p�X��
Z{�AK̀�_���y2E�zp������YSO��f�/�X���ic0R3��ݾ��xwƾ����6�U�~���z %7��ܢXHxXi{bpA�ܦx���|�+�31:r�b�� ���4N8d�������������$�-��ַ����߯wyB�m�]�M����`ݽ� �ܺ�e���漣6�$�r�"w�E~��t�8!�0�"�݆ʵE2z�r� ��Ƭ��y��`F)�1�;L�th�F�m�c����d�߁0[p����(�|�l-W��(��s�|�"'-^��b�����(wt��J�ê
���g�]r�^����"1�1��|J`��GBnc�6��hjuv�UFt:�6F���ס��xI��-�1���f�Ie���Si-p���W�ObQ+�o�Ͻ� ��Ƹ�W�o��Je������g�Ju�3� �$3���/���U��1��^/#H�:Hg�e�Pn��z��B����;�����M]@w-�Ϩ1-5��в6�ٹ�0czn"_�)�ޠ�Zppn�W&.��l�>bFj��rبG�9J���f �-dX���8Op_����簛���ՃO�� �Ԧ(�|��n�mW�8� �Ԫ(E|BI���ElDGBjW�r|B��=���ZJBH-���J�8���=x�Bj[v���y��v��R��� Ս�n��m�� �/
�Ϫ!]�\k
�`R�ܱ�áչ�� Aa���(x#ew�f�l�~��6F!��a����Zn���I�����g�� �[�m�t�
е��hrsc��ŏ�.��w�JP�1�1V����5��ܫF=sc=��BV{�k�H�m��K(�:ǩ��OF�Cncl�o��J��B�m��_��2�7p���m
�����N�v/��ۂ(�1v�u8���E������!�6F� i���^ٽ???T�[o{�[�1�/ߜ�C7���k߿��a|��J��,��-��C�~���k)����jr�l��G�Y 8Zn��zơV���UFBO��y����p=jwNa�h5~s�r��1#7�Y�KzM�*��j!Hr�[�k̃P>�#�T�S�ᶇʺ �r��;�V_�Ut�����K���Dc�y�� ��֨��6;��SoHMA
ɵqU�U4�� ��52H!�7.�-�°6H$H!�8.�G(�Y���C4H!�9��:T"����.A
��q���]k��.5b0����x�|��5y"�h����t}I~�p	�Y�1�;���A���~]Ń�6L����]�L��A
��Ѻ��:^j~� ���h�?~�{�;���N���q���_�C�y.|(�Sbnw���������!���gYޚ&q�w��=��Bnw����,nT������'t{�q�`� ���a��]#E(s���ڜ5�0j+7��s�i"�C��S��	�+���!L�Q���D�	�;L����W��Gy�$�rC������R���'��BMa��7���]��P�Ah�!�r�h�%�)8��P�o�h:���`�A�����sw�A������Fr����3�h'8$7�V��F��4h�tc@�Jr
ӧ���D(��#(
����:+d�EO�:��ɥ�7rcaQ�P�
|��($��>��X[w�\K�ATrm��S�U����"@!�7r��q�����#�/hmZ�)�kRHn�7n�u�T��9ք�XH�����B�5��?���㘾c���/���	����/`{׃zX�ô ���(�\�u��ޟ������x	�ay�=��(:���>�����Vz�Brw�����V��;'�����Q;:k�v��s�m)$wGU�_���m�gDrw\��O=gER�Έ����@D�QtF$wǵ��zTX��n����7�/�*�@A�Q
��q�kZ����6�#��}��Ty�"��z���)�b_�:��U��L��UO�>;�l1��B������RB����VQ�X�Q���B��0,��L�'ſC��!�m�M~�ς�[����?���d�n7���0�C`�i��;_}��K1�����MU{�1������U}cHX� ���
������{?U%�?@ni���N˻��c�BAi��֨��Q��5�~�B� ��ڨȾ�2^8��wН!�7*ڷ�˝��2���[���wi�V�;��#$7GRs��� �Y��c!�:V�1u�Q���gDrw��ՕM�/�:�(��cUu�tI���S�Brwl�ߐ�^ܠxlh0����غ=�V��ޝ)$wǶ���n�ށP�WGL����g�o����A�������5���dj��0�;v�gn�I�ԤDׅ����i�J)���	FS�����R��{��5arw����;��#�D�')�;�V��]l�)(�=������o,~H���ck�k�?��9��CG'��ŀ�;�����à���*��g�����0��_X�����׸�ߧr�8���Z[��cC}�������_�#~��s"����Z!�m�c05k����*�2��761���ϡ�?>��4� �  +��)Ơff��� ��3
�c�r3P�����H��H�AO� >-���y�%��DN�3b87�n_h̽���cFn�'���}�ˁv�'8$5$��kѵ�]�
:R�A��B���V� �Ԧ�h�v�mw�]��Q[N��L����}��4VBH�L�:G �m�^kBnY$[N��c`7t:A�m�VskB��E��`�!���:�}_ѳ�]:������j�o+".��9�	���5p�tw�A�o��brc�䬙x�cI�0�1��0������bRpSJ��{C7	�ZuC	�0�1��~:ܭqt���sc7q�g�+ؖ�Q���[q�\����stD!�6F>�is�v�Ն�/�r�_����v�^s��F Q��"s������j�2�#!�1ʗ�7�]ϫvN���r���  4!���lfY��A���S���a��H�#a�q�9�C��Q_��Iv��!Pr��TA�Cr�#�憠��IvV��2�Ah�!Lv[�Ў�en�%�'��%�.P
�����@�]��,�� ��&:Oh��F���� �!Xu�����:��d��p�}`}��U��E�;��Ƃi��C�.��\��y%C���CtF$��3|��J�ջ6b�Brm4�wz��n��躐�M��öw���:A
��q��Ι:a�>����m��|�f�3�����?��hr%�:ޘ���|tc:p���v�;��Y��J�=�.`nw��KTM���{kp]���8����\A״�W�Bnw�>�d�m�m]��	s����}���J��Vt,�v�A�ܺ`�Ⱥg�1�r����dz#�r�^Q
�ݑvw3bP�B�//Fׅ��XQ��>�:Ve�����_3���ץz�V)$w�z�픨�^}�s����\bw�������_��)      �   �   x�͏=B1����!�;�M~�	������ci���f��/"��t0t�����B�b(f�%�|��� i�\���H"����#�Ts���m[�^�Y���7�ל����O|�A<��] �?���BKY�      �   �   x���K
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
�g�p�'�8��C�b���O�Ch��	:n@h�F�t��*�0�j��Bz����q�c��#���[[>��Ym�H���2�(n��o���r��-_�ے��Ӿ��\�~��/��&4�      �      x������ � �      �   l   x����1�j{��'��I7�5���IR� y�nF-B�y�)���Ξ(@z��
�J5Г�����=?��>7�[��Ե7R���a:e�'����߈!*B      �   �  x�͚Kn�8E�/�ȼ!��E�����
z�h*N�XҀ���x������llثD�
n�=�T�7a�R����!����=��E��V���uxD~���������VxS�pfK���2�/�a7�#�\��R���1P�]�kڴ��EZ�J�+z~U�L0d_ğ��Rlí��@��(� 7��`�c~���@Ke�_bgJUM�L0f�L�`Yd�'1U�#�F�1*ն���4��~d�H6WP��0� �Daxb�1��dE\�Z}���ꑉG��ZmT_cOb��4���@ ���ZS�t�{:���t�&=�)C��pz��ZdoP8���Ob��ĎL�J^�ZY<s�IP���͗�dל1ƪH<�$r��p�B��Z�0����稄�)�s�5ퟋJ���7�i�PH�/�2HG�kQLs�"
S�5�z_��B~��e:�1~Z*��;ST�tdb�9�k�E&zS��ґ���#j&^�Ob�8��P�F��'yӐ9ϏL��F�6
/��1	x�S�|������ؓ��t�G&��px��Ɵ�D��׍Ì�RD�9��&=�I@�4��m*FG��ka򓘔1N{opj�{���U��2-��(�bæN,6
�d��i�� ���{�U��D�:��k��u��Ґ���Bd�{��]i�#��&��Znӡ.5�>P�쁖�|��djX�ʑ��,2���IL��U�w��A���߳�B��cJ&�>�w�c-̅������<%�yF����0�wӀ��Ȅ�S������P�ۘ:i�ӌh�r3�Jka.��>&�j�Ȥ.�Ij�ا廏)��ӌ�)	��Ե0�w�<�ƩO��*d��-���wԨ�F{�/���ċԕ��5���D�d�G�9.��������k�����[�R@�C"{O/�H��Z^�,G��� _(��[�#�h���K�L�����\r�����h-̓����#S��[mC2�Z�����4�~=2EL���u-�Y�nd��pb� �p���|72�R�#S�Đ�Gk��|72�N��y���P����w'S���IC�yh�0g廑):�)�O�4\��Y~V��
R��ģ�2j7ˋg�Y��N���{�9��u�|7B�=���5#��������T����������;��\��|��u�8��U��+��7�!��h���K�b��QG�+et[�$�y�=�I#�
CsYs�|�1��FG���Ғ0���B��c2�aG&�6o�Sqs,��B�nd�B��T�9��^����P����rȑ	�x0+��B��cJ��4�0���M�d-̅���T�����L,z�ϧ廏)��zdj#�ꐇ/���wT!���M���i�E�G�Di�N�nx+�w���)q�|7A%��(��W�Z�>g�4�9�zM��&��(9�և�Kq�b5��M��PK�^;.��~���s-rd*��/1��1P�~�������      �   �  x��Y]o9|����f��&��S���p�H�ؽ{[ �g��%��E���~ő�(�b(9�29bsj���)Ϊ��h0N�A������)(��^����j��_b]��}L��7�x�)��r��+1�Qڈ�l�͵�����D~`�Ū�X�$vBK-�I�J.�,��S��MJ!e(�c��l�k�!�H�5���ͦ\vыa~{we�aet�v���`	/�v)�_���;���Y
�F��bӇ�M~���j;!2}hB�)6&��|�;[l4i����D������*��Y[=$���Y���p�-v9�F��8��וj-)Gr�$yU�*���\����ͪno�Oۛ�f?čR{	��>����g��׺,�7B��p�����F��WG��a�4�f_3D�@-ϊ���������b|J=k8�.5@J�$vu�{�q[7b# �!����_�E��"��`J��-h.���WX'��){-�Bڅ��s�X7��ǹ�y-4_rg'y ,D=�Vgg}�t�^��	x*�����|̻�������9Du*ē0�a[�$��8*����LJ-��z;����"���&�Y⢓[J�:J9��M��41NXŔz�*���%e��B�?`� r�� #� '6.�0�5L�e��>�cl򁅓�啧t�k�"���QM��DǳqPd�%�X�~�15��#��p?��V���&V��i�ț�k�%�g{����8�T���E2S6���6w�/�0T� �� ����e��wTH�	U��D���!&j���C� ��R� ��k�,��l�g�L�@�q����9�7$��čcɵXJ�G�v5����������q]�>]SVg<����C��䑤]���q.,jY����E-݁��-�ЌmV�Wwu�`�>���ģ����$k�|X����ת �B�:2��R�ɱyR��B����uz�����8ֵ��+>u�HtWw��
�8�G�}������o�x=�U��C�b��x�/��A���VkX�ϪH١F�9���|�����f��]����. �@|�t�C2%	V{,_��@zo�Sp�狀�P'F�˻����8rHꠋ/�_u�ԈH�$e��pSb�o�d'*���>�#�T�(�&��Ib{����zJ&��'�Ic�0�h��s!h1�R���bU��7Jls��M�VG������M}�����m�{]����G23p_����N:[�I���8�,�C����M��28�w�C��3����Z�Fd���I��s&J�#{�w����D�G��gJ�QӧL}� �Q���Ǚ>�pVܾ�}C����U��s6~O�t�m�O�P3����@���c7��v�p��_�ib�~aM��q�ft�� rєt߯>T�֐]P����U���>��/�.�}�k�V#�,�UU��(��I�Ҍ�5|�|���8�z'�F�kW�CN��u� # ���r�O�J�x�!ޯo�F���֣ ��fǓ�3��_�{8�)ųD5�8s>Υ�.�h��'0�7ǣ��LQ���y���-\�'@8wZ�ы8͌������^�F��ҍh5h&�y6̅��"��v���xx�jW8<	��?�9nQ���>vV���(��e��r&���jʟ�A*�I�[}V���]NM�*�-oo�w⧸����C�a]�,���x��9á_���{E;,H.H��2cN��4΅2��^T>i9P���֡V�g�Q��Q�����A�����~Oh��������8)������X����wY�N�?ǎ�������}cy��m��fZ����}��8��g[��¬'#O���,�W%"��Mݡy�������_[B��V�C����z�=���O~�1�Q����m�{��h^�s!z͓R��@R��])� x6��v�QD���L��cɸW2�\�Eb��=u�����K��      �      x���r�F�.���)���G� $��	�R*ٺJ���p�#$DX$��Rɿ�1fG��a?�<J?�^�	J�JTAڣO�H�D�Z+��[�t�(2ͮcEqײT�3�iF��H��vg���8e�?��4��PI��qU(51�#9��lbTCe�2��2R9�F���0/�1�~5�oT�M����	�e%G�8���$ap㳺R���{�#ܞiv�U5-w���0��{��ʤ�RY��^Y�ڞ΢�1�Kn�Fͯ��E���j{������8f��W�s���6���r�����kƖp��
(^�0u���礩m�~ܱM��Zv�
��q��녶oY���ma�����f�v4�Jz��u�+�7S�x�A�c�l�s�W�x�K���v��vg{{g�GƧA�ܰ��e��vv;������������$cv�4T2����өJ�F$�KYe1}�� �O�X��ȮT!�; �Ѵ4���$��U�Y9�&�,{�.����ʈ� �Ye�d��1B���U@�c�������j���F� ����_a^	L�&�.���d��+�Kү0A9�5J9������!�L��\	��eeLfU�UY>+�q0W&�B����̍Y�K��4-����򉑧F�Ϧ%�?���L��o�?�|�7�l6Gx���qD
=�^w�x`��0�o!S�-0����ߵ�1Q�t�N��Z(����ɪ���J�e\e@�D�@�7P�m>+��lJ�1_D>n�t�i�P:����ǽ�G�G������8?;�h��"���(����_.���JN@���ʸ�y5����"�HQ�U�?fr�U� `�v�D�P�*�kcUTY���\�J�oȸ�A�M`�^l�l�`\XWl���Bs*�}�3���(�sj2��9�A����;^�N�c���o���\������F�d���؛o�b7�!H��y���jX䳫!�OU�����U1����2�SP�S&r4���	�;+>ö��T�cb���t���� g�jL�׫9��lt�3Nsco��Y,G��$�a���8��0/�4�l�>+��|�����4�����`�*>K��?Gx��p��0(�y�^M��zFG��f��,U=c٫�6���9�U��8����L�8F���F����������g���ޣ�(P]��� �Y��9�^���ƙ��%�Ӈ�Ɵa�8OA��W�Hf��XNj��f�Z+����L���g����ӣE��|g�0�)ި�=Q�7��<1N��^̦ӑBB�yơ�U1>(9���Eg�;ƾ����� ���}G�?����J�2�S%K2(pD �I9�a�����'�ԯR����u+�a�� ��3�q�P���m��x�_v=�X��n=���'�����q68�����A#:;6l�<4�Xux]�(t�GE�{��Ig��%"�z"u�x�g�x>(Nw�Q���v�m��cY�Ї���ɝ!��r��c�(HB�ؒ ֡+"�8�s`W���v=ઝ�e�c�1u�4�.�
��v����.%�v?P��<�H�~׉��4�Ed��e��������w�S`c���Y�=ce�V[Fy�]�,�����]�A�U5D7���h,Ǡ����ȩ�5��r��ɲ�ȅ�����p=|��?�w���
�	.�N��e�P`' �
0�h�	h\ʖN4�"CXC׉M�I"4/���M�(�R��lǟӐm��c���Y���HB�>R����a���ߡ�t#a�(�e���q����?:4�?��\���^�t��	������XCR#ؼ}���A:*�b%j2G�@�8(Q����z�}ЈK��A��=l=*�HXj~jF���%On{�����յ�5�R�G���� 98Q[��A����|�f1�}9,}M4wY�N�|
��눎g�Ct��R����uȎ$�kvN�/��㳏c�?<"�3N������/������4��L[��XQW�q�/��l�Dդ��%·�
�*X�3�� ��,BC뜭C�l{#%'��n��,ESntk����JK���O(f+�b.��h�O�� iE<z6�2�+I��gd�G����4��{s%���\	�J�M�o����d�I�����y��$��!vl��A����W�H��U�yw0[��#�/�P��+!���_����#ѕ��ő��A�a`�K��%Ȗ��<G�|Y31l�JVF��8!����U&��|�V ��|c�-sG���x��nqC`�T%��C;�Ɩ���vU*,DIF�HL�W��z�xY�F���x��r��k��H<Ӂ3ٴUX@(�N ��.(4%�>M�����o#�f�&X��1��4�-����,�u&�H�(Q�bn�!"���Y�!-�+OR*�8J,�1V$<�1�Bfb?�_ �l\�������=�^ ӟ�ͣh��^�w��ߟ���޾��������m�/4����L�kw3O�{�~pp���ʹy3�����^��7P v������?�%����z Vk﮸���q�0��]��/��^��?��m�~�����������?����R�,l��o��n˽{H��.�r�%JPd_���v����v��	n�+O�0�!����>x���'Q�A��ÙE��%]%R�O�kY�z�h�,�7�vC-Z���(��G*���G�7c۷䒜�vLs�u{�*��r��!�� �D�,�34�S�H?rB��-Z׶=ߌ�XB-����`v� Me����{qo"��"����8�g�8�D��!"�26-Rk�"mSu��S���=G��J93t�I��T�n�G�<+	Ҩ#����_)�HNw��JM��8��YYˑ��>@�C$�.�m)��T�c<.������	����w��?�W+g���סӉ��A����X���YRr���Y�%^������1� �ż*|��,�%ƭ�8� �ES��Ij�*5>�	���3lH��4%FF��R�A9̬�Q\��X�+\$�R'1��\d!dc�3`�ڐv��Z( ��ʊ�~��X��,&~�lt`��o��4ͨ�!+��@L��H~�'9���6\V)�0���&�?f�/ ��T�q�����2 0Z��2�!��؍"`9��Q�>��`]�w�ѱw\��Z����!����$�-������n \��8u"�p�w�}���B���}�4��m��fѲ�����I�t�f�q9��l8�̇��u�q3�*be��q,K�3*L�IzA`���LL�q:?e7�
��;�E��D�w�@�|ڝMu���� Aiܻ����ǵ<[�q���.��0��Ե6�j�0>�;x,U,@�q�KK�9p�	ʊ�pC9ŀx:���[#*�	�MH'ʇSx6J���X�kFA�%NaVNg0�DƠ�A(�u<M�U�&r�����x��d����O0�ܪ�Xl�"a&��#H�*�r�n�i�	LY�y��$ >��mf9f;q|��N�}�7���?8�/u�Q,��mu顂��20R�z�j��#yF?}��F�~pq>8���z��%A6��y�$.r]�3�Y����R�C-@��Var]��s�T�u.�������1��DÍS`�����@\�'3���P��d�#����*5�7Ø@�������ؖ�O�WZ�U�KCx:�t-�[U�V6�]�^�>]p��nx*�h�Kn�XA�v��>��t�����;��@sIB�����$�G�����	j4���U��d CJ��H%�xC4���@{h6IPT�ֲ	�6<�7��mz�`�|W�C�����vG릑)@��:Vb%�|�V�V4�߱Ŏ)z����o&B~�0s���Q�;]3��KC����G6����¼��w=�3��]|�DB�|[� n('�1��tE �tp���%Q�    M�r�$�~v����7,nK9�Ce66~V�Q~��e�8*�f��I�L�
qR�1O��[��YYE���$���@�E�<���u��,��2��d�-uQ6b+�/�a���U��
~,+.�%�~t��Na�!�t�eQdWhk�X48^V&�Vt����[��,v%��K����6yh��@�f�?�4@���x�͑)�d�	�����W� ��|;��]cX�).c��WA�~�����D�۸�ưl��'���8JNn�h���{8&	fS�=ܛ�|��TXxu�%x6	x�e~�xS���-�5�{�?|�%ac&5��4>/(fբ�9�5�вN�ӽ!:���A�CUӢ��Y����0�����$MSmއA�t#��f`K���xp��{�������_�]a&���[�{B�;)�p��4Çg��}9eS3 &�d�]\W<|�z���/���N>�?�}��\\��O�>tx�0^�"d�;B��(�\#+R�<f\g�>r��հ"V2���X"��`Bh��$�(K������0��@b�Ʉ��c�${�M���R�6���>kD��(�̫|�1����#2Q/��w�c�HI{!2���P�&$JMAJ�I8��	o�f5�bQuo��'�`Y��$��0S4���h��0i�yu��G�� G�VC#`�j��HE��oA�Y!�Bk{G��S���s�(!!S��K�l0g�Ux�}x}��/�N�KK���%�	���e�\�=者SF��b�(�����%Ω0�`�����$�
,:�i$��H 
�ܚQ���gM�&���ϹRUmK.�Mr-K����Cb�`r}�ᆘ�Y<�
i��Jvm��7@6���5('�q����_	
��ȶ����7 �]O�b�]���'�m>a�fp9�l�" 7&x�OR]	 �(+Qh{0d���J��	t�_�Q�,�$NX� R�c%=����C{��ј"$��W(+Q��jA>�LJ�yhx�����Q�'z0�H%v���{:�C�/�0�xQ6A˃GBy��9P;Jp�x�nT�@5���**�+�R��XQT ��{�ܮ[p���QF]+���z���*������;o):f(N
bʊ|�En֒�'���%���+\׀��ё��[qV�'n��_���3g��5�u���d��<Ȉ^�ˁE�V+��!�ݛ���5�ﭱܰo��6yǫG��5��������J>��@�} �ܮ���|6���3��K�un�װTB�Vvf�a}�64�t�(I�V���aLI��,��u��|復l��8>H'�x������\ґT� �Y��n8xr%�i*�Q�6?́�K��(�����5�||����Xf�9���|On[!c�p};���}���@���烣��Kc�s]pk�n��&�c��i��)}�t]'�$��ƾ��*
�(�1!&��(��0�@�NX���#vC��>l1�@"��>ͷ@�(o��P�"5��L�1�0G��uc5��<���Y�ZY�aG*Q)����NҸkG�嵐�wyk��۱��/|�#���!�#�  ��al7�
dbv�,�$�<ǖ�
l��\܀A�W��1�xx�1�8?��&�>���������;��~���i��	�s�޸�m���� $��Nc��V"	:2�)�g�iӟ��x��<�>�+c�i�Q\z�b_��&�ܑ��^�o���S�S��,F_C���촃+yz� 䤀��)����0"ı��1�c\��lSW�9�ogL�D��[02X���j����q1+��E��6� 5U�p;n��[��[��2cXC��?�7@����D�����v:9�r?� 2��(/�͙_	��Q�DB��C�J�n�AYi�X	։;&�F2�i���9͑ᅐ�D&�9 A�E{@�䮍�@�h2��و��0M �c4�nd��r���$��٤������F�F?n:�x>��;u���1υ3c��9�02��[�*�^�<�Y�N.Y� ��"ˌq�z���Z�`�,�-R�
�> ���h�İ�6���1E����d��C�a��n컦�i�sb�J���KKWl_�Y��bD�X��0rxX�R=�H8^���
��ZM�>���&�%@G~S��
r��:;V�v��޳��C4dl-�UR���f�{��R�>��@���U�'R�[��[�զ����t/�J`�3�<��1���D�VS���d���}��!S�;�d��@�e�}V`v�� T��p�8G�/�3>c�
��(ʝdR�@�ZZ �����6E1�Qr�i�Ɍt,J�N䴒QF�
�]�զL<���1�"��T' ���:�w���������c&����*�����Rn ��@��暔�J�G_=��~paYn}$�U��uA��+xe�N��
U3�(�L0�G�'޲�t���愁��ŵ<�/:�+��T���ľ��e��`{��{L]ؠ,.���(�o���
�OXu7�}$xa��
C��$QP�J�'P���U
��Wr�M����*�01����\��L�R������<���l(�9h-�}6��'�q̲Q�QV��\U��Dc��!�1��-��0��Q��e�v��M�e�$�f����t�ZM`"@��l�Ã��*�1w�x?���G�d|�s�@ �1��і���`u��`y���`yo�`o�8��u����4����0�����ɋ،�"Š�}K��3>��33�Q72�)�q��iy�hpc��N"r�������W�!e7��	h\ҡLt��*��r�uV#�J��n�)���-% f���J*f�l<�M��IĎ�:7��Z4=�Y�����[+�㍡y�\��W*a=��%g��'�˟���E���&���D8;l��G�|���>�� v���:�B���eT���+�@�@p�,�@l�y6��Fm�O��%h	�t���RQ�NXV[Jl$��O�N�k��.��e��w��C3�+E�bhF����i�N��li�D C��׺���q:�/�n��㭬\{�8Ę���B3����!H����zҲ\��:�+�n9
4D���|�
d6Fx��|d�xm0Y&l�V쥇��~^J���o/K*^���t�o�x��w�N���������'��rG����aٗ���$J;^�N8��&����������t�'���:�v/.N���%��Nw��$��j�Lx��[��d�bپ���ICنfua*ndFR�~�')��_��v]ڱ��ٱ�^`��>����pl�n�Rf��; %�k,�1E`{��)���ԊP:�HUO�����ƶ�T:�yod�jdg�������Ivw�X����0I)���F���(IE�&��Jdg�i�Ё�8u)wlZ]?J�ȷd�	��D�UR�_��㧻Yc`u����p�T�?0AaE&��0D�=7�UA�P�����i� ���%r�1Fz	�����$����nR̬�K`.�ƹ�8���J����U�b���X(*���U�tO&���ݺ��j�|~t׌QV��8@ą4��Ҋ�gB
*�j���ĳ��ث��v��6�"G��b�����p�3�9��L&�;�/u�)h��&A�p����~
/�K$s���:�Y1Ϊ�&ْ�u1���<�}<a�{п4v�.�>��k�?\\rZQ�^_A1~"s�᜹�z�?W�D��o�U��h;��Nޣ��S���q�&q�גY��7���]��"�1�	16�~���'�oQT�N�M��"O�v�āc?����8g�.�xQ�h�K�� b7c��]k���u������u�;�7a�=�qC��������4q\���YC�ݤQ)�(7�����C��=^�R���=U�zs��Lc�d��7ٻ!��=����l�ya�O������ӏ��Ve���2𧲘;g1A�1�⍳�l��Z���Y���t��<@(�����s��᝺    �e���`�C���̷*�u�xD�
Zz��gm*�w@�BTD�-�����!�?��m;��i� ��R�/QCNL�ҹ�)E<��k�o;V�xj�u�$��-8P��RO��دR_ �DZ��{�	Vт�D���z>��B?���@KB��D���h�N����PZ��:�����M-jx<�R�D�b'J\i�o�J�����+��~%�P��c�=�6}��2���,Z2�VX2h�8��0��Ķllq?W@_�_�Ӥ����h�'�hid��CVXV`����|�}8�R�@�RFf�mD�4��w3���P�,�Q��n(�tg���J�~���S��+��N�E�	�<�d�Sk�̯Z�x@M�/dJ�cP~��/"�m>�XA��J�Ԧ%OgXޠ������j ��a~׵8�w�p	>�A�h��>���ǗGlx�H���	�,p�ۭ���w��r��a���7�r?_&���A,ϫ ���}i��s.�ښ��̋b��O��<e�p��'�k �A��Ht_e�l��$f^�n�>�ꓸ.��2����!n��vӸ��̗�h�rV�7�f�`}�u�0>8ӥ^���S,ʺ�R��]�'� �Z�g{"5#t�uI̮�����~�Q뙝K9�fF	R���.\�O�4���*�Y��q�ww�%)zs�N����D��*	8��	\׳����!~�'<	�>���E�|�<��Kb�w�E���&������������OhH��Ұ(X����5�-�����寮�Y�o�A�{������r��.H� Gز� ����ǎ�Ra@تr��;��Vh
��[|w�
����*U�n.�$�5�f(Li.2y-����ŕd�Ugł�v���p3�������/���V�3��T�&�Z�j�J�n�� Ţ(��� �nON�,f|�y��-�Y�&㭽3bǶv���M��'����&���Q�����H�n����T&�9��3Z��u�{�%ԃ�����t>#��>l��P�����������_�@��y�x�g��2V��u3���"�<?�R�B��r���맦I4���V��m�L�G�Xh A�%)�{'�蚩�}�\>B�m�\�&��i��E�i�E�X�E��'!;�G ;J�C��s���0O����I��k�F�)ͱ��Ў�W"��%�9���@j��<R�a����O#ND>Б,��q�z*х~ţ1�Y1�ida��[J�{��j��z��"8X�_�:oL��^�cD�nl�p������Aũ�V��8���*r�����t��M�i:�c�?�*�� z����0���R��U:��mF�i� >X�f�i���k��J;~�('��W�6����(pc�MR���0���յ���Jo����d_����w�2߉@�p��M�w\kǲ{�k��ma�_������X�+A�Di	1*�6��0��099�/�ʭ�a*y"�Id�~�
�E�72*�1BN��ZR�ؖ�tA�w�:�!�ꆩ�KSY2�Z����)���}06F�ȗ��6�<,F�ǹ�q(�����b2�2;+�[K?�O\�,ɪ� �M�̀�@�IDn�����g����K���nʥ��m��͈d\�����ߍ��d#�i��*���gl��mu�R�.̣�;��_n��d��8B�����g5��u3L1�������Α���4��PĪ��^�ϯj�o��v2�s��Iy���B�"k��v��W��Yϥ'�C�;������W��!�5�e�#-��T��:���b�1� �t�"5��b��Zg/b\{r����
a�6�<Pg���.�@~�_��i��j���We�*ʺ�v�@ܓbwp���x5��h4��ˁ'�@���5}}�x�ǉi�$��ȱ�����M�
i���A���1H'
[$�&aS�"f��Av�r���C����۰�Jb9��"�y]�R�<�z���zi�O���Ȱ^##cch�E�z���	O#Gtv%�{y1�!��D�4�	�e�1\�����2þ���1�h�Dwؘ]w��wݺ���:�f;�',=�n�gc�lpj�;?88>���C��& X�-s.��+'����'8r��&��ni���U��w��]Dw����'�����0t�q<T�����M����>�Oz�hm^BCo�����3�o���ٷ�,���h2�Hr�ۓ�$��I��(t��)Ǡd�ggj�{tz��{�]�ƳR�;�Գ�t�bC�I��3q�&��6�ԕ�\
J�֋;ɷ�2�q�7�eĺ��s>r:�?�M��0��K��F���H��:�����0z�;���nj��%��%�^̷ϊl+���?+P�7N�46�t��
�4�*0Jj�m��t%�?r�!�}r&v��f�&��D���ǝ��Mj�t	Lp��4��[<5׆��+2��I��v����5Ju�x6a���:����Щ��x�bn��MY9L�X*W^ti�FV����R��r��Y9�Ӧ$Xqxe��Fv��HZ/'��[dct��QG2@��Y���7l/?�@��T���r��O�}��fTZ��D���g�y
]�	� =`����񔈾�J�<S��h�@�ʒf���D��U�i���/r����k�;��=5C���S��!�C�\�EJ��"�I�v�~dFB:����B
�7�,Q�R��'+9�F�-ZֳA����8�դ�t%X1d���.���@� ���7c&0Y��A������,�&^#¶^աf�������|F~ǃC�2o�S��eH5:�� |C��M�W�=�N����T)P�G���	ܖ"�/H'�eע{EĞ�j�r���� α�x��g;.�H%u�U+I�V���S*��ڳ0(�M�ól��ڝ�k��cC���bsEL%�Ɔp;>�/@#��e�<���p5z�t�h��;_SDq:�kw���^�F�I��C��a�3=����q~��f�I�I���?���cq*%�²�᜺iqK� ���"��vK9�Y��_�R]�TK�� ����!~A�3"�ȍmg��"3��qj	_ĎgF�&��M}������v88�x��H;gG��x9�ux1���~_8&5?q�Վ�tM�<Jl�bpo�-n�
����1u:;&z����k��6��C�A ;nx zW��P�zn���)�n�$��L��.@���'t�,�7��h�1�Xv=�v����!��m)���l0O*�� rd�Ʀ�h-�_l�y�c��f����l��J�Rxqe��j֣�;�&�{Ƕ0��(s<�
�8hPVd9qWD��1�~�+eA'���&�����+�0��+�t�?-�;��7][<W��bA�
�I��
�B��)�D�T��KKX��M	ؾ�S3��Jn�������ᆶe��%�;C,<�,e��e)Pd���;��G�@�O�w\l4�	J:��4?��\���B�yo���(��h> �Q�4Q�_:�YKOÖ�C5��z\(�xǤ8~@"1�S���q�����ܸ�`�(|d�D@�)%az�^#�L���1��n�L�|n���%�$s���xJ��21�x���0��P�`/�jF�j+�2�	�e}ka����	g횹U�L�`
S"�y�09���3�w��0%b���~�����E��;D���nt�<�c,�}Y��.!m���Z|��d��8�Z�qE>0�	�㧞��n�)2�n*|i�Ԗ�m=��>g�ջ�KÞ�G�ݧQʟ�_����:�J_�{d�~�n�fќjL�Q�%�~b�v��d��W��x����p�T��:�c֝�C5̋	���9ˑb����-���{��j����Sv�i��s�ɸ#T��Qn�!ڭ��W�2KT�����	[�w5)u2�OT�p�
�;#.�����@	5�'�;1a�*�)9�-�~]�u��و�qx<���	�ӈS��D���=�U���,��&�yYa�bLW{=��[���Q��v���"�VK�88gZc=k�v��|�    rĳX��0��N]ײ׎�d90t��`����UR�I�<�\|���0��'��sO?i�?<;5�a�������!��u�z�s��ZO�a�8�k�q�)�����@��G�.a['5o��Yk�
q���r�����d�F"�t~�	�ZS�������ҍek�}������n��#j�	��i���qtr~6�D@����i��.4	&���mHu�뜏f�9��'�,ScUKΊm�K�l-L,3B�u$ ��w^��1����kыw/��{�^�I����'j�t���S❯�$�+#ۍ醦wM�����1o�w	 �sÞ�|G8Ϥ��C�2Gވ��7�t�{�E?#)C���\O|-���ƂqRa�o�:@)&�{�s�3\z�%��� a�Q�{YJi�6hU���0d���ųr`��9��6l2od��9m�Bw�E���p)��չ�s�.H%��{=�J�v��,	nk��9�_�Tt^e���*gSh�f�ӵ��Ƈ�H�G���&�
1��cT��؉E�T�sKܤkFv�i��a�p-������e=���jI�a�ɪp�m�P�
$��s�|WuCIa���f��߱���N R��U�>����iF��5�#�U"��q!��A\��Z���Bu��p-.7�}��t�$�2����਌�P�������`�B?�к����R� |�=Q��_��_��I���O$�d�pK��|�j��3����][�ݍnb��7γ�eڗǶb�F#$C�Q��
�V'�
�]Dr�"��LB�(���C3G�ʒOzƁ,`ܥ�q>SË0ǿ )Lx�S�pJͿ�b�Iur�(�\��T��%+r̡g�U�E�e)H},`$~�E-�FEԖ�ڿBy}[�����P#~�^Z���o��	�QQ-y����g�9+��8_=W�na�#v+e��V
����3��࿞iY��<S ���s�)�Bi�6j;����	�/`����jl�ױ~b�F�ك�h�E��_���IKZT��]��e@Eq�j���4���̍���_�W#�	��v���¦釭�V�c�;��3=��w��=<�m-e{6�cK�0ORY�%�P�u9��.x�C��C�h��������x=�@y\H�"�N ��P�W��*�p�����2@E;����p5�0^��Ž���s���J��4�"xt�h���j��M]���Ff��5 �/Q��w���`8��$g�=;�-�~.�����~�A�ƮE>�e����'i����^J	^�z�����fД��lz{z�����ɔ\{	Q���7�OL�s�����%������f�$v��*�)�����d�BL2/���9�-mr���`l��r}�׿}���qUS��Ц���Ć��O�D�"
�a_<%��\ϱ�&��N��O0G&q� ���>#���z��3 ��]ǔ��M���SM Q�v�����D,T�ת
~������ �2��p���:i�iR�<q6�N�]ע��e����-o/g��A'o �o�7��&4o���/���{�fSyJ**O���f7��`id����7MÀ���vm�zF'���e���:f,�Η�Fz�LX~P�i[A�h�_���4ByK�~-2ס�L�~C��D��M�Fא�OMGe�^��֭%���Ll��S1�|'�_��伊�i��!��p��\Z�;�/X�� �B$���Ƣ�ow}ߎ}?4S/~]��Дv�5�U$����@��--��p�=�wB�>7������}�4�i�!�jW��0L�.-lZZb��,n�k��
<�H���.��D�������y<hfZ����i׍|�8�����Z	Zc�1��n��q>��й21`s��$fLG�mq�#��H`�E�7üTܳT́@%,�D���5����f�R9`�ꁭD�~ߞm�>��a6ɸ������p<<RLϳ�����@��{�*�C����OU׏�ȕqj*��P�C���E�m��l�ca���I�������#�F���x��o^�۾�8!z��� C��|D�NM���V~�h��X�~�����V^$�D7h!�0��q��0��E��ׅ�"��5�M!�Zc]�^Ac�Q�n6i �A�*
|�,+t0�],d��/`��0R0zxA�iGI���'��&��,y�f�~�V�p������(�ޞ��<�u�D� �c{��<��R��=���F�6�6�5�m�2p�l<Ow��Q��sOypf����m�n��fn�#uV(%=ց���q��^;�g����}ו6����Ů���(�q䧋}r�زwL��}=ʮja<(�]S�Vz�H�H}����:�h��H�ʲ����Y��sg�n�W<�O�`�A����g@��w��r��.��Y�A:8P�$����F��m��@V��@d�h`�Bݨ��a��"���s�Hf�\I0����"�����	��ƣl�I�[��;աU�a��y��T
*���FN1C�Vn�*l�ҌA���n)H!V:�7�P-�\�RK$�0!�o�b':����W�)��� W��.�W��:�H=rJ0�yڝM�r���K���n�wvFm���m|��<�5�w�r(+J�F��ۊAd��|oXBm��40��m�?�r!����~��V�#�Ҥ����Ѣ]�K��Bq��2(Q�4��u�{}�x�Q��l/r��c�D_��Ъ]�y>-p��Ir��|D��[��8�ܶ��9�L������J��0礬�K���飊[ 8�g��t��HgR����|pD����:�f�{<2�4>s]g�N�^9-|)9�`��@�kf�[�k�@�Ŷ�.x��b��<7�2u�t-Ҽ!�eI�0���	�>]�P5���k���H ;߬���#�H����0e�y^l���,�}̞�յ�39N2`�^�,MTbq�庐7Z 7A�����1&�PnJ��ѭƷ�}�JN)S&O@�.P�����?x���!�Q&�NI�=��'��No��pʔX0���P|s��f��4��o��@��G�ϝ���9���U}z��d�&�3�7E:��k�NH�\���x!������5��_)��k��"V���8a��������a��$2E�
�±��O��M���E(l��z�W�� %������C`������˟����MW[�ʀ�����i��r�Y����-������6d�g�m�憡fՆ��*C͚j��?Z�ezp%��{AO|�륩tC�OcD��m�:�9J2�h<�MP�]*ٹ*�Q(At�|^N�ʩN!�A%F-MIT��$�F
*��Ĕ�#ХC<���=Yd�k��G�9����JcJ��D0��]��iFY�r6*�-�_o�4��?1��a6�oQ��<��&�-��7� �3��_�!A�f����[�`</+�����ӏY�����?����l'�]5�4cD�N#�X�1��D����#n�	��7�n(V�L/��$�T�� FК���
��lp��9�������	�X���C���qy�7>���������G�?�W����`�㘺>�C�Gv�*���D�U�mF����[�E��=f�*Q�-
����Z���^��Zv�)�4qotG�0��n*��K� �Z��ZXQd�;v��<����}�_�n "�B6�
�4��P�/L76�Z��8��;�Bs?��[�:{�{Qk�p�����\ Ǵl������O1-΃�Z��8ӻ`ǔ�v�-_� �JK�(K��V�����y�ZAm� b�(��0�b��bS�a�;�����=ڕ�@Gy:�D $B�X�00�v@߁S:v�'�R��Ut��6�����އ9bR�����qp�ԓq���	'N�tA��"]t�cn�2���D�zU^8%�-\��_y~��9aJ+���H��+���J,!���' ;��٘���#�^ί��A��fpw,3�^d{iZ�Ba[�����z�ǫ�Z��%�O�NXD    ��ȍ�i�^�ݬ��ݷ���� �02z�?,`�	c��R���&]�B�}z[���fף<F�#�q�y��].KݣPe�d��cѨ�A����B��1!c�nʋ��-���QYeլ�-2AU�,O�q����A��nl#�෤���"\3T���ïFV6|:��4��4n��ы�q�tR�{LGk[śV�2|�!�<����iV�A��	��o�:����}<�c��� �=�_�G{C��'����9(a�����2g�3	����:��t��ҳ�߆����F�t��;�;�6&w��9�þ�1�D�s��l�����*~�F'�gw��:'i�!|}�W�魥��H�d�Tςk�|Z�?~ą�h��eqE����X��:)�A�eDE�\���
�b���w����O G�uV���pip�(�^��֋��B�`�����Cc2+�F��0�;�>�C�~,	��;|r�mq�u�� !�J9��H�{9��V�r�2� �bU)�cX,Ņ�鉕�B�m<�
nj���a��� ��0�?��1iX�X�4R�w�Y�&����ԅ�=c�84���-O� �M�q��(��^��#̴'������k��]	�)�����+M��=t4�����'��?��S�ș'ǆ���ݳ�cc�q���A;��s�6�6�E�@�U`7D�W]��7_4��,o����u����F&����D�q��ǔ$"b8-9_N<Dp�o,�nl!E�Ƀ����ο�����3���Ą$��M���VF�7��ֳ;��n�c ��N���q��5~�~6v?5���'�wx-0���J��X��~���˯u6��$�R�K"�Oo\`��-m�߯#��׍D�����I�;�	��h>������>�¼p��{E���"?���W�
_ݼP~��.�#�F9�n"��5����zJY�j�[]�8NϷ}�{�ăC,(%v&Ԋ=�Qc�oaS|��-i����O�������҉՚��T���t�L'v=䪽�a*y���T�\�E��x��h��,���N�n϶�YY��vji_�T<�]JAM��\��D,X�d}��	����n�l���B��� I�0�:Bؾ�0�$�YT�C�:���6�^�<���H;��#e݃ٸ��k�����K�nk�zj�:/�S쪗M�V�T�(2@x{��nS2�J�Rְ8d
Se8�m�ǯ]5s��j(�f_R�
�o�Eә�TV̽63�cSQ忢M�۬d�� v�T�Y����2�&W�wt� fY�7�4�6�l��zk��zd�_� bf�,a�f�03�*�q�����Y�D��B���`a@]M�3|�5"|�/�G1J��Ň���˳S�5P)�õ�vXV�
;��x!Ǒ,��	�J砙l�MO?ϣK�1�H0�@L���ykɢ���9��"�r��y�8��
 .-�1�#jqN.Y�eL��"h'XǺ1:��-gW��)�tX=����tY�/BE��`� ��N]���3d������E�1'3V��c�rx���ѵ����Puyws�)�Y򘐎]nu0�B7�PNb]�A��8k	ݲ�o�}y�c��|�P�Ys��BU(�m^X?���g�G�itE�/֏'�<��0%��"�ve�"��W�7�"�9OX![TF5 	���>Ҭ료h���o�#Q܆�&4��� @��|���%��U6�hf����c=>�=���+�e����������8&(_n*�Z��L.7+�`E׶q"��ӕjdc�K��v��B����͜���2�DYݒ���K��BN��E�:(��L�)Ν�s�
�����e�����PJ.ݙ���f�EK#y�m�2%���4���l�]�F9Z�]>Q:�]�M٘`荼�-IO�\ٛ$���R�uҴ.a��`����P�K�c=��a��0*��s酮0���C\g���I���rn{E��*�,[���xv��3��O��?��7������<���4��B�#��5͟MT��T�˿��#m�.#4F����
2,i��;�Y��N�p_cd�y7ƕ�����e�G�Hr�D�f��lF}�µ�h������͌Dʉ�7bŬҵ����h�>x�b�RW9�JO�5��<��a���U#+	����q����}�jwm�[�G��4Z �\xa`ʴ6�3݊g�(\�q����zsJ��ڴz0$��O��pҞ�7Wף��
��HfO��3;'ٗ�;�;��d�}������zX��"�y*cD�A�]��U}�"��$��Z^���m"��+�:o~�3���p5c�Y=(�����*@1�9�(8�����/(p��В�
ۻʵ�94i�C���H�����2�A�f.�W�H�2�k�郚�}�׹G��BS$��y5.oRII�z/t�l˘��j���njr�Y:�s^�;�#ɚ3�0P���G�#�X�,��-X� ���63&I��9�8jގHt�?�H\K�x��5"��hg��X8�u*r� �����¢J��6��֥�[c��斑�@�Uu.�����OC,m�3a�J����r�h��#y��:�SR?�������`])>�U*A���u�����~�8��-��d$�5�|Y��BN�<G���)i�T�%W���|�Jf�a
�UIw�W�"!N�x�=��5!�m�^K/x�����g,�`�j��ҏ驼ҳ��
��3�W�Mv�SP�eS����S�Q�d�J��[��^8/@�<����ҽϺGt�8~G?�]���ן�;7ͧ��R j��X�u�ɚ�j3��lB�D<C��.af ��Qa^$*n[
���5�14� � ���g�(&����C�O#��(�[�d�8J1�`���(����D�G96N�J�C����}o^
ȰIH�;p�:�Q�u����o�,�Xq�H�6�4��R�R��;κ�g],�դ``�	��攳���
8a�}5"���nx3���W�Wǆ~7F	W�=���{�C�"m&C/�9U7�*�9ft�K���W�Ƅ�����D}�6�p����`��"�v��-�a�_i�6^ia�����Vx�@
1Tĝ�vsL�h���?1N���g\vh�8���ݳ�Q���n�q��r�K�sQ��L:���?f�� ��0CB��X@��YBn�����rk�[�1�JK�D,dE?|}G�[���,_��b�&,��l�0m���b��H�&��;��P����H�5N�R��>���sD񜐑�J�r��^L�W$�?�Zg�zT,̚�/.�O���ϫH�'RnA�\}�MlcW��չ�Yp�k�F�ȯդ��������@t�)���Cusk�$i]u2��ԼY��`�BǡB�W�Ց�ۆ
~��b�%4�*ǃ�&�J�%����:G�gm���i)�:�ƫ�L�],Gq6o-��;��[���&eg�K7�\m��ÕY\�"��&����`H�Ml����QC0DT0([H������=��//���joe���Ј��}R{�{��[����#��U�8��9Q �{�KA F;�bf��V֐�c�%c�c-�����̮�F4B4�coGV��a�ͩ�q�)�y�"�`���=9��p�@��9C�(�;��.�FD�Q(��ј�(�7OûV��X�*�Jɞ�oV��� W A�����p��1Dm���u�Sq����+��0ΪbV�$Gog�Q�V���1Ǖ磱�NN���#ō��䦕��R�l�X�����R��I&�x��o'0�1F����u�[&U�TO;���t�>�e{��ø�~c�@��S��A����5�)��{��;ȔX��t�'�A����G}��uF����n䄺�_�^�(d\�rN�.��[�p0F�m-�h#	�L�8�-���EE8:�&�1�h
e3X�XGDr�1�n�1�f&%_2�l��Z�D�G���b��*棱J
�gW�T�d�ѸE���6���+��_��=�:a�yzP���������    ?�qu(,������q�ĵsC(�z��k�(���������>�B�Cx�D��J~Oz�'Jͭ���=LX�l�[ٕ���� �<�!/�y����n�1W8��D��;�Q̢�%�l���0e�R'��Φ�;�p�VK�����b�זJ�}Ct�\�
��c��G������n�C�������ii����_�P�4�nW�O&Hiy#��4E)�Xo���׈c�w!�Ǯ�-�>�U���#�qUr�xg~b����Q��5�����ޫ8(桴$����֍�4��T�󯹃t�Η���5��I�'-(of�ލ���k�ƫ��>�F���lN;�U��l��2kXůؐ���i��hH�1;�ﺞ�|�4OT�,�sqz~n�?����Kco~.���p�敄I�1����x�&�*0|D����0[4����B�vV|����3\9e�в�rAWM�߷��9&�Y�d�kL���C�=������틩�
>�bL��&��PfQ�R��rn�o2O`�i�sN�����~04�_M�$����/}Y�xT5,��?�]�=X���"D{�w��v�M����xF'��?�_\�9%���{�@�{���b�f���r�����PC&����a�2ԓ��W�Hf��XN����x$�����y��[�l���|z�h���l��������^܋�S�!*����^�8=�<�!���t�=އc�?�b^&$Sel�JrZ�rRNuNn�/��:�LEH�V�����K�k���"�@��]���X���c��q����8�O�����ALOj�a�����p����|6IX��2"55��,�����Fx�1�:���,�o*\�G:�_�ZR��$��J������R�%}���^��'�`�2���-m�Jʧa�S�}��%�V��k,~�&��l����u��|*�,�
&�
�S7-n���1�L�IkvK��8�Ɠ�~�5ȝ��EY�qUt�z������}{?;:6���A�Ë������zjﭳ\;��W�,�1Į_��w/�Y�i��Z��'g�h���ޝ�|d��0�����I#z#���n3�1t4#�i�������vK޸1F���1�ML�d�0��A�K�R.<��y�R[:rǷ�����xȕNp����� �B��e�U1�\/��	Ņ�8:�^�BkY���9�j��w0��cT�3�dt-jҍ��r��г��=����g���ѩ�Y��k�#�g�>QG��숅>u��ܜ)�V7d��k1,O+����?�?Y��3j������_�����`��QKm&o_<�`��/����z��9-�������~�u�Z�d1�'1`ʎ����x|qd|8;=�����?9;9:>0��]J��)�7�Ss���2y��Ĳ���pN`K�x�__�U ���^N�����pN�t�4`UX�;ah�Ņ~��%�����a����w�~8��'���[�u�0�4�Jڠ�=��.�Mw4� PVWE�Il�i�Yez�7߇ݗƻ��>�����S����md���,|�����&�����c�H���U9��*�%շ��G�Xa�_5̓-�����@�8��:��&~U�ס8�L�R\ԅh1v�u�!Z�y�����X!R�'L�}���B�D�%�X�I .q�* /"g)Bܠ�W������G}�����h���{
��ˏ�����~�W�,�qx��녝�Xf�������I���\��4Jv��&A� ��t����l�W{��55�(#d��Ǥw���.Z��ͼ����"J�KQ��E��LIN�l������z���ŃD�
$��`�D��'A����r�I�<*�#@��+Y]l�0�����\dYb���HWh�=z�lԕ�
;�����S��ݼ�*b+���m�&�k�'�+f�OZCwvl{ǵz��؞�L�;��H>���
8�{!]`h'�n�\'b��~*�@#�9� ʠ⑑'��������A`���D�����i��)���HA_)��a�~dc�s�G��uUj�Q��8VĐhD�A~����^�Y��1� ��äs.�_�M�C��JN�ׄ�{&,9�F��~��񓲴�M#<�1A��娿�}�)�3����r
�,��)X������ L��bزSO9&"ͪy������_���af�c�;v��c�]��#�2�D��@��X��f7*���f*�\���2����ks��uk� �T>8��l���K�d�^�q�R��A�u��}�#��n�N�	��>��{QܕW��c]���&���m����I�yªn[GRw���d�n�%ʓ[�1$	�
^�і�`c��h�ϔDP �˭g|��j���r2��x`Xtt#oTƅ���WVu��g��JB:�,Q�#JANw[�)��D*͋�c۬�����u����;"�9��`�F[A|�0p�-��IF��t#��i�JJgN��j�Z��8�G�T��zɃ��Gƻ��㳽���Q�{ ���{e\�Zؼ�+�P�D�)������t()n��%8$f�s�ye%^�(DA��������t��WmB�J<䍡N�Y�J/�Sz����X��+��IA��]<I��_��:i\`}&�>�rK B�ƽ:Y��x�ǹ�d�O�+��9\S,�E
	�I̷9<7�B{M
Y�M����\=����%	�&n� ,���������D�� P�ޝ���}��'P�xc�2�3P�\�-
�HRlǠ���.�ܡ#�R��n��D
�
�es�bm��@)0�TZ��-"SB+Tة�3��] �:6�'ybkMʱ(��;�u��q�"��O�[�X۶�/^g
sKX�,@�����q���5��D��������F��B��ښP�|�jØmC�m��,F㣫��)����6Ƞa�6�1�E�3�~Sec�lØ8�l���J\0�����Y�8�[������ ���TD��%@4�NG�	K/�vd�i���l�!�ᰧ�!��H�$�= ���C0��iѸxΚ��8�]7q&V(���Q�AWx��3�q���}����r�Z�=�;%��8W8N�Q�`a8G��v$[uU��6����SRg���w[n��������!� G�E%˲�:x$�]��":@BB�$��*�U?��'b&�o�n���M�If2AP%҆��ݎ�.K�H$V�\���5S\3�P.-�ZK�U�Bf�h�To�7�c�+]of�5|�Vg�<�4����F�
ۦ|�vu�2E5t)O�QI��ͯ�h+b!߾R���a"�Y���4��	`0ao����"qY�K˽�-צ"UC �5[�#0�C�J�pY�
Ά+��>#������{���)��C�v䇅���1�f?a�?K7��o���Rp��7���|b�E`ւkOO�=^!ܢO����C��|n���H�~���k�|�i��^�͙�m-Ivc���J��l����_>_t��ym&�fVI]0Y)�	Os��|w� J��Cb�1��l\!X,���;6�v�T�n2��|�� U]���A��kfQH�oTh&���j}%�^I���B�smi)���d�4�<٦��;�j �M^�
�1XlG'�m�Y�u]������Y<c��.��`%xC|���N�]qW�d�G�%��*�ڀI�|(�!k����oX���IU��z��	:8��A���&��P8������G��Ve��ax�9��:���|�ܱ�������)h�&g������)rH�s����"υQ�r/�����Ĥ![�S�85N��:<��f���%6q�\~2���YsG�����D�����r�������D�ߒ-�m�QqP���O9�==&	�`&W���<����k�H֛N����\J��6�;�9�������HX�qƇ��TJ�E�DI�.�ew1�i��U��f&O3�1b͝�;�/��'bE�L����.�S    ^q/�l��@h"��6أ�"Б��2Hz�{�5F	BkN�n������M�7S��MhnCN�}4"�f��ć�=�;�^��ˍ0��φF඀Y�q�L �[�a��{�K�#��ѷxsqx�ւ������@_�����k���߲�~��??��������{������-�[�r�5zM?�z�۵�{n��퇡�T�}�^"'q�t���Z{�c=Ƈ��gX�ñ~t�P1i_�#��l�\jUR����� ��]��``]��'�I���
�� �E͛	���Ŭ7��S�+�b}"U�c��r4�8~�:ɹ��k���0ҬiD�j�.Jd�i_�+τ}K�0f�o<��6���j�!�iJ��p�D�'�Pڈ V7�yCԣ�rǺfp8b_��S�Ѱ̚�[ <qmc��og��a��1������\�sw�!0Ķ�-� ��%���F�4�<����grt������ ���E�E����	���k�B��q������R��.�x#�/��	���}�297����ť�⥴c��LTF|(��w�9����ۅ�0!���X��-�Wԩ��u6�p;�<X�	������I;e��T�O���nbI9�A�k������}����_cq:�o<dA��C���}~(%��t���*�ڸrjh�1|��ړ�k�	����8�<��g�eǆq�p|V�#�c��`������0�0�P��lR�ݽ�R���"K������5ϛjc��0.�	�6�Z���_�]�;����ޚ��0�윕�=W���Q�y��Y���dNy�@|�L�t��a�y����*'�L;�B�n�L��_{q1�.1������_�ƀ��{�5�\,RFҺ�H��BU֖�	�YY����8���ri7�\�+�av2��b�F���d*��"�t��ªtX��Pb35����t�X&6%��Div��.���Ǿ�xh˕Dm�Qe����in胭x}�ˍ����o7�T�I�/$-�lo���lo7p}�uQ�:��sO�������.2��4������JW�6bf���#�8/-�#�7�EHM��u���3(�kV&Qo�.��V�����g���1�	��5�/xIQ-\��d��)������|�RN��S�
:!�qz~g�8��l|k�����]ᷣqX�9�b3�H���NOz����t��z��=�=�=�����Qk�a7Rk�*�.C���!�3D�Ag�]��_�J;�7��;��L��L4�=�����H<�E'pP"Z�g �٩ө\��E4,��o)J����H�+9�E�i�͐@nт�t��vɦ�.W����F��2��0#�|]x/
B�=#7�U�	�->b��H��q%��,}���0S�pԗX�3�*��p�G�P]��������W�Sx�6�Qyi¹,BZ0�1�@WTew�䫻f�^m�nXm�>TqZ�f\`�r�������[}\^���������ӵ�^��"����+�,K�D��8q�����0smǖy�E�N<�Y��$�{�/��;2�ǹG���Q,B�e�"�����pp�|�_L�r�خJr�2�����(Oa���`���h�������Ͳ<��"O���m�ʋ='s�O��/&"8��O�~�0���Q�S��1_n�#�,�W��8^�gq��gw����BI�I3OyO��/&�O��p<�"h3ؤ� D���xUk�i��D�s��Y�.��
��e}����k���LEdG2�Rc4-�l�p�XPo����1,�_����o��^SYO5��U:%��#T�n�ZQI��������
��S
�*�,ĸ�ɱb��xZ�"�f�iD`D)�k�W9�\A�uY24y�t$�rT��a�	l�!8��ך�H�o�FI����h�����������㴯��W����R����_<zb�l���G��/{6�tz��������%8`�����:`gb�d�uM�+�=�����"�c4 ����B[�&̆X��?h�	G.1(uyS�O�ˇ��r𫨜��
oH;��d��g$d��$k�4�ߕ\F#,�����i6�ƈ�U#�1l4,�EL���c��P�`}��\�T�V�� t��c\,��{z��C�^O�|��]HL���3�;B�H���	|D��aR!o&c;,W��v�|�>�sNj�X�O�������rL�Y8��%�D��C	�&��{ooFM����z�^��-�*oK�NW�u!vl�x����K�#b�Ύ*��D�����1�.{�_�W�j�	���'�}��Q�'>Ō�YV����J�+Y��FLJ�Ѕ���!�b�^�>*��#�"�k]�l
�Đ��$�aI�H%�;f<��T��ZN�7#?*<:&����ا�i��EЌ�x��(����U2���NT�}�l&XA�ԒL@�SB��0.L��l4��"�v�6��Z�m�(9�Tm��#1�g�%���P��?N����ѹ�Y"���ϯN�7H�~�iN�u�d�d��)��b�iϡ�~]G*�B���W9O�/#��*�	�c_��!��~&r�D���S��G���)YM��S��;~��~�=�c��{Ok\;����g&p�F��D�^I�5�����v��@[�g����&�~MMeT�j�&�6!(M]�ţSU�1E��`*h� �1��[�6� �MJxN��y�T}S=�{��ۍ��y�稪G�@K�c�Q�(�Sx���̉�i)d��&my{T�V���/����@�ٿ4S���G��x|+�'V"�p_:�%SW����	!2|]��ʪ��⭬���n;�X#9�/	��#�.��?jp�FԎ����� �|���D���?����z��_5K��ɪ�|b���C6ԙ��E��vp[IWH�����HT�m����	���o,l����D*{��-b'ŷ��D�����ǩ-S��2�C^����ỹ�c�@����=;~ـ�:�߀����g�-�9��#YA��'򦞍_�
:�Q9}{=,����!r��' >@:m����a8-�<}Q��ڭ�H��s;�T���Q�-����fr� ����F7#.N�F�\tt1�oXD�xFG��$� ����ĵ�~�����I�K��e}�ܴ�Y��z���&�qe��K8�c0f�-���^֏sO�	���^��1�lǎ�xTY��C4�u�fy�%ō��
��(�e����XH��>bX�{u�0x�=c�'(��ޗS	����,_���L���F5h�}nĭ��+�`�_L3Ǻo�)��35M��þ?�\�[g�W���	V�
�FJ_�b��%#j@�*�7S�Nb��(��uD �a�4FS����DoF�>�;u	ѥ��ϒL}�1�!��^W2��mq�BX���b[#E��n(F�n�@�����KF	3�+�f�?'�����+M�B��@#'��a��Ӓ�=����ܒp�?]zS�a�Mq�����^�����Hg�K����ٍ����!=��~"?b:�>P�0��uŸ.�����Q�r�	
"0a<&j��S!����㤐���5q�Q�S���[�7J\u%uX�.V7m�~���/JCb�~�'y��+���|��!u�A�q��9����9>2�o�.;�� ��rM��z��A�IZ�+�A�]��(3��_Ome�V�A>Bb�5X��L嶾ѻ��ڢ������D[��Z�W��/���FtU����[�A]�=~a�&��k8s�-��cI��t~ǿ$��(��h �#@}�q�1C�^j3۵��Ѣ��T.���m�꼩���t0�yr�U����\��3)g�!�\S�Wɑ�[��㋱��V��[q����شf�{�tjD]��X)�a�Nhc/{��+�������=#�_>��U%��@i��C��h�_Y�/~6�ۜ#(��i$�5%<�{���Q9��/�~�:�b4b�mmFRX��B+c�JEK�S"( 8
��o���Ь���'Kd�jb[�NK�    ����E�K��O��/���f�֌HBh�V������F@� ,J�u/zR���+scC�ž��ä���"�^��?\�b˪7t�T�^�QÎ��Nd��n��$[��X���Q�>S|�2���$
l'�B��]�Zy��0A��n�H����e��M)"ٛ�K�����G��!~i���'������'��w�RD��y�}q=�������F�%�_������:b�=��P�q�Y*�3�~����5�۽��)�o(6�YJ�Y��=��	5����x_�%���'5��idvέj�((L�]��#Y�*qVU�D���\�9�E2N�=����A���+r�;N��AF���*&(�]�'i8gd=}�nNvrZLa�zb��q��B���qM,������?F��"���63��š������d��i�i�(
hHa�����Q�W֤Q.=?���T��}�	�6�w�`�{~�o���`�_S��~�k-p��j���{	\�4����A�b%1x`kbpL��9�ɣC�lp����2)� ��tX��s���$��j����硝D�^(Q��Z�_�s�5Ė�Ĵ5v�䰳F�G$�J����fj�(�+C|�?};2q߰�L_���{�4PǞ���8�{nВ&X!�v�e`���<i|N���LiX2��O���7榣
6Q�p���b�$��3Մ	�{��QC��-�%�M���jvd*
�4��Jt�rF;kK[�������[]a���{���]�	O|������F񔝇��(�$vps��I�E|�t����붎>};>�.��XG����cϏp�=���n~�ӛ읬oFE�U6�v��C�Q��vǏ�̰�D�����������}#
��:�u����+$6-1�]�Em��uV����w��N�8hUVEi.�Id��D���/Mro��,8�/5����B둗�+��_nzG4��h��p+��������m3_�Ybc��>����`R�m?N�3Tn���1.ŷ�j���ܩqAH:b���x��	��y[P"�a�Ɣto+{�v�0���u0�&n)r3��T����N���-M���g���Wyƨx��z�9��G��O��p���3m%�W�m��l�{�xc���A������N�Y>��!��0�6�)�o��B�Dbv�O0@�-x���	�D�qY�P�q�+����i\.�Z����<b���R�/�;�2Gc)��Z�w�7�a��PDyL�JQ�/��������C�h���k`m�6˔�oK����Qw�:sY/�5��ͬ �N�W���
����۳W���+6�\��з��㳳�с�w�S�z�!�r!G�g��̬��i0W#b(�X���p��yүG �d+��$��-�z�/�^�0�P�&�9-�/��Q��n9�[�5@XiH<�}��U�%��@a�B6�G	�+���6��s�U&��ڑ8"��N�-������������6�����<�f�������+�5�O[kJ'B-�қ��������=�֛��e��g��V [�M{�.��7nV����A��c�h����E���Ր7�2Xٌ���}Y���,��X0'齡'V45��gD��iz��Tg�z8O1R��oڜ���Ll0�KM�ӡ�y' ����R�^Q~�uJ�F0���p�4��T\%�}��<�3�J�|�*��>��T�N6,b=-&��3H���s����**���S���v!*L�E��h�n������A9�N�r9ɂ*�?y��T��%�p5¼�C�+���V����A�ՑSQL�F��ʑ�J�l�;��^|��^���WI�hΆϼ�~��UrRdw���k����E�fB��z4M=M����N���`&���&�� �/Z��� �Ҕ�I������j�lkt�g`G��QZ=��5��&k�na-z��3�C~(�(��Q��s�LS�DA�8��R'|��V�F�i�(��H�2�5_�_���I��o@l������:l��׉�T�:#y�g�F��4����U�qfJnpA�\d�ﻩ��/߰qב!H@�A8er�����q�'�/Ŗ'��K,�w�w�@/�L1�?LE8�$%���Q����IR)�o�Xt\���!=c"��D*L7�xvos(���Pt��x�!��r��C�J"��{y.c�V���}O$Id"�ڶP�/�\$9��4A��s�S'G����b�{����ڟUq��Is�D�RDm��!�i��؏\'q�m��u�۶UҶ4<��J������[HZ��	��$WclC��i�gq��{No_�1���ʗ��V-5�'3d����p	}���-��:�����k��.��j�ۺ=��a4��x��"��-��Kh�-����CƩ�X>���)ђ���Ɠ�J"J�b����$�e[},���p<��f�v���Q�������v��)#�w�e9�Δ9B���wr�{-+*�옍i����':
`;�J ���s[����4� R�;I CۋB�TS�E>H�9����!���֐ �]G�Q{0p_�2�;v��SOy-��>Vr��nқ	�_������}�w`�0,hw�w�!og��[!oϞ
7�S�R��a
����)ر��N�p�f>���[x]X�E� �n�i�T*l������"eX���i�5�U�����/jIY7���)bxL�MɁY�t�k}T��Y�q��D��L���U����ʉ���iO�7
�Y=K�i1�����0 ^8f�&��G��6G8YǙ�2���U�kU3�%��e�/S�&���xtۅ��~�(\H�m�+2&'^�{��2<�կ���B?�ǡ�+��Sa��F��]_q@կ�c��4�#���XQ�d�{�Paք[�d?+�X�FTk�Է�N�L�1/G�����r��#MÛ�K�(����#��S���v���$G�{9��uU�o�myT�txP�`�d��`$1�1Ā}4�*XN�V�T(�t�ޕgd�;�@4ɲk���A�5�CӐQ¨:{�Yln�)H���D�Abg�����ӕ��&���9�U�Ys�Кi�ŲOs[ڽ�]u��Fp
3>�D�QY� g.�+L]�"��#/�+�MZ�}�,��xR�M�2m�ߦ���aǂ>�FjDY7�&��j��քaMR����f5kv`d���V�no[Y�
h�@�����U�2��_K�q�p�R�]�Y���_���5����u��ɣ8?XS:Җwh˿�8>{g�XN
�(\pzb	�zO������l������3��Fu��R�����5Ԃ��@�%�(D+3h�ߍ��a�+�g5���h�����tU�����������>\�7�z�Rh�=��cۍ�1�dd�I�n?='TQ�8i�/N����u�D���L�Y�H�"��B�%v���$N��s3����뉈�K����	j�E*�?Z�s3���`��blT���ّjrƆ8_t �u)B�c<H1)�!+k���Ǆ�5B#��ީ[�b�W�<E��<�Z�}q�o7�My>s����0X�t͐k)� �Q:~ؕ�s�ZV��n �EmI�v���]~8\X��ϰ�����>��������(�󺬥uz��W&��f<
V欶B6�97�c�
VlxkVn�k�EA�gXMe�~�`�xd�c;����$����]�����D.���v�m�n���,0D�K�a���{�;vU��~kD�;-��<��X�0�BH)��/�I�#� ȷ[���Ό%AhP��v���◦�,���(D$h��q�WIຈ�詵��:&��^�l�-L�D&*'I�4J�8�.L�+L^�Fa�m^���aR��3���{�߷sߖ~��(��0���Y���Ǧq6��y�$���#�������9���1h��K|����ܱU����~����K�csaBD!����c�%p}?�˲D�F��{:a��p���ꨣ�`�d<�]�N�    Gnj��(��IFv�J��߲ӷA�,K&��n`����-w0��Y��6J�E3V��^��.��umkq���A�����/�#�SSu�Ö�4�b7M��`�?��kUͩ	���6P�ʟ�� ��_�����(IHQ�dnq�^ΰW�bر��S;ǝ��3P@���aҸE�ǡ���_��!�_�e��V#�;��?�KQ�xZ`3��L��^��CEΞ+v}��h��Gh�M!Ai������j癭"����\uo����zԧ;꙰�GG�?[�oO���?[/���ӗ=^�)y�2/���3�@W�T��>�C8e�,� �����寕l���7����\&v�s�#C����}e����9Jd���؛8�J���;b��J/ݷ������x3��p��8
R�D��9bϳ��`�쀬��������$v[�D����"�����1�h��#1Y���O�G٢��>k�<"��t<����N� l?b����;�U��O�D��dvSh
`���c�����[jݒp�p��<��<�RK��,�~֦L�&t~���їt���T���n�ٻOS�0]��^�zv��D>�]�����4�,�7� �E�Jc|� �qr8���e���sj�O���n�xI�z#6���j��m+�G������)�f(�.����Z']��Ga�JF6S.���Tf.�I6�'������u��O�}�F��I�~��N�ĭ����:q�:�X'��ƫ��g�ǉ��J��8װ͆a�e�JW�`\c�����T��7�h��.p�뇞�6i'^=�Q(2ͥ��v��DB����-c;7��
%��
�k�<xT�[��	s��]\V�l?�|8ؤ�g���!����B�d��DY���0�}�Ks�"����N9N�⤌���E!Vj����ϠofdpPͥBr���uK=1D���"͔�F�7����-�a�;2�g�7ʢg�IT,Pv=ch��G���]/�ɿz$e�L(T���9�ج�!�HJ���a�z%����4��n����#)�Ȓ,���M�r��}����.?a$���)c��Ո��u�$�B��f��Y]�n\�t����q}�D��x�p-W_�Ьm^���N���1Y��^!*��������(,τg�HFq�gIcm�\5�K'����� �_�����iUN
���$.�0�~K�D�Wc�`��OER!`��K�6�b4�����{ =]5FE`����b��Z��*;d���!��(K�*S�W��τ���E#M���)H��� ��(j��IY�*;:�K�}�ѓ��z�H+�'�g5�ۂⵗT�zY�:�5�j8��
Ŧ:��ɝ��^"�A�r�![�CY�7��c��ۂ�u	vg`��X�bi�n�MT*�����C�ٻ���A���E�����l�ƃ�ŭ�*uM�u3����t�����ۋ ��k���}�Q�? '�$��3������e� ~tk�χ''�w��"k��a(�ϐxG~�qG�g��dn'�\�-�P��x���>�oeQuV��Rv�$^�S��*"P�A�*s��V��q�D����ۡC���@eG�
�l�*j����~�x.H��dQ���E��W�:^�����4�d
S����v({�ϓ��|	�\0?�R�2���f-�W�k8(�+9��}���
4cf�<%�u��M�]�;coU���	BN�"#����&ln�*�`l����:����;��)B1�]h�X��AKg���pF�2D~��k�Ɲ�]Gc"�`��"^/-��6ӔI�ǥUC�
����ȎF���r����	3t?7/�kh@�Gbn��$�3��~#�D���OK^<IF�,Һ�t R�n��7����ϳy�.��-m#�k �"�{��l�-.�S�"�/�9��uu��ES"m^���U�r9.}��2�a3���s�!�x������~Z�*��ô|O'��(����%���l]���o*5No�A���Q��M
GX���z{�ص�8���)�G���I�H~ �K��fQ? {/��t�W��ݧ׭(+�88���\��m¬�����`��3p�r�SQyl|� ��m/�28?H�S�.$��	e��iY��=:�?c��?����)x/�Y����,56=b�bAI��k8�v�
�߽�yE7�K%3�5YE�	�W�	�v��7f�x|<"�#'�3?�N��lv_`TEfnb�P$*��7�b�Z�!n���a"�}}|�������9p���9��4|�Z�"��T��q�	_=w�>,}Lf�d�I� �j7WRQ��2�`Ts�D ��w)ҍZq{e�f{���PpVB����1��.�ϯ�m����]����3^����TI�"b<�
�n	C�$����T��e��%U�S�Qs.)1|p2�hk,�b���%+'#\p�R�-�
��熄�^#��5[�� �C�'Rs�;9���k<0�6@�c�����cl���5���!�XUb@%�9���D�eպ-)Ʈp�V��F���b#u����%��e�/��֩����֋��������E�ޜ�M����g�����C��m�tG���0���,GA�h�A��Q5�^�E�C�u+\��9�a�������'eY��#����pғ���`����h��ʔ�����Ű��	b
�_I�+���P��=I@yMBf\�.2�
|���0�\�J\1`ؖfQ�F�1��6�5�*W��nOt&�n��\`k���Z&�n�8�2�/	�ч���~]"���aZ�� k�A����#x�c���j���lؖ��)76������Fh2Le���b��t:���zI�S���u�}̬��,I�n���6"�U��".�n�/~4��|����Ë�Ó�3J�Y/��>]���e����Ѣ~�;g��S�)ƽ�|�`�i1���c��%x�k.5�:�� s�c��_����-
B[����,�L�56SSe��H������2F��.[��G�c�=2��ͼ��9�1h��l���ȞK�=�.?a�͝�UIYr
"ӂ�޴�ͬ�!KL
�D��S�p�U��sZ)�f^P�&j	fнժ͂���o%�ä7e�Iܚ�Ț���4�jmM��.4��e�Ռ�!8�0�k�󜍋��!&д�sI�@�]"r�p���˘j��A����{��큱��������bpvth��^.�ϖOX1<M��Ys��pl������hX&����7�p}�S,����յ�A�F`_DA��Q�BGs�����b��[5mD����=vR��Gl���W�=�3��l<VS��a���>��._[G'�����gg�W��+�A�.�h~�>b�u@����p�����z���A�K�~�s-;��
��a�����a6هH_���Q�)&k�[�����\�n1ҲD�[	Sp�F�ac�Y ���D�>N�Lԯ~���̒�)�vT��+	�F�Í���=fz��o�O����=>�b�P��̚R~��ȺI�KTU�{o��f�Y�����[�����`�d����uJ�' }��:B �b�r1����*!vF����¢�h�Jm!%�q�
����抾z��eP�`]�� �*&V��[����D����97���A������bZ�U�����H1�;��^����Q1%ؖ�%�7�h�48�.�����p�%��X��"`� ����)*O����^�K<S���T�b��#�)��w�*x�=&���[aI���NgC�!�VV��ml�qpbgL���K���8�rO��4���,�����vn�QꥭwI]�����.;�=�_��%7�5��]�箊O�n��G<����k녵l����ܣ�T51^S�	K�������0 � ��l�4�dA��-����lѻ|c�"�+p%��Ɉ�:���&=�ŋ:��Gכ/3�.�Awb��{�k}0��ģ@z�HX^�a͍PX�D�貰}0�    ��B�xυS�����~��'��n7҄�(Z��<�p������ڐ�,�i��%{M*3�w��褼Szғ���nW��_���D�����!H�!�6?Q^������RϷ�熻al��
6:���:
NHi�9K���ǡ�\�W�G�v\�z4���+������tp����Oxğ�x]P��g(���o�/k�� ��^j��=���E%�s��g��2	��JS�a8�@�%�*j�?��!kt�:(G|CT�����+��0�]�Vb��lp/�|���iEAk�!+ilje�A����Y�OT�3*qM���wt�� ���.�K�ٷ#\���S8�ցJ��)��ΰ��a��=?X�	Y>��»�jÅF���;��ǫӇ[��<;�p#��d�}�ԃ�`.a���w2��u�����3�jLiB���I6���Ӆ	�PI�e2����1����������/9~�#�m��=����AG�@8 _	΅q!��f���gD�lNRO�Z�o���bl��LN�2)(LFL�y;鹇�Y�w�ZYG�_������@��첯��K�Q�܂�*NuwT�ռYI��f�xωw}!l�n.����
�X�!C��l$Ms����0M���}��ZUrh��A
�#�7!
���օC]xs��;��[�x��GYc��h� �v��\/����]�6
h���rO�R++��F+�b�b��85v��`������Z��Gޔ%��pc���L��\GILY���M%"���L��fV�Z/5 /���!k\�.4�ޕ�}0�[�A���L�c����ðG+����BU;tdV.��C]0b*��+4eg������Ix����������qp������'`��6X(�ޅ���qv3�.o�'P�;Eˈ1��a�!�`XL�`^� ��=9՝#����#v:�\=�2����F�[��D�F�v"2��ay���c�C�M�Ţ��^6�[ӂE�9PK7;`�#�E ��h?�FRj�X�{B �����y\\,i��p���Cԁ�6"d�� C�̑�����B_Ug-����)�k���fT��$���jl:�K�h05�%�]k82P��̃ ��\9h�2��\��<�^� 盜$�ل�#��	=^v}�
����%�p��ŔȅN��cF#v�������� ���܎\r�E��|)mt�{~�H|� ݕ�j۳=�M�Oֹ��᢭zF�w���p9@u�6@�����2n�E�g�*.�
6�{����lX�n])ijά�V�aAxd��FUI�h��$p�������զo��h:�0dX� �-j���|�[��SՔi���}Ԫ�.����Q���v�VX:������#ک`�����=(L0�e��N-��?R�	F���ʒ�l�I����-��
�}j��`]��1f,3	��U!JY��X�^�8�,���v�J�����a7�9�g�)��s}�P��b��>�\n�Á5��<��K�����`U�3)�uӉ�҉�Ȃأ�RJ0-gCL'/��t��ȓ�/�7��F�J����
�kt�>3H"^~E*�����ze�jT��GCƸcI
-җ�+9�q_�6j��t�ěc�����+��졾�R`!|Ri9?0&/�݅��c�X�:�Z �£9A�(�tgv87����,�;\{T)��aɆX<���܁�lu+<?��Fs\�ݮ�}%_a�Vo뻵܍r1ylLc�Ύ�We0e0��~�N��-,~߀�yk6P�Q�߷�`^7&c7|�%�x��P�7ѿ�?A��F���ParQ�Ƿ��,�fOE��I{��4��?��|6�$L|��$1	�$
�Jġ
��Q����_�_AK�U��ut3G���j`��_�6�=;��n�8��Q���!`*�|�0RaH��)�Jl��%*��H&�5a�U���#�z����?N��'�����͑�Yn:y�A�=�8���?�r4��hw5+*�X�m����0��8T~��0�`�SʞM�8�S'u���U��\=h��~x�o.N���9B@^/F	�'6�Dn�;��x�N3��~���,
��{�ʲz5�n$g��������Q�n�2�c�r����~*���!�bQ>�!a
�%�)�d�­��3�"�DS	k���y��N��8�a�-'��nj��|J4MZ��'�M,pRR �*<v�e��Zs�&qC	��`�+G2.4A��D`ii�MA�3Ƈ0��3]E5�N'H�Xv��u6&��Z8�a���F(�O�q6Fn�c�W��-��N��)��rEg�3�Ĭգ�,��_X�o�k��oW��D���g*���=q�E�����O,����"�rJld�-� [
%U�ρ��5�?}w�J�~�
{ͼ��;�fl����ɢ�� B��L�ʱ5lu�P�	z&�G�)�(�轀��~����b+�a�|^� ��`�o1�uA%(0e�c�ճ�\ӝ83����x�H�w�ϡ:]���Z�O��K�H:�&�+aR�q/�ʱϩa�#� ꫉�D�p%ź���#Yg[qe-��lE��j+
3؞��l�>� Oc���b�q��}{��^�_>���f��`),�s���.t�c�T�G+]��K[7߇KS��U�1z[&*k�(3�9��ǵ�
}�UD�(0��,�����o Fe�h�`��h��!���am��4z�P�d2Q'/A�g�d^���)�5�@`�K����SyDS�VWK<�(+)x�V�+e]c�
CI-a��&�%k����� ��Y�l�E�����r��R�F9!��0����F�¦_n����VaI�A��!�Ǝ�7^�}�����u]cV�|8��%#�.  +�
&:f�P=0�+������*����H��*yǣ����%�m��&�f���4�.㦸eǴ�S��Z��X|��zT�X�?��(�̚����{�E�l�����Wv4�i `͆��s��Z`Z��n�U���b�����l�C�aZ��@���I��(�k��Hyi?Ob;a�I�7>��@���L�v���FD��/�G;O���a�J3e��~���I}_���*.ԡ7n&����|�+^q[s�&}����*٧�lg��>6���-5��	��С�7ns'�u���0(X^;�'�^4�.0���x]n��qQ���Q��ㆬE
|-�K�a��ŀr�T����LƉD�1.$=�I��� VZn,������%�y����-�D�s(3;vK�b	c����a&ϝ�1n������Ë�C�zCZ ���g��=)?)��zW�~�C�96f,�܁&'�d���;�*	��%��I�c�>IA�뇾�r��� }�7�6�K�;�Mt,��QfI�y���{�X�A*�j+J��&r(�	Ǐ.gg?[�L m�w�`��`�k66����,�2C/�U����L�<_�(�;i����������$�#����P���j��L�/�8�Uu#[���9����h�4<k�	��9n��1�G"����h����k㢓x��Kܻ����:�!L�Ǣ�U*�bLVݩ�x���v(�ۯ	����m�+S�G��X9V�[�����5����J��ҥS�9��
dX���:�R[���F�D���B _��5H�^���wn�%��o�RW�
�ӥ������2͒���eY"�,���C��'���l��=�"��p6g0zt��>���vF��N��:�^*\��?�胤�	x��1#N�ϔ�y�3��t���D�����6T&������:-~#1xi���C-lj������N��h���Qܧ��{������2M�a��@Y����0f���$Oe�,�f�OH nXIugr2� �rx�A�)C#�e(�N��CC����jk$�3�a�V���O����[Rŷڿ8?88?ј�4L@�O���+P��jW=���K䉘�w%A=`�x6���n�F�.s��!e3#n/�+���2    UR��\�qe�k,X�����?��1���:5T�.�G)��u=g�|�܈�in�����%_E�^s����q#P�kW�����[#���f�
H۶��e�֖|���>���v|vxy��(�Y�;@���~Z��pl~�Q���~Зނj-HU�G�-�e�:�j��5�^��w$Y��k��5,E�(��Φ��:D!�!u�@w*�_@��#L?�
d�# ]N=iq��/o`^��i����5e����]��F����!�8� MM& 1���5nCPᇁA�ys���r6�=�PCE�ag;ge����ps�y��i	�`��{d��B����!�.&��6� UYNK�K]iE��;"��ԋ�4Tp���a��]1�����h��@��+��J��,?8n�f�Zu*r��/�<�0��L�j�ϴk���;�ҭT�d ����09�4<F���~�Q[��(d����ţ�4�jK@��5V�f�L�����m;^i�oD�m�Nt�� 7W�QD�!�&'c�K��W�-oS��H��}��$n�G�`<O~p�8���c����/�qX0vÞ<U����������Z	��-;{��.�B��HxO�Ri���Tc�̱�&�^�H��}lAp��Z�����(\:�]͡c�CfJ��?���(H���Ƒ+��;��@��0�s��*wM�
rK8�OOz���.���\PB�����j9i���Iq�W�����O��f��s�-�S�OR�An{6MH3��~$�Ԉ2e0��F�O.G��fry+\�����e�;�|��j�9�N���~U"��j��e
��
��w��re���A0�}R��ŀ��g�M]t�c]�_��7�Nw�c]���(�D'1��u���ٖ�J�,c�S۰�Ğ*1����ܽ	[�P�t�%v�`��"H�r}�?�����*�d� ���x�j6$d;R�1|��(+���[�����{������|���!�y�9��e�d=	�-�ص37K9��4X�h�B�>�{=X����~:��&��x�Bŋ�q��^ F���){�8���9��C�;\ `64j�LM��Q���U��#&���0�������l���|jJ�7�!m�S��S���8�]l��:�f�J������(C`��g���!0vSDY9��J�H��zu�>X�^�nʾ1o�l�f��u��������pz~z��)�빶��ϢT��L�.�4��wk�����=������g���!ְ�x�`�5�M-Q��(�D�{~ ح����z����7����v����YñPa����@�����JBǕZÄ�yU$�`�|x�����A���!+��/b�yL�|0����s�++���v�l9�V�݃u*Gb�`���Ҝ�ӣT*�t�c��Q�������'�j�̈���E���*f�h$�M�)A����Al&��)@L���vm:W)��Y�O��a"���7�~.���!Мe���0�����5M��J�H&	ؕ���hv����`����.�b&�"a����C�Ie�L
�D��m��nr<xŠ A���熟:���#��Y�fH��׷���T�ف�}s�c=A�nr��_k;h+a����L��V�
M��4E�9<H��(H}�:�酽}y�l_f�|FU���G	~�hFâi�%����2L�KO���n���tH�C�2ǋ ֨�Mo��]�#eV���^O`�̭즼����S��v͆�A�/����@e�����*��ҘB��MEG|��QdA`����|ii��3�m�ß�lO)7s�b~Z?
�,ȃ<������K�����C=��Ex^P�O�l�'���z7�FǴ=ؿ����a����P��	2�L4���g�AQG��` ��M�e9�5UAEvl�5k�a]\��|n�:K�!���������+�:���Y�v�DM�EQ�quJL׌��M0��T1P�A���V��(`(2A3���}
C�����}�� d��k'��ь�ō �c�W��?.׷�-�rOt=!Xs�m����iSj�%����a����r|Y�NŶcD�hJ U��O!�7��o�	̞x����n���!h���	��E�q�����;1v"~��0����&P9RH�FphY���ޑ�ݕխ&�`��N��`�x����vk����&a�E�w�;x�W�a1�32���>�k��iy䃷?_ή��~8�~><99����W��������=^*F�x*��(MR߃IJ���I�ͅGY����G����{����9nz��yt�_z`�([��Har���%i�Ij/"��=p]1��`~9����|+s=A��`��9�_q;h�p������)���o�I�.�7ՙ�	�w���3��v�jn���e:SDq�a#�8��I�0��h1ӤA��=|��J-�ԉ�R�T6T�����纽�f6�]GA�J<ǭgY��XԆ��G�������ke`��aYz�{Q@!HH[/_�O�:�f��㟾���Q1V����~�uQ
�Pu��U�G�s=��W���gѳ�kY_�__�D�p��F�9Y�������G^�)7�n��{�b�u�<d�8�Q_��-#��4���֍�B��R�-e���	�w#���H�Z���kn�of����E)Vf�m���$N$�NR�+������'�=G������R{d��VY&s'uے�Q�MBO���o�s��ɳ�B��݉���a��"O�t�w � ��h��\p��������◦=�I7K#���d��s� 2%��� Xsol- ��� _Q����*�M T��Qj]c�Ĳ/G���|��0F����hV�x?���D%��C�̀�9B�� ��a���Cv5����f;VR���/5�pͨ�;|��Q^�z�j9���9-�"l�@�( ˤT�*S���>[� ��tx�^n�4S_�ĸa��2M�|!F�X�{����PH��!~�2{\?
���Qn����ǓR�+����*q�LM��#,U�������������{�q���zb8v�*g����bh�Qz�[�ظ���bi=�"5�DI��*�j��N-�!5ƗՆ���&e5Y�Nc���R8�s����ڦ6U�t%Y�L���K��В�V�J�Z'e1����|�������6SY���9��j�ʷDnu5�Z1����筌�n���î+����D9�ɴ�f����g��>\Y��'���b�ǋ������!	�f�%N��n�I���0q���������7%	]Kּ��YM��G�mot�5�r�!W��n���D��"6b��ohS����R���ʵ��he3��	r$�,�3�8�a��ȋ5)'�quVV��ty<��;ֽ�MdQ���|oM�Eɻ��9'XIF�5z�ˤxϏ�]�wз��hK��������?�[�UC�i���I�����˜���0S�VJ��ȳ��y��']m���.����n���$\+�%�T��[�(7H�^�O�8A,�T)�ȟ������F�#�2��G��L`X�dG�m�Z�A?"����yͫp��C��?�]Zo.��6���t�2��59h��wb�Wf<@p����e$C/�R���`/�	xrU1��qO������y��
�R�qF��{�ۯш�OjH�~�a�� k@�L��L)������Dk�a�����e#͡�m/��.�BQ�����G㠡Jz��J���a��n�ϞUKD��G���upq|z	V�N���
��g��p"J��L�%J���;1<��@��������W�2�#� �ؖc8!z݃AܹғbT��Vv����z��W�3��y��d�!��I���GY��^�Fm�O��G�ĨD�B�h5�Y��V=�u=��Vy����."�c��;%�޴�?m�.�aG��m��)��� �X�������A���TI<Ĳf�    <�`��Mȩ�~���՜:N0>���G.=���K@�G����G�]��'e
7�����3.���x�,�wG�Y��l�U�GvЖ�X�y?N27�(N��f�����q�MC��f�a? ��%�w��'�*�W�`?����1h3=�S{���x�`C>�P��vl����+�Nf7��e�e�#�c�	���K^����!p@㝓�7���,i�2ܶ��@�vİ�;:�]��1�}_9Y�Z�v�	�$�2?���[�`�J�����}<�G�s��<��3'��?�"_8���D�.�$`���G�����V�F����c#��O���Ԙ����M��<	���N�<����7��S��\�RE��9A��;���y)C���#{�н��NmP��9-=.���}MG	�97/�)yi�C')Bqh<>�(MKe�G���,�#�t���a|]��ݍ��8�J�\d~��a�&M,��J� p�8u��G��!P���XV0�B���
9w�q�#�Ban�a폃˷�gGWh	]�8]
m�ڑ���}ѻ<{��:|�������hQ�rg�(�{o �7z�\�����FM�*<k���ҭ���8�8��*�,`䉪��h\��6��U�c�-1�.&���=+����`�7!p�k�� ��'�I����F4�b�+��|(�hݱ�����q���x[}�4+޿04�U������'}ٮ[p����d~��̽},��ͅ�D�̐���ēk�� �3V��N���zsy98Fϣ"k��;ٵ�a��cTT� +���&g35b�x0,n, !	���~`����*V;�2Mq~6���~w1	~3)�o0���
?�m�G�FΨ
R���9L��������j<Ӌ{9C�F�AhH)Z$_��{v~u�g�ۜ�8�Kw��9B<�OLnNXJ2W֫\ɺhug��IYQ�.�'�
�嵆,Bg|LT�o_�?�q����
�]�o�5!!��������_�5c����Z�G�������O������g����Ҡ��t�g� %F����N��L����������/��X�detϳCђUB�	�_`��`2�֑���ds9�'���{m��0b�RB��J$�F�hJ�Z�z6�ğ��$$�\@9@d�	3aњa[ ��)�JB0[Z���Ruc�)C�� �=�ی���V@&D����˜@Y���%9�ࡁ�2%�����������.b�`0�i{bDˣ+&7�� nlw<��C�_]^�6�p��alΧ���mkf̅g�G_\I�WV/��eSNP7cpB�|��odꙂ�$p�;�X��$eu�
ٰ��;~C�z�6�1ܧ�xH+��������T���~8O�H#��ӕ#R�o�vF��`2m�����:Ϣ󰚑t9�����E�F�=b-�/|�5�� WZx���d�q�.�! r�04f��1��w��|$��!2�D�4���X"<Ix���A��hq{� %��a���lb���0��3@�t���>r�Mc?�$�0�H��$a�;��e�3���(�n��EY���6WY�1�	~� ]9x��(K|;H]�B� �Q?v��N�v�ALE� s��H�g��u������wDJ���ט8�$pֲ�(�ښ^�p�^�S"p�*L���3��Y�,b�h䣤�F�K�'��$�i0�V��p�>��Y)�la�4x��h��'��f�bHӔ�m�aĪ�kxj���Uߜ��9��^��e��D��7,��3�`5���7��2s��P�G+�{�uU,C�Z���u�"�J�����XA�8��`�_L/^��a�DQKL��G�<�DD^T�{efK�=D>x;8Xߞ�Z��G�g���i�W)ڞI��qB��}˲z5��ִ^cBNoe�tLK��/k2 O8���lƃ$ m�v!��x�uW
1�����]W>�>����l��?���<_������+�F��To��Op
:P0)����!G0y�E��E]�Ǝ��� ^�|<N�3�v�{-.�ڂ��(wC�^�5fT9�P	�W6�[={v0y�FQGvR�[�o��}�8z4�����������z=8���������O���y����ٚ��t����rwk���UU�UV[�	�h+��k����%8�Pq�k�Ex����@�{���c��7S�0��B8� ��`�|KURZJ������	+��B���pJ�s�NV\�z�Ci�f�d(��T�Q�fC�i�ɰ�WX��~����b+�a����6"ۦ��(��(����(�g�F$.Ĭ�aN`a$fX���X"��b=Y�� �SѠ�˝Px&���ܡܩح�����Sfn��XP�lNnUgMr�JĎ�ي[�b+
3���#ڃ��0���&�tr�?�pz"Y �����w�4�`�����U:�BL�,�D���zz5[$}'T^�9�]z��ى`�,����E��2
E��� 6�+q�����b��Vط*XO`��c`�S�o��7�+�.�	��P��\�(V-����R�q̀��s,�Sj�zJMUhD'�i�Z�&�O,�seWd`�Q5^��y�؎��sK��j&h�dh��B)�I9KoHs^S�W��{����/����R�&�E�(��E��b�=�5�-{{#�^UQ�T��:�q|p~e�Q�����[��d��D�B��i}$^�p�Lt�}�4Ue}R��Gr��V8��H�*K��{]aVy�X�l!�cYu���^ݼ�����*ʸ5u!X��@v-a:���~��m.��/�Z�_r5����=��q�.�v+�0jD%��(Bc/��Ǥ(6H�4��ez��>�e +ﹶ��d�8�8�i�HofոA[�Uَ6y�$���dܯٸ���>��X��`m�E납:�'K%#x#=v�X�f6�cMc sO@��ʕ�je;��fd; 5��~�y�z���t)O� %t�U����y� @�{s�J�:���L�T� ��'�G�u�������BHrӥ�4�}m�*&X%;��ŉ#H�lQh�[��
�^�Z~�6��lw7tm�v>w���Y����R'�F��~?I��4�'��W6ǹ�PM�)�:\}�8<�������{��L���<�z{4�a^�_�)�ٍ��;�Z�Vǳ1�?[TS������x�qs��5W�(|�n`����o25�L0Ը�FX$���F��\8
}�V�����J"P�Ah�K#S�D�%���v@�\��P�#51,̺[���̚���K�Ԕ�3r�A���d�]:��r�9ƹ�!M��tB9��w��P9d'4'ؐ���fW��&{��+�#�Uz4�����������������qN\8�v�L:~h�0i
=?�;I�A�8��=��+PЖy�V�}#�ȯ��"�$4�?jMd��8��W�&#E� \i*ynT������m�-#j�0 n�L0�S͒�	�J�1�)�ES���/.���G�n&��ə�犽����[����k���;�E!�� }q�(Q-�Ԑ�e�PDG&� �U?<�#5}�8{"f"��~?ɬ�2�B�,����2w���"*�H�\�~�ƃ���arv}������H��{�E����<)�T����b�c�rgZ�u���뽓�'�N�\;�,t��`x�N��	ݓ}�d_}_��vh���ݤ�þ�,�p�ù�jS�eז��siG�9�Ϋ���������4z���ӟC���X����w-4�!U*�A�Fu*�J�)��Bk_L���:Ɖ�c��}����d���i/��%N
ѦCw���&��8X'U��~+0���4'V3�YΊ�̛k,l��� ,M��*M���'Zz���?ħ 9� HT��W�ʭKb�3�W�K.����W�K��~9�����06I��$|i�_e
�)B�\���C#� �\i�<��(@I����E����5�aَ��<S1�������:��4��P�ZW*�]�/��o�F��ͥ6hF���f�y��"    N�X�s0!���Fo��lܡ�_�p���bw�O7�I	
��	yG�Ω*��ѫlߥ3�F�9o���9��(��ǆ�.�!N MTCx��{~bF` Ss���L�B���zF�9yc[��$�V��:u���}S�� �Vѿ87�t�K����0}��b�Ђ����2J\��q]�u1��f�*KZ��La>^�"�
Um�>7�a�_h�V���
f��`x�)��۬抰sE�6R������!�����<-eJщ��\iE���1��<�]3�3ԥ�gw��������s�m��w��e��H���������_	�d~�<-�B����E��آ��?M4���NNz�)���H���1����C�}Y�!��C��^�F9b��c�k�}$+<�h��8�1��Z̝�'�1s13�O53��ǝ�V|>��|����tp��kY�0Y9=7�o@l�:j�h���u���7�b%�+�9�,���+4�.-Rp��%��㛑I��p����5�$Q��Re��
�k�WV�B�$Cdɠ�W��qU��)H���T=�w���5p�9`K��R�n*�bJ%�e\�FȧX߆���o쓱�a�V��Y�A��8f9��[�E�����fZ����?�<����(��:6��Ҧ:N�5����>�wւI^\5x��&�@�(2�p����5V�B����7��S"�v�v��G���w!{ܕ���b��@eN;e�w�MCk_�4%�P�$�Cj�;�x:0��_�� ��1�^�s�z�����h�HS�=H�e�ـ�C<��-r���?��e�����M��]m�΍�\� w�a1��:Q���~��;�(��3��!T����&��ܤ�#��ݻs�{_��o��:�p��7�W�B�`��Qx?�{2��c�u~��!�T���L��+e
y����jc��;�;���;?25[Q(nJ����:�w�q��V����-��G���:֊wN���L((Б��u~�y������N�Ϩ&��O���*���Ձ��_�ʢ[��r3����bb�J4 tD/���+�����^����u�h�O~�`��p��8R�hh�M{9�8s=N(��??�;7y~��Dq�z�!-��$a�ت� ��Cϰ[)��Jv���e��LYO6W�֡"�j�n����V����AopOoPQC�oe�x���h������T͋�JE����/�Gr�YE^PI`+>%8|,��}�G�<�6T��$殮B�\F��wN�d�)g�R���nQ"Y	�.،�[ /�P(N`����b�ɼ�LU+It�(�s�z�R�N$~�z�i�@���P�ٗ�,,k_��1�@�5=���C�Ϗ��z�����A��?�l�Է�<KDlJ4�������2�m�q�S�����lk�I.E��'�����q�l|�u*Y�)�f������@�t���������Xv����C_��t�G�1r�Jo<+�b|ѝ_��
!���a���/��#*v���e�I� �SG�3�B�N�ٹ�,�6,�a�["���������XB&��89��=���6��*���x�� �d�ڎz#<]�!�a%GճO�"x�ySރ:>�,"χĻ���(��Õ��4�|+Z�N�"����_����������$7;%����Z>]`�{p���{B�8����ǃ���?�Na�E��F��5C�����Ǟ*��1e���U��qW�2MR�u&�;���!>�J����[W�O�RW@��	S?|�RDU�,7�R�j%f���+�A&T��w����T7��!��㚿�����
�S~`o�6d���G��_#�C���b�85��1�Xk��e��NscDwi��&�|���O�o�.'����zԩ-�̧3�*��Ͼz�0�Hc�y��x�-B��|Ϛ��B�B/������*5�GUC8�m��Q�#������K �I�LF��Тv�2���B����C���,�ݒ���'�ס�-�7h����y��_&H��0�QX�XQ���!�p\�D��D�x�p�uP�����¡��e��_���%��C1�V~��P��ڵ%�Pra=cY�bNںa�/�1v8�q>�����Ru�æ�W8���}�ȍ�M�$��r�z0s��=�z7b� ���`a@��,nu��Ѷ��nëC�{��!�DjS�H"�c��S��������P�{~ۋ��K�������+�џ�֖{��T����|cl��W��� �dc�<�g���~q >�����p��}F�ԥ����x�c�]n�������\�;�.��Gu���Pɍ����*p�8U������!���?c��'�y��E�;��N�	�����/@��0����YUn��*�?\�W�VHdKP'�ZM�)[A�}߭p�Yw8�C�����ћh�C�/=�q�F�G�(Q��w����m�<�B70
�^�I�,eh3յ�f�$�Lߞ���#,"�key�e$4vƩ2ƍ'�`�5�N��L��mN��t+ߘ��?�ԅûm������Ƽ�&��W��Ds8�5T7XQ�َ$�_.X����@W�3��{@��~2�ʋ\fijy�C�KW������ͬ.KD�h�o��9U�a
F�&S��I7�%w.��%�P�������zt.R�Խ�Y���J��r�Ç�� �� 	��g�,ҥ�:1�K�E[�T��F�0���DGUc�B悔W�\��N�-W��SV�����J��͸̟tܓ�{�q?��KvX�#S�0�e�AJ��-���V+c,X�"���beR��\��R�}���C�UW:�ӹ�\��	=�?=D���qc��ܚz�&<k��7�T�%K�jc��J˜�3��zc�%�S�^�ېC�ڷ����9Dܺ?K��B`i�yU���Yƒ��S(�B����:�k9�R����:�(I�>��̶@�����j����@3"������wP-��q���w-Zy/
�{�3�1�61��#�<yf.'Mʲb���u2�Z���������u��ˆ?��;:�[�<�.-��1b?��$�r*��u,L��a\>	�C���Θ�Z>TҮ�5�2�_yk��]�p���Ɖ�I9���IW��*+a�q!�z)������e�$�5S<�	��J?�L����M��@�՗΅��K������.�9�/�����L�>�)��iu`Wwyqgc��aPpP�T�:�rSM'淪��/nQ�DM��Y�Yn� ��x>��*h��C&���K��A�0��t<����'���<���F*��,�[7M��v$��JՃ2m7S��4�]ɤ�M�3*��D'L���q����!�0��;2��Χ��D��ӷ�������H�U�~��j�ح[��eVX���
Ew���#i��
����[s�V��xU�t��Jvjrt��u$�^~n���㿮��E�$�^�c�2��Ԅ�8�9��q�n�Y�=�Y��  }�Q&�Ąx�N	7jUS�@�A��N��u~�l
�����7��X]�v�O���'��k�w%Uo�/[3�P��5v�de��CD_�`�^��UN�0f)���̹LQ��ֲ0]���6�x�w�Q����ջG���HQ�R'�Q��*q�g�&�&&�F�${:I�$a�y��;��ed��C|�^�>^^|�X����!y����$q8)�εot�X�)^P9mC�Y�"s�RE��'��?s+d;2ّr;*�Ń���![�á#��T$�A	a�1V��
I��/˴d�`j�3���N��� N������7o4�	
���ݱ���
ы����O���D	�@���ۗs��T�RK_M굮���� �x�Q}���!>a%��2w1/q��a2�-᳸HD��U0:�J�j� �v��2�?<��[�I�+��n+���$R��������8����D��\z�⋍+���Z�W��"���5yR�UN+=��=���ۅ�|     ��C�(��)U�5x�15t�0���-�蘬uT�����X����4Q��p�	�9!&J��V;�Uė��{+�O���[�hϭk-�WX��"jR�aR3S|6�D����z�|<�&ġ��2l�n��:��V2XC��"�%R�5`qAps�a��ow	�:� ��"��|`l�꯬#��9dq��ݘ)dkZ�7�;Dc���������A��.���)�p���u�w����ɺ��ۖQV����rJ�-i��k�����F_����8F�머���ǘ�խ�US.�xɺ����};���ax%��@J�-u���E�=��u�=;mԱ���m8���)\�(��� /U m��=]��u�P]��{IO�w��֦��D������*�J?T��G�T#���Q[N ���3F�n/��uk�������
�A�~�M��~w~a:�S��7����;�+%����H7\J£�'%�r՛���e�V����"�K2�}�2]�$.���y0��{Ry�b^��gs�����Y�L-1p���\ �r��:D�/�R�_��E�o`�R���9D�&��P�:A������W'}��}��j��3��~G��E�fx�V,)�.���)�l�@���{}��3B�y�s7���EQ�!6(��Q�S��D�NQ9,䡴��dm�lG�m�������0���x&x�'qڐ���6gF+����顀[�GCIF�y��u��)�z�����
.�gp���^�'�"������s~C0��%�N��oC �Ԁ<DT�gs�M�w/ܘl\��H{��7�f+��!j�x��6�3� ��Ei[T)VO/��'�ʁ5`h�V��D"T�""z��	��z+W8���lb��b����x�'{��a�b>�S\����l]����i�$�u�O�ȄE
��]��q㞎���w*Ɠj��a/���-����ۼ͆ld����ȸZs3�l��`�/����i60�4����q����\�}�d0�vn�x��-/F�a��x��l<�Q�R�-���+H��=�܋(R�����m��	��:���X�w���W��e������:3
T]�ϛ���M892�`�y
2��7SNO{%����o*_�ވn��,@�r<����p��-X�n{�|�'*�5k �+Nl/�s�7ö��V��7g����66Z\���^�>8|�[�o������L,iN�Hw�f�)����H��l���z��4��S�<���
. ��i��[�v�f��郊�n�OY�ۖ��IS�Ru�x\�.�,�ٯ@�t�.�y7�D�B�`�ہR�)5I�	7y�f����C���%��O��~� ����xV#LP�����!���=�,AOL*&�f5*�ઊ���	m��yd��^KO~��B}ۉ����;��hQ�O(�3���@��a{��/f��~y��G_0�s��y���
Zӄ��+ݤ��@��Rج?��4*2��P�����간��j�$:U:}�;��Ij�
UV�*���ez�h�cS�&$��htI}!x����x��b`re�&�W��`�U��ͳ�v99Aٵ`�;Ħ�2j�m�]�tџ1l>�K}���7ݶ�ӂ�$WMk�
	On�R�L%eG��u^N��������4ƓAP%"l����7!$�
���[K3��	h:$d
�,z��c��﫜b��%� `�bWYU�*Ā%���28���d�O�䇬���i듇�G�UDy���s�S�������N��Gm���%�Pێ51TS!nMg�L��/3��/!�`��l���^x��Yz�
~��g����0�F�|>y^�5�~a����������<U�CW���HI1m���ײ�r�M4�U��0]���ٻ�lQ�S�'T]L���|�j�Ϛ��a������6f�_��%��%�Q���ov��B������PQ��n�iJ�@c���@q�)1:����}�Oxw6�H��~eȣ�h�Rdz�&�|�賧$*p��� K���غ��f�qY�#��V�xh�ݕ��,�G5���A��W3�C��L�ԞģnV���-����¹�/o��4b0��\"�[E�\E"(D���.��@dzpxa,���8G:Um����J�ނ�C���`)��l��`�	;My\��N�,)�
���
V��nRj��rLX���^Cf�r���&Q,�(q���(!��O�,M6z�̤2�u�mJ_��%���)\�ST*23g.�O�O�O�?�DB��z4V�J�)��C|�'x&��̗���n)Ti�$����7B����{B�xB��~���5�î�5�1�J� Ȅ5m.��nae��X�� &�
�������1���>��?)ц�P��$d������������G��3�J�ت*L|d�23f|�_Bi+`�Bvm��q#�?0�#t[��lsX׌�x-S��*m,3��ƺ8���*V��~�$����^�P�T����_��75y�r�"��Y٥3+�N���}2G�����v��N�Lȇy�#,�Q�b�El�$s.閥�&�\;�@Y�V�(�`[�c;N�ȓnJA��I^nL[J��q)lҕiYՙJ麥�U��I�\z��H��^Aa�0ħ�-�Ș),se����ֆٜ�[Bu�֖r�w�0c���U�&~�=��sg�LЦ������,�»�}��k���ܴ�d��-!X��,�#q˲@DS4��뽣�ׄ WK8�H��sg?5'���I�SB��Z[es���Ta;U'��L��,��]⅂�?�$�����n]��e��u�fh[M⺓1�R��3�4�!�NLgTjC����[�	�/�XDYQ8��v^MzΦ+s�0�I��Y��M
˘1I�=A���esDV�-����ǉ��Ƽ��E&E4���׽���h����M��:7�������'�� � ���$�۳	 Bi��չ�L]-
pMdn��m�/��R�' Ⲭ��r�1X4��Mnuy�0���Tp�$�VZ�����؜�"�y��E��&-
c�|�����>Y�?��1�%�fkm���﷝��:���Ź���v� ]��_i���,B� ^���kbP�Ú.��)�k�`3��2w��ۙF����,�.f1�
ֆ������*��)B�������6VE�X�V�]�'X�I�fT�M�n���"[M�1����ҿ:����di�oLt0¦��R������
��[�X�.���;`�΋y>"`�Oo��¹�C�׳��O��fꁚ��k��9��+�O���3lK(���ג��s�jüZ�%V�v��p�훳�6�}Q=�����KC@jg���גm�����re(A)R	|���/��j���"���P�˵,�S�c��@}s�7X�G�#�$#�Y�y���N��R��	R�`��ۃ�>n�UڒVJ��I�����*?q3��"�?���a� �3J��jdW	�Ue���R8Y�h�`M㫈����t~f&�+%"i�/O����c���J��2�u� 9�y��a�L�+�ᥤa�L��f@R���E�Z���ݘj��o�/6��ާ�xY$�9�G�������I��M3)E��`�+����v<��my�x�*�M� ��)C�u\_���I�'7��#���#n��ޮ$�����t�_&��2=_u�E�4��+Ӛ�3�����d��.�ٌ��ն��RԚ���EH���*�$����\���Y�$)j���[��~��G�B��j�U��mNz/N_{�s�!>&����i2�N�U B *��]��a9��Bg�@S���r<5���o��TZ�)I;8SX���lG
xiY���{�y��V��\���JL�D7-��m��}�\�(˯�/>��#��B��[�� 3���ne������Z��F�_,�=?Ϯ�d"cǏW/�IiI�n�h��4�>Ƞ����,q�D����5i    P�^��;��z��ѵ{y���.M���8�e���Hs;�0��DߩX�UUi���6������9���<+�v�P
�69��Q-�h�B�&
�9��9�� �0��ۓ�r�t<_N�xR�1��s���gSKaL��� y��K�F���R����^|x�����I����wJ	��]�ś�_1�r�^�rO�5���,|{d�5�p����O����pI���^��/�/��
[�m��g��HI���l�I�3~ť=�{=v,"i-�N-�#
I뱈�XD���e�Br�N�'�Zs+)�����dR8��L~t|ڵ_28�1��Lf���C|�j3.M�]�x)�Z[7ˬ26�MI�F�����vc�$<l{r�Fm�X!��]��Lm�t��mlxQl8�(�&}�6��L��Tc��y�Ƃ���2iJ�;LaW��*�ia$_�o��,r�3փ٬�])J挰.�v�6�����&� jo���xB�`>���[��b��E���n$Nl�V�vPb�o� ���b�y;zE,�=�q�GƓ/�&�0q��V��C�Hc��ا�u#W�g�9��.�kX��r�[UUV^>����N)hzi�����Ek�deu��l�ŏ�I���H�-���-������������n7�r�1���Z38B<s�-f~��z=z����r[�N��� 87�8�u��*�-����+�cF#��h�J}����R�C�#'�aۓ����`Rp���T��]Uڼd�bb�*@7�O.�f����4��� �g��j ��錊1��0�HL Os92l���l��h�����DK�h:����Q���S����Yt1�"�$�&���e��U�E�,�B���B��{`,��.#,��!'a���؀:u�y*5_lIm����������
-8c��
�ўZwT�	!�b3,��{.�O��`ʕ��C;�����jĆG1�����I�~ÿO�7d�$���e�e���(<�6�6m�+¹���/`����{>�U�z�w `�{0!d�v~���H���'��=d�(��#P/�J��C���/}S	ΖGjmL�+�����3��)�������+�V"����IA���u�e�̶7SQ�#=�d�-�_nXוejM�tl��v����f���d�������u%k�"Z��O�v�;z�z�퇷����?bb�����h��ы��T#���H��	��R2��	�rEpX+��i��MA,�f��y�$�b&�������"σ��N����Y��ΉE�XD1G��mg,�	���@ӂ�N��"�y�X7cTҕ����F1a�˯�S;v�O����;:�^������}���^'ӷ��g�ʰ$!�KbUt���1�08/�ҪC�]�h^	-��+�_�?�OC�/�Jߺ4~<�*�sP۠����%|�@��{��r>���r�`�>T��B�=�S���n2$�	�*@����!�"�Q)�)ByG��!Ј�+c��37^=ȡ�:as�[�TUME����MP���S�����E�;{s�$�Xs�8J�	fSG�����%2K3�?	v;����R��;3����=��\}�5�Izgcp�}�9�˗�g��f=�KBvY\�����K������9~H�Cdޕ��I^暁b ��#�'J�\�-\�x�){��
B^gF����,]��")�q(�j,�y�r�t�_�I����O�x��ϋ�.讽�w��w��Z��퍇���'l�'l���6f�����n��f�34RI�B�ѯ���W�3_0@����:l[/���r}8���j���Ю��]���6?W�aw���.�U�`���MG�t���)��Z}�2��S�ˊ
�HZf�=]m���\C*_{�!c�4Ô�Ⴐ1qS��n�V�i�6�,�$��%�mʹE��q���c̬�����}�[��MA�x�~�5���텾6�y�iQu['��2�/��(B���1�|f�+�I�U�z����
���p��m|a�/ZĜE�J���e;\}#�:-���mN#,��<���ݙG��E-R�dsz�޸���}��"@hEy�ATǨ��ϸ7�r�F�9*�<�n�]4��n��4�Ay��/=��w%�,*~�!<����(ID���!ZJ�-Z�j����TƩo�ka�� <#c�0˛�֦ൗ&v�,TYd��mKh�~�%A��6؎_�`�#�q�=��i~O�1<�}��[z���4	좧P[�����9��}u$����{^_�V8���Џ���Өy�5���&�^%d�ž�\�)~kV� ^��tI`6�f_A�>�^n7qU����i�`b�
������	3��4��)�>���v�_��bߪ�u{����F�yeׅz�~�TX���P}w8�T:q�:�0����+<��kUWw�S��;<xc[7�[�o��gi�hg�4���%S����u�!�7��Kp��P�2ħ�u��I*���]*X��D,s�YΊ��|����I
�%��qd�`F��71[���&��3�_M���c��?�Z�ֳ��K��i@����d������?S�RA�ȹ�,���[��E��)��.��BEC����Ga��7Ɋ�v�+'�]U�|O���N(W>���] �W�R~b��(�[��$�Q��O㌌hHQ�~����*�zqhÅ;�S�>�"�M��X�DǞ�b@��?$ԍV@���g��3��/#���oD��>�xM��@w()��[����@���p�@Ih��#�w�ݩ3��	�R7 ~��G.Qb��������k)�;:��>�6�G��3_�I�0w-x����3ĈL�4��=8�;��\��U���c]f͇W�SR���]��

y���/}t�f�/-"�}�q�ڹZd	��J}���B�L<��,���C|���b�q������t��Q�e�0�pW�� �G�~���6)a��۹��'0�h��`3=�'�U��"��+�6F������Z`���,������o��T�4 L�Sb�O�H�����%�F���qu�x��f��V��k���o��᳡���b߄ϧ`p�Y���-,�*-¬zU��#[C9V��!�),��>(�!p�;@Y+1L�+��7g�uu�Ze�J5;9����:9�"z�{��-��7Xl]����*�ҥ�"qi�9+�{j*�K���b�/�e7�[[[,��b��<��r;K�2� q~���!'��qa�����Bg�t�Yc�ZB�M�8���u9��V�L���f�3Q<�I�������s��	R�/���[&�~�h�^L�� x%�ڮ~ �ZrHP@�|� g���%	����i��t5�Ռ�(L��F%�*aL_��V�+<`S[�Z�21�z�/0Hw�\ΐk} ����d��s���~�v9���t��R�y-�+��;�xL�G�����
����W�K��0|j�@��ӡ:׏�����x��U�3�5���'!τ`<�+���L�P���}K�G��Ӝ��|��'�C�{�u4��t�bN�������Q�n��ԗ�ꏿ����>�$�>�A�ϟ���8���ˇ�A��'�Q��AF�ő�E"�&����XW�R��/Az|~��3&��|h�����o+q�7f��������J�̅�������A[������!왿�7T0��-�O��7t�jĬ&m�э��l�4,)썈m��3S�'�V[��x2��T9�ߨ�mjͪ,�s��7����*��Lkz_C,$,-D^&�if�˺RH�ĥ��$_K¾��|OQ{R��M���IQk��ÁVT�@f��Į-K�}�Ojxm�|'�p����@	�:�B�̑}��֬ C7�кH�Ԭ�j�~�[dcE��rD
ԯDx�Q��t-Qˮ�ZrM��J��ݪ���VKZR�8��j��]�Ȍ��VNE,�x�K�x�2�~r�O��(�'�'��-JB���F }��0��c����xf7�zZ���*�S�-ϊ�:/2�<�D�    �,[�
VY/iiu3��r�a������~��R�oBI�9���ג�oLIx?�"���=�Y������N���{c�D��ծl��m�l�IB��6���1�k��;]R��Q�����\��ƈ�K`%r�Zŕ�L0����b��(!?��9zynF�KQ��p�5g��i ���V��j����z
�2�D�~���8�o�q��9䫻���܂01�a
�@����_["[���l��	��i[�*����z��8 kQ�x��lG��X���Ϯr�0J�kʂ9�����e�PIƒ��Y\���bɮ��{�㓃��˽��'��;:���0aAUK�b��~�'ҬC�W��T�C���/��p���ByMPK��h��V�v�2��(��u"�.���e����2J[��`��Ɇ7EX���r�\�':Zyy'�#z��w����eu��bi�y�Io���OB�����
[�'�����a�y՟���ӬU��;�A�ʆe��0p�G}CTM#Lk.=$�L��)bUw�/���/�|��Ӂ�g
s�l�$*�#����?�:����XЖ�ǚ��w�O�a�^�����fw݌Z�Α���u�e-�2��o�L,�:��%��i�d�Kx�Aka�O�F�)����9�M�䈩JX�*Rh)r���y�B+�L< �k^�&:[t�6�Q)������KP>1�We���N���yߓ2vKo�	��P`��na�J��1f��2��i���1��M�M�MARe����BHS��(�[B��W��
�JuK��ɚ���e�� pp��Y*u���~������.�qe��4��$q�o"!Z��b%>\tdʹ�f��d��	�O��0^�έ�:嘤:�v���rob/̓،�Y�p�	<i�-S휊�����q�2��=�7f�����#f�m��2-b,F���'9���F%��Rk�k��\�F���������+H	����A�f�/�;����1�tf,���T�u�x�4-9��+�5*Ɋ|�FS�t���\O!��(�ĉ`�P��Xq�'�[�MJ�Y"�`�ë=�]L�;���P����4Ίe��&ؕ;~���2R������D/�-�|E6Q{��L�g�P8���j�RD��Z ����e���;���IAM��Ytrf.@;��ըW��W�ܟ��n�
~�8RM�L���ك���=��_&�+�n���FECy4��������ѽ�nK`(��A��!�MԠ]8�o&[`��@��
3	a��]�XQR��>����%e�IM�a"���6C ,��=Ќ8���܎>X� �B�kLq�N�4`�����]k�qc�\N-�5�¢��V^��c��EX%�5���}�:(/t�&RKu����"�q��0�E�l�Õh�ÁOz�p/O��D����]�訇�o#��w�����ӽ�_��na�k&:�G��E��Q��ɇ�F�{�� j��,��O���D����M�5�}���h���O���w9�|���c����%DԃQ�z���	`ksVH���0K�k|�'�o`X��c��v>�iv�ѯ�n�Ӹ�q9eBc�C���#�z��O���e%��?���S�l;�"���|��E����wZ��&	��Kf@����V�8��D��:=�D���w��
O���A�����a���T�"(H��9�1lsX���b<��	W%*��bF� ~�(.�^L¿�ܿoP��#��m�ӣE�Q.#��9@Oj�Vp[GaqO�h��K������^�DG���v����H9U��x7x������v˂�\��Qr��)��P��x�}����NC�	���}pX��/��Ḅ:�`g����îe�`l�J����5���~�� ����|�{w|�Q�������A��6��:��fѡ3��z��N�y�)e/�}JH8#�.�8H��������\͝�) �>}���ݩD?�ۃ����^�/{��$"�ݽ����e�_&R��=D�誾w��U��W�X�3�����J�&�㑻�R�\���@���	��@(/���TS�"j	 ����p�d��-F��Q�B��6���E[�r�ýfD��z���p���-��xԬ�p�l�������]M��A��}�oրG���o�5Z��)��d����5��P�Ղ(?*��D8�?Gi�@q���dT+��켘c��ҔoLq�e^Ub��hf>S� �=н���~ R�J���z9���{H��$x�C[�X &V�6E`���_�"+b�P�4�''��J�,j��1��'0�����#�C��v<��x�AA9L=���K0����
�w<�	s�Z8O�5�}�y����9����Pe�uI��h��fO�U	����E���O���_���>�>xX;x(J�H�� *��:,��G'�Q��Qe�_/kc�~�W#��|<D�:xӗdΓ�L|�і5&V#�l���u�]n�~����-%e��{o���;=�Tcuu���;b���;T��e�#�&��g8x�L�<c^����(ǋP6�:T��Լ#�y��{�ۃ[��?P��3\��³�d�i��������?�(�r����l����0w8
����ФXY�92���M�z�u�ǉ��s$����G/�O���!���`,��R��4��BƲ2�:���ť�1��%i��!��r؀?��ʞ��a�C��� ��]ҟ,�0/�9S��9�^�����D=�=�p!>�Z-�pK8�Rdm
��ar�g�ǭ��#�D£j��

�zKL���ƅu12��@�PM�k��P������aǯ�
��K�'@���|��	P�[B\a\����ĕ@ĻBъ�����UE�HR5D���O�q���(~�(��"�� ���n̆Qk!z�ٿe��0�ME2�+������=�h����ݺiv�&C^�ju�E��"-Y�����l���Edly���_� ��t���{�q�1#�C
��FY�T����Ԯ�x�Z)U��;`yg`���%ݮ�)�k9e��i�`�
p���elRm܂d�[�k�O�R!;/�'�S3������}�uF�T��|E���LL�lN�<��`>�p"Q�(P���Ѵ���GXߋ�7���xB0�y=6���gPȠ�<u\(.�/\��a>J�s:85l�Q��U��\�Q͞7s���61u	�,�����L��F�)}9�u>=ߢuZ^�i��c��@�F��b�,ʑ��N��������pP�#�q�k�caĐ������"���%�5C`1�P���C�8�3�	�T=Z=-ئp,}q�DU�����Y�5�9圪�����c�HE;����1�e&�K��9{��vN12�n����a�R�R�V��|п U�>:��a�����'~��O�v�;z�z�퇷���������t����R$��K�ng�HS�Hci�{�:8���,Wq�]�����
�@�����LԌ��n<]�0�����v���A�O˚1���WU=�Bh!���7��U�zݰ�7�oa[��9�,�ޡ���o���e����@F�vX(�y��^�V#}�-Dd��d�a�t�������!���e�4�+ނ�#R�V�5���./\����l+��w�`���h)��aisH���R�Le�_W��T����RT�!�i��(eY(U��-�U`�,���w��98z����(��ʃ݇�v_��6��sn�Ԅ����<n�3U2)�M`YE���Z���EO����brm��0�#�6�tI��!>� ��<O����7����h�ua�"�[�;7��sol,�d��V�	16E�B�U��M�~K���L�W�#8�S�Y�IRR�7(�k��շm�} ����^�T�J}�v@2CXu��3.�xPH��0���v�.���L�Ia,��,g2+T���'�k��z/i��q'��N���z���dT�R��V��IieR�]%\S*,=ȋ4�9̻xb��u4K�X���    �,v�@R&:1y�-:\CI��ۊ˄���?§�sN���6����]�.u�[U�Go��9�`R�
��Wsb��:f�qI*\ё�Nn�I���ǤF�������Bk�1aA���l[�$�zm켛�@���c�T���5^�59��ri�3,gI�6��72��$F���\����x���S�<vB!���2H)\�\Jmb%�B9ɖ��j`~�N���q	tUK�5��*)�b�T�� N��؂�V𘥰 �+Q�	�>��0�A%@-�εX��HQ>c���Y�yjv!$+�s����#�xo~UPB��ueRZ��1y�W�pI�uڪB��E����}f�>/y�����'NH���`U\[j��I�܂��(�;�����x~���r��$M�X�4)Y7���Lqk(���'���aU'=�;�5�[�u�YZL����j�%L
�
�a�D���j�F��?��EoZ���A?�g����BYh<�XV��25��DbJ[�� ;"�(������t�O��0禍�T_h�J7A� ,��O���|��nL���w��f|�F���l�7�!�Mși@�;5���	�������'C)�)8�H�c����L�b��S_�?1_C���9{0+Xա;���j��d<듧q���u?�����ͧ>=He��du�.��j�%GfI�t�O���KC$�a� }���w�S�b7�!�a���.�6E-��/}?|[Dg�ѠE\&�N��A&+�.8R�Vip�8R�s��YL�uC���#�N�����>�������S�9��I������`�/�������%�3�g��(�}w�X쾏$V'�{f�i~�S����#��~���0X�㥰J�`�3�3�7�˄����K�l�_`Ѻ�pi�x)혰-�+�V^R�k<d�<��V��Wi�9z�dA������ڜ x��Vo������wo��a魯R[��N�~����(����'�{�s+T���쳹�C�SU��ږ��!_njȠ�57a'�\�G��εpT`Yc��b:3Ծ?.`��T��v���������wHn��"��H[���P�X�.���U7ݩ��.�&eL�������"�ڧ^���X��a��ʸ!��(*C� ~��,$;�2��r~F-�:m	d��|���dݍ�����0J���I��w�v �z�������wB�q���s����+Q�oyeZ����!=Z>T�٧@�u��Qj���[ؼ=s�P� �iX���呵d"�?Ð&��7Ѯ�n�iy��ol�����9v$�$=&G��iQ��>P�a��i]�J��d�㣊�P2XU�\TI�kE>��\?�<!�����Sj���?W�������n�������}�lm��0J�k�L��ε��˷���#��Ɓi=;�r�g��}��qB���%�h+����͌��ᅱ1yc��,/�I�Md��~�����lG��X�\>X:��)4��N�%��)I�Ls'��E��{5��ܤXq�������'/�Te�I�$*�=+�ɩ�3����!*QIT*S���[�<+����~@���|wQaq�,��-,i�<�e4S�7����u�UX�+,WI�4�;�0�vd��ش0T�T�Z��u-8홰¤rAŲ!L�F�3�6$�e�9��%�,1�ԝ���I(Sp���R�	{P��C|
�I��F�/�(��F'`N�8��B�}s2)��JJ�җJ�t3�v�e9윧#��/���ɢ�R�!G�CTG��%\m�"bs���R�� 0�w?�2�qA��Yŉ�-E�����+2��R|�t�H�f:4�>夨R�����=.[�A���$���n�(��E�񨋸��/�F��贏�P�=��i<��N��|6�`�ST� %��Ԃr�w<���R�z�gA��Tx������pU&��`��:]J�fR���?�f��;n�!!U[˕%��J�d'h�e��L-�Ǻo���h�MC�ܔ�\��NM�2&��np<:�����;М��ӷ�������H�U�3!�y;h��F�%����r��I�Ck�:��|>�(�>1_��OPc�5��%)F�1@��`�-�S�ɇ-�����MG �34}/�x#�S�"8E�욯>>Xwi5��pжږ�b n�m��$v����Am�7S�Ϛ��̹�MŖX*Ypk�R�$ë+����x�~�l�_��
(b,��]�
Ř�W.d�sW"�D�'(� >)���z�8�*�xG�m&���\�8L�S4+a��"�8SŊ��9�e�˒9]���
}�~�(5�wo�S?<�#����������~���_V��n�b[O����N�f?�=��G��b~E��b
lI9PSu:��XTŊ�Z��lU� �׉viY�xG�Y��>��ⱪ���PU4%�� i����`����j����3X��p8/mw�OM��C�E��j	��쑪i�ڟ��� �Ͽx��4�� ���i���:V�Te,8��IZ1Pɘwy�lbt,Sm�l
�v�ޖ\��-��!� ��Ҝ�*�7�U�UWjgB��>��-�S�����񖧲�=g��4���w��{��˱%�v ]�oc�
ЭR]%@�"wI����C޾؉9j�4��+C�p3�}Хzq^�;��.K�p����rV�g��W��:�D�Τ*3?��< ��� N�3��\>02tu�JT��t��M��*g��p�%���.*F��M pΊ�u��S�4YcdHu�Neڏ��f��|A
ڡ%�A}tN���k�C�@��74��[�NI�$��4�V����!q4�S�S\�q��I���E�F����f���k�D5jNaԶ���Y����#cL���˶�����oœ�5V��uM��<K�Tq,W�tR/�K�+�:G|G������z��8<=�����N�"{�/:CwT�OSv��	���qۏکs�N���fS�#<�Z
��$�B��o���K�qu{��^��!�o�`�����!��SH���O�n�&k��O��8-s0�P���tNuKQhÔ�Ҳ�,�i-H��m��f��|�M_���\L.Q�^��(ͯ�����n���R���j^9����?		�m��A8�Ԧ���K�݈�tX�<����T���B@�pp��9�l�Y��.(d�3P�H��Ӏ:T6Zڐ��M����(����= �䲚����<qɎ=�mUZ�U�R�Ȑ�ktNx�+�ƦmjSi)H���8�b��m^���\W���cB����K��d�U�e��,.2yK��"�f��B&H���zow{'����y����M�/�f��Q���Y0pz!�bP�e	�=eθ�=��ǭ�a;\a���4�����ׇ��;(�2K���z���nl1T��xg�wS�	7���4�ϤEWjn���6;�I�[�L�%�H4{��]��>��4�i��^z��26��"��M��<�y*H�U�ڠ���N�&b%���{��)�l)'L?PD�Q��bnsfu�x!4�/����߿Z���F�ۂ��K-
���D%�3�'`����|տy���X���@gn�x^���@3�B=+��aH֑	84�B��H���F1j���FXN޼R;*�x�&A$�at��}��Lʔ�����Lu]��<UU$����lM��0,8���N���������^���������W��v�)sSk�����8{��ʅbRɧ�m��m��B�$�W��Js���čCT�[ɸ)�O-^����@p����Q.d��	�9N�*j栣3Q�JIi���I�W�$���4E�P�2D%}i
'Ѝl�,0k��u����I��N�'��`�6���,����1��J����u<Ϻ�F=�����R�k�ϡT��O�m	^��\ia��2O@��8ᢆil*U첸�~ax����09�@�2�uB�+��!=�#��r	ϖ���%
&_��9���"o��l	�-Y��Ԋ��)�6+%X�8�
$?ժ˄`���h O�    �Q�b'&�T��ӌ�0D�KR�,���M�Y7-y�g���cH�ej�MbQ�`��kJ[�&Q�L���du^1���ogi�X�7��:c��O2:�+g��TY0PK�K��m��y������������7{��
�`N�����L�T:O�|�t�dg-�'���������ŝ���c�����p:�:���D
�ms�x�y\bIF�V��B%F&��,kL��m�v�8��k��� �y109u�Q����R8�����G��_Qgn�`]��X�f��w���UE�X����r;:����
���l�f٪{]}�!�u�fO5������ xU�8�����@+~ㅣ �=���p�����f�L!.g��Hzuw�3��w���d�xt6���l�a�
�[ s�h/���,$$پ���F������1U�����j�N�v�`�����b}���!`*����p,mj�L�]i��s-�½*;�ׄ�0ȍ۩/���� ������R��9����&z{���-NҖj���*�Q2�t}�X�]�=w�q������w���WN���	
�߬��#�I[5�IK5�)'q�rr��|�����r҆:��^{��N�jUI����#&����$�F����� ��m >�׾;�~�n��Lf&�`5�.xg�?��Q8���Ȫ?��C��'Ǘ���1z�E��Ψu?Dz��^1��Pqnw6�'��֠G�	X_(�^�ۅ�O�|`������-�|���9��ڀ��wy���1�a�E'� T����?���׽���h���⍏o�߄U�����6w��r��J
�i���Ii�O9�"��7w`4;�O���է���-���b���/�V&���'E��LmFAX�$����0�,�'8���|�F]�P�l����n�Z/+B�(�l;:aH��8ħ�!K��f�o,5��i��XYW��2h��k�8ײZ�W��N����	��8%�8:��p�w�;z���4˷�{ڲte����f]Q�D&�(�6OQ�ǭ��"�lk-2�*��U���{,t�6^p&J��K�S����*�\���6oL.��+�S�2i�ei|�E�����h۳ʔ�	��Dx��@����0yV"n�����%7`��ЦVQ����X�D^F������ �qi�Z��SR��gd �wX�-!������*���p��*��4�[�"16�K���� �*W�5�/OT�,�R������=���;�o+�R�����q[�Lۦz��]��.Jɓ<O����"3�*dS��T�\�؂5�����җ��	��� |ՍCT�'��V�M�S��&�U������'}Ne2�7&������r0���=��!���a�6��$}7QI���V2o��<�q��+47߯t;IL���bfKg]*��y��ǖ���m-�T<X��Q�<�t�]�#��K�3�ʿ��%R!���p���vU)�,
k4������8C?����1�d�M�  Hc�8��n�A�&�*�Iy���K�b����d8��/������?��u�R�6�W�m�D�7^��,�
*<��-u�܈��zŚ�.���:�4�����dJ����+�F2Q�{�%��p���OnD�y����|����ǰ�U@���n�+����')m��T�����o^��r�[�Pjb��e7��L]'�G"t�\���Lgp�9��c��d�i�Y��9�'�0���K�#�m�WZ=Hl�� �G6+�� D"[ն%e�UVh8��,+�janK���\�	+�*�V�E�p�W�i0�?�����|>^Χ�A�eE��e���W�J�IZ���[��{��S	�S	�R	$��%����m�G*����������o3B���*�������祟�/C��ƻ�Z&e�˿Q߫J�g����7�R����w(�{��ɷ� ��%(kxB߃��~қ�X�A����c�'!�ܩ2�cO�>.A���M�I�zvtT������O�>jD�NXg&������������z`���x~v��Lo��M0�hʜN�22��T���8;&&��o��
#=(���,�a��;��a�М>h3���~5E�E��I��@T��8>|��d��|��������#v��$:}�;y�~���(��$�Gy?A�����c��|���=~[+�K����#:�a�:t�C���������d%uF0�؂X�-F!Dה<Iq��)u��uf4�@U�A����(ܘ�+��y����1Qke�V(Y�Be�/ޅ�b�#��ncQYF�S-Aa9|V�R%y��k�M,O��]$��k��\-G����{������"�W�H�`m:����f��v��
&T�X�_�����O3���$)��PL��)�o���<$4fk
���!&��_��t2��F�w����x�T˪E�ձ��?��n,��~W���� ahH���4D�Z�X���k��C���O�`��4C0a���Q}4����C�+t�u��W���]T�k >�q���3SL*�W��Y0P�	�ny��Hw��M�.�}��8m�߰��E��h��H�.����
�	�M!Le:�{UJ��S��\z�T���3��I: 툹��^`�Z7�@��(���r���%�9h��ߟlw�Z��s��u?�NWp�����q�Z�^ك�!�u]�:�P���w��W����C�и�.��i�hI���@aP��?�^L��O0��㏨/�E/̈^zPzfʦV<�c�l�H��` /{; ���R�5M�� 3��+R��62��]�g~>�S��A��a�����7�C�6�]�Z�8K7]Z�27��՚�~���q}r��������4�R�y���s5�͍'6��/Q����spx����8U7_~>��B���[�8~-Dݑ����#���|��_�@	��Z��ي�G�9��#��)�(��gt5��|hF�`?�.Hkr�
���G�4� �Ƒ>i�=sl�)H�ҥ~�0�p=���Km�H��3����~�~�q#��Es�����7��z�����?����(��r_��M��O�iF`�k�F0���lҷ�mu��M7-�ږE�-�v$�5�����&�mc۶h��l\�t�(�.���,��V�+��;odĎ�JB�$x�Ne���{��x/�to�~�yr���1�Z T����tn�"M���0�b̭Ï������gœ������!�*�;�rO���ȵZ��Ш�?mZ��Lhj���+��>����l�V ��+��nⱑ9��m��E��VC�8��^ѹ/DA���H��$�>"����=*�o�{yp��N~�3kM��������5�?";x�5-WF��ད�:���#q�7�l��E3+�
���[����"��&�!y�M��%��;����}]m�uFwW�ڴjk��Y5n~@�x!�U9�M�댬�]5����#�H�3 S��X�y1�h�����L8ۨ�
���I�i%$������6�^���#^�_�񉼼I5���5E�ˎ��>�9>�Z<���d�:\2��H'��W�qD[�o�]p@�,������3�D/���ɬn�!��b�K����1���rN�6W��7���&�}8-���J���l@��gיt���ύ$:^�|p��t$bv
~*Z��+:<�~i�.�g�͔p\��gg�'�71����jTYX/J(j�K�N�Y=�dXS���\�:LѮ-�o��"pzbo_��ƺ0T�~2�6I��
 �P!����H#I�/��W+��vF�[����ߎF��8�h��ȓ��+��W~��Z-=۴����������9�x5���K[Ԙ�E/5MeUë��S#�o˪�)��HM�|7��������,8.������qLV��d(�GM��D��rF�b���x<L�/%[�6�Þ0]�n+$xiE�%/��U��	V��n��}e��K��L�8v�G��%���s�&=�����P��    zI�g����^����I�o �!K���ãݝ݃��:y����<Xkw����f��C*��`E� ë��P��
5V\[ �%i��Ba�N��>�Hg��C"2ƀ�g�Ԇ�Iy5'uȄD�v\�J��`x�Y=�9Ψ+��D�SB,Tvfj�H1L|�wt�VP�&PP�0EL1<+��j�)i���dv�b.!��]��ҹ�g��D������9�u�*ųj��BZBn�L3d7GO^T�g�=�ln�^ؕ��qj��xD�R��p����$�AEvâ2��𷁵��%9�!@�?���cΏI,��=����O��7�����ˡ��ߐe���>3;�$t����Du����������~����$a� !O^�X��9F�	�9���Z�98B��|�@�A[t����n�+0^�!�g���ش�J��2�c#�G{F=/��b̛�DVϧzub�D�c:8A�h�E��$[�o�A6�ї����m����J�K̺G�c���dy!
�M�z��Lsn�>�ʜ�K�%�L��Rf��f�G=ua$Q���� yH�����M���j���������o�����<r0�z��ѹ�U�)I]��}µ�x�B�y��
{8�E�}��`�ӳ�����M��q��B��$5�L�Ҷ�2��f9.Q,d�G�2�x�6���	�쮉�.�]�Z�wW����D�$�i��ob��V7�6�ʞI=w͛����������(}�MW�C���c��o ���(6���w��G� os!�w��rOVy���ٯ/%}��d_v�5;�de����Ub��	QA�OM��2��V��Z�w�P֢�&�"-Dq5��Q��bg�-e��|��#-?Pd�4t�a3}��q�kuK��716��R��$��-����V����na���(��q6]���}s9a���ɺ��.�\زl�ɼ��g?�z_��s������=T?��0�U[oӺ�/I���n����-����'�4�J�jbW}A���j.&i=-�$��(���F��N"Y���K��@)T��>M��-���Ax!�Ub*��iXr)��33�"o�g>��ż ��t�q��[�e����T�C�,*��o� ���P�>��Yg̩�zZ4���h1#?����/Б\.MK�B��|F�&.�̚����.�ۀ�ʷ��<�/,�J����~.�@V��m���$\��%��,��>Dm��}O�=(0q�8;F�8����ĭ�aiH <#�{ ��::YǺ#�{��ϥ!�_��ϱ�Xs߭�kC�kI����*�Iۖ�aNd#S�\�:	}W��z0�0��_���>z�n�嵧d'�؉�#�\��i
�B�t�.Ѥ����I<��G�)�e^�u��Y��s� ��b��'�_�w ;�D�i������}�i�НS����rb��z)�#0�R}1,�u� B��C �X�t!�¢TZo�TX�޳�������Ur~q��9�7�s��f���-�x�w>�zt�?:ٵ�w׺�Bn��="�!V)ǿ����}C��&>�yM(���XJ�%D�ْ�n���0c���<eBM����	�rΤ91�-"@���R���_b�D�cu���O��5���^}����G}���ۧ��(U�Ɵ��]��d�Okb��������"���Vj����Ճq��������]����He�΋|�{E�_��N�(+�7�N���#x8����7w(A�S��pQy������Y{u�=�A�M[�"m[ue�Ã��F�#m�����=��>L����������:���B�u!�I$_>��c��� hV��g��m��(�*ej�\5LG�����?iU,� {�f�e.4��S�32T��Z��hKԥ@��뱬�̰an�	�*ŀ��BMZH-�8Ѝ':�r`n�{/溼W�\mX��òJYd����-�3'�]oA7q^�M-T~��h�NC��(�����V_�K�a���WGH�^/��^4?:><<�Z�ym��B>]��\��[�C�#TMP�C�W3��'R��ux	y+D���B�\��T���O��c4���܍T/q�ϒ��k�n���;�)/6VF�,�ORo�V����E�_W��[��$���D��	H�H������u�ވ	�jf8彚	`7g�h�9�<Yo&������
�b�ԣ��8"��!
��Ҷ_;]���=�k;�ھJ��(���G�%�M?%���:��n�	���~�;�Vj�Tb��K�z�y R���v}j��C\��L�a�K%�*��,�û{~�=Q��(phgm���!=,����������m��G�}<��j���4��g�|�>�B���]��9:>��L�	~È�gWgh��:w*���h*�)Hl�ܐ�b��!(:IY�3���❖d���N�]���F��	^h�
Ԇ`��$� ;�O��Kó�偖��.������/^�4��m�t�i�������j+���GW9n���8�W�1���_@�HM_�0�GHN�
a:m��k��a��Z����%@6��2r���������ڝL�S�Y���\��b1�hz��� �@C2d$�r �"O�<9�_:���bj���АΖIb�Y{�\�9��$���B?:�r��ui��q:���9�����g���Xxc���<�
j��>�f�,����!v+?���b�s}��� ��}���S}/��~��1����/�s�����/�6lL���?ގ>�X'�#��h��������`��G���py2+w7��})?���������^f�1($;�}B�}�	�;���eͣ���m�ubCi܍!vOk&�;���0���|�?/�� ` ~�l�Y��~#�k�v�r�}n�0�~��ϒmZ�N���1����
����R����V��X��������⡵=:��?^�����v/�r�w�����D�md��]��}����ι.L�A�o����gu^�j	���\^v3)t��328���&���&���(��_�e?�f 95�ɒ �qa��Z-�ˆ��̋���>&f 
���NMA�\��;;������S-m���'A	דi��
8�!S���\Lz<����[���DT_���x�/���Y� ����e1���k/�m�z����_1��p�P��|��t �;"�'��O��Vs|V�P��G�݃[���(�nܛ�rT�rԓ��a'���n�<#����}ա���^B/��a�o �����AVտ�� Y���{q8�5W��ع��,-��l���S����r,<�2�:�+8}�0+��^����I)���u�����1���>� 
�$�&_����M����Ґ�|8eZ3<5�V�Bh����đ"���t^��R�e�$vI�X0���,��֒�����ms�;��y=}7��8�(M؍Rsi�l3k�(����g� }4o`J��_��!^�>���qx�wx�s������#�%7�GMSω*�E�+[�����v���O���Ig<�f���A��a�Q�гΥ�&����i�u� ogHM~5%2� ²�_�Pg}����K��2T��1ew�,ҫg�tIV��9jJ*㗊�^�A(d�L*!�C��f�oh-��_b������{�f�����j�tt||xt��Z��y>����x��ֹ871�p�l`��w^���?�v_.�"\��𕸃�${���?�����"�z��ĸ�G�H�p9X
T�>ڝ=7|���*Ƚ��w�_�C�<5/	����\��5裿֎R|�����K��_>������$�3D��i���j�֤-C7]D�:e�prU3Fk�K�R�N��a�����OǺ#�6����������LT/�M�ޓ�a����b0�����o�'I-����8���9Pwϡ�'�[��o{VL�NѷW5 /�$�ʫ�*�T<�	�ة�Ӧ,Q��"�	̞�*�{�������9���=�D�     ��u�z����0$�TQ�� �g�7�w�
@�6Ĵ�	��lIg�J��#�'���;ācl�j����8�S3S�7�Mk�J=\�y"�ϔ��`c����[��2���à���o��r�C�2�JX��s.��W������B�жݾ�g��32�N�K��5��^��1n��6�#N��������z�4ޥ��� i����7�}� �ِ���k0L�)ɊJ�Ui<Mou���І,��a6�(���gA�����K{#�N־��M�����_�~@5c�Jj�:^�C|�1�6,Yy��яǣ�������{����������d{�Շ���2e�+J�>�c�$�D�{lV���烷hv�-��ڲ�����4&��N��.Ӈmp8�~�Gn��T�Dr֫g��[z�vm��V�)P!Ȕ�n��M;X']1��Lԭ�l�`�5�7E6!��?h�� �|�0�a {�\��^h��AL��ݞm�s��zm[3�rD�!�F�i�12��l�X(b�7�{��������^�_4c��$%� 2���$���P9	���li>C-�,������[#������H��xf�7Cf�/? ΂^�D'u$_�j��Q$�2F�=�+4�Ih\{�;oO���Î.ˌ�����8c��e�d�%�;S�<��쬵��Q3fm�,@�Z�+��ji��)��,S�ݚ-XL�V3@�!�2$�'E��Y�$(ȬH�0��U�'�lR��Ц�ҡC2�`�\�
����C�*G�Z����!����YQï�|F�������1�1��8�,R�Z� �Hd��$o���f�����
[?�◳*�Ј��&"S��ޝ�D�T�@���d#9�4�'d�5t�M7��"D��e�c�t6�I@�Y�ٮ�Q���������_��ף�w�09����`��
�K��r؃��s@_g7�<Bk��jXA��A.��q� �5���vƽk@C��� �K
��ߵ{�t�F�{�8|<���S�{�O��m�|Z��%��$����ƨ��_t!�V�]��Pk�\c���"o�j�-���♜S(v�f�}\��������E�
�V��i[; ��d,A/����~9�{���ȁ�WNNn`BO��_��0Ꮒ��3��HhjIJv9n��w�:]N�9�zV���Dg�A|����j�2��Ũj�Nx��F�Ɔ��Uu�%&��oH,�����V.L�_uMsq#��jL��",j�}Ũs'�[�K55ſd�V�W�AIӌ+H�j{�ϦE
�^~v&�p���mQH�@|��՟�m1f��!i&�S����1��j6+Ԙ6����x�>D΂�_#(������aq��2T���;'�|c(b��Y<`fuY��2]���w}1�(�k��%v�YJ
`D��M}��^]�=�b"�X2�aӨ9�f��[��2"��cֳ5�?I��R�����Ï��� �#d|2=� � -�6�+"��lRY�����?/[f�{q���J�oxu�r����%�Dt煄ѵ=�����N�H�a�,
5�9.��,[�H��G&�I(�p%���Xe��ౝ�Vꋈ��okg�3�I|1�i����
�%J�JL��]�)8��Ì����6a�q� N9�ז��y@�4\8����j�g/x��'AڔY%��F��!�bOE��k)#����5o��5J 	=v66���v����"+&d���.~�if��C��ic���6�6�c�a�&C��돽�?Ř!s4�J�����d��<�����r�7��/����S������ΰ��}c*aN�m�J�Q�D����;8^�b6 #��n]N��$Z���y���$�mJ�RSc��+�ҕ�����+uu����j$����rj��t���H���͖��=���MY&;k��L~�|��[ξ����é�椪,t�a�����*=��ƽ����q:u��/B]��o�����B]J�>7���jp�d��I�
�*K�����q`��F"U�^-$%�X)('W`�L�j�o�'�+��ZN�R&2X��NfH��9ЍR�ۚ|�	_�K�����}�qv�K�3�\��+�[�v�;�:#"�f*�sQ��C�q�� �r������'�^�|����b�?c2�'��l}�J�<�{����";D�e:��z�q\9FSTui &��|4���q 1���A6��\����Џi=�u2}���c��._�������X�2������W��Y�&P-R5D��^��;��4�r9BC��A�K:*/����%X=Yq�����í��9�lA�Э�gq1��u`��}�$#/�|Iu>�n&u����@�*�M������drQ�ߖ\��KW+z!tg���&�\r���D�Ah �Q}���⯚��j�n������ag�:	6��	_����C��M��!�K���A���O͙Hs�s�3��͙���f���ړ��>F�m�7�`�z�,�C��	��A(�V�����ƨC�o���� (T��+C7$����ř�U�����D.��~�������Э�~L�h?�0�0�V�ݩ؛=�8T��~E���$�;�T��$���`�Gk��h�pwo�*�h����0��[�"�M1���P���I'G��fd����a~M���;Y���6Z���l9� U=&�ԵZ,�_��O�ӳ���O�@���Lf����#�~%2�4=o�m���ґT�:}��8\�ў����%u�RV��}1#�5����g��L
{UV�\�k�a����T]P���V(BXd�Z1V��V�rɵ��R��_�7Ca�e
���
u�h^v�^2��Vz�P�/������/ו�_�q��!VKnX��oR$�OFfI�!�= ?Zo��(vX�6�.�!��6�Aw��[��w�Z79r�.����Y��~!s��x���^�2�4�_1�"��C��<f2�ڈ�1��!�L���r��x6��!tT���j���tZ̿�>���SGL�(��ҁ6�k:���9TL��
�?7��J|��v��FM�H[�ϖ���%�E@p2���RҦ�z�����4݆da���q�`Z�������v*�t�F{�6����=~i� �st1��
W$"���h�P��d�G���3��4<��=<�˱����_sx�}E�*ۿ4*ۗ�ܿ��/*�}�NO����yo_�D�;���ݗ.����U�Mb|�`��F-��+�"r���z&�?��i�Ͽ֔�/����*S~�كo��ڳތ�/�qQ�͗��zr��h�ee��*:z�76�9�􊷼7y*�=�,��RHp�J[g���:}U�F��7�'��%oyu�\�H~�	�?�մV�n6��YS,�^=�W;��4��na�f55��5���B�p ��eL�&a��J9�:���mm�i�.���nr�6�i�crk�+R�賛r+���VϨ`���$��o��R����t�J�������F�Z ��^�,c;�D�b�o-�D4�A���}��q�=�<��o�]"��k���ۓg�GHlG����o�V�?�3��7���w'OF(��_��F1���%^��ů Ynx}�p�`��K<�W��r�m���琾�`���乀J���;WaRr��I�J����q��\yu�`�N�P?Np�(9=���5���{��o�-��'���	����7I��/Q����@w+�L̎rmM5N\�4(�,vTx���@Tܞ�����hu�P����ZN'U�PR*T[�\lh�s����3F??[��իt%����:#W���a.zs{�Ƕ]�V�(���cw�Ǿ����@T�����z��/��n��$^{K�V�EeE��q�ݤn�c/Q^�� �r�H�$f�L)b�40�b"kn}8:�����}��z���ю�=d���fu���܌7�ibvc�T��y�e�D����V,D����+����D��(�C����-�� RiO]�l0IБ�����������MP��O�a��2m6 2\M��\�q    ���t��Lb8�hU4}[��~��[��H�&������0H�8y�]_��� ,$7���Y��Q`C����Dv+��볱$)��:^s��hwt�z���~����`�yK{��z�������R�qTgs�瓺�Ҏmegq:�BZ��I���S�.��`�K
H^��$P�:�� ��!�<�4Y�~�|�:���	s+0Wfq�FG���_x 'i�i=� ��^̤�e4�1�4b/�D�kʔ��L��j9u���P/��×�3n\��욯D��󁹪Xp8l6���[M��jf>�$�����pG�X�U��񁱾z�\/�ܱ�[�7�`�y�z�~�����@��}fAPخߕ�qE���\/MK׍V�s�k�r��MV]��N�?��ߎ�n��?���?�2�����,/��˙���U�/Ұ�U��O,��B�� 7x�%����㌡�K��ȷ�]�M�I�]^�Y�و���∷j;�̣aT��_��*��	�K��=��<��mz�j�<�>�.���l;�� \���G�x��<H�nP�����y���1�nb��J�0���|g�J�-t��9fl^���@�{�:83P�F��j��J�3h�9>��F�Uƅ�M�����)4�ج�M�S+�;���%��A&�wF?�.���n:	���W���Ƚ�*�|�s;��fe6,��O�(�}7nI��7��ӝ��]���ݦ�(�;�^�k���RQA�P�a�4Ͳ��vx�E��� ��=7��2Е%Zہl�(��m�k%N�T�Af!鮯h;~�@L�B{���iY8��;t���w��8�:�ƿ1��򱕞{~��
G`ڂ <���z,���9*�5�g���Ąct/$���:
cY�� (h�a<�4�ߠ;��ԝ꥕��Lj������'��_��Mk��4�J�3О�d"�S-�	�z}��������˂,ɲ���&,Dz���� ��]"ul��ED�l�����ly��
�CYI��ò��,�'#�F��ŜW��st�������pwϢO�6e�*#D��h�^�&l!/��G��-���˂�c�"\g�����n�s=�1�{6�����4��VgX��hf�ꯨyO�����.�a���8���d	Ǚ;��ז�tT�����6�h���W��tTXi�s�1�cu\3;��������j��2B c���yx���B9孕c�R=��1����A�e��y^����`g��Y�H��k̢w=�S�x�I#�H�Q���
�}i�p�0�#�1	����H*E%�]�!"�N��*Ȫq��r�0tTi�O�Z��{�e����O_������IB�]��X���#��'Ř��O�<�럟w����ˆuv��e�7$�����-'J_��w�Y�%0&��G��3��4�;�L�M_ٟ_���m�?��$��Հ��>����!�b���)��#J���u].�qt�}���wx@���{?�c��<G=&����atǥ�)]��j;>'ڳK[�N�eV`~�w��7˦��o`�N�b��\6͸����{ݗ~�҆��ő�(�}}��������8Q���=5��,���K#;h��;��p���9����@���I-AV�6�Ԣ#oqJ6y����°PQKz�����O�����d��MD"q2�����RW0�.
�yoP쥭謞�~�7_���Y�4��#��Nkd�F~�I�^�0xɆ��3 �Me��e�9�b~�c1X|���65-%�J�.������[d+���eu\a.�����Y����HTmт����_T�v�5�[�����<�;��$�i����M�zH�x�����+nX��RzE@_�]�L�<���$�T৭sG��U�� a��R�8,ƅ�Y���[����C��Z;�O������������C��zʑ���bjz���e*�6�՚qȈ�I�SΒc(�&�V^Y�+un�Y��H�k�-�)Lc�f����_�2��>؏�s��(c���\�#ci��U.0��a��1�F�����,�)����
,j���2Dp4o��,�%7�7��1BH��<f�~��4��j2�������xV�`��Y���n�$���ʌ��l�l�X��ˌi��ʫ��O+3��`?	4��ɤ� ���zQo-�_̴r���y|��}�V'�b1�o� .�Ķ2W:<"6����X'G�-:<�,��Г����p��:%�5ؚ�O���u8%���NAgm�R��3$b��U��C��$9AӲf͛�X[���90j0��ɪ�vE�ItfK��-ǳUg�)��l�z:�|�r�5p4R#�p��������Y���ن����Do��g%��Q��O�r��?Ŝ#��Ό�@-��ą����b�B��E���8Jl�p����d�q�YZ1��&fZ�Q)T�X���(�9�M�=�����3��:_��@�3�5��=�à������'l�n|�{Ƥ��)���N�σW;����
2f'Z-l�cD+�O	�hF��,L:S�Z�¶�
��%mh�Zo9���p\�gS5gJ���#8������Qʴ�9|~���a��rVcX��LŖ��Q+�&+ѿ|�5�S՘�nF��8�vοI�����6^?a&z����	����]���0���%��*|�b	�B��Q3~O�F��esn�K��ݙ�+������k�إ�ƣ�dwI�+黾&)O�����r��Y�9x5m8TG�hӊm���5�r���������1q�ǝ%Qھݥ�4
�!yT�%~eb���HUld'�b��ٹI��T[Y�d���H��D�%1���4X�\
 �&�#߰r�#�$�����%Х0lO�H#�Kk�%q=��R0P�N������ܞr���H������xq�H���m%aq�%���.��N0��(q�,v]�]�ַ�D!�d������������ɶ�'8�q�������|W��L64W(X)��8!��⩨`��
��QT��O^:(�qC'y,]Y�'3<����r�Z=#�#�����X)7h�N_���͝8SoG�U��ì��\�vj)&칃��ﭝ�k����.	ɷ@D`;gE1hc�:"+�U+4>�R5ӅbΣט�?V`�?��],��g���L�^4��.�;�ޢߧ����uw�_��� �Y��|��-w���x�wWM�����ȟ5�V��9�Z�%��C8� ��T�|P�;�����>l�J,���qŸ$.��|�TD�Z�\"�{�aJ�G<O[�7�σ�o��,5c����d�:$��2N��������i�*|{?蚽v�l�{���Bϯ&_�Y���B�MMM2߁�ks�	y3�����m��f�=~h���g�+�b>j�f}���r6�F�v�Ǳ�jzpx������7L�jt?����7G ��zQbح)!��6<�Ŵ��|����!���zn�}�~�rR�C��[��S��:��I�}�����Hk��:��d��uJ��P�i�Y���F,V BFR-0kl~�v�no�S#ޏ�v4z�y���s(Bh ���{��KI�Y����)T��t�NEv�1P"��*�<���7�
��(�P��F�kNԏ(��P$qd��Z��i�u:������Z�EXb5`�5����I�Ĕ!Q�uY٘�UV0Ux{��:<^�r�3�竂G�p5�j���o�{�w
��.NԐ�Y�D�@T����8N�A2Kqh�DJ ��h���e?@�Y��/3�7U"� y8�Q��c���K�O8E��<�W�����Q�ʃ03�=7�q�]���� �;�#2������ �v?yڀ��$?��|~1x#���!"?�%�tZ�$Ϋ�A�h5�����Ήpg�FgM�C��ˁ�yA�7߱������G�lh�$xdcd2�3����<(�H�)�CHj:U$૙�#�6)&5ڌ��L���R<8��a�j�b�b��"i��~�    |���_&_*k#_z|r4��j}Ʒ$M#N��I�E�D�R�UZ�$^�A�9�4�t@�f����_�f�\;�Y��_��'�7㜗:��Y��1�����4��32(�Cؖ�V�6�Ղ��M̕�V�S!-JFᆩ����+�Ў+��ӏg'U��V���[ ��t{�kȚ�7���6�yEB\;�%�N�+\��WYo�B �Pi���xuv��s�a�?�;��?�i�fIfE�]"m6�M�8&�����8O8$$ʎ¢n��#�3wG�'��&�gk�n���sd�d1��﷏�W����ɮu���m��X�㱠�������)�
��}��`H��d���C��#��k}d�����W�e�GR�D,����Jri�0�:ע�	�ֽ=�s�Kn���B]	d���/�^��If6��[qV�ҏ^�f�{\q��%��Keu�~�:��[�d�{Q]aG�[�.����IU~:��\�h�z�����}$K�ru��w����PZ����D0�]ח���e�n���(�*��u*�L�>�Hlo�7��Bח��Tj���c�Cξ���*�eP�Y��_u��J��rϓ��u�絡b�q��l?� /#�C�$v�/H��IU�7�L�'����<��\n�r2&��y�=r�?i�?������� ��6yqY��[~��#_�'���ΰ��D��$!�U�E:e�'�{�=��q,��/=gӍ���&ݸ����J����C���\�vG:��+|7�"�l.)�=�ӨL"�(l�!�K�^�f��wg\�6h��L�Iuq����T5z��>����*�v�j>�]z�{O��Q��$q�GchR�S9�{��`�����4�dA1�=:)�TFO�����6C?�<Nw��4�$9s;*�,r�rD������x�hw�U������X�,K1Ev�O�>���_[;{������O�@�\����O����<�z%Y�a��E�>ջ<���1�&FT&m/�+��,�w)�(TzI'9y9,I4���Ǳ�u�]
?� n�F W���LS/-��G���Y�@���]1V�G���\pi����I�]���,<iL��A�T4);�Ba�y�]gs���CW�U�)�֗�7t)��T�?�_�P7�kk��zʎ��t�r� ��v(�ҁ�!��=����jm|��5C@a�l�dX0����&yS�\׫b(��c��F���W�Յ0Y^�F�R&�3z@O��D����=�Afc���q�֯�8u����L'���0����f��Y!"\I���ܱ�r9��>V�B3:����V��[��P�h��;Ib羛"
��=�8���3��/���\��\��\�E."�>9d��H�߸�Om�9�qYzqW�Y2Ь��,/��_�&q���M���`��v�*�d!�D��z��	�ɏ䖫K�B+2���C���&Cϳ�#۷�?�BH��r�����Ig�Fe�<+b?5a>5a~�&L��e���t݄��Qly}��Lf�D���ѐ|��#�K����UT�m�,�(��0�l5-�t蕴ˬ�H��/���g4&�3�J�jb�����O+5���b��c���)�g ��O6`�N�6�:C/����)m����Ӵ��l���ntG�p�:�&�M��f�U�������[1=��w\��V��R� ���Zq�cp�q��6��R�)g�PbQ&0,0f����_����!��|�!xT���
���	,\����q�'�Y.�^�.���p�hx5�4^��� ;�[��nX%I�gr��,�,&7�+����Y	k�Xz�H�GK�VH�r�ɉ��	��+�&e�i��s]ejn	<�s�xF���V�X�F-�!\�5	��lN.բt����`����-���6<�t9h����qϺm�8���P�Ƥv#B$Ws�y���'�QG����nX�Mڬ�Sr�J��a{쭁�7`p6�	���5���5vڻ��}��:S:?Y�%��)��f�.���ܞz^� /��F�//x��K�ђ���)�7��"�]�!쟫N5�(+B�t�|��LO���r#+��'����m� �z��)�a�t��l9�
e��b�a�9�$�)�mH��`�F��:Q����tg�q�*�n�f�D�p!�v7t���6t���S��U�C)�� Tb_J����k.HsN�P�.W�j#�����ʦcp��	^~*�0"-�{1.>�ܢ��F�T�\%?��S�����%���jf�VSޣ�zĿ����V�+�I�	`܎z�{(L3�k;��\_a����T�҄|</
S��B��e� �%�X �Lƫ��FC�m��~��i�����b O}w��'�&�k��4�)��ƥ�%��K��DZ\mEڴ�s+���xY�$��E�e�q����@oqSNs�E��5�C����2fB��q�2t]���Ч�b��A������ٷj���} �^�:�"m��dm�|��
��w�Ƌ�1��w�ӻ�>%(�O	�?G��if��i毕���q|���K\ܡ�A��,��k�������HP�Ŭ�e9�R����jI��[F	?�H%.3]N�9���ƕ�H&���H�s-��ld������P��FĞ�x�O>)Dj$�%��+�|r�7;x�θ��;b/��#�I�u(]�=o�f{>�|�S��H�X���JG0��5�k����BegҾ��h�`"=�V�$)b{f��1{��F�YL�g���Oз����>����&F��`��������2�.�|R�������㶷MN�H̲f���^@��6ޙ�Ef�\ z�K��T�{�$*7����e��fL�g��{/�Y5�W@��k�5O�<f���#����ߛ��4Ԟ'v�����q	ڊ+7�D^����J�̍����9Aig����^08�����r\��'��:&7�z��('m��[o�~<����'�����=<Gۯ��}|��o��p��v O��o԰�W�xW�������ę���,��
�ș�T>��g%"�h��AL�&���^�6��8T+"
����:�|����~�cղZ��3G���-��n���T�卦EÖ�x	��>3�fd�"Ʈ�*�L2�L��� �*��I�մ�gH��X��}�Mk�5I���9�#ȿ)?B�.ʙW���[�q�қѺ9���
@��\��� XS�Ec`�p�wy���B�pۣK�Wb�ABK
 5z����8�|x]�>r�DB�A���lDRv��U�@&�� : C@�t��@b�ƝsYQ鄢P�P����T1�RFے1PS�D�F�G��5�>ƙ�W��ɓ�,¸�������#-�V"�O�Nr��aQ����h}�*J�aReL�[����a[T̓]�勊{��2�9�q������0�Ғ{�����*�xnJ�+��ߊg�PT�jo���ST��Ż>ޓО�8}�q����|)��9�>��<���s����5���n�#t�C�I��9&�������.y3�HSM*DyKD�q�U6��3���){���r ��ɷJB,7'��]��p�+���Z T�]�h��
��*���yg5���t�A���d��uJ��:-�.���Tq���X��`�{�.\��-��ň;z#�U��)�£�G�[�'��M��������'����?c�����3_��ҥ_M�s���2�����j�,`�W��{��௢8�hz/۰�����`3t{�5g�/� �H��b�Kh���I�j���ݬjP[&u�,ؑ=1���2��.L�3�k��������0��S)�Hp�^�6��	'PL� "x��D���Jk쇋&4�`�Ha;*�m���'e�&�S'�8R����Hؠ�WvL�V���0�jsJ�k�9�(�i~�a&�����9�R,A��P���YqD6!���ܕ��/�^�~s ���#����{��[J���\��������B�/%�-�W�Q������׹��Y��H0�n���jc�fK5g������    @>��	DʻQ���ԂD�须Ў�U��Vpď�m��r:����p$�Ed�U\��X3-V���p��A�"�·JDn4Sb"�3g����+�dz��x�Х�IWf�H����^�>���i��$h���׼Lo��
mǾ3���~�%
B�6W�0,�<N�,s�|���cI>q�~:W)�x��`��~��m�u$����u E7�E�<r��i��|�6:��&w� !�"4/�.�i��0
U�'���� �z�����
?1�T	G*N�2����H�2���H��ė���!C���O��(��T$�{7�l�9Q�sW���8D�Q��u^���&��j2������)��V-֭FNÔm��8���H����ƴzI`	K��:�7A`�QZ��y�{�!>'�ų�@��e#��yz�K6u�]�(��g��)?Y(�b�v�^[��q�e�{j�#��0Kb���ZI�T�K�k0�~^6b�IÜ��X��1�ŗ�3�G˃u���:��aY��c�5�+ɲh�z��Gi��$�"8�nơ�8��%�*ht"���V��Oì��<�`�W����n�	�a�`,������m����ў�3�]�o��R��1X�{����A��Vopȁ��ۣ,4/^�yyTJ�U�+�|b��M�� ���xո1�?]�Xc>)���f�e�l&�x�4`��@5݌+���$W���h~TϤ�r��jN�W���3#;i�jdՒE��u�����9�ʦ�_5bn�U*f��vb�}PU���5j�k.8O��ԛZ��\q���|^�re[�G\N�3}���=
p�}����nA��+��������X̷���Plm����<7�����eb�C�1aOgq'j^�O�*���Q]ׯ�P�5c�SP�V#}Nt�n�k�H����]um��QRy�q����R�ݏ��8�7����{����uk�S�Z-��B/��T�K���8:~�{�srxЖ�w���z`�'D� ��a�&˯��wO_��[K@��
E�߿S9��ByBuN'd��sF��}n���"�Ʋ I����e*� ��Z;=���w}Q0���hу	Ǿ&�`[O:��kn} ��������-����w�����k�k����{}O>lԏK�ց�k�K��X��.�-��`w���8pܧP�:�Y/�p˂�WYu�Al�܌d�mZ<�HF���3җ�9Zdp��I��N螁�?Ǭ�5��{��!���Gqޓ<Q-�O��WmL�y=C�@<�I����O࢞�S���^tNZ��j2aa}�0��|}	�ؾ5ͷ&$A��K@��QeM��^p���jt�r�94��}��S��Y*�&���z{Ik�Z(l�*w�!h�����Y׋|?��<}�s:_ ��T�q�5/�8%$m��{�Vu��N��8�q�SK����v�,��B1�^3a��Ì�,����v�? ��)�x�8��~������쬪��W<�Ss+7ީ	TĪ6j�
G���bڙ�I������c?�#V�3: Dn<5"ASq���B���LN���YUJ2{?S�� ^ʊ!�?u�!{�h��a͵��\R|�7�-�7������a;07��a�-Ѥ�wjS�����K���:�.F�F�u7$&��2"�E���ӻ��k�A���λ+>S��恧����I�A0��$-��˽8��홁8[�j��Ӂ�W���|<� \b.��H�0���6zt#l�q�	TbF��\fF�v&�
�J�O��o�
�0���ah���EQ�2̓��O9�7�Z��콴���w��e���K�~A�8I�n罠pXD�U��A�B���q8D9qw�����1�~W�ᄐ��o�\�g&�dr��>W�@�Y␡���1\� (�HU�"�����*2��*mW�TB�^u߫�U�U�
P:Ԃ�+N�,�9���k�Z���I|m.՟��`H�|�*���z����L�Av�=�z�AB���S#�<f�����L5R�������L0�%x�L}�>Im��5X�14;E�hbѓ��_j؆������	�!��Uw�[9�̼"�ʬ[�l��Ѝ�H��p���-��/�r҃,����L���ɓ(�˶�w7��X����G�.I���5G|�y�K�ӎ3|v��XAl^���cu0�QK5��;k�D�K� \ ہ��R���0�U�O"|D6�̥��B���n�6�!k�MC��d�o΋� ���v��x�=,��H>����� �\�;��G���d�h䳾��C>���s�p�%�ō��
��nY(��:$�R�(EI�r��/�ߢ�߿�c��W��3��:I���I5�Y��XױV6]!�@��aI3V�F[1�
C��lC��hj�N�������#t�m��;NU����U�y�y�.Q@˙�W�@D�	D�����펪�A'�YTR�F�o�w����h���.]���9|������ϔ�,�Q�sue��v&v�;�\`؜��g>Y���˖�U�S����+�˦� ��.��ʸ���y��<������7Wc�4u�09��j�<ʓ�Se\/ B�tr=]��Y:�N�Y-Ѫ��y��m���Z�X�бb��Ao��mձ0��-)hM�2d��<]����=5$ar묉K����Fv����/FGoGR��ft�nԭLƣ�Ҥ��`�'��m�������7�g+'�۴a���c>��V�-� �tGSR!��z��40Y2�M�ϒ>��g������އSm�Ҍ��	~��6uTZ�	�p��y�rXz9���az<��>��6�\Ș��>�5n餡�ȣ�T�`���t�M7L\��V{X�'SF�ؤ���B[Y$��a�-Pb�t�Ǎe�ĉ�vIa��� :��endG�o���c4�Fy���8�QRҪ. d�4ϊ��mZ���4���7Z��B�sZ���t5U1����ƅ���V>mZ�H���L��L�P?:R�GD��H���u�-P9׋��ܔ�
��A-l+�p�,m��YiciaY,}FC�/�3S[�& 7����ar��Ў���NOU�x�՚TQ�G�L��i��/�`��B7
y"��_�'��VF^��1�a�ϱo�C?ň9/�Th%}si�;��_��!���p�q�����V���x��BM�1V�%9Ʋ i��$0�y�z���Ԕ�R��tDk�5IZnr]�f<�	5$�È��X5b2�-�󢔱�P'� ?��͖��&:��B��ΐ���T&��@'��2C�螒�A�ͥ�\h �
ؤ� `F��8f�m�}
Kkx����8�������_\3��4���ן+��ޗ-nm������2�g��������õ!��/�Q5�����h�ڐ��<���Z4).�)�-�܋�E�q����?�����ށ���,|�k(7�^���.�(��M��� 9����K�r&��G��YK)_=/�cK'��?���&����%�5s�dh{~\:�� YߜZ�5sj�������.?
�a�^�9E��U�^�f�<��w/@�pic�p9�aX:�C:����/'vsMVk�P��=Յ���B��\�<���?�*�p����j)̄���y%y�2�x��?;n}p)�������~,i�LD}&ϴ�~6���vZ;�K��yMtŬ�wO~j��F9���![ݞ��^bC�HSǁsY��/���%%�/��߽�7|��W�Y��Ж)���x��b�$�i��h��gj�+.���J�a�m�z��ߞ<��ў����|M�am���N��l��=��i��W��[��u}� �L^�eHҺk�d�n�4	C���8)�~ Sng^/���d�a5�y:wG�t�����,������]k�2ӷ�q�rX��Dp4����u)�>	��	<�
�[��Gv&k��P/��fR�c�q��OO������ڜ���*3�{��	�ah�����hM߿K�1T�,*N�ȋ�W�`�o6�����K�_�ed�_�ey{�}o1�f�����>�X��{�O�N�6e    H�#a��
B�G�O5�	XJBgHM@��k�q7�Z(2�=�Gn{v����N������sLp忥��s���6�ٙ'�pY�g^��dc1=Ru�N�:�߹�|8�c�*z4q�0�tLc����3�[�P8��^�x ������(�r|�>co�K7�B'���z�W���wC=q#��o�"��ǜ�à��d^*�θ�S�X�-�	����.�Gۯ���&�w)��t�"��=��D6�� �����}�K2�Y�S>����ar׆�4v�xhm`r�_�4��iB�c'��I�����/�O����ˎ<b�#��O�]�bt~6'�m_����Ec�+�$��1i�Bhq����=H�@'��rJDF��J�2��h.��x��T�m}�.�-�n�H�nՊ���zs=�})B�Dng�3��������7��>w�H%�����T	R�j&��8F��9�4���V �g�Jɜ���6G+��M1.e�f �-�_y�Y�rz�[��	���yϹ�#��2�ύ�r�~	<���^����צO��i�Mfߚ����t
�+8�Y��N��#O�x'�ÔTC�d����цA������oPI����D#*J��
����9��tXIY5�>����e�B5<�H�
��[š<���P*i���lsP�r$Q��j�<�U*`���shC`ش����uzD��:nD�Vv f����=��x�[&�]���ga�X�"���a�ۚ��2x(��oą^��?*]�j��W���z8���{��9��l\��8*��&ѻυ��a�)�� �����ir(D��v�����N�ɡ,�G�&_�5W҂d7uԲi�F��m0��'2�y�,m2�H�T���į4Ƅ��<�3��h�C��k#��>��٪�����i�@�4���#QO���֜E�ì���n���Շף��5�^��\�''�.N&V��8�k�fBB�:"Q>@ 8l��g�J>����b�v	�
97��p�6�$��B3d%qC;(�^9��8Y잌9� �k����D0T��CG0��L���@wȝqd��xeRj���ԋ����x�]��<kv�Ҋ-M9����m���C���$0Ϙx�X�L�*]�+ck�����8;	n��	3�V�����b�nv�F֫����d�:����j� ��ӻ��2p���v��m���c�*i����0����ΫF�v\a�Ԧ��&ΥT�z�|6��s=򜨙Xc{9�Q�BڡNk�~����?/�%l��ܷ�să�\f�_s��	�2�&�e�.�w4�=�=8�^퍶��E<����?�_���kB�z�w���_kzx�p�c�f�x�0�;ot����^�i��ٹ�p����
gP~� ^"�l�L}���z\���UP���iu�<[�AbuL��dB�U'd*����BJc����68��r��l�+��*�s#�ˣKcrϋKS$�o.�8a�����O#�fĎUf��#����l�4���o��&\�?�N�Ջ����|��	�p{��&�*�Ó�km6c8�-9�6��,T�ƲE&�8]N��
nP$^���N<̇Gx^K�S�t8�����Ar�mR�(�[�_�s�Q�UЖ/��w���t�Y����Q��8�/���#F���(˹o�HJh�Nl�J"�F���
GK�WLC6��ނ�����f�{f�6Єhk7��{PY��^�1�E�ϊ�����y���,��~�~�0��;M�r�Q������ޞ�������Vu���3'M"����׺u��:�4_��օ�n�
��E|l,���>��=�^Y��I?>9L��/ސ��z�^7jp�&��d9N�Y���3V�P�9��PZl-_���"W�����.`����"��l�
4�Ic��u͚�Ⱦ��qV�׼��J�65oR����1����6������Ж�UЭ�Bi\���ִ�lrL���"�j<ҧ7o��eͩ��ڸ�ZC���"�L�C���HY�"�[sb��$���V��8��'3�qz �5��pz.��~�<a��#!(v<�����>'��"9�x�����`:������ؠ�V0��bN��9�'\o�s���ɕ�dg����XMdB��x�B1=
�f�2;ca|
(=�g%����4���NN�y4�\\9$������J���>j��c_w���Mz^����?��:<�^�hf�0��Á �g��3���J9{��%ѪNd��rD˧���B�\�5�,wY�'�<�}�	w�H W�F�h&��Z���v�r]�3���h��	Mh���;|�}mFy�[@���iO���`�@�I���s_/�z?�������˫w�����^��ܒu�G�sKօk$�ڋ���K�io<U��|�j�ua]�� �������֟r�O9���x׆��K�,���/r������RQX��<;{>��29����3Z ���a����BA��[��9m���e!jA��D�h�ݷ����A�T��c�I�ki*��'{��&���^��^#27���$�n����۵v���W��$g3ɹA?n�3ة���Q>W�����9�EVff�à7d|n�iI�Ut�Od ;����s��	q���~+��0�EbAD�-�
G�3��L'��U78.#R�]��#"�7"�����jn}(�{8��ҨۡP^tg�`g�hE�t���h_�a������t/�h���joh�\�0����[��5,�3�f��C�Fjq�L�>�!��W�BOG��B��i�oˢ���I�#��[dm�a��e
��j��H�WEgv	�E5�0|$ԙLFdF�~��0Ɗ�`���'-:Y�3�H�e;�8��`0d�y!��N�h{�����"�'�8�������s�+��@�W��zU䱿��s+�V3��`S�Ef����l�>�;�|��;gZ�_�\]��9!�O<���9Q�Ȃ�J5)Y)�O�V �����OX�n4��r�[�h*��C����KN*�#���}�)���l^�٣Kg'��qF�c��
6PJ7-����������LA�Kko�x��2x,�4,#d���`�J6��w�ʊ��y=��(�GP�)w�80>G�<~{4����z�M��~����_��[t�ξQ&yH����G��3���szi��zd�j0��.�^�M�f��G
}�C��f�t\7��{��mOa�̘ٟ��Na<ϊ��R�fJ�a�S�YnS\L��0�-�$T�I���C����o!��31v����v�F��;�ﮊ;fO���� )�5�*��zN"{_�����gp�~�t���᠊�d��̧A���dI[��Z��cD�s��LS-�(Q�f��u��l�Ϫ_UD��C�H�	C�q䠧k��R��!�����	��E���\��I�������uxt`}<��\�;�Hÿ���ֲ��U�u�`�Q0�y� �Cj��J؛\z��3��U4�y�W�V�ֱ��^������_��ԂaO��xq&*�D�eAΆl�)�L����]����B�N �aKX��2ݩ�Bt�T?��GH�O�>od�7,�*��x
Ϥ8P[�b�P	j����&�6�_�1T�UƤ2�)��y�h��\����.���=�jϘ��_����	��آ�ݵ���<�aY#�y�g�.sX�)��`�<Nt�I�W�k�ar������IƏg�L� �3���OU:G@`u�j�IE� \��WL���B)��~���J�C�ҍɀ�/�\���A'3Y�	��ݰB��\|�Ԕ!��c��:��d�1��a�Pp�gt��Q���?�Ti��ϛ�����	�XN�|S�2w�7���걀�(�"pm�+'a:�f��HOλ�F�R�Cb𙚐R��U�~����e���r8P�n�:�bf�	���!����-��$3[y5GCJ��������,�vt�u��.	���
���d�����r�W�.��1��<�'�p��>�ZǡW}��(�}R�0�.    [�A���U]H�M�Gd��6]k�X�r7Ͻ2<F�M�^�i��~���owҪ(	�Y��A&af�O�����W� ���^��$A�蹯W���|��8�Ҳ;�8-ݒ��ܔ�3��O_|��}�o�'1����K
pk�Lr��dK��d�Ef��ؙ/s�uG9�0H����<
s�	!�	!��ױ� u#��j�u�dXF����	�0�*k��䩸A�'�=,��Ht����<��V���*��#G=���qT�8�:��~]7�گ~����þFq��z�kC$r��%���2�[�nz��_�<����./�今��{��$L�a�ELNHI&,F��lέ}���;#�`�|0�};!�	�oCÈ��r>+�4f�M����a�M^,_�z|��GN>b���@s�Ad��#G�_]ڗo:M7	/��F�C�)�,��"��V���&"��f ��u�?��V�[�;p:-�6��i���u�&I}=���\:��4;K�I�N�������&�FzQl���B��6�3*7�Y �텛�i�_l2��,MM�R�y��v5D��a6�~��s9�(�G�T?\-�%9�֦^�h�2a�v01۲-�D���r��q=3�o�d�$Ӽ� ^���M�5��L�))
~��O����:��"̄�̤�xѝ�����vi���޻%��%��Ϝ�a��R���~�dYV[�#ɿ�vTD�� �D� i����<��z(g$'/k %Jd�bw+:�%��d��˗_�啝'��D��&�_��Uq���ZMfC��w�x�O��w�}ńD���\��f�"\_��� f������\���ץ5�	��#T�*��#ib	fp���x��JI�խk�Wx��� �zȫ"���4��8���^*ld� �GB��D�V�D��˺or_	w'Y��,��v�$N�_خ(���~<��$�⒠�HWn�p��d	EX�i�������.&���<+��,��Ă��b��(`Y����=6��x��i��9��q��h�8����:�nv"��=()�x\夵P��s���L(y��"��\�Xù��	�}�s�N�js��>Z�gD�ƦsE%ɛƼ\Lo#�'�gk�Y�`��XɵŐ(�b����v� q�� I��^9�|g�{Qh��OŐo_�'�'�'�p�h��f2����(�3�qj�}؄B��i>ׂ͍M��M���e�����O�?��9�4N�ώ�����6]:=ݵ��H��ۻ.&n��������y/����`^MS�����(y�9۩��1� �qQ�0O;��x"���^J�S0�ȥ7?�qa��Gc��K���[�� �@ĘcB9���<Sv9:jju�S��\���r�.�k��y\��y�������qvxM=���u5y�S�����"�2� 8�4^��1;Ja�B�C�ys�s���@L&�P�����D�cAA���������-]��R���X���\�[��GH��z��r<6U�o�e.�>�8n,oQe��G�`��&��ϟ�m*�������T�"�Ȏd��i�9�N�M���q�9��;����,xoD�t�9@p2*�yab�����(a���׃���F�x����t����;#}ζVi=!"� �ӳH�>|>݇q���%r"����y�_eC�{���~g����?��~C�����)�;S1�ѣ[�
��9���tH?���
J�Б�"B�?r3K���:�>�n�s�E�l�Ȳ:��G�B?~]B�2�����m��B|E��=�=��$�b)~��F�N���g	�
��[�ڪx�K#�h�*�:A��Z	�9�[�5"��;�!9����Ԕ��r�U��b#	wZ��>N4K�T�g�y�%��}�	%�S8s��y��;���n�x_��^���	<�N��@��<v ��M�R�`�v7�yY�{����NL�@69[V�J\���(��+dX�Ї+cU�RE��Hb��vCM]�7%fHׯM���/j�����2�6c���p�]̐86��H�S$��906h�W�)V��jN�s�� ���""��9k�ԣ�;�DI'抲�0�tM�U���2�g��b:�,�k�}��
G�&����,�Պ��a<AD1ǸGǰU]|>���B��������P�.Vn�5^O7�xȩ��E��d�d�A9YO¾3
n�|V�T�������S�����:]"Jv�i��f��2�e��쌠[�m����d<t=t�P��W��/k(�GMJ�!�f2���u_� �����Uc��-]#�:�.����&۱�8�$MԘ/�{�x*���w�=�"BM��'=����y�*��SG�;��h$TT4�0-�H/�j_��Lu<v6*nm�vw���*��hX�ZsE0[��,��d�v3���7����9�d��Q���c�h�8�|�
�'�dQ��!`S�*{�IT�$�ǅ�t~ I�S`{�� L��jy
^g���ǧ��n�+8^�=I�q/�K�<�b}<<�"��I�����ONŒ��Qچ��aj�84#��\,5:��i�ș��-��Aɐ�y��1����{�kNo>�r<�N�#��U�JDΌ-�IA7�\T�6�x��D������kd����B�s��c�$�h((.�b�"w쳓��U���L��ѐ���{Ɓ,�4̋1#��U�=��|^�^�)C�n5���,i��|��$�v�A�� L8n2r^Oé�����35����$@@�<�
��V���-�/��]�S=;�夠7^��F"�A�H���+e�焠7�oy�7,A9Y��Q�X~��yb�g����O,�5p�A��]mS�*h���(vn�#>��gã�ϗ�X]������E�9��P{zݞ��tD�(
�T�`u�����ker�fY�{�A�,��N&�U���s���P:X�'�յ|7p��n�eR?pW
��F�J��4�n
���U��4I��HE$=!���-؃R&�l~%~Uo#��ԧj� 1�'z�[
��ic�7�Ou6%`-�m%2Hd�0�Q�`�����jI�~gZ{�$6�t;X�΀��e�"�Fj�ȌS�W��������{i�k+r=<^��7�YRs��3a²'���o'���x=��ȁ;���"��c]�� N��{���{a\ ����`���R)��F�o4����C�$�HU��m=����l�8��Q�"�����C-���XK gt_�Ri�G�t��J`CO�WY��I#�̜�p�i��Jp�/I2ߔ�]��Hh�����t���;۠Ɏi�_p(�p b�j>�c�Q�<�2
��<8�<��?�4^�ĳ�7 AMu��2�3��F�灋�i��G�c
c�Fx��Fw�8��{p'�������"p�pi����a�(�eC��`	r��-�"p�M�*�y10�S�__��g����3P��ʽ�D^�'��<��0tJ��E��\2�e+�tG</m�hD����J��y����z�f/A�ᩡ�>=|Sa}���#�����Gr�o#���p6bw"){�H��#��������;��l�+P��f:�B���I��3
�n���~+���^�]�5�K�2�&5wFk,{{���;�|4�k7/�'5֛<4&5� ��<�`�D5��"�9 s���jZS�h�c��0W<��6M�8�Wѽ���B��@m����L\��)E��$f]E偻��rw����^F�^��������������@*� �~��D3�/��Z��y����ԯ4�}�To^���` ��5����[��|��{�y~@"߾�Oz�W�F��:��Z��I�����?b��f2�R���/rG���O��Ќ�ԉ?s�xF�;X�']��BS��"�f������D��n֖�������qd�,yNI�}�:'��v��d�8i�m~}��n`G�c�wLc�r�j{0��������\i�w���hB�-�!p'�4�����O�>6��e��LV�s1�L�PAl��`�Em�9?���o��\�enx�-�B���    �����4��c�'�����)'�ߢʧ���aN�}CY��G�c���{s龑r���<�TG���q��	?M�lQ]�-�;x�l���셁m��r[]�'M�y��EN�t����L�2�b�)�do��CI�H[��s��4�S���0��f�������o��#SS��{ӡ)\s����tC{�"[VQ�ı`�s�0�'2��M�����X�E�Z$�1�g�]'bT�SL�V�^��i��|�'���&Ӎ�AX�A�^����O��-ӖĞ�f0��p �u�I�^��7�kC9�����D��B ���GvLg]�h���6ś	Dh�K#$>�ů��J���N��q�E����w�Tl��w���G��k�?�ް�_�5w:~p3��1x��S?�x��|��C�"�z�7Rq�w����,P�}R5�H�UQ�m�&��'���)�8���yvR��nr�dX�X!��c=�s�2&�#H#��w�ו9'\x`nź��[/[ߔ� a�'�e�Ft�x��"E\�����g�W�2P�?_������\A���Ժ�V5+��9θ	�;LGr��i�:ۨ�'�wd���n��F���P��M:?�>ؤ]������̀|�<��g���-��Ö��(aQ�x�N�Z QJ��Պ�4�,-n�8�[�R�[�U�Vǫ�s·ߙ�G�UJ��1K��ՐL<p���'��k��?7H3�L�G�5�y����ȴ:���,O�����T.AWz.�n��cg�P���Pql�J����r��u��)��]��]lW�I����|��۱�j��ف���D�$Dc�|���a��T�L�P�������D�gJ�S�>��^LV(>%��Wr��4���B���]��*�~3YfL!S4@�I�/`�T�l^���ނ����X܌V��M�	u�X���ѱZ�g�H�ڳ�A����GhA�I��δh-�G��5;�"G/�b�������h������0��Д��(�Kw�=��1�+��>RU;IY�����K4'�侥�S��=�L�����\N+��f����U�,R�v��.��T�A���N�qZ�(��k���:G�~�0��*��j����mf�e}�&1�K�i��80��sYM�$#�0��2Ԭ�z���I/���Jm���LfS�6�Hm�O��z5����K����#�B�'Ƈ���a����y���M] d��z	2�������5h�N��uf�^C��gc�Fb�9c���Ŕ�T>P��n���y�e��4*Y$����7����LC)�5"C�����ޚɲpc�u�J�4Ϡ����u,�,����}���r`��6�3$n�H֬:l��{l���+8R��l54c�<�KAGI�(x"����������U�յ�ĥ*�?�&h�L	��A����5Na�ɹƄ4dm�������yt�>�OQ�H�<�b�g|���!�+�ڋ�8�aRJ"P�k��ѻ;NH�����|�ᓱ��hq)1M��ip��	.]�N�E/uzUi4�T�{>[��4r/W�mӌ��4
d,��]nB����y��l��b4���#��ނ���~����f��}�*X�.��3���^�?�y��_}*ٯA�pk�9��c���O�'d��Ri�&�7�z��"m3�A�)xS���#�JA�WE�]ȱL3���@�����,�p�B/�!@���j�6�tu=��^7�m~�|	����`F�A̮(�}u��^����H�/� ��l�b!2v��.�a6�b�s<�0����`�Oα5��xB�R(X�Y]��t@��{C�%&����S�&Ɗl�I`ŧ����՛����g}E���j^��q�RB���֣͂3دT\�Xﱯ�j�u�t�����vƁ�˼*��:J)jƾ������-��*���P4?_^��������.�@�������������J S�~�t��E��j2v�O��btRwp�Z��q3)S�g�B�hE+
g{��Ȫo[�Arc�=i��Z�Ԣx�l�W��I�����/�h���R|�����R�f�w)AW���T���L �Βd����Q)��0If{��ut9\�jfޕgj盦�����;��rvB��.�N�<dj%����i8���g3(DnI��Eer!�k&z��"� �I���c����v�g
N*eH�1�#)F�Ω��O�t֘G%2<ݲU�� ���8��B�Y�*3�#dy~����v��4�� ��k�����s���]�PvCRa�T}unXi�W�}�Z���m���#��δ�	P�Nh�˝��I�b/8{�Vy|T�g\��w��{��RL{_�\�Q��x`�5=P���t�������A��T�$x<Z;�,f}\��%I�s����(� �������j��=Մ�ek�K��e�g��%{�*R�����՝T�3멬�ǯ����!�׃0 c�+���lTTKjUm��p#��R��]*�2�7E�L6��Tr+�|u�#�8�óv&��;v�.��%�����8O��>�O�����;�zc\���HNL��BV��i��,�$�
$~!�D��(�iX�Q�8��̪y�}
��0)�G�EEO5~�cą��o���fpe�p3C ��t�bL���1u�,nD�-F5��.
�T��-"�(cE�&S$���*� �¨����7ؑ��a�߾��bl��M7��Pf��K�= a1�E��{���X�G��~�빠<"��X��@�YԷ���6��Ձ5YЖ�S��r�$�L����D��.�9����}�+kb-}J�#
��H	5��Fcy3!C��<|�
�,e�ا��W��w_U�-!�_��72]��dx�[�P�N8X;Vtw̋��y!�-���hW�|��<Tx�ScD�i�`c���m���T=���'q}|��i��O$�!Of��!��f1�hr&�*Q�XFF�V���	zU�V������-o�r|�m�ߌW ��x�`�.��*�E�k���8�a�,P�9�>ᯊ��i��	�n ,Es����׌
mY��<�F؇!^��b�N!�ߩN�s$:��bu� ��m��������R��Ձ��tʮ�2�.Q�n��}�:ЊC.<�a�I!S�}CA�'v��5�@�L��;?6��J�]Ka�h�<�_ώ������s��:F�p9�*�8�V���,�O)	S�)��j��[hBc�A�Z+�L���CÉ��1N�&�B��PH�$�cL��L�W���A���
{�lwϵ]�t~�^Y��u"��$�z�����#�}ǋRG�	��e��ToV=Q��^>�:6�.ό�áqp2��y@2s��=/|> �OSm(�^����E^���}3M����
�z�e�ݶv)0"����T�N�?�U�#�����/�^�%Dp��?� _�o,f�<�ӏ4��s�Q ����- ���%�L2�Z�����ʓ���N �E@՗�J@M{E@m�lþ��@DՒ,���G�g�.�1����?X4l��@4��^�8͍c����A�,��7eJ��6a�*�%�E�h3�6al��Ր
�H	c�R��4��#�E���=��OĭH���=0y����TA��z�ŘK)�f��I��Ɏ�<�t2��Y=��q���/�ʰ��t�o"�L�4�SJ�B�X���KP��/�Ɣ!ȵ��A�pN��q4��V� ��#��e7|J}���
oS�ī��j��|~>�&c�qx���8>=�|v|�#����p~2�!<�8����6F�`$r�T �I����L�I&|"Z�������2���Cj������FPr2���&�\ӆs!c1M�u�1@���Z�M��VD�h5j�,��~�G�Nt�[E�ee������l�%!���c&�"043��������N��}�޿�I*�v�t�L��T��|/�%y/8�8<6N�WȀ��`���v@�N��({�4��nCV����d�1�QƬT8(�گ=�&c�=�h{��Hd��`�7	\���@��X    PW1W���N��I��p%ЋŬ�݂��7Ɗ&)p��w�#�sj�E��'�ݩҫ��RJL���h6N/���!�BA�9-K|\*���&�ޏ�\�o��Ѽp`xA
.�ڸK|�'u҆�#���vk�(�h��5qA-p4�L�	@��9��f>� D���c*�3����}-"$�?S��a^����N�g���n1-	ԖR��ds"�;u��b��s�L�Hz��$#d#�K�xN@QۈѪ9%U����ĶH���1׮��P_&x��>Y��@q���B$�J]�$���P�
w]'�W�T)�6�o�bI��;i��q6��|yx2<{��'уs��G�P!^j��]5��P���߻�.�j�M��3łډ5�$f湉��S�j���z���b�����5큝Y�/ӅW��|���pL�o�(),񓚧�&n�H�V�`�G��(Y R�̳���)n��0�s^P-Gew4y��	�=R���cj�E6�{)���AId���d,�b#y�����/�Z�ʣA&s�25�F6��9�3S�͝�uF��f�����x��)�f��}����`R��kA�.�U���W�%�5�E�5Ȍ�d_9G��5���Ф�1��%ΐ�jT�@M����;Btvw�'�	��2J�#k���O�躜G���9:1?p5&��E;p�uC/�b�P�{�1���P̫^��5�0��,� �vR4��vbH Q�`s����a,���j��qQ1	yt[��q�I��:l��y��[+8�s���(B�k"�Ъު�Y��j����a� E���������\�^�̀Q�M?l;��g��	�@�i^[�z�8{Q��&9$,A�?ey$8�{u1'��,�!�l��~���u���j&�%�yw�ǂCS��n� C��S0?)������Ʃ�����J�;W����K�����t�e����W�S�!�EK��&o\ĲZ�T�x�Bv�gw�Ž� �/\i)�
����l��ƽ�Y
��#����"ա�w�ObŠ����c�ӹ/4�xup�.	E�ԧ������'!�⬨_O�b���;%$z~4���<��6-�Q��TΊv_�\��Z��?,��sv�㉧t�`�KzN��v�	��A/��a�7�,K�4�ȑ�=�U��^m�"���	5�tH�k T�EIl�]�l1���Y䨜+��,ݒY5�V���N ��RnYb�u���/�8W;b*�Bځ;��U������PE�G3%_j��j��ᘏnd��ޮ�Ec4���u��b�d�)���5�;8���-ӳ锺2zʺQ��ms�z
$�J�����o��"�y'��*�q�Cƕ��,�����v�?A1d���[Y�V�~���}�N�����z}�]'�������^leGiP��"o�bCy�������	����n�c��k&ql�S����_��)�L=��5X���t��I����f%CS'��pt������L-~x�m��]#5��{M
�;��T����J�|���%�ȃ��d>q
�4��Ŷ��Xo�^۶��]-$��b���2s 3�1�:2Y��8�,�rdB1�`	Ԕ��SIl:��Z,L�d8��7M'�#��3=�k�������#j8�R<O�����������qqyxz��ti�,>;�։:���2�����c竿�7��W�w��s�s�7���V�:?Rk�_���N>��E:O�Q��`
���$l�JL��I�R_�`�)�d_�UJQ9�uGt&t�R��&��t�V5"�gnόk.���&p� �+
`��p�� �a�񽯿*���tWt&͸Z��UCDG�YC��=����}�*��y~R�������!W75��UW����K�-���0��c�v����>�����
��W�s�q R��K�:�KpSQ���I�׎�>�J���ii������ݴ.;�dt/Q3զ]G����h�sW�;S~M���� O�O�֣	�J�.�+����U@Q)6i���:�{%u�@zr�|�7�SB��/*������<O̭�	��C#�j1�����G��c}x*��i��)���ԝ�B��;���/c��Ɔ�Ăw&�f6[�t�e��$�%��_�n;x�9{�o[!J����S=4<0E�fRJ�c��b��88�/J�c�����B��	��:�����gz,���+��٭�S4ѺJ�����j-��b����8�B� ->�GA�1�0V�!�-�DcC;�a"�^�<x�p���th�ݩ�T Lt��"m�	���Vz���������Xھ��ѥ��7�s������R�<��O�8�T�F~%lU>��	�O؆	O>"f�ȗ��mA��8�3��������� ��r�����8����B\:bx��	ǹ:OfH7S06�#Pu���9�X���x//����0�R�4j��3����r�v�m$�D$9�(�0,:��;�a��8�����q��b:�s��G`������������q�����Z����Сyz�ӆf��z��q_Ŝ~*¥aF�\L��c��,H͍�W_�.h`������E�O"zK1q�I,��D	�Q��2w?��[�˓�[�m{j���������%�����@o&"�c�.�.<MG� )�q�Q��M����5��Y�������9%��pJ��x=�DV�y��7�1[0B��0��%�T��'�.U�o4:u�4���r�d6)�i�iA��'������K>�55F܊i{g`�(�y�g�����0Z[1�q�rc�\��$&1�f�\�Ц�c *l�㧄�]~x���2���\;�6鰉��	\��`�@ 9*�+1Ű���T�/J�5�>RĆ+�)�	aVG�f9�S���	���:"���n�Ҋ%�k"؅��{�ua�L��J��q�����r'�7ˊ��,�xkdH%�?��#,�� u(���7��>z�[\�i���WHJ?U��Q�o�g�����n����"�jtdH����R�9ͭ�oT�w��+����'��%������ֿB��ֵ����u�ޘ7ښ�_�07�2]@��;:E\Q�▱�*kW�E�f��������`ݗ:G|��HYJ����=��+�$���D�ʑe�bib�D�MS�}�1Y�'p�6�b���ɧȶ�c�'LY�y�.W����!�#�ގ��B#B��m�<�)0?��r�>�rx��/��]<<�|j|�x|}�~���r`�Wׇ����>��Y��cS��ʣ^����G)x����<��Q�F�r�b5��12R��u��j��%��� f��GE���J�A�K�F�X�CI,�c�J|�H�1��4tR�ck�,3r���O�c�x�ԭM��BC�q�Z��0sƦ��ێ����3�wR]�y�|�p:M,+�.ƙ�3~�H�\��bs%���_ֽ��(F��I���`�.�{tB�\���)���%�Ӌԯ:Ɇ��5��L���b�U�kuOşW`ʧEBt+�U�V�3��W��?UI]���<鞻5��b2�&��������٧��d1<�-ƷC�_1Le���ϋ)���ł�W�<f7�_�� 3�t�%w^��4��.[�5�`3A�p�т�E!�-�1�ג� Tӽq���Q2X\�ծB�D��}���@U���1օ�>�s*��4���=p-��
]��(oI?�x��H�܉����W��.fLKƬ\l�y ���	�H�+�&M�m�ߺU@�E�
H�������QA,99v'AG���?r��R����#aeU��<'�������b"K��޷���؜JpW�.U-�h���ՍDW�o��b9Pw�,O�4
�B�g8��xm~��[\>Q:�h�V%�����>'rtQ���KNQz���7��d�i��-�8��_����.=���E��x4��R\)P2\w�kc��~��bF�N�&�i�Î�[=� ��ܰ�k���Ӷ���Z�w�ŉ#����'����'��&�p������L�\�����    2�p�)�$���!2E��ǘ���e/��٥�<�V�|F�ǐ��^��B��YǛ��bc�6��Ó��/XCQa��21.��N�h����E��A��3�wO�?��n36�$(;�ߌJ9cˆd�P�K����|��{Ј%_���L�}����G�P���J5O9[�שP��[ʈ@K̗�ఄG4�bu9֎�X���W�r��.�rF��jL��U#�1���c����Z�,i��S�.��	F��b̉mt�٢5	�~�gt
39+~�-�lE�F���@�d0X�J�Ai�%r��.��ǁ���Nt�+�1:
Q����l8V-Uq��<�h��{-Dr�T0��!��E������og�hI$l �~��MEDC[���v�/��m��h�V���=MU*,ߴ�nA�b7�7pL0^�g-?轗�Qn@�P��2��Xx�R�c8��s��V`�ڧ�p�5��)(7����M�6��h>FդK�Ʉ�X����_F.�R��l��P���H���^b|'tvA������6��a��eq�,���{�I2ڏ&�*�)*��*onr�`ZP��I�����/�\Ơ�Ԩ�*�iEk= 7J��5������8Q솾$���+5A�|g�{Qh���J���G�Ԛ8���Dk��6��Īb����8O�&j�M��T�Ȓ���X	x,��s��fj�zv�j�O�-6^_���U�s�Έα�}&��(mX4�}`5�������X�T�҆�Z��J(��ښR�)���*��c
�ԴPp� ��:�O:��>ם6��Z��Q5t����d��x}uq|6<��0�)� |<\��v[�^�D����Ŕ��}0'i��wH!����8��4�f$(͗�05��:��:2=����#������V����xx���p����
�8�`Æ��Sb�����G\� 8����h��WfE�Y��;A�WR�T���}�i
y���A�%��v��M�ڙ%|�1�I�Y���:��(��-��,�j�C��{5��p��pyP_a�@fXs�huir_�>CU�PNyQ�1����}����lt�R����ɨ(�[1�V�StLm_�v_��Ǟ�N�f�Fk�;�v�����K��G86�L�c�M~4+��-&���vsڝ������@���e�_U��J��R�����ؚ�dξ��M���.�6��I�+�)0�ܯGxΤs����VF��TW^�5��L���3�@辷�b�#�L���1��8�<j,�9MJu}FY�'HK��z���gP�|�v{���b��M7��p���R_�O�Ju��b��~"˱֦0vF!�pK�XAVv��x��R��C7A��	��d[7��R�v���[����L潡1���<�����T �&�w3.��qk�<.�"
�+����_��B?*�&[�>���Ԅ뜆xJ�r��W���}�� ?�DrD�y^hdf�!2���;B���%��O���ˇ�8<�dy��mӔ�hYqŸ����X�EFM�{p
آ*�J�FD�	���1������g��/�8S6��X>X~���y�zzjQ%��_#z^s�3j�Mi|hxo��q�)��M�`�:�+(���2ǹ�5E9L嫺|E�r�)g�̃׀�	�ۇ��P�S0#0���y�pƅ�G�#�Ҥ���VeK�xl���߆
0@Yqǂ%X0th��G�?�0 �5������3������FouD����1%2k�k.W��O�m0�^�A)�غ�;�����U�ள��Kv�ae���è��ļ���Ƿ���l7<��l3�LsP	Ϲ��L��e�d辮=Q�P�ds�$���� U#q�ۣ3�8����R:�`��x kr��5p�@Q�Oš{�Q�k)��Y��YC}����:4%x'�mJ����M	OZ��S���y�7fu�?+�B�|w�n�\ ���o2�%�����(rPׂ�`��1Bd�>Ǧ��Cz��H�e���\�S�e�%�u��U���Ŕ��yJ7��Jio��y�d���شRzL��n�RzV�.u~9<;:4ΆG�/���L�z�:��B����	1�w�}���6�s9��i�٭�:�7�z��Ө"9�X�J~�������
(�|S�5�.B�^�Y�yM�WQ���)�·��%�o��i��f#d��U'DB��b�1)�L�0+lP�Kj�4Q���)��T�d�]wr�r]3u�}9��WgkM	l_��A�]���ԨY!h�zf�نa[�O�]�e��� -ʔ��`1�y:�[TI�����jV�c��({���Z�-2s��h�pk0��eQ'�+%L�Z�a8λ���{5D��ҩ:���&ǿͼ��`�\����.���F� 1]}Cm��ǲ��J�B�
M����$��u�
����[�H،ܢY�h��Xq��>;�>���c���>���$ar��Ӧ-�u;�B?�}�|�D��`��e\��i���E�7F�i)�o3�����~�|~��h��|s�)�\�$��8#Ӭ���8���价��]}�.<�z)�#�=�����-y����C��L�� �����:����͡�Lo�3��6�$L_�����95�\Q����U#�+���HXE�<N�dH����o���gs�A����mN�p�X֘*lf�T��D,*�D`-��m�°����{_����h~�g��}4j�^y��@_֫!D�:���� /�xҕ�Db�i
]w{W|��Z��V(����c�5l���g$9͂��U5��$Y��"�t\�&9 ��=V�����H`U�'�=��p���eJ�~@����˷��d����e��;��A��pz�eeN�'a�Zm����Y^��Tm�`	����I�
Ah�4��������SY��������E�c�E���?�g���Ó��o8�t�¢����%�����H@ �<�G��!&�_��;K�H,��$ı��N"���^�/��cg�W�<|�2`��p/�8�ƎP���U�^^�����1y�g�ln����ū+�_�� ��UXT�x��N1�l�|�T���ݦ�ac���%H��a�I5. LGRU��)�e�2){�x�-�j��s�WJ�=n^�H�^�k�#�4�����[�ﻩ,k�m�.Fb�
$�T)�C����W��_ r%y���.�兩兩兩��2�쌽R��m7�?��e3���T��%�t�$tpVx�;A�c�c��������OK��`��9�O�4��
;Fin*sA�r�d�O!�oz�r��E�zU��w�J<Ɓ�J�)��~��̼&�#��"���(2���x�
(�9����fj7A�$�>4xvG��Y�?󅝸V���N`�<x�v"!�yZR:X�������F��� Ɍ�_�9�#?�V~<<�l?����E��512ʒ�Ž��M�B���b�F�cm�y�g�h��!UԎ�K0�9e��竷����ϴ�χ�,�ܤm3d�� Ȳ4���~.*�`	�f9�J�"��������H�}�W�]į����7��]
z��ݽ>-�q���_Ȫ�T445��<S<������ٜؖ��������t��KA�keCƱ�dK*�t�e���ԏl�>'߾�J��h<�l���\�x t����㫏����B��.01��;Z��nhR.�7,1D����fo�s.��L+�I_M����*=6GC4·D�a�U%�v#*�ŘA.��%��M��$ؘ�=kՙ�%i����b�R��ݍ
��%A�H����i+M�DfB��-a�Y�t�u��y�xKOv�K9�g��"����R������J���%آu�����^�������B��r����hLX-Ƴ��cy>�������uu>�uh^�*A���ȭ�����s�'wS3�TK��j��Q�]���) 5(%%F����2�x�$e� ���`�B��H�5��%��6U:�|�B�E��%�i�#H�5+4����R���Ɩe�:�    ��=�},Y������%����o����s~,d�^��9��r�/�5�fyoxD�C�M�D�Єh����5#�@����\(^��v3L��@bM�8DVQ#]p	���\�9�z
�kEjd$�|�8þ!M�La�%�j�/*ƽ�3�=�⩜�s_">��̀ە��Ro˷؆���\�G�����m�xl���pߨ=��M:ɘ�N(������>T����8'�w����QLkN��Z;
��j2�ǔ���S�����m��w=�������D�;Za�R�y�!_��ǯ��N��Fn���d�E�O�o�}RC,������:@����f�k�`���q���d��;�x���tGz!�a�6G#)k�>(Z`��^�#����,$/p�m����"�s��L���x�Ѣ�֭c�R�K��4���Ppl�x)�pMǀc���~%�}d�Md=�B��tq.� Q�ˎ�*�]Vp�1��}.1�|7= ��Q"��d|Ցʷ�Q�v������C�zi��ؤ$���T'!
9����Z�7���d��X�����g�㦧�_��W�d`�#1d�a��a؟��$�z:ac�:���HxQ��]�Զ���"s��υ�,�1��}1\����67�����q���R~6��|yx2<{o���'�=~B��y:��0�K�J��p3�b7�:b�k��W�?6��X�Ӽ����ho�������|P�)�(���)�h 3'����d�J��%Њ���ߓ|P��EO�??d�r��}�����Nb�Hݐ��Ý���&I�������-}MI`ő銶��l��</�Ӌt�;�</tC߲����K��;�R;��L�׊X��BN�Rʨ��?��i3�|����
ٮ �7�
,OğD5��eoH�q��p����N/rK9��Vi��e9R��L����c�f(��$�X�+�F�9����\��]�I��`k{�D`؋�(ԋr�ix���x�r��iz:��P�^҄B�pg�z[Y�?#Q��,����Q���������n��wSl�-u�'S�w���>w��k��Y�>u��*K��n�d�n�����{Ƈ�'�(�h�ݴ��Vx�	SM���C����s�7���o͈��;�)9���W�x
��3�|���݊��	6 [��Cx���&��&��M��Z�I8>;;���Rm_;��2��FK��"���ב�lF;_Ga�������d��ZK
��D��B������&�t;�u'_�Nf��������dK��c9;��x���V$�F�==�eS�+A�"(Ӄ�$�#[�j����(��K��i[�[�mY���A���P���Y����������\�!Q����ޤĝʄ�D����	���y��GvEw��;���%��Z��ex������|Ek����<ӝ�!�rw9et5���y�I�����q�AN�E��}$a��	3���u}�N\!��i;?v�v�xB�}�w0BRq%a��ӼLFo�X����
�2@���IbrL�Kf<��T�������Mf��Ɣ����̈s�4����/2^��w<��%�1��(Qa�OT�0��C�f�/�u� /I2ߔ���;��m�uH\:X%�t��C�f�݆�	"������ �A1���)�mnn<>99V;~�\f{���g���ϸ���\hc�G^!O*�R�T��r͉�N43���+X)�����
�j�W�U�/ˮ�/�M`s<\`/����h*!��G�H5���P��=��ƪr;I�$�rֲ���E��r�m@�1^�rx|u|�S�
g��qO&�6�����H��un%"p
�wBO�I;�&�=Ȳ R;Ic?���}u;��D�H,i{a��F�L�� +�%��_��k����t�܊J؃��y���s�A�en���x"9���J��7w�n&c/(��^�Ψ�r`�ҡ?�!��=P���+��;xѳ�=� >����}��Ý��l~��v�Z8�R���Ja��(��7������;ٛ2���H-�gE]x�!�v��3��҂��P&{VЖ�\��#�*� ��v�}����ClvDԾ�����l\�~	rw���H��`=!߿��=Q�k(�hp,۳�f&ؒ��F�u��SQn'�`�������Hw�� �)H31ψ�m(�z6O�}ckJ��ؾ}��-K�Gh�����q���z�ؼj�{��E��R!�P�E���u�~1&_U��L�Uj+���"���Z�� �R�F�{&
��xk�I�Ř�L������бjR�"�4�i5\�4���~@Md�u+Kj�Yy�pU����va5��m��-P_uS-@Q��[�d'��땎.�?��?�|m���fqr}�Ǽ�Ău��{a�xa���bGT��.;�g�\l��~��F���;�;|��,�9�~�������C��׫�(�g5��ke| �Sh��!n�����Ό���.���1'���AZS��H/��Q~vz��'�	���U����%8���8��H$��z='4���ER��q��o��H��#�O��C�>FD�zNdB'�E송g��be����|3�B��⛗��#}��6�=������qB|'Y'Q-���8��Q?����Lo����fb�#g���E����������5|��6�d���̓�i9V5���4I�$�߼�L�`��� �����dW8���5��b��i�\��zV�z�%�}�-��7�Փ,����_E*�[��4$���U��x��)>�i̭�C���T!��	xD}ژ�GrQ'�����5�AX�W�������?k"w����ђOG�+L=W-�2;��������#�w��E��?��<��n����.���-�����Ʃ�L~�����D�!���r�J���ϝ�W3�)Iq'q���t���4(�9A�V�`�Qf�s�c:m��g�X0�
�0G�n@ܒ2�f�MB%3�M_R�*(��S�j�$�6���y���#b��cn�t�Д����Z'6�������,9R^���'܃)���.�)�?�d�)��3�5f�=U/9W�`��VS� ��-��*ؖT��O��|4 \q,R�~A����Qq���+��|�w�0N�y1AO���˪z�7�a6�$��m1��Y���BG�YO�?vDP���i[7}��z(7��������f��Q����K�=��f�#V��Y�z�+'���cP��O��f�6`��.<Gn3�!��3i���R�^�¼�8mV��PzY]� KX��(Q�l�����;r��>��ȏ%�^���tx}n|<���QW��h.����N���%��ߒƲ�N`��Y�Pߑ,���ߜS�륞JdY'ח�wNd���aXN�����8~6���������M��*ܻЪ0�d�Q&[bd|@޽霊ڵ&�z��_Y����Xy&K��	c�%M;��'�"Cо+���3��&9���_�i�"�'ф�FE9��˧�൐��P��!^ܱo�i*KZn���W�!E����T��+M?����4o:Um<�������q���|��n�T��xG�<��������%mɫ�d�8_P
QO(H�)ӷj��!�zmq,��W�3���_1�A��W|*�c�-�:5�Ð_{�M�I�}�M>�J��^�Ň�����c��ą��|��JgI�X�PG<��#IOE%A��_�����*�^��:����'��{���Z_]��VH�J)��9�R1�d5����8<���/q]4v�Ց�k?��S_u��+����L��רm������������rxq~B(T��MP��8��b��ˌM��m�6�_�gk�q������Fm������e�?n�ݎ����=��G�@,�a�Aѯ/F '�Q�@XZ��P���·�-8�b$�8%ю�1J:Nb��oHk!�O��$[�+N��̑)Nʮ$��9)�j���'�ק�Q�oO��8 |l����b</��	6�pЅ�    ���P=$o�������u�o�x8�����wׂ̍Z�,{K\6�?�89�6����%�ң�Lٟ�����V�('x��aZ��7��>J f9Ap��g� y*]V�o��.�Z�=��cE��7f�]��c��PFBq� �M��c�I� ���Rj�-*<.�\+�7����Ʈ	P�;�g%�vV��Ob�$�,oy���X��x�;3�.�TQ
	e�v2��z�����j$ʹ0��8�n_�+Fa�?�  ��~�N�d���EM���K9(�RvuJxj�*RON������<�x�	R�޾���D=n�b�Q��o���L���P�W���{�;�b��N����<nL�6�a��L�4����y|��ቱ�qxy=4�O����)<4t%;�b̰7,�ܸ���G4h�B� �-C�������^�l�8稟�-�.�t?2xhP�q�B�IIV�1�[��óH�(98(� � o��bY��V�	�){
ł�@�I��w��q+a],�f��-��@M�-��Y�}���J�� ����2�[�/�崠`����fxͬ -�i��-{̘���c��O��WW��7������)B�;�.l�[����M���4{Cct�y�*
F����QD7㢪�U��-����)�+%�����bF�1I�
��Hݢ҄hV��8`����;���BSKU���v)���'ȷ�ɵ#�WDQ�O8Ȥ5�J���(7�޷�`h��O�LE��� 5��I]�,C`���>�
�3f?adIg�_��y��L����vg���g�6'ER�gz#N��h�8^-��1q��MB^l�>e�3�2�ր�ַQ�/��4OeM�zq�b���?��j"UA��U���bQBr��)W[�Ov[�*=C��9��p�r��/�5�J��8��m�T�����PT�д���m���҅�ba��3�	�O�=J�v�ÞQ�l�|J _�ߠ��KN;J���h��Ӫ6�!=pѥ�V��6�+*?>�G+�u���ʷ1^�g�Q��Z��|�߼c�����@n{$�{8<�2N>_��5�>_�����3��[]����r�a����k����v�����6t5�Zsb�8*�̜�7�pۢ#Q��A�p{å��RcD	;�jĎ=����Q��j�c+m1Um�Ӵ�b�N�M�1]�;]s���n�z��\`�W�!b��(tsS"�:��R��ni��H��Gع�X����\���@�&�;���m�p�>���8�r�=�����D< >�S1��Fs�K��oX��MO2��9�Bϴ}c�yݘ}t�]�~G��3��JZ�_�m?:�|���[�Qd����=X$�I���O�6��M=�"џP�'�2�D�����@bf(�c&F(85��_�{�s �C������+ (:��#Ԫ���i��^HI��['╀?����t���Ln_f[�HE���Z������}��%Jj<�:,3�0u=CJ�Q���ԭ!up#�zfKH��]=�����}����\���l�b]���a���<�/�����S��<WwO�n#�&Dw��8EyU�u�3t7�p[MR�Ll5Bs���uk�
�TT����$�:�ƫ2C\�2�X琒
"C�(��Z=�y�z~��S"�JQ�:Л�WBG�e2�j�w1���ft�:�ؚ3zgHhl���.��+��͹������T��־/~`���P�(m\����u��V\S�f�!��K�M�F�~o_L�m�Gp�mN���I������_�
����'E�\I��sN�N�k6�$���68�9��b4�p�hV���n?K&�˅xs�D����sUt�������)��>����|�z�'�H�dY���V�8'�J��x��bʆ��v����B�μ�w^ux�-a?��?�"�W牑��}��m3I~a[�Q"�]d[�>j����ң?�kyS�z��5	U��R��д��I;��$E3r,/M1��t]dp���F~��Wx�o�+�]/3[\?��,��=�3+�E �?mY��wN��u�,�����%~R��,qb$q��i�81
��K�$����F[��	7�Z*���?pi�M��3��.���eޖ��1��ރ�y7]?��$�ْ���\��ٞc$o,��263v-�m���t|׍S?�,�����=;p�GP����4�"�����c�S#�wQ��4�����v��AT�.�h�Ƹッ\��8��Q)�
ؠDG�f��4r�r�5V��o`��20eѯ
(�uפw�>��q�s;�{c��y�a.i��������ls~7��L�];,s/��dພ�ti���uBO�1��m���w��ζ�;r-�$�ۗ� ��Sϋ�Է��<m-}9��I��ʄm> �� Ҫ���0>\~>��Zǆ�Xz�{Ϥ��pW�>:B'7��\:��H?�].`',q��4]0G�� ;7z�}�s�O�g��R���D�7x�X��;��CBW B��� ?*@V�cFO�S�,"ر1	.��V�Q�]��6)0��S����Wj}�A��/�E�/����;;�oM�q��YgM��$i?jAO>K#+�^�X�y����̽Ȳ"�LXK�V0�a�3S��D���?p�XX�뛁׶����H�(�Ɣ ł%��@�i�f�_ ��n�2��+��
`-y�v-�?*�A�$,aw��Z�1:!飡�HOJU<���9�R˷���uKsnmcBWI�q���:�!��f9v�S��e�HԪ{h�%%.ԟt�#�K��8�C�5cJ��B��]��x�r�c���:Lj����,���9���]Z��:]�>ד)�X�J�*�a�f�n�8ψsK��[i��� �L1�]���.x0����F�,��"X����oh�#�y�x{�M����1���1�=�Q�<F}�yg�D�'�i��f��v�=�o�[E9C�4����Q��yD�Q���|T���#�rv5�`�[�S =��jy��d$��o�eq+�c�'�T"L-P�����Y�X��*���ǋiN�w��z�
�/P�S�L4��D���WtY���Q�.��W��s�g�/Y���ЉE��z�Н�u�w9-��m��������^���ڢ���#A�Чg�nh=��T�G�GvZ{�t[���"AH�����R���d��jdC�A��rLD19V���`�� �I,h{�I�{Q�c��r�z񚼂�1J�6bNzU10�_�R�@܌�d��R��j�*�Q��fp;d�)� �˹Z*��ˋ��Jȫ����_B�pM2�X̓B.u�T*%|�	�T��N��5%:��ܶ�#<JL��y��oIh\����k�ƪ6��>5�J��|;�}���R))�KÃ{<��� ��)�0�=� ��c#�
�h�aǋ|L\�\<Bj��M�ƌ�T����g�
��ϑʀ���~��˸ݧ��o�*Rb�\���#��Tw�!�w����"fŜ8�������K0xE9G�1~򴘎���]�nA#oW��KW��)�/�KY���1���˖Q�$�8ŉ7�� �SW:>l���^߾��7�v{��`�E�gu�	�8
O�73��g!5��`��0��U��n� :��
��k���jI���e��?�w��\���m�W1^�*,��)4i^�q�E��\[b^3Kd������)s�rIJi�\1ο�Mw�^���B(���{kB]Ԧ��Ib�10�Lƣ��5)iG5�h}�t�4�l��8����E������g�߾ꀵ��h:�/?6��V���~<?9����S�]�.����v�Q�O�q7S�G��O{�c9	�V*�ƽ���R����#�v��
ks}�z��k&�WW�맻�Si���m��jQ�8[�����g��7��/D���D�gڰ��K����A�IjǑ?g,�}��4���� ��TF���qL.$:&t:��jЄ8v<P�p�q[�'��(�2)AKuQ�������[�n��    \�$C�ו�v�p"���-��YK���!n�p)��I��]/��Ӌ��k�̐s�uT�24I���l}������XwLo䛍�Uwt�L��yk�?ʟ>Lbi��M�P�|`�1�a���bf�A35�������H15%�bR�V��q�7آ�9~9U��SNZ���.T.�s;J2��Z�秞4�4�_H��t�:f:B�������%�V��v�d��!�T�k����G�oM7���짇�m&���P�Ryg\/��d򂨕PC�W�~:��ԇ�s���vJ��X��\?=���<ٞ�+��ΚΘ!~"�;�x�f������#����|��J�Um%���\�}�����x�8�"Z~s�\PJ�f^ٴ��<��Pp<�WJ��J��z9��̔m�t1�8L]W
/LW��l߾��J�k���4Պ�_?�6D����|-q��k��;�IG�M话a&����N�^4�/�� ��sb��K��l��<'&�1Yzu�`XL� aE���1BL����$�s��R���mAoo`�vhG�gY�6���o_�'�ޥ����_?�������f���<�Dv:�)�Ll�>����%~���|<2�{ >�P>�'�H��3v˽uA�P�i��k�ġ귘�"\�.���+(�U�z}^N�ޒ��2����}��V"��t��%0�bo�|y���==>�6N��sx�n|h19���E��7��bb���Mѣ�_���#$��T3nvG��Y�)'�r/���xX
&>3�([�H(��Z8ߒe>�o�JN����745K_��y"9!�o_u��}���� "�S�m|,"��ė�_�:��݁ԗR ��ǀ�!��.���ĩ�1�sl5+*D�1o��y$�-��8C8_�~l*�Oi���dr�����/o�[X�gzz�Җ���b�|�c�[�/A��þ}���~Jh����8*O(�/��l%�><5N�gG�vd8�q�~}b���:�|T�N��v��}�����U�򶏕����c���?����*3�Wz�V%��4�ْkt0���"��3���
��(��=��YEʣK�$)�!В*�מ@���0�TR��y�$R�@�j��u"R�sVz��e�_��pr�������>�]�$<8�+���T_���l��s}�N(���AՐ��$�*�w�X��Di��㴳��d�8�3�-ߵ���ۗ�}������r��kQ��RŠ)WDMκ��W�[��3>_^�Tx@��] QM����/����ͣ�:��|��82�eҞ��	g�eA�d�-�����?i�׭|��iq�6/����D���>^|~������K����L7�j����Ϣ$2GZٳ>�/���������wS��h̀6'�`�ʕ��!b:�a��%��kY�K�AZ@��R��g�q�\��
�C��5�Е�V:kcdi��;a�i%॥���^��s���K��[���Y�:&-�	�����F�YnI]8v/#vmD��m/��%�43s �$6C�q��N��}�߷'��C6ݟ�=��?�X����lN����	���<?���d�ۗ@��*5�Ǳo����8��,oz�/��9�<�,X�d��"��6U񆉉�^?�x��D�d�p-LVfv�����������y�%�s��ۗ�����ؚ�<`m�׆�z)f��7U]���p���q�tg*��BLЁ[�V��}@Tj��������̩�!�w��u�2Ͽ�f8��[ij(d���*E��z�$��0�|��p�@έ,�l�{���\���D�<#�cر����C5�XGi���$ ���.2�L�:��x�E(��b;j�v�6�������<�H[.�'9n}3K}?���R{,��u�il�|��9_I�`|<>;�:|(�<���QC8pp�ly�;��ǛA �y���Z�x�L/�_�F}
�c��5��xō4�`Mq��mg �v,4�M�4�4����ԄT[uɳq:���*9�9�R�t�b�g�)!�|A�*��w��"���L���$�b�հ�_��%r����u��,���,��ICc��t�G�`�+�MW�4�$����t����
LL1��^"��FU�m�]����T���׃,�d�z�����K��aF������&D��
��S�g�4r��'���ŤF��o���y)'�w44}]�iM&X�*$�S�mr5��s��D�Y�^��hd[���L!�$���� |�(��Φ����C���4f�1'�Ot��5��N2Bp��K��i:�5�_�S�QE�T� 4�WKuds�?�g�j"�S��	.xB���n�ү�Ɍ�\�^L��v_��.I��#�IŘF +>f��r����:br��=a�=�wl��"I���*M�>D2�w�Ԉ�HLO�IԆk��/$�mW�`D�\��ۗ��e��Q~O��B�7^�qq1(M��'�������̳I:����2�B_���}�r�H��3�+����#D�;��,�j�v$y<��� �&	m��Z�4q�y�߲?e���
%R&e�͞QD_$�,�̬��\�ؾ�����e˅�
l
n�o>���+� ��,�� �x�q����v�jK�l��D*�B�x�����/m!D���Yt�|E�>��e�)F�W^��x�yЏ���c�(T��� g\��Y��+kJ�H^cYzm	�5�7��}E.�M�hmY�[ᑪ���l>�������9���?{g}|�u������ϢC�"�zF���K�k�L.A\@9a���x>��sJ,@4�b&��ɪ������hL�G<�X��@b���t�Bg���,3��Up�Ԗ{���Mez�Y� ����� O��їYr?/4� ⡌}�V o�+|���e�ƈ�k˱�8H��_�Ɏa-���8����ۃ�`������,�}����H{���x�f��2ލ��g2E����` 3$�N0�4%N����j�i2��N5���o��܋Ě�ͷ��[Z6��k9��X�uH��4���к�!�a-��j����E��D� 3 �-v$��]�QXN+�(�9�:S̚�g��,�1�\�B�1�dU��W��o��C�1z��k��""��Θ���x_k��+�Q"�;&���������t���P��$�ڇ͏���7���i��:T��qNc�l�/;��q�	�����~�T�+5����9�~�	4��wJ����~}� �rDFS�9�`0�^:���..~8{o���x�,�o0� �|D�~�/Αխ����"H@CJ����3���Ą� ��5[��4{�4���P�ل�f�	W[��k�k����x��5%�YV{2'1�����Y���q�_���{:.���K�}���r����Q~�(˳�e�����+�(J�0�D ��� �ˎ�.���/���?k�\S��������#��n�}��ʑ&ι+�[�j�x:҈"3�Oa�aҰ���y/uV�0��������/���ie���X�	S�MLOQ�}�"�=�ї���U��tܰ���������@9MA�� M�0��X��-���m8�� ��Gs��	���il�q���bq�`�l���GNt_^��#F��2/o������Q%Q�a���Aq*Ӯr�L�i&#�}ʕ>�� ������t{	�+њ��j>���q�{^�`���+��9��]0����S�� �l7�ΊHx�3`e=�6s~)�>�uȝ��D�*1�6T�(NI1�5ߌ����C"7�mA��3ZT�;��5%���y��(�}pbƒ"T�>�T��^?%ivG�4�hV��!s�5���aDT�"8N��qC��bz�!xVN���:��l7�>_/�D&�3u,������w��bK|2C�e��اym�֘�c�O�|� �4"k�!����RwE�������:���t ���D{�J�c�mQ!�|�d	B}Rsi�`j�    ��u(���0'����̶4i!}L�x.SPmh���⿦��<��)�:	����ɐ8�t�)����i.�^�r:�#-����)���ġ̔�Ds�@2P�iM�p��&�n�/R�4�o7�t^=��d�>O���6�?��+�B��}}�՝����?������Q��.��bm�X̘����^��AH����v����i��Q��I�cC��u0�>�v�?Z{�vw-�37���������[�ܣ�8x2ǵ�@�L��֧"H&�Y����]8
=�<�� �P�^�O���2��V���:7um��Iv��s]7���Q��|�1�ňf@+_�o��>�7�݋q�J�-`��)F�@�����0�2�Ӟ�#�P�.�=n[�7G�|\�1x2fMeVR�dӬ�qQ��I�G%��~r��ji8YD�酷�y���N,��ŝ����Uw|�I;�C�Fn��Pn&)�}�͂���|̾YE��	xa��g���}�tg����k>�\0q���w����`�C�Ѥy.����soo,�����`��ߡ�kvU�l�7��� <Ax�����U�BR�z���ma+5����<��u9d���C��;�W���LS0&������T]i�g��Z�G��z�ƺ4�j뵚PG�%�HoNm�n�ӆӞt�$[Q/r#;�$�w��0I��"�b�ϸ����,qB�*7à��ܕO�� �Y`���\[kȐ�-��sqg��ѫIkG�wf.��C�!�"��G*N0�O��@O�!'�]��*�h�x�&���sţ-@+.o.��R߈�	T:��Fٴ����/{q(����Ft̤`�ՠ���}!��C֋	�+�`��K��������xa�7���.�/��J�Lǁv�������<��o��n�8Y��pǙ��0�/�fg��SUW�G�"y9ΐ���;�B�Fy>N�U
�bw>�g�V�Qޣ��.W�8׬e��:�x����!'�@zgYx�}eT�C���D�e�ӿ���M�!�u@] ��lL^�1�f�&�~	NI@I�O,�`�G�G3?�CE?�|Хq%�9����$`�v�M�B�'��8�k�,�N.1��j2谞[��GH��o*���Ed؃ R'i�R��G۶ض�^�{>��[X���S���D�|^i�D��&Jσ����%"�`�1Z;>a��&�������}�c���g'���c��ǌP�r�ӂ�!�[���l:Ұ��b�m��b!�\�x��H��rd���X�:<�����Ǜ�I��)�W�w���������K�m��m���7ۮ��E�??��|�/c����� ���/���
��	�<���3y��<:�� �$��"W]/�Sɼn���g:��e�kao�����鵰ZQ�'���q��M�2t�0�'��9�����7X[߸a�|���NM*;�U��D�O|Z/�����ɉ���`�O?�[;���6u��S�j*C��栦��dMxP�IY�s����gV���tn*���qE4�_i^�\Jc-��]e̛WuX� ?��s�#A%~Fn�+LA���V��e9����,�'�Jl.����2C�2�u�\���x��Ϧ��$�i ���n�I��g�|��j�#��x�h��Yr�rT�7�F�/��+:T����Y�" ��Ϥg�{�c��vj[9RHR�r������X�3�������&?�Xٔ�h#c��5lnUVov�dR~�ɍu<R�Z��<�4�>�^�c�ɏSt���<қ{6���*�=6��;�A���n[o �&.qӷ��0��/< ǈ ���*�2E�� ��
; �E��}��	6�r���`�ǐ�{s����Xƶ�EG,��׶QXD�v�^�`����K`��o�I��$��4(�&t=W���B%�!�4#|F�����5�b���^�h�^������ {��1�o���?���QžK�]!�����I���(F���uN䕼��3�������o� Q4���N�砷�����+��7��4�	d�_[�:^{:,�6�|�c#EȦc[.�G��E�rJ�u4��1O^�-��W���*��P���C% �=z�1C��s�Bm�7&�����$^�T��"�T��� ���	W�[��۶ǰb峅%�ǥ37]\�!L2�\�%�H?�|�z���Ù�p��U'�������ȶy,Խ纗dI�r:�kw�8���v�eX�W�iv�F�.oQ�mX/��q����d��8�r];���
�v}gI�#/�����=:o���*��K��	$4��QX���yA�'U<�[Bby5�4[`��ɋ��M�yp�+��+��O��Y���i��w�_���!�����z{p��K��D����Z0�Q�e+ޖ�Md1�d�&�?ъːiS�_����`��A�iY
cwG]�z�4����� _YM����ct�s��KD��@<�U��z�W<�\������Ī�MVՖ�]��H�?��/Ń#t�)�D���_8�yW����?���Dh'm������"�֜����Gq�H��ɽҞ;~�>\�oü��]�����N��x^u��Ŵ>Jj��a�Pq���j>á�S��lI����C ύ��z���T���˾�XX=bi�K�L/��5^u`ݗcp��Ȁ]��T�QH��sf��w��"�����!5��z�2�R�!�����Ø��3�H	6'�2]��\��E��z(ځ�	�,�#��P�h�����!JcǓ���e<�޶-z��>����&�ؓU!<�D(\L�gc]7��<
l;�f٫����j���+x����W=�jd����''������� ������<7�3�u�VS���z
��7(�r׿q�߀��W4�cd���*5�iqe�kXۨ&4����p%Εһ��he�#r�,G��^�y���$2�Ȯ�ȍ�r�f��B�ha	��+S�hf��j��!�����w�t���wp�z�P�f�
a���n��)~2Ŭ6��UH��Z�]'�fI��I��6߿Ŀ�)���0�Q���f��p%��J���ȔH�ka27]�
Dؕ*HcpZ�;�m�Q/=S鸅%f*��f1H�L0�,����Q(�Tٶ�#�Կ�w�12���5d�w�nb��iV|� qz�ƎA1�sm��4�H���e�e���z�_��Ú���,?��if�T�g��\�4$!��%�	��;)�N��)�IZG��������p�a1�R]"T�g��([I�Ú�lu.�IXb'�8/����k�#���������ʵ2�D�ph�ip&I��Q=m��	)�d4���x�2Sp�y�Ǒ�y�u�Z����ø'����@�ʹ���V�2�'�V� �]7��Y#���A.b��Lk�C�Ρ;�N������y�-�3�^���\/ub�D.8g~����$�F��E.��LD��	~�	]�?��6��ű���.���/M���ddb�]7�}� ?����3�+�ÞL�Ʉnh�_4�{���T!p"��{*�;��z�u�+
C��*g3��G�a�Y}?j�3x���R�� WD	���'�q6	>�"[$�se֍����+b"��:����"�a�8V�*pe��$�Kd)*3���[:r�2��v?p�z��5����&`�뱨w�<[��ԓƭ�Pyh0�6e�9	�ć�1XO�I;&
�Sj�g|s"1D���&$�- H71�_�h�*_?�~�C�^��C�����1���>5,F�>=���
8�L�@�bi��Tߑ�a!H��쫙�k�;|��h��r���ݸ �S�ӿ����ú������i>1���L�m8��+��/g���(L�B��jl��Uf�_M�(&�[kxd����-<.)�I��N� ���>"#�
�(y#yD|qթy:�Q<tʡjPe�Yи,���Y;��������A�C7��@���̔��rHnkCd�3d��Zd�f�����    ���2��l鳮�5.Uw�c[�/��?������&���"�P��^��	�7�Z,{��3�M�:��s[�n�25�hv$�����<�C�g�h�Y1A�G⑼���;;c=�s�Xr
�!K������)�=�`��|[!&��hKq�8O1 `��2��%�ʩqQ�Ͱ[Ǻ�G��3%@ ���y|:��r�����y�ɹ�"Ma%R3�'u�I,c=j@�|+��|�cG铴����+s>�i�i�\�'��Cr&��.�ɕ���"��]�	���lY5��L5?��֑�GSs��	�(I�R�䆭6|l��wk�$I�+�:>���ZG������/��B�0�ghE{)4$'�x�X7���Q$�5�b�<���<�B�������(��kv6eRŊ�+VH��+���x��䖢���p�'���׉|*u�Sw3HR�/�ێ������B��̿�,q�>q��-g�;��[�B7�2`j<o��3s���@ ^����r5Bz[�ŵ)��o�*SeX��M��x��WP�+Ô]�ӑ!��K��������k#7s�j��vv���Qw�x��E��3x KJ��}����ۡ��X'vy���'-��o�.>�-n�b+Z����y�ܵh��|���$qru�Hn�w'��.Hu���}�%�P��M�/�o@�,Z�F�W�Wr<#����[����x0tq�`kLF܄d��')�mXF�9L�B-�v��� L]g_#".o�qAd=��B|1��۩g�1Ź�
��4}t_��W�_�H�XZ)�G��W�~�y�*�hN\�u��p$�2�ċ�R�Y>.bc�-z@p����Z����0ls�w3VlL7�L?�9��<V�N�s�����Eu�+��׉�+�ƌ [\S�ut'�.���zx.WHL�)+N�=ճ. 0#:���J����X��4��Mt��o�9B�s���q��y��@P&��N$�c�4�x�XN�):�(���+�������u��?(��#��7����U� �vX{D�y�m��R����!Z�iχf�f~�0m��;��%�#�Fg�gx�H�E�AQ���4D���Ѫ�0q�E�o>���>G�7[sCM�qk��wǈ���?�B�2-8�7���Y��4��\���G89�k�2v=�-\�s:ON�S𙇅���2��߶e���.Pj��!��-:�GH8,}�3����Z�.X��8h�C�������i���+��MH��SlT�/.�EU$Y@*���4?����_ko�N�t!Y�R�Wא=��jv����N�7�E�`�����H��oͩ��\]=!A&�s8;���������b�+p��}4������&��@��F�h~*�|��8���g�X
�ܤ�
{���nCB�m�-P����=�"��,�y���"�پ���{k	�l�^C/N�T��ohw��sD�@K���_�6�q�A�Y�F<Ȓ7�����^Qe�����Aa���u�_�~�����
ǘ�%���i���1OI�r��	'Q5����ZM<�!���2j��_ꉃtʞ�X��H�y�X�=�i�����$$nJJ�H=��C���0��DN��Q�Hr@|-��"S��iZ�R�K�E:f8z��++#�cU�)��"vT�(����IġoC��z.�N�H�������M��6�3m�X�x��nyF�\�T���/是H�ޔ�����̬5�ZE�m�\8�b�2�ǭ�d���A�������%/
�]�}d1���V��GL���$�#&s��7�Ťs�ߕ�}<j]NZ鹢�p6^N�8m��Itgb�����)�fZa�)Ml���r�n�Dv��`�j������8�M���J����!�?<�ێ�����s�22%9���.	p���j�������|*y,�kbl"�2MPt=� �����P���7b2�x���$L)kj2�r���䙡2go�D,!\Zв���r���B'Zt�'�J�N_����Z�{Ch%�x��=a5>�[d�`CŤ��B��`O�	��(9�l;�6�U�u2�n���D7羂Q~_/�����%vL�4�{�:��r�H�ћ����#=�ӱ�*�XO���O�YM���o�\uEI��!F2N�n����$��2����\�U���窇B� u�d:v�nz��%A�+·�·��LΏl>kz(FJa3Vm-��uQ�D$7�:�k�x���i����1^�!��Rc�:=W��V9xc� 1i����h}�b<��C��k�K��T�}:I��f�i{���D��zA3TFj\+��2�=n�bH�3�Q9�٩,[���
GQ�@�R�*�
g�^��u$���}w;��O>^C�y��t��C:�#��J��7$����1���`o��gɭ%�,����ǩHq���Ǿ�wmW�����GR�%���֋�:|x���tL4L�F��D�yԠ9�v�v�\�I.���tW�*pF��������Z�>\�@���ݪK��Gf�n�ʂ����L���bq�Y #2c���=�;Б$�;�-�j�̷,<͘;y�(�����Or,'��G��n�h���)��4��s|�H��Z�p���T��s�?�a39�6m�U9,���B�G�n4�J��� vz�:�<a����Դ9c�H���:�f��a��DT�1;wŹ85�3ޠ�ѝD}	{�s+ZB�o�����`ۋ{*8\fna	��0�cL��#�6���Ht��ɽ0��D͐�wKՋX�P_�f{P������Kx�<�]���{5��	4_š�J�3�����l�ځN�ۊ�D|&pX-�<�����F3�͖n�*Gt	B{�t�u���b�����Ce��Q����i�qb���0�n�p��G��*P�K�/��7s�E�ZH�opx�4��l2eX �7��6��AA*f}M�L��h���־�T;��A>7��Hl�f'��q�A�yqN�95S�r®��J�� ���SPK��8��dC���!�jj�]��ӻ�B�'~'�3dܯn�k۞C���XdY7'�h\��J�/�J�ހ\�n���9`��p����dZ��0���k
��<P&J�-ӠV��J��V<�?��կ(�T���N�:xz�v�>�e�P���d��ү�
��i*����g0�'��K�T�>Fi!8{�p��((���Et���xܥ�X<���C��(�����%0��K�A��vs��Hu��	s_�1ڧOK��4��z-/j�9�(v�Gg���]��rr|����M(����T�v�g�v�W�"-'V�z�����P4Lbޓh_�1�|���؝L���,	�A�����Y;�I"zP	gmLˆ�Nm�i�	�Ł'W���>k�8l7�3�/�b�83N���gd'�*��%ǿ4����Z��شX\���r�NBA�?�������Qn��]�+q��)�w���T7LD�>���}C<[X�$�__�:�wH}&9>��9>�ޜ�j �����S�e�V��'������v�$ͅ-���iW$��N�f6����mK|2 �U5����t��0���I	��]�;v�H��ia��ZN0,G٫�2���;�*u�Vu3L�>{�+���-Am3��F/U��D�e|�yɊ�#� c��h��M�R���pk弎>�0K�|J>�Ο?+嗚���)�<b��G7�ٕ�ë��4*E�c�(M�t���m�`#*�Gz;��'ڿ?Q�?��dEz��E�$z�&	��9Do(G|9����N��z���p�T�+��ܨ��7R�y_����r8���W<�0q�D��t�sǫ+�%ِ1�B�k�҅c4M�Ĺ�Cn��D=7v��#���/�'p�5�Q���'t�A�Dy$]pf�o����멡)�,�>�y�0B�ɷ�:�L����KZ/�����ω|١T/|�tfl7aan�-��T�1���i�!1H uN�4͠���Z���K�B#!B'��@f7b%s�,��,�c����[Xk��}'6A>l�&��·S����F���6ˁ�辴��e�t#�(��    w�0�(�38Y�Ҝ?(��ld�3F��{ ΂%��%Щ��Xo|rjB�V����8�����I��Ӝ�iEΣ%yR���#�q���i�܍^ů��l/�m��2�̍}߫J��UZ{�V��=O���!���F�hE�	��s�����1����Z���&�",�C��~��޿{����CI���:%�̌9�Ȋ�S)S���q-��p~�8�4�"/��]�g�� �n(`�E֔[�o�Ѷ�~���oa�:c`�a���`�X�c�$�,�(C���&L�YM��Q<��Xc��#�Q�Y�J[e�� �:�+;�s/S����_bm}�A�(V<�<�Õ�Ι�Zo]�Z�@�GY�&P����g5J=���>�,8��9:~���{�����4W0�q'��8�aKj$��;���Es�;QL���c:&Ρ�)+�Kt���
�\��pfڎP��
�H��<�T�jM��^�W|�K�[E�J��p��Q�S������"���%�`q��l)7�[~��-�b��{;�����,ʝ4Sx��io��+r!�,��2��\_O�eBC�	�����9'�o�����	r�$�1����#��g޵�aN�ZLh��l����:*���4�/MC�n�q�v=�7��,��yn�+/��y���p�s@,l�gw��F��&J�!��<�8���£�Pu	��!�RF��������"*��W����{4�8�D��z��UE�բvZ��q����Sr�_��	Q�'��5kC�tT3.�֐f���=pJ3�7�2��^�	��=�>б�,�"|^S�&�F�)�4Ƹ�-6�i���M���Mnm$�^�l��q�]�j���}��dncj����k�p+2�MC���&�l_x�~�03��0��MT�۱�`����i1*eȠ_��H��Y�������ˣ��T�.��̒�(�̎~.����1ܮ�oi�{�I5/��Y��G�D~�&Q����?2*�2� ��̔�����p����mw���\Rϲ�$����uןl�h�OȌDR�	�r/	P��F~��ny ����� �64��;�ٴ��a��O풷��.1u8��D&v�����#ѕn(R��LU���>���x&����L��L��Vd�iԀ�.�Δ�o�<����<5P���B��ch��I��ˈ�g* �t6Ac֍���<����gN�1�$w�|�[H�9.$�� #��/ub�@���b���MSŔ۝�d�
Gx�wUV�FD����9�T{�X����6�[P�Nq�^�9y.�@Ǌ����}_%�u�ƃ (���;���g}�p8�-�o/�Y����$��D/B@X�~?��%>f�4P��l���48Ipf�0ϳ,���v���;�Su>W��7y���������������3n��t^���b�sPA' �+�S���.}���N������{9\�-�#�vF^�B,G�o�2	7X[��Ń��3�\<��Ʈ��ћ���Z��W����H�kt�	|���I���b�+� �P�2C؛�Y�N�L�iIv���S�pĊ�5�=��2�3�������t|5.*},ܲ�z����!��B�N��\ÂȘ��d�M��E�zRUPs#�p�
�����u3|�pj98=�=@��#dw�m�������K`!.�ּ��B?���k��A��0�C�F��{�7�/:�Y촿�tf�>�Ｗ�R7�z�C��gE�
��wFH=k#�t����H����=qGB^c���rk��;(����C�pp �t��&Rp�	D���L;%�3��En�5��������?.�mŌ`��_*"�bDD�&q{�3��>�Ƣ>�[�u\:%����ҵ]ۃ���5c���|f�7K.yp�+�i'Q�dD��K�G�ͬ�D&͜0wm�D���@�]P/w2σ%���vNX���O<k��������.��1�����ۑjeNuE+�W���pA+�E���)�'��݈-�n�ζO���]��p	�l:(\���x�����M��M��Xz�M�@����7�=3�?�E�xr����n���?<�������ƭK	.�fч��E��]��y�'Ϯ4HM�,��*L�����ɂ�@��k�\B��% �c�޶ >H�#��el��ِ��(�"�'f&
rэ],�bߙ�,�ES/������6.��Gt/�e��|T�$�{	g/�(^OM��פ��ō��G��28w���v(�
�x`d#�R��	4�P�'ԙ�u\@7%f=�^E�u�'p==7P#b}+2�TW���B/�~O<�X�� ,�-�8���0��NIT7r� �N�I7kJ���p޼���5"\ja	.�Q!r���� n��9����� 22P�p��a`������v�(���0���뱤FP�]����*�Q�f��cWNV�'z��'~�4�LiM��;Ɯ��9^��'_�x{�[�M%��$렩Z�t�F�QCD5��H�z2�,wx��W�"p�}�C�n��Y��lN�0��N�w��Ꞌ9��C���r� C|쟽�?�;?>�gI�K�Q�ۡ��!��{oq�ztgo���S��A�2�bw{L��'ǠK�N5�T��Y���YG�TI��A�ot�JS�����"&�fn��V9w�:5�d*��	B�1���Ô��G���8Uq0E*Sl��׺���a3��8��R녭�g��%3]*_w��FL�)aPk�!�U�^(fJ#����$��DLU�A*��mղB�(�s�,�2o��3�3����:�q����뮳����_�C�8>>ڳ�����H=�q�FF�>��c;^���\d�EB������+_8
�� ��am��'���Bw"�X��N��eDd���Z�)dm7%R�%͇ze�SO�h�p1�3u�ҝ��e���#p<�]αb��p��m��zQ|��͓5-�D^すC���l�Z��Y�Q�\�hL
"7��A�Ϩ)��P��I��N�W���=:_��c�s�q09U��K`�ϐ�L��W����@��,���WA�U�:_�����R:_?bk�x���A~@'��u쉐ቐ�����>aU�|4B��zڞ}+��@���F����E�O7�q�Σ�t�C�y��'�H�T`��AtK�Ew�u�[��5/M\G��U:7���:<��C�e%�Y�\e=�Ac�0��g6㥞e�~���`���p�%U3Ed���#��H]����ǁ��EE���[Rgi�mcT���V�bSg��P�M��>�~��^�d^.���ܩ/�q"�<��8�3�vDOَ�+�aw\�-���ɧҵ�8�,^(L�9	�����r?���yd��Ø}�|sK|��,�� ����i�A�Eǚ�v�GB䆂B, ,⁧N:l+�9V��(����Y���n&��0��Mw�~��Sp�t ��X�*t���~�9��R�.�������O��G�;��Z�����C���[_ՠd��ήd�#%��Wh����l�ӋK�ZK���F~�"$�^/UO��% ����3���	]/��	d�D����r3X����q��rsK��蛍�4Km��Q?�b�n��v�$I%i�`v���8f[�ⶳ�f�������^�����/uu�@d�e��C�My�@�pV�8�K̕�Q%�S�Ŷ��ܖ`ʣ8��y O���A�v��	�����z~Kd+O[�D������R�p6�	��D�� 	w��]���$@-,��E�(J����Yw�H�;�4���O]���^�H�iM���w��3'��R�.�Bg�&H�<�"�'ӗ%�S+��Hy8���O��֚��
B��-� Ѷ���8����8��K��0�y�澟˨9�)	�n�0Rة����,��<4̂�z����ϴ4�n������4�o���m�<���<�8��D�$ �C���b��0�r��ҕ�����}�~��@&��_"�ΩkG���h�G�ۋ��u�bo/��.�k,��U��3tî�+ЩГ���t/T��P    2^�����/����z��&�v�~�k�^"�l)q5ӵh��5�1� \�<��=x�	���_0���B���@��K�c9�.�+�+�u�F�C,>L�7�Ɲ���>����ݢ>�֌Gt�a����c�p�B� �M�����In��'�O��w���9%��23�/�@@ѳv���TYtu�c5��8�う�5-hR��X"�zKA��Ǜ�9k�4ún��_�|����_������_`_H����9�o�s|����agG^UE:j�ŋw ���e1��Z��˗��zٲ��
�wv��/[������亨&�A�Eu��ٳ��ͱD��@�NM1{O|�d^˪��`j�� ��pP�~#N ��D�����M� ,lK�K��6F ����]a�-��?9���p����wF� @�u�q�ݔ g� �T1*�����Z\��p�q�#f �S��h8ζ�<+Dm���Dh���p^��/I�n��a&�<p��� �큭��� ���{d��U��EE�캲�;4�y^�4��c�q
p��#8�C�䣡!}�^ ri��������Q�K4Yg=������ΐ]�A��ԿT�%��K��9���t�M�-���F����r� 2�%F�n�8Q����pt<�PNk�`�){���.�	�ߢ�Z#֚���?�V���1����Yg�jc�9=�&�o��F��ky�
��Û� ���ٖ&��+��eD���2��{��������ЋV@�aʉ@C[R˦JuW����p���w��;����O�;E�CM��\T�[�n���2�q�6�I�I�37��TGq�ǯ���4o��
�]�'"?���%ȦS��R��m>�He1��8���	��.��|i��q�2tШ��soeH���,h^V
�zaI�A��'�{d�#L�x�o��%frK;�D�5p �n�xN�d�#D�;ȝ9Y.m��H�Lp�+�ز�`E�����*0�*L��w�s�O<~|��Ѽe�2�����Q^�"�k�0~f}T��������Ä�0�����yM�L�!f��e�VW�Jz1��_nը�~Uɡu���W`ߘ����Cl��^�BV�F";���-��!n��8'�]��g�������h�H������Ab¶�1wy�wm���=w�=7��aZqw	�0��� W,bEf�g���QzA.6P�Ɗ�&ޏw����پ��o�ϐ�	�R������E�y����N����u��0X�0}�q��i��4� ��D�6,�z�.0��i��B��r�䃳��L+�ۑ;T�އ�{��/�����n�t����KŷR���B�P�{1�+1�����+�L͍��I#�I��аv-Mѭe�Z���z�-|�Y�p	J�q��\)'}��	$v�K�I)R�	���f��x����g��bA���Qn.������Vzh{�7(�ϭ���ZU���T#�c�/����-43>��>͵y�k��\�#��l�%h��?ۦN{	�ӹ��}�J�&W�42�ځ���b�Q��Q�x��Y�E��c�̭������3�t���	��"E�W�b�.�Tخ�Τy�K��X^��k�&��L�>����/�
���@.��P�iI�S��D���J�
i�T[@mD-�4>�����5$t(ҙ�7ji�w>���O�X�"c(ŴX��10���a��{,��b��.4�G����8#g����o���\���}��OU]��?��F8�Xrtq���mKs��ǁ���D�5$�����β(�����ʯ�/LN
�����AތƈR�WN�� kY4ڊ���5"�\��Ȕ1���7Fr��0с��|ʱ=o6է�~p`�;ǧ!�<%+2Gx�]��a�'scʎ���"�	���7F�<wm�s�����y])�[a7��7;���u����k��*�xa(b��af:9����y��4�	RA�ޢ��3w	�Ԙ�2��F������L��� �| ��u����>�����n���I��*�P&a]�	c8X*���!�g�de�Pc��hK��Ť>'#bM'�3GGL��Dř2��������jG��u��n&�4)8qT���+��l�����!:(	�8)if��v�]��a
^�R�e�Rct�����Q#�&=k��]Â�*z$U94'�n��y#fA�pgTW��[n���(G��r��f&��'߳�8�J��~܋���rH�l��8�)�]�>�}%�gvC��<@�e�QDX�^� �>OA��8�)ԏ�v�����<$_`OB�35�|�hpt�X���	"�.z�wR�S�XD.�	U&�%�
*����=,�������"7��L������o2)�@���[tu�V�$K^���E9C$�_��$f��wq�ʾ���x5~����1w�5�C#k�,'�vܞz��>��0��e-!D��H���b]����D��r�fq�-YZyB��3����_�n�o&�ȝ�����y�C	����"��Љ,��nj�$p� l���A�v�6IY��A���mX��_Zz�T��;�'*X��@��U�p��Eݏ"��a��ͼ��j3��ċdmf���`��wA�~�����\n�k��q�Y't���B?�q�$nכ���"�n:��+�$�õY=��*��&p�D����x�y��i��Ej�T�ۮ�-�^(B���_�n�rR)o>�$�8uU.�<����ic�W�-��;�aF�N�x{/��I�h:!X����"�	��g6�E�B@{,�%T��ރ'*xK�In�������[�������m��w�iw���A�78���'p캷��%�1�zM��^��s��J�"	F5,��tM�W#3�x�QmU��F�q���Y�����1ۗLq�s���#�|��w��G�f�u;*� �ڢa3Ֆu�ڮd1nV�!�+,� Y���rL���iC�][��E����b셂���vc�\�m�����y_�������[w�,z��]r�Zx��S������S� ����4g��Xtj��$e��ȥ
�<K�~"cC`�����������[�N嵼���}����ʤ��`�V����������Tb&��N�r��'�fT�+5��kNBM�s	z����)x_��R��Z}[�@�@��� �<w�֯�K|2#����(�7��tb��w�$J�0��m���~��.���L���]��|��73Dqءn֮�i���YY~.V����'|�^��(}�kKԏh&|H�1�#�8fbeAԕnE"�B?',g�x��x�s,�w^�R�D$���PM��$�4t���ta޾W~�����.��N*��g'���W����
���+k�pEF�s'��k]�j�0�n�QG�f�����#����9�l����x�=x�\�h��HY�j5�(>w]x 0`T�`td�jz]��u���w��A�Fܵ���ؾ�:Թ�K`�y��Ȗq ~F��Tt��Q��Kc��W����j(���7���Da���},����:��Y9N4f�ؑQ�$
�%	Lq�ͺ"���!�Q��BL�Q~)��>Ѷz^���$�U�v�0HR�&a>��m�:�C?p����\
3A&2����ʑ��H��&2}�A<8#�X��F�u�+I@ ���;�ƻ�0��������[뀵4ƨ6��k�^ʯh{(�
���lXf8e�����僕R����U���P�x+�G6s/g}����T���Ke�j��h	Uxs���0�~7D�Kݐ����U���B�C� �W����;�á�ߪ��s�O;J�}���"<ӟ��L(}c,C�W���I��}�P����h���;�&��-�+��H�
�r!�J}ũM�3���]�a����ʉ���LC9a��/���i�L�9B&O�F�q9����G��t�N��<¹;(��<�'f9LJ�±��nd    n:��WuqAq��� �\�!ө]�9=�e���5L�g�¡b�K�*l�l,�&6Fa<w-�1~w9��/k0����P��;�-H�6U��;^���H��{��^}��:5���3k$�5�À��;��M���
�7�9�.'�i�6�g��6MY��j��I�����p|��,T`�,��YKq������|ls�I6�8i�99�'�Nm5S>��p���g��ߙ�-[p?���!��6�O^�������-�>j���w.�?��|*����5���k�W��Y�?r�-��\�4���D1��4u<�2dI�(s�q�tb�/�[�X}z�=5�p)h��,� ����m/��p����%�ԚJD;y O#H�M�N������"XRҀ?�0�����;��#s���Tհ)!l��E����������Ip3�N�]=}>?�p�G����~�|����Y��s2^!��G��9T�zz�(�n$�Mu��[���x�d�x�CE]\��,�C��[����ۡ����o�j[|w���TNK0�G�H���뉤Or<U֮�1$Z�"0�W�����y��Y��0�A`�!�aD"vV�� ��3t}�9y��6�]�h��E�]�Ӹ��r�����i����e]�dx*����g,�MA<�؂=~���LP.ư�&X\��	�TjSI7������W6�'��N+ʣ�Mo!���YT� Z�>���:�ݞ�?�1&����������Ђ�w|���~�e�w�h1_�O�P�G;�c�(��-F]a�!�:��	t������n���8�fЯ5�P,pmQn�ʑ�r��?T��NS"��w�Ad��f��"��w|i2��M����f!�4[?gN�tt��.SU\�t[5N�fB �`Rf7-Z����J/"�4��	v<�����'q�}���.�%���>2��1?�[K<��r�h�hy{r�����Ǜ�bf�6�����A�B�Pym���f�5���
�y�F�(G�y�S#��.c�Ue3�v7�����-I����z�8�b��-�WnK��C��@�
L�Cr�`��c�a3��P�Z�@�Ec�Rf ���4�9BJ�"%���LGP�������C�rFa�fJ��J�Q*L3���J��R�9yEÌ��$����x�hӱ���mJ���~����.��|����n��`_Ow��t� P6��a�UÏ��v�Ǐ��;5N(�R�*˶�|���#��s�j���,�^�\/���?f�@:����D0e	� 7�D1����t�j
����o�� �B���-���r_)�,�{:�U.��dKS���Iz'�3C4Tn2�]I�x:�2��P6�O0M0&�Ŗ)�� �Z���)2�~��$�:,F��Br,��'�5��<����p�������u��?����A�|�H��Z������gp.���@~)���l�F���Z����vJ��1QE\�~�	x���6Pd���J��Q��M�jM��<$����XKAw5�����.� b(��r��a��h�9�O�1�t#��_���^y��L�=�WSx���B׫�0�E7u�T�|&�f��筭K����f^�����A���zC6 [�8�߷݇#;V�':�G�����?��~C�G���á������0+�����D~t�G��H���B?�q+a�ӵ/��U�jV�q�Mo���o�s��|���|hF{0_����#�gա E&|n�K�/����9��0C��_�;=�	�o�)������!��`�$XbzA�(M��]�YD����7G�Qy��J�2�&T���n'��^��N�I7k�����p�Q0-,��oT��s\gn�L��<"'t�0v�9 Ͳn2��`�}���Z4�R怅>Bjb�pH�j�)�C�x�K6�Aǋ8���i(&�r�m�H�[~A�uo�YD���4D�p�xȗ�iz�n ќn*��� 6�3<�#�z�(��̀z��e4�d����z�u���#&h�Ic�(|q�������Z��D�:x�Ϟ��cZ���:~u�F\*�QpK��[Ɯ��ݱ�5<��`�L��T9�-H����Q���;���+��譺�Nw����ӳ�z�n���=آ���3�p�W�q����A�h�͓`%�N���oD~��D��4��$42�!L55!�[O�栆�⚱��$�oT��yK�n��1w����6�&j�:���v�9k��,���i�û��"���\N/�8>z[�mZB��kK�j����)ҕ�&�!Z�OPcp�\�𾤗�q͌�N�ٖ��Ǐi9�h��N��9�u��F�q҇�u[uWDQ1�'1����H��z`�����À1�3ƶ.�j�qB3Ou����W�{��fHo��%��)�򷛋: ��&Y�<U��ZDh�����>���Q���j�����9�l�h�.�����-(��4����I�M&�"�Nt�[�_;�|_����+n� ���v�?Z{�vwk��xk	Pg�{��A��|�.�g���6�b���avΎNN����x���ک�̌�sbhr9�L�6�o�2�Z��_E�͟Y��7�1����Q�D:��������D�yU|�YG%��`�R9�~�2oݿT�o��xHWW�>�w!�z�K�?t�'~��q-��J���jT\9�ٜ��J�����n�I��gŠ���e�h�B�De�Ԇ�a�2��~OdO�g̵B;�+:T����Ȕ�����ӰC�A}_v<W�+vaf,�x{?�F2X����f���"���W��qW�lJ��G��צcl5��.��L��,��H�k���h��-DK��0��M̘wJ)�g��	��l�H�!A����)��y�����w�)�C�PݖH�������Ԇ�O�i���fc� W� �0��䕕��S�v`�w�b�r����ݛ�]\�:{�,�#���6�B�]+��J.�,�ZL0oM����i��� ����c�@������&<L٠a��0F�3�MG���衺hC�")$uc�K<@����U�?<�f9h����p�wqO��O{n�9�O��u���wK�ᄞ��g0	�E���"�&�Y�}���bt�VcM0WC�3L��cu!c�������eo�J*�i�7]���B��Ҭ�g�Y����jqee�y�aIL�#e:$'XT#�u���-��|��W����f���(�1ﮕ�z�����nY6�T:�s�Kl(��k��?���O�_�"�,���A�Ѓf
�\`�If��s�AwήHں�w=u��j��Պb���F�B�L�?�9�idBZ`����/�@Cc��=M�۠L��Md
*��[�k��q������k�%0ɔ�B\�P���[�M�4�~+��B$���L��iů���o���g��F!Ĕ��{�Ge�7'�#P4��$˘��|ڐ�i��_cFYVXg6�9�D�r��N�S�]�93sL�
�ڭ�;F)�eƥ�).p�<C}R�DK����J��kl<G⣲���Pe�w[�5@=��S��8�U.�/'���s�����piIzc��#�:�xKt�xҠ�4x�l�[��DC��i�ho�:�`��Ľh��h��a�:�+V������u���j���!@�u1�����r�-�Ev�񧐾��|�oT����<F*� �c���`��H�V��9Q�N ��`��cWN~q
R���Y=H�]%����y(��q#p�Pi2um�#t���"c����������c�Y�����1�|K�×^�H'�^�ZYb?�&n�i��k<\�;�`۷{���bKz�5S����z*�5�$OC��TF��`|�<O�vwr�C6��Y��T�����P�+^o��?+>���?kl+���)u�����{]C���vp�����h�(R��-Q���P�-���)[�/K�,<����(Sr�^�(�ƀ��Ο��G���� 3$$[V^�xF
U�7��I�Q�5O��3,g�e���syS;v%��k�Jq@��s�a2`*��� 
  )Q��Z�f��E��E�L�6g����]��Ł�y{|z��h�:�}k���*゗,a��W���)U�+W�wy�ʦ<U���U+9G�/z��t���z��e�6�6���>6�5���z�'¶� xx�%Lb�(!8�5D�`��)r��~�t�񝌜�1�e�wk���A���H|���ȍq�+*kla�Ģñ�&ȉ�Ѡ�/��$��%�&wf'U�	�k��
L���Z�t��|�$�k�i���e:>m_ˋ�Z��2�����uz|�k�^[������Ad�mpN��w x�X1�%�B3W�O߾-�p��r;s8eia	Τ8�ј�ȋ�W��iE@4~����_� E�D긚t��z4�2�5��R�h*������bNR��3�Г��6dt)rxsd�_ߚ~SFyͦ��Y��ۂ���A���YB���fr�m~x�' Ch��D��5lEZ�7Eo���� �aCZ�/�k�������w�+���*�����O?����(�      �      x�Խˎ�8�-8����w�4Ҍ��Y�;8�|~A�?z�<�RD.�wǮ<�:U�k[�/'�E{��cnޖz���[���̈�8.��0U�}��y�J.�1����?SK=���f�h`)=��H�t*~D�\h���o�c�q�!38gN����}�=����}��܍����d�%��<��:�c8��N�8s��f�L�����=9�6�u]�*��앬Or�xc�L��V&��|�(����IO��z����k�I�1|�ѭ��e��x���' ����`q��\�n#G22�&~�Q	gZ��Z�ߏ7�f�e�݌�"��9��]��&�`�l���Q��|�������a�nٳ(��%�&�2�U�_Iq��$`��1~����4��ņ���|�\ʨ�UZ����-��>�5/��3��_ى�ς�i� �z����۰>�>��G�1-'����&��U��Oj!|<�Z�w1�IATz߃F��;��'4�I5�IZ��nU\)����J!=3�}͵-��˧��qk%�dc���k>()z�WF���k��P�#e=0P��������O
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
��n��5�A���ûe�������n�$N��V_��������ɜb�㩼�D��!r�Z��]�$vђf���IA���t������}@�*E+P�X�����#ՠm�/��m]�m�ְ$�����k�0uS�n��kQ�7#q�����X]ߎL�[ٔaa��'E�n�-�'��Y���/cat�tcVAT�Ѝ�/��h�UF���P����us�ب1�YEZ���bye+��`r8�:�ҡ';|?�x~�~R]�z�a%���S��h��Xo?;�/���bE���N|�qmINV�[�$�ۂ�h�&c���)�Ȣ��TIᬌ"�h�h%�k�����Y(�t�l�=�z�I��uޖ��U�!:�.��gcq^��c��znYk���+��Kb� �9����y����U��_sW�9�����!��(�;|��^X���aY�'v����� S�N�e���b�Y+[�,R�;o�&�>�Aqt����QŽ�P�.gx���0�>����L��K�ql�v+�l��8Fζ���"���#���}�SE��1j�B�àØ?�%�>�8�gb��Iv�������l6ݨ�E@�G\��AL�Vך�72j�*��J
ST�,�{���7u�R���$�S��$A8'�9�@��&!�ƈ��_�c�W�(R���ZB ���5�DZ��,�Hݨ�S+T�" �O�#�u�+UN3�����(�?&<(b��YF�&�b��=�	��L6�P	��	��{P�Z�һ�3:7ί�2o����8j�1�3�$�L�M%[G��/�6��k�VԐsw@Y�#H���J���	�o��}K����Y]���fb�`�� xI�D�9����Jj�- )���{m)��TO���)�}AÕ0�ƍ)5��z��^7�ր�;Vse;�sFRîu�=ɏ�Pjv e�!�]��˿����*X��l�̅�;���gH�=0���e^7�zɼ�ŉ��M��}ƌ�V��Ig�ݣ�q��	���͜S�:-���`$�!��ca�)���oUɁ��x�u���T�3��� K���ǘ�x��_�FY�筎�6�Q��%��
u����C�Mcz�#(C�ϟ��3��W��#�c������Rv�4H8/ ��	�e*�DC��LT���(tXL�|D֤�2z0����Zl�ֹ�p�$�~�fɉ ��=@����&|yU::l�Ϊm|St��9<����n�h�s�%&�B������'����=
�qIiY=�q��X}a�"�5@���3�VjH��l����c�� ��|��T���2>�|�+��巭���?��R��GOkB�����L���Ş���b��,yc���|Q��$d7���^|)�;9�d۶[[r�W$�R��C��1�Σ��g܇��+�M�A�L���y�ˢVC֨�����&Vܧ���[��d�Y�2Yc��" ������{�zq������b�2�&��ޙX}�Gq���T�m��V�- )ͫ=HeC�hy���c�=�v�~��<*H�`�]��ڱ������C�?�^h���[�w&��8���Y   Y[\�G��+Y ���������ϛ����Q�.t:$�S�a|�IF&$2��.���k[�WFu��ҺO��d2���B�S��6S�t�:�I�]��h�xca���.��~s\$A7A�����@�2�$Y7(^�8�я�z�9����P��Ɯ�0zca�U���J�?*����k$�C+rj���D��W%�c~�>%�c��'H>�C��Q��F��*�<&���I��L��wۇ�ڋ� �7�ArB�c�@MW�����+'�������B�9���Ċi5=�a0�Z��G�PlU�&yxZ ���A�[|�3�0�1z8ݘ�c����`-�c���5e*gr�|>�C���&J@��7���Yɭ��3y�9�^�f�7nq$F���?�L������"Yȇ<�%Mǩ��s�$^'!�<�D%�`�z(�Km#TT�XUɘ�������d0�T�3-[�L�d\@r�>�D��}��S�\�zHRuH9J��ʌ0�}F���F���)�ԉ�w&�l�u��_�	�E��zi�C�~���SU�,��w�I_{��c�#FIo�-�o&Vq/Q��%�4:�s��*�d�\�J�=�>�����\,�Dlc�F�ښ���Z3M�;+b#E��^b�̧����m����l���i����U(����&�/�IE�Ѱ�g	=�X�9�u��6�3����Kv)Q�l��n{Pe'Ȇ�gtߙ���٧�h�6�[y�$i:�|kb-1��)�%k�%�N�8o�� E�����h8��?� �����ލ�&�hR��9oe[��vy9qz"��P�r{C*�I^%kxB3$�K2_��%���.=V�s��f�6�����8බ��� d��J����qb$���s��Z��9����^g�>gWm�l$,(�x�H2 <:Gz�e�F� s��<*<j4�?;_u��ĚeLIr.W6a��X�K!c���(@!bo؃d#��T"|�3��m�I~�K�:t^`ܯ�3_$����O��;T�^_o̔��u#�%@���#�w�I��g��P?��S��O:��H��!^����-y(EC��i!���V5YxlZ[ ��W;�l�p0w���8�W��A��֒��"gJ�J����-	�0�yX~�����6$���ۯthITY_���u�'�N}�B-�M���.�'Z$z��G؃����[�3SP��L��i�M�e�2������3J� s�����R������+h%�vM��_:��-�^�O�UǗM��y���?5RVV      �   �   x���;�0��9��唓[s�\�Y]rłZ)E��[qg�[��M�)HUHY�T#P��76�*���tm�/"��RY8�2D_�r��l}����֭E�۬S�$�B!��l�:��v�?����� ݲ#G�)�> C=O��<�8O�u���P���	�\e\      �      x��m�,�q&���W����$����v/րWZ؞i @��Z�-y%���?O0+�fee�ˬ[u��[mw7+�L>�x"/�%[d�Gݤ9JY�ѧЎ!���*w:�hj]
�Ѵ��&E_Z�\(�6$�AI;w$W��Y�A���O�8aR�I~���-)��gI�' \8�K��y�~���-�U=�����ƣ%j�>{�ѧ�TG��^N&c����Kڞ�8��������o��������������O��o����'�ױ5)��Q����0oJ�Q8i%���<�cߤ��Ϗ Q��Y�6�%y'��6M1��m����2G~����cLQj�)��������5�Z�˻����3�������ƼIq��*
}������r��_nG*y2d���\c��߷?�����?���������I�?��O��}x��������?n��>L����a[36����LK���_��v�jw� R7'H$4�IDW�֪J�G�1�(�X�h���6:�dHj���7�o���~���(6k�q>���cr��JNI��W4��rP����5DmU�[�aÓ�+�ň4��L����?	m�MV�11� k�	�8s�X��j�Z,�l������c84��.ѯ�ƞ�I:#���K����	u��aw�Q)Y�*?���bC�RQA	Q��}ȶ��yȦ	�7eN�y��{��\I�R�,�V0sI%��!KΪ5dm�Rʔs��C��iM��+N��5��8�������l�ʫ�X�煆��2(IT5kkR���0`�6"6CU���逅X�oZ�fjl����!ߔ>Ie��g�FWE���:�3��H;u"V��ݚ�=���=���=��GSd�b?���=)��ޑ߷_�qj��k�
B�
MK1&���� r�J�:7����v�Mk�A�tV%+Ւ�bP
� Q�t�-]��s('R�3,m�I�l�����E�@~��� <��o�U��tt"�Ʈ0��ⷿ����͏���~�����χ�������ǯ ��QiV��3c6p�z�̯ޙc�
Lj��B��E��b��l*�7R1�8��eY��-�?b�t�T�� v��C�U4�"�`Tʣ���>I��xh�M��M�3nD��̂,�IX �|Z��'r|�$�������_�)�>�����$�#ަ�G,X��J�#��βژ�[�a��>X+�*�@��A�ۚ���Ûpo�YH�~��V2<���sB�5�"e
0?��E���Ah�U�bYl���U|�+��,0n�D!X���C2Yi'�b��;�&�A>[��8��_RZz�E�,
��I������1����B�Z/�&z��~�N�S|P{`��#*��LJaf9��r�5��R
�D6�9O��$]��J���'zW3���C��Q����V��G��o����VK&~�8��
�I���8���[��r�f�!�ܱ�X��*����+�p�ɸ�̈́Q^g��iƨ��1��f��f^B�W��Њ.�H,�ȱ�H�I��#�0jS�ZG�x��0d*4U,
B۪�A�ݜلv�]c'Bp���̓��R��55$!i6��L��cI!e��'�CP;��eP�f��@	@��Qj2����x�R�O4�h���Q����MJ��H�������n4�F0���/��?Q�._�� �N�ϝ�&aSt�P�����ޜ`��f~x��r��࿐�q-y�4����՟�\���CI1Q�cf�0a�G�.���*�FDG�j�5���56�����������Z
�����T{�4�_���ԭ����o�N�`��~����O��7gֱ#�v`��lj2`]�ƒX�KZ�� �j�t�ͼ�4T8�Z��^�
��eP4	J��xKP9�c�V�A����56���(%|��a�{	��'��i��S�w>���#>FW3���J��c��`)	�g��jŒU�u�i�V153����i1{X�1�CI�����(3�U����ގc��0AX9��g[>�&?���gw.��aO�o#�}��X�N��n��`��,n��Y���0S$�+F� � /���@�AzC�s��?�蛨�*��r��*�f�A8H��X�g�K�>Th-�L*�>Tbx�}���@�<�+D.���P�NT�LPR�}��G|�zf;��`�F|�|tF�g�Y`ԮiA�L��?_e�B2xO�Y���lK�z��Y����XҠ��En�-+ fƨ�Z�5F��5��%�_����;�|#y��#��o�?.r_m�o-n\�v�e�k�v���C��A��;6kY�%�g �q�l�(��W�5|M�i��0���q��i;�	
�����u6���& ���!5�@�~V�7SE4c�;Я���5�h��Nc�N�d����*'!�X���#�*�Z� (�Z !J����	���f�〭xU.:[�:�3@Ww�M���&��	R��P4�Р����� ۱���RqP%�,6�8f���x� ���Ac,3�W�Z���-�erN�k1��y&�y�)ꔝQi<^�ǟ$�A�p��'*{7����:�����1zh����S`;���k,5�Rύ`�IXg�JX�RE��g��&�����!�T��-j9���@n���?���U:�h�u��R�`7`{��Q'���o�>��p�5D`+/S�;9tcO�n�`MƓ�KY0�K�2������@	ɥ�aN�e�Zs�(?���GW*��W\#U��
�(w����yܫ�ŭ
����(�[�û�<c����) 4~Dx/��`:�]�k�l��]�y=��E���_�3�����%K�8.�v*����f�
��P����f3��\˿I�(�(0�{Ù*%9��F��&|��M�k\d�_�V���5-n�ୄ�'��d��{��	O��಑!�᧣	�`�c���.n�7�a6��`6��n�S�r~�uswUS�����+ >�X	
����n�Ņ�2�-��(��l����D�/�<;�Z�~Vݪ�TB�F�#�����~�
��ʇ��B���ޭōC���;K�A�R�Q�� �����xR�c������k6�S� �l1(I�AɃ�d��mG�w��F-'��o. �n$/�P	GB������\���j�+�ŀykq�`� ��� �-����g\qxPp�G�|O��r�"Rh�~h	e%Y�C�%Y����Z��r3�e
zf��BAX�П�5����},��S��zq;H��(��LP�%8�>���2dU5	�9�6*�޲�t5ׇZ��E�E�'/��U�2�kg�-�f������3Gc��Ӡ���`^-n�dP�k�iF�J%x�3@�|j�g�(G�SU��`���A�EX�R�$�����;_~�r�\⍁�\զ�G����<z��bς�S��|���|�Y���0+��a�pF�h��ܘ޿s�lAVr��󭇗�X��,AV�O��9v3~��ǒZ�%[�9V�JH>[R� �'�<�U��= VO�䍱�Y��"�akq;X1ì���l��R���N~��8���0����mI*Z*��~�EXrr��g_�ѤV�Tjv;�E�J0MC�DR~�;�<�j������$c��a��ɷ��yW+�Vo�6�Վ2ȧ5�rR&y��ua�Jڨŕ��-��VZ^F6Ψ�h�3��8(����cH*%UȔv�^I�Af�K�,�4K.+O)����[�H�7iNV	��/O�^/n�f��5̬YG]�ٱ�B'߃�SZі�I�<�-d�(b������dÇ(}uz�u��LX�} �)���8D!���/Ϋōù�L��%2FN�1Jg��e���Wiv�t>��&د��Z.E�M��A&+�-)����31+�����(��db�7���\mS&���`(F?_�5.���&�����gbv�H΄XA�:Kh��C���21q����Ms��okJfO_�P��ȷ(���D�L#=�I�6    pI8N�����a�5��0TN������=b�j)ONl3_��5�;囤�� D7���@�͕t,�.׮��q��B:�&�Qb���ǿ���귌�T��f��M��Eб4U����^ˠ�b�YgGE�h�ޔ�D�K+d9Q��KUJG���_��:VO%y������4J�6	ӻ�$�| �L�X����ڇ��zhM�!+$ ���M�g�#6%ؐ�������ͩ�	v�s�r�DUzl�]��,n\w��\�0��2_�Bf[��ǔzQ��Js��\�}�fab�����_�� �dV���t	�Ӑ�e����pb�o�<)pu��B���i��G��)��Ls]�7ٜ�����>�
�Ms��W#+Z�;X�NBJ�K�>�C$Wg��R��R�)c� jB%׈�ؠ�W3c����NJ-Xõ���uW���#]��Is^R1,U�3���I�3��p�c�"s�Z6Њ�m>a2hߌQA�V-*d�ڢ_a��)��+���CL�7!OF{%��~k��wA�jq�L1�zsRؙs,�x����5;ĽUk��d
��ѡr� �G���k2Qh����f74�*�F�L;h׬%���-pUl*fh���(\٨�0ْ">�]W冼�jWE��ä���q@c`���� �'�۞"�9f��S3�������<J�K`�5���
d��P�zT3h�^Ԑ����˥�0�����R+r�Q-2o-�gF�,@ �#����Q���ʁCE~(��]/��7ǥs�[��5}>9�W�s���&W 3�Zn�Ȝ)9>�;`.ZC�	<X��{b��|��3ik��Ǐ�>j�(
g9�3HQ#.7XNx�j� ���8}�ϙR"����Fx��IV���K���I�Њ.*�q1f��4,W⺥�Ӻ��a�Q�8�(il��rf����Z(�E�ڶ/��I46�0��݂���� ����k]
�\"yr�t��H�V��d���bQZ#��ωJP�.��,@��iG�5.> 5՜^!�����''\uF�zbW�{�ll>������&�p(�5v|0b���JJ�#v��ى�̎�^��z��jh���k�3eJ`8��8����TLJ9O���i�X�.	�m.��_R Hz:F%�,��kEU��xħH
ܜY��T��
;�a3`)�b������i�����B��ܬ��y��2�̶�h�?�&R�� uG��_ծ{����^%x%Gm�U��hF�k3>"�zX��A��8~�O<P��}�g`*�K�'����&�T�Đ3� �������+��d�T~��q=R��Jr�寴�迀��Onr¼�Ji�O6����{)�~�~2��듁�̭�^��	�Kr.�[$A^����%�P��Cn��q����� ϙ��qȓ�)Mý�~�S�RrX�+<��R���nB)߳�=r��ݞ���l�|�ަĒ�Hc��
#r4�Ϭ�!�6>���n��i�k���������9𕙗��f��K�+,=�3+�,����/8�r ����g{�ȏ?A7eՂ��#)�H��]kt /O�����7?aHp{�(lwI�t�h����sd3��A��:p��k�H�c�,&�&?����SN%c�؋1p*�غ9hT�Τ�8a�h9".ː��Tq-9�͇��(�����T����ǽr���ō{�:�l�k����#j��pv�8[��0�c��0	@S�{(�B"��Zi�P�۟���>�TZ��Bt;a�)X<�]������䲗 �5%��y_�t�e�u�l��0�)�����T��t��X�&�7W�A渹�5Ȁ*�-�a�uI-���'´�8��^�-'���2AA�t�z���ˠЬJ0�:j ��ZVŭ��?�8q*�j)�	vݹk�Ϣd���f��_���"h��kJ�5�i������s��"��c�#<�p�V�厉l���r#3E�q6��Qnel�]4�,��o��0kB�5�TkJ��ďF��w�\]�P�HM��ͣ�����H��>�����XJb�	�-9e�����i��K��G������\w�w��	�j����^�kkq?�z^������S�H��nм�*�t���^q�z�9�0d�-�01O*�]�#����OѪF&��Q7:�28���aF<{���V�rL���L-�.�ٷSAp���&n�D���o�����e������m�6{	P�Й��"|M9p�=z��eP4���F�"C��E�4Pb/.}s��7Q���иҮ������@�>y�`���{��G|Ep;���n���Z�8T��KJo�V)u8��2����$|�k�5@��I���y�=N\�n�D�ں����9ǆA6���z�PB�ER�kɾ$Y�QI¥,|hQK��S�����s�]Ox�A�JOR~���8�lZ�jI��K��k��t�ek�(�d������m��*��u���1_zpz9d�z�6UZ�P腗fg5wĉ��r�j�~匉�]I��qz�wKiK�;���f�F8��h64�3�������y���y�#G�1��@ˍL>�aE��t�7kGsGY�7(NPт�0�ö���\� Fe�qA��͏`��Pή8X�q1#�BH1@��	#�Eo��FG?�B�/��׉�]M�7��!�d��d�y�hL_F#�޽���%�xO���W:J/��E][�K0ACT�g���|s��T�y_rU��`�|V�AN2�80��#ԟA���J�Y!��F�a�3�(�PG#�ـ�BF���@+h����	H�Š�j�{|��
� e�yF)�U�yFP�܀�{qT��%�Q��C�G)�%.ز��X����e����2�=�3����;-E�|�*�g�ev��	I%$D����9�a�p��� �t4M�a ���Pn6�ߊ�}Q��m|�R����W��� pT'Xϒ�A\���E���y��F��f�f����?���ƾGl��c*ر�S
����\��zl��8������w��|"�B�[b����B$o<cS��.�fĜ��]c(*�D��@/T
B*�P��u�z:�V�����OOr3^]c(�`�f�;�����|(�W�eh���4oJp׏�Fr���{�=(
�S5�/7AY���63��Aw�x3�q(v�Xs���8ob�P4M��˒)��)P
M��-��ި���	�9�f�-C�Ҏ��*7�Jk[�'��M��s��wFj�������p0����M�GN�hG�F�w�qE�Ыw���'�I��f	����׫?��D��R�5O��q?��5�X2��#�|.��(7nuG�ZAA�@$�g�r�]�83�b�X�ش��P����s��8�;�f�y.`�Ȧ%8�S^B��D;a�ҋ�`-��<���ю��g�h���Dj+��%��9I>�����d������A�A87 cjz�A3,�;�bph`�qn{���
5��\m��<�A��;�ff`����Rw���v����A����յ�2U��l��&n�$Zo�$@��+����I6��坩�"|kk�C���7gn�A��>^�KU�`"��Aw�$n׶K6fM�a�YXv��{���6�ٯT��%�e܂�U���N`����;�/�������P�IԦd�~�����GD �'��~�/�T�P8�"�'�a��q0w�E� S��v^5[/�H-3Yo"�A(<Q��5-`K�B;$���Y�UF�Š9��UHY20��eJ,DI3�����5Q3���/�Ke�[̋��8@@X�®b^ߊ��P��fq�x�8��g�S�l-��h��^x5n����V�%T+�?�[� �����7��u1(qWxդtNrm�6�g� �?�0�����k�M	�χ��\c�֘��������1�ǿ����A���D^����L4�;���.:wtR3�a'��)r����s��N��z3�9�/��u�[21���5��L2�l���g��/����cm��-<���ckq;�� �g�d���|�ڨѲZ�=׆�Np��+h��ޫ     kPr-�Xd�ɻ_��g�K�&��ĸ#6�Z�&���S����*�O���-�7�N�Mmv'�@��ު���S�6R��:
s�:$��@yJ"X�c����5�̀�^�c�8y�o��V��F�O��t�Ύ���8�1��Xk�R�bOE����W�b*WJ��m-x�z����Z j�%FWjm4K�ui��:�·��Ρ8U�@���B\�v�D��|�=c���z<�9r��h>��i>�݂��pf�E*�N�S�rJy�}S`	r<�����[k��.nW0����5�
	(B�6u�@�����-�@� �!υ�A��1 �z��
�.UTy�Cg�#8�2�:ޓI�N��d���[uM}R�~��we�����ᾆj�;�.�>L0{�����a�Ԡ�x.��z���87��D��f�㙯a�#M��ܬcw��-�)�+1r�08ˁ�:�Kd�D����ˠ�
i=�~����.&4dNfj'?8_M�*]���M�[ k��:'F�c�G�_�M�CP�6<�����6U%�ei�}�P���c��ycf<�O�<U��SZ������CY�T��}���7����;��\�{NzrA@G��-�5\S�2(����h&gƙ`"(���$���%��mPb, ��%�[Iۯ��Gh�� '=%d>�#{`0$��dL�zm���j�:��L6!���"B.�ΰ��%5��&g�V):W`�d�,`_r3�/�"S�J |#�� �l�Rk�RL1��LF�5�us�Ar�ȗ4|M�Fۋ���2�I�h�F�uW�szG���P��fq����%L0c��5� ,��j���@ī�A��~jJ\�sf�Z��Q���x�:��>q'��4�9eT#eq����ʙ�x�l�� ���#�� ���7\�j�}�b����O>�v���� ��716�o�~�0��T�V����c)���@�K��\v��k�w7��@P'G#����MY2e�L��lEl%p,��wZ�Լ���w4�hQ(�y4������oM�^e�|~M��X�}�=���7�wn�#w��G�p�U���6�:shн���m�ys	f>���m%WɁ"�M���p�.B�t����
^s$� ��PQ�JV�,�*9�a� ������q9HC`��K8UB��`�EU�bs�f�c*�`N8(:9��^^��u[nhE3/$ѫ��^�MH?A��Gt��q��a$Ì1Js,i��[i�8,�Vз�A��xsm[�xsb�1����q�[�I���T떙R+ WE`�t�-�	�@�C��,���\�qT;$K,*	���(T��L�K��ԑ�z5 ��W�Ͻ�=ȣ^		z��d��%-6��O����S���1;OQV����=�n&b�x��Р{PޘYOb��5x���"m��w���AhpƪW.��ݼ�dS4��"������W,�p��?	�� �5W�@��(c&����T�Z_�G
]�F̸�5]K�O�A6�sr�#���d 	=^{_D0��b#�6�VZPˀN��]-��]/a�Y�k�����L�����fܵ��YT�L����q�[hw(��\D�Ԝ~�M9Z�(�� =��/,����wOmb<�GB�����Ę�"��?9k����O�l�� �xT4�&�%�?Gި�W5[ARl+36�#�ze�l@ϩ-��3�{�>��|3����w��/L�"!�?ǖ��Eb��)h캿w�������9�OE���|������3�n[.�����W�� =�p�%6�D�ꐔ���,^yN��I'Y苕{�� �Z$����7�ĥ�U`�����2p�q�7�'K��;����H9n�~g�������ٳ�N����4� �7G���K���|��K�������k����P���C!>���̡��J�nսhL�oA��,d-��XE	_������5���k
>������>�搝�q�J�$�X?�u�z�\�A��n��~�
�mTȻ�$�q�ܵCMӭ�ozp6'�!ڿ�HLT2pc���:H������/��m�i�L6]�\ո�U�k�<h���.B�ܫ��81Q�̹�"�����8�AP�����T��8$�j;u�⩼������"�s\�`_���p'qr�@��P��"N�:���m#������h��4`����m`D�U��JG�R~�0�t�^2���Ԍ3̷��8<���A���2(r�x�IL&&q:$�y�Ɗ��:|Ѡ������e�g��r�K�;Pۛ;�H�rå��KҒ���iy�A�S���8�}��ŕ8�۝����pڅ�Jߣ�Ȯ�w��U��HY��Aۇnkq�*��.��,���Yu1�,R 9�d!~���j ��%�� �"�@�sO�xI\J�����\��G9^
Lv6B���3{�Ɂ���Bi���RȟYU����K�t�DsӲ���peH�f!�Z<\�KLqE�� ��Rˎ��+KRó���asJZ]	�c���
0ژ�Z<Om(:�=�?��{G��.���~OP��T�Ra\����������v	̸��5��	k�Nb0j�-+>�ܚҘ��}���h@s��
�Ń�A��q�g�R$��-��Ձ8�25-?�&���Ǽm�߶�ćW!<��7Eۘg�eA��7.�;�8G~3Ӵ�X༃9$�6MX��R��2dK�Y	`��4��J�C��a�\RQ��\�l�H~�Z�Ʃp&}$���/@���X/P0a�0�B����Q�a���V0s���h��EF�C���rQ���E�և�<[ � +���[�A)7�HА�8l��.
?�\_���z��ޔ�w�>��hWN����DnM��ľ�F��8Ǫ������
a�;s�@�?���C�s�b��x�T���2�1�^^�~q���-���d��ZG���J�Q&m��\���\=��}�pOm,��\?�T��^6p�ם^���7���91�3�w��`��'�xWS����1Vi}7xs%K
�K����)m���u����˿p�Y	��sN�o=��r�M�:��YS�Y�ePlx��DdL�*�(V���4�+]�#����ªݳŅ�dwq]$!X�{-����_,�5�w����V����V2<��Ag����1ʊY�`�Ep,*�v�E0E�%�
g;�W+�2�V6�4�%�;:i(�X��P�� �KȞ��ghH�=��(�JrgB�!�z��kQ}�+T/R�wN*w7V|s%K���� �)(:����Ư�����_����� '�C!�/GC�]Hk.��RY^�'����)�f��8c�`��7%�ύ1�]!`:�������V�����}w�ֱ��H�XSk��h4�����ݘ}Ւ���&�sy��t�TU;�'�n �fO�g�/6�K����A'���Šdq�{s����?��q~Tsr��g6����2*M��$�I�<g��~D���P�8�w��z�Λ��� E��6��t7Z�f�w�7&�!2]�^A�$���;�|��X�O�|�a�Y�����9@)r*Ee��x�S����JJJ�)u���oa�w�Ȥ�7�^�� o�ʱ����7���/��<H�}~��+)��Oxħh�9��L7�iP��YH9()���8��WP�%y�`�Ԍ���_���A9P�O^���2�e���a.Å:~��&
>�^'*�H���%ƺK9� w5(�l&ך���=P��l�K�h�W�P�rl�;���3O�� ����\0Y��c�EׂrN�U��*8ߤ�ykai�mM$�!��>��V%s2x��=_�9��+�o}G��"��ş��v��`���:ݛ�u����~$n����i
�BJ�Nx��BF�:�$��k���J��ah�\�S��f��Ms��"��
�S*2�`��1��\Xq����$��p(�II&%A�g��m�@O>�J��м�ȗ��ٳ���\��    x��rB)��$�'cI�x׫#ɶ�N$�j	e\�y�2l46���A�p޶)�D\�Ӡ��l���~[���Q���KX�%ȈA���7ZW�$��8p .8^��K���XnV�zxG��;�~���@��К������0K�vݛ��������d�x2x����yP40���FS6��c���E�,��]B�Y����`35.���`oW���0W��.��y��L� Х�4��!�bK镹�E!�����zʨ�5mn�I�bġ�:�,Y�JSY�,*ԣU������К��R���Ȋ0m�GH�+�j�W�'$��0��`����	IĖ%����s)��Awc�n���%t�e��0K\�ۥ���2~���]�hn8\q 𾹾Y��
�g��#��C5� 3�bP�lk��5������lTtÂ.���n[j�q��|U�	J�͹7>��=Xc }�y�zrړ�;�m�C�����ﬗ�a�i�+�Q��XB���-b�8n���?��T�2*���f�D�8*G&њ?LQq �b�g�IK��0�jv�0E���w��=e��m�x�RЭxv{e6��j����<Ê����>��(N���r�1�jD���r�d�I�2�6�86��M�������,V�N��ux��w���2Ym���2�c����CIF�}^���;||r"&	bN:6!�Y�2ƃZB���|�=�&{���b����\�w}@,夳S���LT(�7��岑��U���V�~[��#d/�ea9����F�wηK�03,�af)���l�Ӎ��Gک`��	ǅ��L�|%�4���蠹@c0b1�G���RV�s+y�%�uV�]�Cs���Ӫ��Я��G*B~������Hyb�9�L�# �,E��Roۘ���\����_7��Bc_z4 ��:郳��vo2�p�^� qi����+��D�Х��{l<��,0N��"�����.�ō��ì(���q��%��ƌ�%��-F�^��ϱ<�;����0��34��273�|
��X��8ܾ��?��������~�۷��P�7�NN�ٯv5�����۩�S��q� �E�7Wұ��
K	D�|���5��./��wR�P�"x��9* r9
[��C��AP���$vLgR&����da���蠗]y�S�Z�T�'��ա�[S�b���
"%��k�.��&}�қ���ע�[,`�&IJ&���N�H�d9G�$a�E��ƨ,Z��c�Ic�������&�@�8�+�y���"�z���!n����7z�B�u0b�VQ��q���|Y�aU{�6
�̦��PTJ���
1��[su�"��&�����i�nE�!ˬ��w ����IV�e��Kj��k0<������� �t/�����>�~q�yD��(�&�>D��N��j�D�R�4����	b��w�:�&]�2Z�EX��0�ۄ~���
TLJaG�Vְ�T���R��/Є��>c�l��D}�*������O��Q_�B�M���?��h�[jvM��c�.ۆ�0�����X�؊�M}��4I[`'PZ��0(�{���L [���nb�s�%F��^�`��H��.U�c��|Ӏ�Q.<���O1�dL�4���k���w@���a�j�����SI4ZX���������ˠ
@�I�]]"�&���<_I-�6������y<v����6^ܩό�ͬ0������nD�1�w6����v�'ցö�
8!	i�+^��.F�;�8ܽ�-9�船�I�@b���'�����1���5�
DXm5�K[���I����uΌ}z��)����3���Gn/F�kGl�w	�Y-� ��:�8�q3��D���(���Wu��A8	$�?���j��X�t�k:jQ�Ljy�C�a/��Ŵ��L����;x���_a�������*�|�kٛō_`u���_�L'�0}��Ǯe���ܻ��R�`��P���R	�K���	��d�����A�P�5N��� G��Š Hs���Z�~��3oY����.`h������
����t�#��Fe#��MHF������66�+�����!���+�d2X{+:�Ề%�x��_:T;{Cm9�����IA�"&�����9z��;�-�GHʷ0ھ\_{�~�y��];�!/N�Z�8�;�tVk�%H|����F�I��EN��nl�54�5%K2�رw*f��(Q��~,E�եyd�����PM��Tg;�~];���w�5��w�8}҇@S�]Oxԯn@���qLw��;p2E2;���b4�s�U�;��^�4p������XE+��6��B04��[i��$� �c���P1n]�i�6w+r�0�ަԓ���G`��B7�����un�&~�%jvVcc�sw���HXY8 ��,�+=�G�q�3Nw�_qV��������Uo|�	����9�BP����jf/�~����4�}��8#��(A��1�_N�]�H&$��^v���;��x�:�����)��SnN�j���7��}S����ǃn:@�h� I�V:�bo�n����3!�%Ҍ���YP��%m�3�~��l\��V�p�	n�p����@����Xտ��s#�?i����4�����B��>���|�Zܽ��%<t<6�u�G��)�5C�y�;��z5I�9M(�;�|t�&d[r�cP{nH�ePT<�C[�v�V�V[�׃���X�B�x�=wG&�����FX�Ȓ�Ȱo�;T��v��'l�#���}�[�{�;��k8BgC�W�����u`�TD5YK�v؟սW��Sh�r���w1�r`�ZbǺ��YcՐA�W���K�/�s}K�cM$cK_n�?&��Z�50 �^�#�:3���O����^�zF#���R�O�Ԩ��=Ї�d5�e�Y��T�F��W��r%ɨV�,)�m[<�p9�� ��W�犝�q�F��6m*�����e�D�Ȋ��0=Z�¤�n
=����A�CD��~.��7�pN�ڲ�J����Ž ���{�^�1ᬂ�k���'�R�H��~+�����]g,�����@�ч��a��bP*́%�o����5�V:ĩ��n�?�Ԗ	3�we>!�:���|(��
Cy�M(ϥ�9*{^���(�nRH�2�ؠ�`����2Z��n.��Gl�`���w���M��a~F�d��1 �y �`Hg�]�x�1�&f��Q�b����¡>�#&�n�k��	ur���wE�w`97�{�g@R�k@��S8E���w�O�LU�X���=�Y$L�\
�?��!a�h�g��HsX�8�s�5)�qF~%uS�µ`�?���_���#���I�����zq/ ~ǣ"�ƣc��W������(��wx�f���%`������wM�,UD��_%˙�ėE�T��T]2�^n~j��+z-�B��P,�z�mn��Kw���ޞ��vr:���׀��yE�T�^P6�刳`٥وhk�*>�ц���|?�_v+t��9x�զ���a�`���gמD���J�K��#3t#��Gf5�w��;A���s�>��v��9���ҚF��a�4S�!��be�%�m2B�ߨ�@���ac��j�k�y����CS5HMY)��t��?�A���෢	@^穲��2BɈ4��z��ߩt�í.j|šrA~=zghMs�I#S���vj�6��ou$Qu6gN��yf�；�J#�Rc�����⾭��7ީ1p��]7�l�x_T��wN."��4LG�5L���h�4($]@��1pU�4߇&5�3N���XR��ڰ���N�h?PXo_�Iٷ��6g�m穀�]ߝ�hok)ތ�8	'���kAg�yΒ%�c(e���֛�
Vt�EpPO�9A�& ��	{��!�����e��zTN7]MU��xwC��P}hV���z�R���kWAS:�#O=��c?Ow����/�Yj2����h52���U9xi��.r�]@Q    [�6�@Y�v(DTlO��S<Iq$zsِe�Sw�5�ԯ��pJ�T�ὔ�Gқ<ߤ�2摐��G|�����:v���
;�('2%���-#�7,H�����q��jo�mU����V���A٘ci1(0K[!l4�)�)�ՠ*�#�;��E�T���̡��0p�5��e�{x� hK���L���G������H�c��� �1si^u�����������mRh�a�^��1M��7�|(���A>�|��8��Ur����O��ٔ����v�0�X������nO��ŷ�[S��!2����Hu��L�<\r�K�%,X�lY����Mk�-��1@��{�Fb1Pɀ=hr�ׅ����P8���$٤�V{�WI�\ a���5>wzA��M&u�V�{��7t�����F��_{��c�����Ž�b�Ga�9{�n#�ý8��C�$��P���:IR�-�ܢ�}��=n�5c\oߡg�kA�-�`m�"����[��9X�ĭm����g����0��X������79�=�	O�/9|O�6�� �F��p:��J�!tG��x�{^���G��$Pd`��{�n�N1�wgd�ȋ.|���5py���R< ξs@Br	��4ǭq:��Ap��tp��ߥ+���0u�j���B��d�r�ʹ��S�IZI������@/񴨁j����C���!�*���-��W������+�.���$�Kr�����M@� ����s܃�Z'}K�d-���~Z����:V��d�;J)ר��W	/�p4���[�j(�����ⷦ~��n��td����6pw�I��_��W�I{	{g�j#ɛ���5;X�&/e�\h�S��9TYC�u	��̈h<�_v$+:kZh��V�����G�+� f�p����U��?���u]�v:E�9Sf�۰.�y"{kn��� C�P\��J�b���_4B8+t��.e]�8�����F���t�5򼣇˱�����~���\��� ��2�M;�m���b�����\�2X�A��^�:��x�%)X�c�Bh-�s����`��!J�&�ue��R	/�~�݄wsIV6$�S��� 	��z{-(�)��(2��:J7��&��|I�ͥ��=�Fִ��&��`�\��|��F���q+됴n��*Pt�x����z��6��FW6;�6�~�)�M�?�n|W�E�$%��&nW�_���JV�ro��+�� ��]�k4�%+^Ǌ���Wl^A*�@��cE�S�Htw�q&�
t@�k�dir�P�S�қpK*���\�\�8[�ŪD>8s�Ѓ��1W���P#�8�P��lᅤ$�t�QB�N�%zW�?Y���d��бdkmy0:l��k�*p���8xEw�s+�1�I����M��6C)�9k�>(�(G���t娷ʗ>J&����m
jXZ����G[N]�h3�H%�h�t�Sť�p�$2�*�@��A��ޜ�;�k�M��N��oCw]Qv:�U�0����{Q�Rep��܌X��&I�1�`tk1��4������-;���)�`�??X��CJ���D��w����;B[N�����EB�A����K|���k۰������#78� �/RX[bHU��_y���gi}������z@�L�c��4 *�Ə�W;���JA�5���I$޴=M��t&*�S���=���\�ڱAw����>��t����k�r��Z}+�������MaO�\	0�������3JaOJ
�3�ț�T�6��9��E��	?D
/��L�?�*�~b[�FSQS�Ң�a�n��u�z��#OH�m���h����n�V�����)�����U�IY�S6�C-��Ct)����X%'P���\)B��:���M�p��,7��z��:2Z�~���m�-�F��UȮ���P��e5��/�CUHn��w�xRe0��H��WD�F�@�ԋ�}��\{9#ɦ�t>L�`�ՠ�;*J6S���mT8���2�X�\�W�#��鍏V�Z���l�"u���?�y�R��'W"Ǘr�6Ӓj�b�J�wHWaאv	)W��0SnJA��7?(���a�J�j9�$��-����w�X�+�2�R�N�b9��"��]�ږ_�T<��Sϻ=�7�zl$��4S����"�����[S/F�!�]Cۂ�)5
A��\#/����hL�m���L8c+��R�Ҩ��B��\�x�����O1�[��$�Z|�f\���?vMj����$��ޤ�������� Zi�}>rE��X_I���B�������g��j�+ �Y�:xY��Mb��vM��,���b��8k���K�T�Ŷ\��Rn�F�E#��^�w��o
-|hnv��5�w�/`�w��j�s��Mz1�{����K$o���Qr��5+�|0C��}X4���x*��*�1獝?Hr���קZ�|pպ"�Z���9��9K�z?n:6<�����N�#Z��������	-�)�۶+M��n�z§h��5��o���O� 7#d��ߺEp�&��%tXc�=5�����rH�9|M�����j��P_��̲���&`����OO0�k#+�	�ma���Ρ�,�P�7��s������|Z6#4���{�v��\,��f�ؠ{�ܘYGo�
9�E�U�=h� ��y[7�n>֦�!�D�&�k�@��p��D']\
96|'z�� i�1���8���Do����Ͻ�ۼ��N���>Ծz�C�|}j���;�~��D8�>zQ��O����p�霴�4c��Y��x��Dp��Z�[�Z�?j5�.&�@B��R�r��qIJ)r{S�/M�*7{
P]�e�G|I��YG��y����ɖ��(%�+I�H������#��@AY�?TY�`VbХ��M�a� ��0:���9E����4����Yӆ]�"p��#��|ħ����:vZ\cG��V-�*i�Y��ʝ\AT�F�*^s1���O����a��.I6Ӗ���I{���z��s��]~i�g<7Ź�hq��t�iW��Q�ڧ�zɗPڝ$GU���G|U;���5r|k�A����a�E�^�::��y5�!?��\����,\���� -��@�zǅU5���q����e�w�0��@,;�������F|�f֑c�rB���zX�w��O�Y,���!�
.JBĐM��i�x����
�]��9��JGg .UM^�_:�fK�+i�y����,�\Ϭ#G��&l5�X��c�'.��%e�D�9���6������΂/�<�I���"��c-����G�L��9\��p
�G\ޘ�ׂ�wO����bˊ2��.�拹^��	]����࠻��fq���Ѓ0P������)��Xl2��h�tS�J�{����O ���eU7W�7tg�\As������� ����~9H�v��!�H�AH�R��r)�)ȸL��`<q[�S6,�|j�<����L�qT��v���G��gt:�{~	�����j�ؠ����u���Q���ov�*�[,���K�A5�D	k���5��AR�G�R�0(�;��Z��Bt�����)�<�%^rI%�zI�[B�7H�O
Z����#>����ل�V��)��j�&���9vyOE+�KMnr�MK�ܻS��V�!8P�\�ͯ�xMHUf�ߪ��Ŵ�kd�G
P�_u<�/�E�&�H*��#>DW3���V��#�`M1���#M	�������*E�9y�`�����e���V�:r�NJ�Q�aOE�	c.]n����lK~W���_����4�7�Q�R��e���Ńu;�����;�QP��Y�`ܵ�9�r?	�
J�3�k̹A� Tʘ�_� p����tT"�C�o����>���U���C�<La�I>���, ��YGM~�%r�I:JI���n����,U���F#V/��J�-͂�+�H���$�ӥ    &��>�Sa7Զ����W��Q7�:��M� ^��#�ra%���&�Yܸ��!�^C�$OU�B~�Wݖ5խo������Ej3�N��²�����UX�8�ړ^��3��YC�S�!C���^b��T��l2�[�s�ao�G�����d��n\�>�vq����K� �Ͳ�q*f덨q��1wX�Ps����U���؃H@TK-�YA9�/�f��9jG"p�En�}��Zf�S��sZ�O����q%�qDI���J���ƾG����:%'KVN5�?�/�zq��|��.��\ -V5��{�R߯����k��,E���^z�|�9��i�����j�rlF�p>[uM	�#�׀|sBå̕2��=T�b-uW��q{��R��#帑`�X£Ry��O!�7gֱÍ=W�	S
>S��y%l�A�Zϯ�������H�ȐZ���qȒK��J�5,}�^k�y�j��@��$�1��/��W���Y[}�ঘ��{�7�6�)���1tS���_ݽ�,9���9�)�"A�H��
3��	��X@���.�h�Z����o��8�y�q2+�k�詮��p:n43ڥ0��=�k}R��U���j�(��g�=�kVZ�P��|v�:l����#,�.�JF��Ji�)B�[�Wv�!�Q`ث�HcڻS|���v����R�3�=U���m�>�~e�Q8U��+�#�ZIm%�ߞI Ԩ��I�8�[��)l���@h��� ]�����@��)���'tH�t4�)���ճq[�]>s�I�9l~S<�l�D����)%o+���H��(h^7WU�ɰB1�|�T�K$觅���Zv��a�h�x�V��R�Ǚkq���{�{Ϙ�]� ֔k{Ĕ�����}����`���F*n}����������/����� ����*E��f�[u�$9з�B�Ф��*�%�� (��oz�� u�r���&5�%��T�_�Qy�)����bS+�@�Hf���H��)��.�+��+�ȝ���b⠒����O���Þ�M��S�u�@��7�zI�||�Ӭ��$!�3�V��M��^"%�3U��JS�/l�����O&~�d�~q+恤�1��!�^$��/���������%bFŴG��m��ONM�!�'~I���N�ES!���XVg�!Q���0�"h:�`�I�����V�0&�
Ԍb�i6��/Wu����J;�W�Q�G"����O���}@�n	1�����}C��u2W�]����E���&�O8$���� Bj@�\j��p�zm7m3H w�ecW\8���ZO��|87�5�P�N�͗t%�)�G� ʔǉ��/7��k�_���k�{����A9�#��Ze�7wn���9)�x};����&���ݫޡ��(>�U��:���K�[���eb�(�픥̨�RF���¡�s����I�Sj�)��d�T�5�����<��˶.�Z�����YGg������U�4�l96�L���0��x����=Q�}n�]���.�wW0 ���!�����M�޶ˮ��+5	"�AN�o�)��,.�Ԓ5��S,���H�A9�=�qZ���;���
��S2�����2��QjS��*>��{w��pYq��6��`�sʹ��&���r�.���ԨY� Vk��EB�	=࣬ʝTվ6| ?�t�P�b����R��U5PJO����Ok�< d-v%���R��);Ҹa�8=�A�!Rv����n	�2[o(��@��RWh�R�m��HY�e���~.�fuf)�������Л����
�s���9���D�F��w.5����x�D���U6�<*e�g�FR���lz�c�sH=D�I�j�R\�c����"*��,�Y1ŤO��j��4�5�7Ò������b0��m��\r�^=S`�S!{,w� �煭��\߻S|����O6�I��ͽ3�Omu�QƋ�4w#�xJl۟����;�)|��z�!د�Ūxn����ݖ=�SPx��陈:�W�o�HR�]9���QDwS|#DwO6ة��ى9QJ9���j�a_[�s�ģ�\���׀^��R'��b+eo�	jW��{j���9Hv�D77��:�\Q��SӮv?�B;���T�2�%J���\2�U#��>�(�7�{Gi���A���5e�{י�	�Υ�j^���p���o��J��*0���	�<)��~��:F�.)��6�<� 6���=e�����> ���/^1�ʃ,�(���p=�����[��,�003�[�4,pVCw���}����%�g��[�Zb� rɺ�;�S*=�R�AZ/t�$E���rk���ش˵1}3o��X���5��-�8
��og���],��ؔ�����h]3>E5���k.!�SPJ�Z|�U���0n�g�M���7�O�I��ˠ��;ۜ�+ЈR=��[�����RxFQ����Fs!��Ӄ���>��lA��=:=[�O��'�[���mEe��A�h�����`Эnah >g�kˡ���W:q��F
�夺��>��mB��L�v�?W���Ud����K�\_����/[@ǳ�O�}@�?�@��ڣ�?&H�����0E�D��dj6���7O�(� �
�$ޑ��`9>��6�@���by����6�؋��b�	��
H4
��߄�����/��G�w�O�] �}�A���ڑ����
�娪�ݮ�G�l�xG.
C�fK��ف΄/�Ib��*Ba� �n��y:�o�Z�-6wG���c��B_R��K�5	�7=��^M�]��?׀���uḾ����q�z�S3�$���7��m�E 4� X�� :�T	m'�,��r'� Z�v������������b��+/��ȏ]��N�}��?� Ƕr$��B���5åd�o:��A��3:2��V�"��2��1�
N�E�����Wis8o�)C>j�	<B�E�#̎��Z�u���)��7�tlU{tp"�� pJ��2�1����Q.	��W��0�֧WZK��E�0�9妄���(u>rO�袲�TX��s�V�g
��6�Q
q�^X��<�u;���t�d��ݞ����J�fU�{Q]S\JDB�M�6.�#K�;�woª��G/~��
5�sᮜ��:�h`_�K�A<7�2����ʗگp�:/9���X=�C�O�}��?� �zsCNn>0�g�m���Z�����~�v�SIis��^�l�^O���X���b����Y ��O���賹j��f����|�BK#Y���y� ��)���'�Ԩ��Dq�%G�䕗�w��Sd��`��2�-�<ĤΊ� �^q��4"}�AR�T<��p�:�:WS\S-Wߟj�z\���z.̖�{$����$��Γv�9�C�g3>��rJ�n\���S���.[>-���E#�!�ˠ�7��p��#i7եؕÖ�Cܤ�C�O�_�_��������A��S|��O6�����J��h26̫;�����Z�*���f�r��HW����S��ƏP����5����:�ɀ�g��wV��<�~���Q0�j$ʆ��P��y9����M�ln�^���d��@��>
��d5h�������F^�Ys)�'�j�,�R���I��S�������@]�����Se�'�nz;r�+�ƨ��Q}b7�����'�����pORlYؘMu�'���'/ lK�%]�O(
�g`u�ͩD� ���ߒ��3R���r�tw���y�,���G!�g��-��b��v��U�>�?D����$ޭ`Ʊ�	Sdk�-`�'m�wcU��H�1����$��QY[��l��5�4�
���<���1�(��9}�]7]���b��g��K��S�Th��y�C���ާx����m7�Y&[�1&�IW�]y-;�.�xM��Q�	��f��d��!��d�g��W/�Ћ	� ������06Ra@®����@q�?���>�x���X[�� �,�0�<���l��M�!-B]�Pی��2!�tU��ћ��&K����n�1V�igR_r7�J"~�86,aW    P=�5�sl����wS*v����%�Z-{�Z��x-��I���u�	�b]��
�o �JR�AA%�źPN��d���b�J��KV1Sf�t��cmd�3ͻ/p�W^�z1�?��yg�)�cKU{)�I����Kg�P�d�} ����T٣S�#A�)N���uA�$�'`�︵��j�5��J������bX%��l���4�0p?�]��`�'���Z�R[�������y�d��ߣ\m'�t˓�����*�Cٰk��(�*������N	�b�
!��5U���B�:P�_��>�	�42�S��ѐѹ���a�Ћ�����.�-�r6�%���w�b,���Դ����bx��-�ڝ����Yv҃���=�R���j��_���?�K���Mo6�bZ˜�{����ƿ�a3n^�{	�Cz)�8O� $�5h1J�{�]�^-���A�q~��9~��W�lH�H�+�7�n��.�.�H�ڝ+7Ko���{cE�t�*���Ja�G�LI~V=7>�s[��I*�XW�CF=�p;�wQn�l�S���q�m��1餚�U]�"s�������[7�𾠤�Zٗ�q.&�^<t��2ޢ-�2Y(&bQ�e��J(�s=cv�	����ÿ�O����������������uq�CU�e�G�0��6XZ�б)/��Ņ��.n��������+�:5� {IOm6�w�
۲�����(�hײ8ax��y����Ԇ� Xn���n�>��1�F��������$I`d_4^�c�F@��#����\��㛵��߬`���	+��0:O&�w��ֳxɒ\H��/��MIQ�^������d�ޞ�TΦ��K�Rxw^������$���j���(eg��&<�v;�w�.�,N�ѱ��!.*�k͓1��)-�q��髧��;72dt���	
��������$	��Dl��p�Qֶ�:�O����J�R�>x�v��	S|<�<����"���&RSzV�}���"�J#~��S���^��_פO��;{5(��N&P�$Of�e�U, ���Ⱦ�e��"�'lq��Z� 斮$[�t�Z�a�7W۵�0:8w���(fW��jD��jR-��l놳��ˠ�r=�̩;]��0vː:J��Ԙ�O[�$��E9�?ط��{ �h�F�gF��~l��׽P(;��~N\~�@��G��drW����?��7��_�$آOdߌ	���FL��{"A;H�e�:,�f.��7���,��ۢ�F*�v�;1�[�U���Զ?�
�<H���
]�k:�ZJ3��j>eU:��iQ�lM)Qx:�����>AD�H+���|_/n��V�:�Z��X�l5�	�F3N*�]���	���rl�N!xC������J�G�ZT=O{����T�fHf]���lUz[m(��j����=Ǒ�4A��}�d>։5�PY�x��o�z<�W�j�����|�A���j2��<Y��^��W�B(�ۛB=G�u��Tp
��`B����}���Q��/����x�9����e���'F/ޓ�2���2DE����ϱ��Y���7;7�]�ow�a�@n��Q&]�Ʌ�d���	2]):��ڸ5�tNXj�T���d��K�ePr��`��qS%�t��	�n[��7�3KD����x��r��Ն��-����+D�]�<�1���!�[I8��q��=���*J���wgE4 5�)�*�t?2si�L�#>���� ��ٚ�:<�g��h%Y�V���{�:�wg�zq�L̆��*n�F-HA��`v��w~����|Q֠��_fN�mӍ�=�n�$Qdg�T3P���n>�"&m���[���q-�W�/�����O��[�R�}2!'�pCN�V�g��:�M\�զ�u|@_,�q�Ci�d6]S���S����Q��{験��i=v.1�m_�7�kҽ�}.�d���r��D�=�_�?�h�Z�n�a��[v��O�b�`զ�y��Z��JWi�A�U��ܠ��=��#Q��X��Dc�͓y��T~�������f�Z��G$�P�_����Y��h��
�����E2�vc��cy����lc��.�%D�Q)^�K���3�){�����%�H�=e.רC�8ϭߢ������� o!�x�)k/�&J[҅0B�'�`٤Quۮ� ��}T�X�$&�T[�:�g���J�ǂ��&���� �@��2��(r�_T�'P����Gy���XX��-c�lz(�*�ɚ�wKK�Z��3r9�	z��p�������W��Ep��Z�8x�IIZ<������3ՆOOL^vпZ������N�8�=�`�F;�+v<�E'cK̳iFW��@���b�c�g2Zi�5�'	J*Ҡ>�C�')����d�
�H�5A����!���|�*=�v�Y켸��b����;��ax�do�Ӊcm��T~O�JyJ�U�,r��j�4�lއL�ړܚk�fP.&���F�Ti�@?��3����L]�/1�k����T	��)�i�Na�}�&�����p���٢�^a�ȔԪ�Х����՞���9VM��O.������ ��d�ʏ����Ľ[]:7t��C�zTy_%�_�=S�59U&�B��6��O`Y���p/6�0��9��I[�H)�e��hS���J��,��wKt-��WtI}2���%Oz}����p���P+�ڤ�� OƳ�5B�-�����ǒ��o�tc�u`��԰=R��Ǡ��Z��pz�f[[ԅ�<v��L���pDL��z����x1#*��fX�Qd�u��@��:v�m~�b�Ҥ"�<��A�����|w	33��w�i���=�YG���������_��\a�����ߋ��s˩IV�t�z�� ��?1LJ՝+:m��hXuJ���v{�b��TY|L��%���ʮa7.sO�ZH��;���컎/�!c�������mA�kaQ��p�T>fH��AC}�d��n�!�Csi�
6�ޘr�օSp�5FM��Q9�]Zt*\2�B�|=q���QZ�"�!�Ϣ'�}V�b�ү�n�Ƈ(AC67�I�-��x�|�OS�����Q�����c�?a�)�ADOj�2풟�Y"{�%�Bznл�>�@'�t��.g�%}n�|O��9L�)��!	�~����{	kmK�g�T4�İ�h�nC���`��#�r�\�k�v[Q%�}Pa1���g����t���7bjE;I�^�y��2��_�`
_[����f�,5Ĩ+#E����H_=נƍ<�kj�kV��lw8GꞲ0�%��a���V�����|�δ$�k2����֒�G%�'ց�ݹ��"F�jR6)ès���Qr��������[Z)�S<����5�����!�}���=U����w�^��p*�E��A��ݓ	<Q�x`F���j�L��[wc�~k�N��eI�0����Ө���	����P����V������L��*���Ig�]�R�Z(�����z�����7���N�W%�S^�������[x�s�����wT�1E���`nл��6o��b��,)�E�T�-�6�5��Q�V{)�R��ҕ����N�\���iZ���=���uOf2E}\9��W� �"�rV4����Xν��c�˼��V?�Y��SH�B"\��&h���t�Μc��2=7�=��<�@'Y�G�v4dh2F���^�s@��G�^��T���v9��3�Xi�񦶃����l�����@~s�J���=�gz ~�X���s�C�^�~����x�g�=.s�8{���xՄ�Rn��TSI��~$i類��1j�]�^_{�E�����<Nr:{���Bp��	a��ah�?�@��д��®|��u?U���U��h���O�b.��*ď�ĴV�A��{��4R>��A��ݓ-�t�G����nz���D���P�����z�d���ҔkĕZ;A��a�G��5G�@Y�ޜ6�:��m@2�������&3������0,�]�ON��D�D ��cOܸ;�wHܸ�d+�����    �68KB�i���m�(�n\�r�V�:�:�p=�0�'E*[-�d�/�<j���ǑM���x(�M3v�����\�6�#,�Ŵ8��#�V���wO�OX����*�`(�������M�ÑzGٽ�w�ڂ���ֶ���q�H9�^T�6q�CLR!�BH�"�wY��mMz�D�+��5a/_�!�����,�^��6X�V��]���}���ܠw��y�Z�0d��3T�E��d�hA�d!��;��(�Pqd�Y�^�}=���u�_r_/<9W|���
k�$;���l����C�X��a3��2�Oe��7��0f�J{�pP�-ȳ��=���`^Y�B��l*�-���4-T��HJc�j�Pw�:�B�OTcMǆ�|)*�\9�P.�o��A������?�����W�zo̟�����=(��Qf��U�t�r�^����:��l~-����T��L�S�
&g�A�}d�5��(�ޚRqR\��j0J;4�=������W{�v'����o�V.��7���,�ʠ�&�Pk:R�'L���<�G���]��x)�ZC�S���y4�]����s�
R:�(Fg"c�o�
|<���1Ԩ�[��b� g\U�����Lg�?6s���0m&�Sk��Œ8Ez��f�nkǦxjXg��v�ndNأ�]�>�n����v���Z0k*�`q�ZM�O:���`��Fz�5T�Xy�x^�;�-�Z|2�O�*U;�lm���<�QL�&�S*�7r�ۥ�J��ލ+�j�o�~`�E�FI�tx<��zfQ�[oX��o���q�mK�������2Hٌ�!557����6O��,䲧�d�Qh(�YK��$��r����E�b�Fŋ��v�d!O��8N)�d\�K�"ug�)$*&�����"��	�0�ո�_R��T�����fA�b�S�FylʤBv�s�ͺ�m G�NK"HtT�8�Xznې#�gE��=�#���;m�vP�/�X�g�
��%��型0|��60��L.�̲v�4Z����p�#3<�4RIK��˱�L��P��$,|n�G�BWk��zp��gx~K�Z+�K̓�3ؒ���l����׎���)J%R�V,+����!���L��V�� �{�p��Ar�
�HK��fs�w�뗤��g�	��u���S/Q�h������^��#��Uj@��ΰTJ�>7�8��������y�Y$�AGm�l�\��9�������*\�Iy{����d�T"�Nm>sɮ<��\�G'�	��񙊈����b�m��#��c��Ó�OOv�R�[��P6�f_Sf���*ԁ6cd�ݘ��jf�%��R��������{�ew=l�N��S��f`Ȧ4o4���s,ͤ�H��އm� �ּ���2��fq�X��f��G�l���b�Qm�7��v�ж�,/�����:�ǩ��M̏O��9��b��q�BG�[I/���LZ�^�YB�W�����]�-��s+dٙb�3k�m�oA0�.T��q�{>�T6�����>��\�\�}D����B3k�3�U� WֻI�Im���SA����[a]�XEe�2YBPO�d#�[��z S*��Z<p��V�k|���s _�h�����=;�L�=M`=���ΏH�`�_���q���WUg�H)�������}�������ln1c�����&�z�z@�P�y�׷^�aRZ�rڞj�:$�l|1�s=K�J���۩X��9m���,0���5��bg�T_��6Lp=�����`�]�f)�sh�ǹ.u���z9��Tp�N��}��������@�3���9�^T����q?���T����-���vR7�=��������(9���}��Bl,:�+�1(�uA��׭�P]ĵ�]
�?U\�U��b�Z�n��/GlbX��q�]3T����X��`�c��Q���׋;����`��C�j��|%'��dGO�Yh����K�-��K_a���R�,Xs�S9Im)Ui3�*�|C�Z�`*���Z0�fU��5�DL�Ԛ�w����Kd��R���ฆ��$���F��;DO����&��A`�[����3�qI�����\co'�aʶ]h��AEG�Ak"����6	<h���3un��d���C��
�����9��aN?�o��E���z-���QK�CS�Bm�R\�&l/~�+��l�����}�����B���n8��a�Ȇ��u斍��k�Ŷ-��ux����ɶ[Y笋��0�Υ7�$rZ�:��;q�S��>v�%~kc$4�1�7�� ���d�f��`�;6Jn�-ωky#��Lu=��˖X���4֔��7�R��jk2��u�<���<�8}�x����u03�燱ƆJx ����M�߿�٭�@`�P�e���=�gŬ��LX��C�[t�K��j��80�]�}ho��h���NK�T�]%c��Wk.�gǵŧ��VMD��S����ڥ �jͿn�B�=]�ѰL]��;���A�����ւ�^J.n1�n�+�	��r7���5����zC�RL�z��L���k̤�V�t7r�mm��4����9��-���"��L����F���b���/�����Yܑ�`�l�c�0G�j�<ywf�"YUrK�T�3�Ӝ�9HkŖ4��G9�dH��I=����A`���XY�N�엂�
L�����g�o���z�` ��k��J�)~�>&�K+��N�j��ݰ6'+��A�r}��׌_L�-g��K��n+�n�O�c�D?����GX�=:�ROҪ/� �*ۢ������υb��/#
#���E]��SB�YM����uz�	��=RJ�bB��b�������B��0#/��ssm�Ŕy�2�U&A���b�-hIΥ E���՜"�M/7ex���X �m2�X�3�ո/}f��[�ʏ��#�mͫ�/��T����ڝ��?��?������/��˿����i��_�}�v�v���=coثYi�&��&�����E�SQ�����ڹsc��@���c*ф�Oe�&ezm��D�%���{�<�����J���G��W�{���L�Y܁G�LW��,3^M�.Vq2��t���Cl�zɢ��7����oEWi���d���������O��y�c��<K2O��f���X�����jHzj�1DO���n����ܠ��-�@��L��"A�W�L$?������v}$���/N�|�9�h��Ih�5����u--��:�^m���#�>ѫ`F��:(��gC�H�_�n.�"�䜡巧ިۉ��5]�6R�6x�C196��Xލu�R��b�;�u��5rj�X�w@Z3��f�	���afN�?���Q�V���Bxe:w8��O�$I��ښ�5~/�d`�s:�{0��)�T���n�����A ��H��Ǳ�cz^/n��fLFq׎]�TB���c�����rfkD�׌?�䃔2K�g�$	M���Ԧ����*<7sW�T��.���0������zq�0��g{�:����S��F��m��4���޶~T�U�K0�7�N�x���6�ͱ���T���$�#�1Xi>��S�"���-�G�kJ����~�����fqVgU�=g�GHj�ٺo�1�9Qʤǡ��0D��1eg��l�9�ȎR�6���B�϶[~��s݃a|�\K��ꁍ'�����OH�����eK�+ʰ)AS�L��b8~B� ��R�[�:�UI���$��N�hS2�� ��lI� ����8�L������q"M�(�Z�@����=����U���w����ށ��3J7���
���&�e�[~��Thr���}{�9�����
f�q�&%��K�w�<���KǓ�(��-,4s�|��T��Ї��[Ib��� Öݣ3�q�a^��?��W����h�/*�SN
Ӛx��������Ϸ+��vIܞQΔ8[�/��Hv�z���a��UI���f�Un�O�$���TNksq�l��M��k���U�J)�/ y���[U��,�nF��~U�N��\2��sɋ��Y�n ���	<�o��    ���N��%w����%'E�RJ�'k�B����|�M�e����g
rK��~"�rN��z��V����R�zV��-q�P6�3���7ߏ�JH��jAxTܲ$F���%mo����ݭ@ KR*�2�$�{\�t_�޹�M�E���f�zg]ٝW�%r�(���g�F������ϡ{i�,���^+65��>���|+�O��b��1���b ��I��)�`i�.ʷO6���]��'��W�4N�k�^�r]\b���gqxt:�����dUH[���:Q!˞���*ء����b�O��=�W|5��^��_��z�`��n��9���f����\�����{�a�eEu糤e�
�5C��AP���fߓ�A�y?BU�q�rL���Z�E�}�s�'��"�'Q����a?���3�l�o�j���|��{�f�d�Vҝ���.���҆κ��h�Y�Y\�NR�K���K�L�`�Ui�2�yo�yu���ga������aHG�Ih����d�~�߅��'%h�z�S��x���d�к;uw� pns�E�(5e��$I�y(�0�b9�҈���Jb��yv9V���q��f$���~��
��jJzI�.�b���怠�zSk��h�$�}�����˄���	�;k�Զ��S��nP
�} ��O6�1C帢�fN�E��6=A����֘��Z.����" ��V��S�Z�d�AHqn��O� =)�WR &}�bR^�G�W� ����QHwS|#HwO��3ܧW�t&��Ue�d�*���kA7W9��
q�RWYjq�,;gΑX��ҕ$e%g,Αf���gZ��限z3S���X�`�S������F��l�SR���rq�:f�)�>��L�R�[�k�]�b�J�5���V%<��-���Z]��/�ז��݂��_����ڏ�ڣ�Z	�u0�_�� 7��z�L�M��w�l�o�7���6v]�60�w/$� �[��T��q��3��dH�*}L$���.�0��e#(�II��4�j���*5a&~��Mc��W�l̽4b�FG͏b���a�{2�_�#���pM�]���,p]3�R�h
 `�I�ȵvv���k=G�D����'�\�/�R�{`h+MC�I����CO�}��=�>c"☫���lt�00��]��N1�PYZ|Ȇ��d��9S�PK.5ĹA�1��d��1�5=&;i�X�	���ߋo��cg2��ƶ���Y����I��S��HMkW�U��G�/���Wb��\w�b�RY�Rp��[zUi[�AMI�4����8�"�>�Sk��V�K<��1��͟0�\�}k,���X5 /�G�{����(�y2�_��~d��Z�V��O̻#�ϩU^z��f(0N�	���,��6����gH�܃�{�2�i���3_��Ka��Kl��R�V5�4�P�ϴ��O�LO�i��a���s�����˙�9K��W��>�̽��$�nл�>٠ǈ���K�x=fMm�Ea�K���;�r`�&���q�
�=���Z
����̼�46�t�M; )4b�1������B������/l�Y\M�0Ŝڛ��^��[,(eR�Ue��[js�>�t�d��P��� �����c*��ͭy�H�(���h(�k-І�2�anI�[�
덼��R���d7��BlV�>�L������ԘW�0_pR<�sw����<���U���(2)l��TLIRC�}�6r�5˷�CH��;��:+�
��65֭��D���JS��KR���O�|f�D��#b0H�>�V�o;>�QR}ز������a�o�Z,CH�cל�ܠ�$����˦�]�����`��(���To�{���������?��o�j�˹oW�)�1���wVQ���~Pez�R)�2��{&�Ӻ�ϔ���#�s[��.�^;�@���)����?ـ'{���!j�����ԵJcx����ݴT�t,'%-.��֭~Ί��5��r�G���{���+6r���"6�?��n�o����<�o�1=2��W����A�7�I�ڍ�B�g�iU]k�<��+���L8�S�)$m]�G4R�6q��j'�p?�zZI�jÎ�^wS|F�O6�I9���
vy��&/��;�Q��z7�7���Iz�����P�L�5H��A)9��P]�nr��<��%_��O�7�_cb�m~��A�����)�E���'������N�����8����
-IM���"_g�S�D'�bw���l����C �����l]:���)�W^(��QFwS|A��A������ͭ�ٻ�iS�f#���6�"�h�T����x��_�/�4w���s)�yA�ׄ���G���v���a¢�s�_���AHo���!���{��<v(�W�p��kL���+���^��h���$�%����E
�)Uz���[��v3(e%����]�N;���{T�Nq_z}� �uU���?h��a�_��G��,S���A��^��"Q����.a`�%�f��'k�FѤV�{WX���l���i���>���@56�eNV7�7�O<��������U���hk�4����˰�ֲ#��ffE�Ę�#y6���ON>��bH�j��s������-H��`cs!;��[	�*����b
W�V��;E����(ua������@�D����T\"c0(^�0<mjF�V0_��w������uͷ���c��F�9~�l�j�����&Rb�^^�.���,��JVVYR��� Ʒ}�W�&C����g'�;o�)賥>��S�+)=M�_�H�p����_��fX�j��= ����~-�]v�aŒ�/я�Ͼ&s�C�(U3p��ǯ��N1wM�p
i-/��M��wޥ�m�mn�}��>٠'HS�kz|g�9�!�ɚ Nos"�.��F��De�+Zߡ�#?���;U�W�P�W�&$E�c�{� ���D�bVڑ�K�Υ��LOÄz<���.ʽВ#hY-��?a
<JU::7f��,QZk&�j�!W;7�= ��� �%,��i��϶Vy�B����Чj�1(���-�aTS!�f��F��q��]�@�5[W]��tӁ�^"�	_""���OtX~@�Y#�IdM��6��D������CD�nqw���K�y��̌D��N��l�Y�F���6-�ͥ\o�$R=�Zj�p�o����P֎�D)��-�fC���^S�;���y�U6��exGVE�YikPCl1v��9�n���xl/�.��R�⁐�S�QR��0|�>��\�=Dv��j��tػ�;���MNT^<;��X��.j����r�-����`g#�ڍ�(�
*i?x�l�9w�s��"Er���_R�<�Hâe��ǅ=������3��z�X�Ԛ�7Pj��SN-U�>a
Q=��H|����x�X��R��{��l�xÆX�V.v�@���s�Lv�q�r_+����-��K���u(�J9xq$V^n�%C7_b��@�9�y��T��cf���&�'�b��[�w�����'��tCO��qF��d�u❾�<�-w��_�Ü�Ѷ���SL*T-�\?��  ��F�u���J�c�\�y����HD��_�mE���Vat�6+��]R�?a��"_|x�}���Ieώ�.gp�m��[U����@���z��?�j��*�ݝ�`�%{�ߙY3�Y�J�LC当J�.:�ԯ����K3K�y���A�~Zz�X���g^���s�goߝb.�%FX��m]W�]��xn���� ���-�+���bSr�B(�9���MOc.������IS�k�؂��"��A�h�F��RQT��p��	����87/�s28��gJ≫��bTZ�H)A
x��$���E�y2agT�fGS�`;��لA�����6h,�.(gm���`�8}⬣��r���+�D)�л��:/���
�w7�4���$e��!֔\�X��X?_�X�?Y�������AI����H��������a�;Ҿ�2��eU�@�W�� �#42ٌyS��.�w� �  �S�{,�@Ïx�C�Eʺجo0���L�T��čp
���t���0��6f�0(�/�"�G)���A|�`����,��64�uRS�
⸋�/=����yGI�6����Ɣ�e����zp��q��T��G�ƿ��mڥ:Ӓ��˿�Eo1Ϳ>�w�nl�Y���ݸ�c�B8��'?0ڪ�3�+BK�y�^U��	'W�dS]��FPd�H�����t_�����>����ůd_tpކG�M1'Eu���M��iY�M,��
�J�,����'[�-�)n)Ѷn���C�B���4�Ln���q��n��/�x��{��}���ꭥ�6y{�`Vs�6��6 	�c��q�a�t��^�N�-r
�>ـ�%���F� 3f��g�e��k��	,t�BU���."�疠9�� ) %� �WP 
M�CB��LD�W �rcN�%�`��/�N�-R��>ـG��v��[RKN1�S Z��:�4�[��kw����UdBn'jb-Rt�c-A�K�H�bL�@jV�bjҩ>Q����.F�HgXE�i�tw�������9�Q�� �s�>��'�==:�F�k�f;}�տ����^�5�v�o�z��^����I�-u�_z}�g��R4��Q_jP�+=�2�~� 5j�6D/��5��;�w�wl����@5@���z���Gb����=Aro:t���\�֕�O]yJZ:)%�^ys�g(�ۚ�������״ZL�y�5M��H<�7$����v�jlw�����l��˞��S�j}2~�*{��-�E�������HWf���U(��S��A�~0!%�[a����z[�5���S���/���fz4l��rt?��Z��=��:�;��%��S9��@��l�C�$��C����s�ms��$���t��k��$[\�ᙡy��O[��P_�%�p�,��^t�eP���"I��	��B��o��4l7Q����h�6�̮��Z:���?�w���dBO����)�$��s���zS����jrA�4J��	Շ�"=��r������2�?�E��r�<�Xm��R-ը�Вf�4Hg�OFJj>x�o�q�����=$n�kzR�{�}��[���hR���j�k"Ptf褡�$��	߃�Q(zUx�I%��\r��Ł]ff�Ft��}mQ[�"�>�T2�ŋO�tfW��&T�����-K�H�0M�CM-j����ƥ7"h4�H��)�(�i�0�k�m.��ň?�*�!I�ݫhq��=]<�����R�Q=�͢~-� v	{���T�9�_��g?�S�Cw���l��vP�]C��!:s�R%>[IX�V�L���g�2�/ʎ��RDV��R�������'����4r-�fT5n.���Je(�!��[xU���褰ӒUl��e����Ri�i2RkK��T�e�'�HC���,��N*�̌����r�oa6�}���p�_���"Yr=�<'G���� "lw(%V~�.�m��?�!������}�ARPb���-�x5dy�^}-edm;w.r���q��><P����R���焅IS�D_�x:�~�Z��.���ͬy�}���B��H�����f=���$�L�a����������k��vz1/x;ĸJ6�}�,�z��rWU�R�ZZ{I|��ₕ,!]�.)�OZw�/�FK\�V@v�&���O*�i_R���d�� r$����f2������q����Tp�U_��?�c�����DÃEQToi�0�ɮ��ݶ��`����tss��#�Γx��$����0Mw�ۏEg�)]-N������ن�	3JU���ͩ�����l[|�>'.)Ԗ&<9��K��(���u�,�Z��.	�E��i�?[O��{m7�Յ�_v��[�G�>��o����>�d;�Y��X�֢��IKؐK&�G����&�n��S(
Gy��3���6�Y~Ym�>�q�%,�Ǘ�~���g���      �   �   x�͏;
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
W[�t��n���r/�8E���gp��bsQ���9`t~���k�u:��1��X�"��5"xS<K�I��S�]�=����n5`o�H8� l$|�u:	&��j�/Ov�Ρ�$�JU��e�5p�4��Јq$ �K鿣_��}���ߏ�*      �   �  x���Mr�6��}���R��!����ٹ��!FIe&���E�ַ�JM1�3�f�� �H)��TҘu��r*�����9����p��o�|J����ӟO��6�6�����eێc�2��Ҽ�|�-^�?G�X�(�� �D�����|[^l[~<��Yy��˾�c���j�R7v9�(���?���]�m�^?}�}>�=`�z�P�#VnT�5�<g�ܜ*OA�7Z�3Qp�"v̹Oh�������'t�ʹU.7��&2l�R�q���b�1O�1/ج����a���y��v5�؊��&�v�[�����M��cg"j��۝�C�Ϲݹ��}
t�����U.W���p�C34+��s��?�]��]94�L+l��1w�g-^����.-m�K��x:�S����RێQ�D��Y���[�-���Vޣ�+/�+�g��S�f�K���ܺ�ϻ|�ʩqnXyH~s�[@����}B����-��ۏy�ʱc�}B�rn��	՘�ο�K.�䒯.w�+V΍�n�#J�;��E~B���ٗߝ���aǜ�'M�f���ׯo�����3�5.�W[�An���a�;�ԗD�_=�͊�2T�KQڷϿ����1!��.7����ٗߕ|ZMKQ�|���*�fE�o/ϒ�:�+Z$��n��bV������+g�y�S��璯#g�����rn>����]���k�d9se!�:�sn矛ϹU�f���n{�FK�ԕE�ԬH��K~sy`sKP��`��͊�� ���%�\r�%��ʩ;\�K�DN�K������\�ǐcw�F���K.��˩o�J.�9w�\r�%��S��}�%_ ��p���h�� ���U�>Q���%�|���R�}E�%_ ���򆭸;��)*ص��?��)�\�rl�K���*,�vD�rlw,��%_A���I.�9�;'����#*��K.�orl�,�v��rlwNr�ȱQ�W�c{��K�rl�\���.��+ȹ]h�|�v�$���a{\{^�a{\�� Ǯ��r�j�aW`9�>o�*Wr�g������U.YN�-Qw%�|�L���K.�}˩u��/�S�\�%_"�V��K.�=˱;\�K.��"��K.�9�Ă�?�{2Gr�BN=S$�
r�}��K����/��!ǞX�\r�%�9�|�aw�%_A��U�\r��V��O,�t>��16%����bs�D޷�b8����[v�v�m��%j��Y���[�#��+�Xy��m��w'7�ܩ��Ds��shn1뿭 ��3�!���Y��gh>��s���gn�d�-�'��hјk&�/����r������ff�|�6Z
�����>:Z����6�SH�9��ˡ�[zV�v��;��ο�3+N�Ĝ��g���y�S�ܹ���D�-��縨sh��(7��GWάr�'-�'��������y�Z0�ܾ7Ǭ[��3gt��ǜ���{s̺=�\97�;�nAW��53����VP��
�����*�OCef���-�1��p�O�B���2kž&�v�;Aw��dE�
���l��=G���o� ˩�����ʱ��cW��r�c������[�s�s܎(W>`��[�rn��s��-���ؙ�+���C�����R�+�D΍���͊\y�v��o+�1Ǿ��}+�{�<����ICS���ۋO� �D![>H.��w,%���J.�ly��}��K�&���.�� ����|9v*���ص�cס�K.�]˹�"�<c�-�K�@��qI���)�|y�\r��X��C��W������~��K��唣�/�����<vŶ͇z��Y���[�{ĕ*�9V>̾���֨r玹Q�ɩ򌍖�}B36�'�ʭ��[qT98+��3UΝ�7�c�<�Yѱ��h�C�rnׂ������͊Ty��s�veQ�Y1�3Q�v-��&��b���o��?�_����Z]:      �   A  x���Mj�@���ݗ	���!z�@�����6NZ���4��C]x-$}AI��4P�ژu�Et[�U�<��JV�uV !{��Ε�u!ha!���*��d�B@�4���-�-��A�� �p����l��$��3;}���*�흼
&������4�r:�����-"J�UME�e_�iz�Ʊ�_W�/#D�E"���� �C�Q��
���8k�-�yj�7|]��3g���#g"svV�UI�T����O��m�q�|y�Idc�1i[|��c�[O� ��Q.��ϵ��<j�Op��5�������hv��i>�Yu      �   �  x����j�@���S������vF�PSH�7��GBk�������PcV���w?�Zf
����͇вW1���6�s6ז�^���0�������}�0_����T�S��uۗ5; ����ڥ�e�$�B�{�q����A�`�0�O wh8��{<�Z�Vد��,��3%3㱨[C�)mC%������m�y9�e�j@QC�E��8�M"��>����?3�����KW����I��juA��Q�!��GjI���>����w�<���H'�!����Q�.!k�Uկ�X�B��MnT��*�q��cL�JDu��?rzv���q:�Da��P��m���z�'�I������+��^j�nY
�i		 ױ�/��!�p��'	�ᨷ�7�֟rq?���3�      �      x������ � �      �      x�̽]�-)����5�zo�2@���!4���5�X�:;�mK�2Eĉ̳�_�/�?ğ4K͜�]&�Ǹ��=p�7	�<aE(�_s_T�Ru�R2N���¿���g��
a����_����rܿ¿������!�;�����_	���ZK�j�)H~>��L�o��2�D�������確?�(0�K�\S���?��)`FuQ�"!g*���S��)���H aX�Z!��P�)t�Z(�MJi�L�v����?���k
Գ�V��R���S+��yQ��e͕�g;�j����`.���a�sQ����[�}�I�z.���?/B�GD���?n����>_N�k�S�W;����U�������\�(C�տa��'h���m�"H������(pS�B�&+Pc?뷏��.���\�a*
Y*�ָ�5�)8�"l�^������P�)8�"lXw�Z�k����=g]������Z��~�:w56ՏHMR�P��.�W��)ꢌ����B�k
��h�@��&HC��IZ���̎6
T蘈!s.i�����'�T��IK���"Ii��#�YEV��p�=j�o;��%����r�
�_��P�����Q RA�Ě�V�a�鹋0�3��ϋ�z�)��('t՛����ƙ}ϱ�j���u ]�C���=o]����
M!�)a��ଋ0Q`/e$��F垂�.�F)� 2�zn@����DaŬ.
Hi�=�X�}��"�#��H�?f�ͳ��P�zzɐgX������͎6
���Z�j�r�,x����T5�L��ϸἧ�̎&
��^��9�D���=gv�Q�ވ�!��;���2�
0rn��l={�㯶?����Lȱ��5�k
��h���2��Vɳ>��=gv�Q��e��	����=gv4Q�a�z��@��9����F���|�p+��5�X�~�Y(cJѱ��P�.���:	7��ɱm��/�����C-垂/;)`T^hؐq�Yʼ��ˎF
S�)Ռk�A�S�eG�=`R�c�Z��2�>���Q ���<�;�l��0��)��b��ĎW���FaM�S��ڎ��?��h��A�jbj�9`��v���̎6
M�kȎ�(��(8���B	I]4`��}��>�T��NkҐx�㯶
%���W�C�����Fa蝯��ae����3;�(HP�,(u��3�I��̎&
;`С�(�J�1�=gv�Q��]N��}�T�^����%�#L�;_��Ca�gW�&�Q[��)x���B���ue�T9�SpfG��ʎ(.m��{
��h� zQ)�z���pfG��H�#Hҳ>�j�Yh�m�	�M�k�������W=�F��`n隂7;�(�(��V�}E�����'��)�!�s;��)������=�9�^�ҫ�ȹ���^���C�6���3?�)�q� ��C�����8	��i�������1�����_��������煨z�cH	
.�!�u�6-LP�eB�=�=g����Mu���j]��:��Y�	���4c�-x�(��P�I�u	��=���u�6
�7we*���,J�?�:JJ/�2�CZX0�uO��m0��iR�%�I�xO��m��2"IZX��y����=ɹ�����l����zѩ��9�'*���͎6
�_��@�%����Y�fG��ϔfI5��vX��)8���Cԉ80�\���ς3;�(�l�R�K{4v���
�͆91Tߓ,��~(���Cb�]�w�톂7;�(���4�D	�����3;�(t���(�9Q���SpfG���c�V�����gv4Q�����Nt�βHҨ��ӡ0-�v���Cat51��d��C���͎6
�����=
!)�{
��h��H*,`���=gv�QhE�#By�������3;�(Āz�B��g_��%�LNf����v���C�h
F��W���gv4R����^�3M3O}G���D^.��$6��)����B�zG�e���s�S�eG#NZ�0K�G8Ge0����N��D&�[_��C^�B�Xz,��)x���BՃ�A#���힂3;�(l�	�XS�m���)8���B����e���P�gv�Qh�eU&�<Bl�#t���`�dw�k��yd�����C"�Zjew&횂7;�(��#�ǔ�g�"랂3;�(T}`(`Ls�aø��̎6
u6�q�P@V�ó�̎&
u��ʎ P��g��Ч�<ˑ
�^<��W��6����>����7;�(�><�h�˔�xO��M0��W��h�*m�{
��h�Pu2��c�.RR���̎6
K���Tkt9Ǧ�m@z�B(k�8�s���m�Ph/Ǭ㓻%�(��5ov�Q@��'�m�����3;�(�r��ܟ�����D���cS@�a����=gv�Q:0�c���:�u~��q<�:jr}��g��)��u�����ov4Q0���=���wLyE��m�>(���7:Gk�(8�����f�-���gv4Q��j/ao2C gޑ�FU%��v��/�v���Ca��0�YC�����͎6
K6�<ej���ς7;�(�W_'��V��F�����F������'}��SpfG��F��cL獘SO�M�������y�_m?�T�,}G0Rd�㚂7;�(���ӯǲ���w���̎6
T�P�������Da��As�r���)8����*t;Lh-͑��>b�,l#<�D){��z��W�?�JŪ��oB�a�z��^Q�fG��Sr�������3;�(��/s/��sz쎂3;�(���Q�C��(x#���B��/)z
������E�����g����slǟm?h�sST"T�Ƙ뚂3;�(Ġ��LJ��hc:g��(����Bֻ�P����s����/;)��.� ��̘�S�eG�u�IX�I&����_��5��ϩ>��P�Yѐ����"�)x����xa�H�c�~Ve�(8�����2�\�����3;�(�K���^W<��(8����K�)��a�q�������&���<��������L����)R���͎6
5�5k�V�>��=gv�QS�#:u�b�����fG�Yԃ�8�F6�ɳM�K	�Es\(ON��EY+
��ڙ�:y�㯶
���8#��<�ov4Q�1貵8i�%��~w���F��Y����'}�;�QpfG���V-���Q���)8������F�=���ķ*�%�E��V=����C���DDY=�uM��mHg�Ҁ�`�g_�gv4QhAZ��8�C�C�=gv�Qx9h�Ps���̎6
Sg$I0w�Pz�gGk]Wc�8
ǧ��
�����
=�x�Px��x'�v�Q�z��@ �SpfGҳ,E:G�s�����Da���jO�م��HrG��m�xA�5!�4RJ�~�/�Q�N)۾fX�{�㯶
����s��8?�z�)x���e��� ��#�^�{
��h��u���������َ6
L:[�H����ax#���DaΠ�G`�$:[g�_�M�-��D�cy.m���
�B5h��x�5隂7;�(�r�����s����3;�(tV^ h��	%U���̎6
��,;h�U����̎&
�j�&��X8�wO���LHmH��ɔ\��W�/E���F������͎&
��zI�_N�J�����F��uX�I�QB���̎6
;V�v�\������3;Z(��^�����9'E��S�a^�4f��g���7��(5�����Fa,�G)yq�O�;
��h��RcHd�5�}����,8���B̤{J�<C]�%yO��m�^��!%�6��DM=v}�h2���yǟm�PHQ�Y�D@�O�tE���
�&��ʢ��=_v4Rx�1�`ڟ�|r}�Q�eG#��AB�ZMh��c;�( ��O:{˅��l.j��j���������Y(�'�y�~��^Q�fG�u������\�)8���B�[=����)œ'���3;�(�N�)0��.s���7;�(�Tt�    ��&P~�h�,I�-,���϶
/��bZ5����5ov�Q����Kޱc��(8���B�§�s���̎6
ESXu͌��vO��mX�G0<˵�Hb}vq�:����-���|��g�?vT�HR������)x����S(
�`��R]鞂3;�(������<Je��YpfG���\�H��:Q��͎6
=齯��b����"t�2�)���)�c�_m?X�0�y���7;�(����<�����=gv�Q��#�NyVnl��g;�(��ey�\�D+D�ó�̎&
t~ǵc�,yI;�z)�;��6j��s��m?����d��o(x����\/�Jg�Kb/,����D��^̌f� �K���̎6
�s�O����
��h� ��n����oOI�
M�*,׻���Ca�^����2��=ov�Q����k�[��c���̎6
��)#�Zs���{
��h��G�zG��2��{
��h�0��B&,2�s'~Y؎$�H�͵��P/��cX=�o�tC��M�رR�\ʚxj�QpfG���Me�Ly$�{
��h����T��J)��S����3;�(H��~"�X����91�%�i��Xca����P����	K�Zs,rM��m�ldj�+��<�)8�����O�5�E�a���َ6
M�6G�́Ө��W���FA��}�=��w���S+*X��l����g�?b�XAB�! �k
��h�����!f����_v4R`]{���}�&=�=_v�QHIW݂'��U��?P�eG#�}D8��8;�GªPu���1
�;z~��P]����{�}�k
��h� ��Vi�}�M��N��h��t���;ZL-��
��h����̄�pm)5�{/x���B.M{��H1��g�u䤷��֞���Q�v���Ca����f��[=���(x�����	�L�c����N��h�P�>+D�:C�f���̎6
M��=�^j���̎&
5�>bw�c�gJ��QXo���b�؇�z�?�~(d]i�Ў������7;�(t=��B��d�'k�gv�QXz��i��{XP�)8���+y��{�9�vO��m^rw��M�00,>�6��T
���)y�㯶(���!����a���͎6
���Գ�g�
��)8���B�y_�h����3;�(,���ɚ�1r�����D����ꀙr��铣gt�)r��R:��ڎ��~(L�����ͅ�Y����͎&
#������Y��=gv�Qx9a�aFI}f9�>�(8�����A�'_S�"�tO��M(5�tSi0�!9�c�!����jO��^����Cu�W�$����;y�����y_��Xp�|O��Mf��	�7,�9h}O��m
��0�!�N�)8����Z�Uf(#>�Ν�Ћ� ���H�'	��C�S|�TT�BT��2�)x���B�O�����{
��h�@z���^č"�SpfG���_h-bl��tO��m��`G�q�A=��*Y���=x���,?�~(,��I�*V�+^S�fGIzƭ��<��(랂3;�(���Ɣ�*���SpfG���s*ȥ��
�gv�P����L�SV"��q��.�BϪ͐���yǟm?���Ҩ-Jq���6���̎F
K�#��	�{���ˎ6
^�h����i�{
��h��zO�$��H�1�{���D���8��eҙw�8uz�L�>Yr�r���g�?R��Ľ��)x���B�r�)�:Ǌ��SpfG�j��$k��&��,8����l|RtT��?O�)8�����}D�\��3�S]� ��nƎ=����Y��m?�����nd�Vr�����D!���t��y�M����⎂3;�(4}�:S
�b�b��g;�(��k"�i��`vG��MJI:̧j!����S�:Qp"~�f�6��l�_m?:鋰a�<��,�W���Fa����[��䞂3;�(ԗR�M�D�5�Ɋ}G��mP�5%����$z�{
��h��r�X�+�Fm�u�#fM0��2��k;�j����0��rK!��lw�lG�:��=�=?�����F���Ԥ�1z�{
��h�В^��bq-���̎6
C���G%�s.?wj�o�\0f�<��W��X(��@W���)x���BV�##�"�$'+�gv�Qh/{_�[�2kxO��m8�s����}q���̎&
�螲��%��N=�>b&!�S�qz������q��6���rM��M(�ؑ1��ͿpG��m����I�f�v'�v�Q�:��Hjm_x��QpfG����ޚ$��g��.h:�S|{v=����C��z���|P(�5ov�Q:0�����-�SpfGѫ2C8N⺇����3;�(p&uђ=� ������Fa�<�	k�i�����]��$�%�5���2?�����FEX:l;�����7;�(��0n� �^�B��mF��[V̣P���̎6
�w}f,�&$�����DA��䃎+�8o���B鼇�=�a�g;�j��0�,�"����@���7;Z(���ׁX[�A8���3;�(��.����U������3;�(t]��`�FX��W���D!V����1#��91#��(TV�{��yU�g�����^S�'ξ��̎6
)�e<
{<�q?P�|��H�D;��Cߣ�{
��h�Ї.��S�����/;�(@�K7�b̳��ۣ�!�!�5�sխ�m?�>@��\[��k
��h�@/���L�Z��g��mDTO(b�q�s����3;�(����a������=gv�Q����00�\r?�ogA@�r�[�s償m�P(Q�G��@{2�4W���F�V}�J���d;��SpfG�!:G�~mn�����̎6
��.q0r9�SpfG��M�1Г|q�~⅚u���6Q����϶
Sg0�X(��C�\S�fG�IOT��5���T۝<��Fa�P��u�4B���3;�(P���s%R8��(8���BK���=�!u��)Qt���z��G�|��g�����M���f����͎6
��G �JxlC�SpfG�Y���C赭��)8���B]�T)��W�_۝<��FA�\� P�ߚ|2!�N�Ȅ �J�$.ױ㯶(�l-��B��:yܮ(x����K��UpN�ȶ;y����	��dJ��W���D���ҹh���垂3;�(t}�z�PBo�ϳ���/[�BN]ri��Y�l������(�w��;�xC��M&��R�=�S���蹣�̎6
-��������q���̎6
s��i�3��ǒ�3;�(p�EIģ4�f*���Yz���
5���̯�
]���+�La�xM��mx���9�������Da��k�#��X���3;�(��j|�9�=��sb莂3;�(�>g=�=�C?���pU�f�Q��l�_m�P�݅������䉿��͎6
m飧1��C�랂3;�(����@Z*��)8�����kLsw陳���̎6
�m=�vJ����q�3�Г��$f��g;�l�� z�@)`����_QpfG�����f�1C�rO���Z�;� u`��b��c;)L}V�b����螂/;�(�,�� ��G���j-�������19��َ��~(��,B��ȂM뚂7;�(��g_a��� �w�lG��^� �Ʋ��yO��m�۴�L�#�?���h����ݵ�Il�V�o�SOB��#��Y��m?^�V1Ii���'��ov�Q�z&~���f*%�\�w���Fa��j��۝<��D��>=0�'���NsG��muO�=��Ҩ��������c�%�^�����tO���8a��lw�lG�_��=CM}���w���F���]�0c��Z�gv�QXE��v �C.�����D��)�O6hi�9hFШ�\*�;����W��X{4Ճ��������D���L�g�$�uO��m�����2�\垂3;�(ty���j�����h����v�Z������m�7@�1�by�㯶
U��B���`�&]S�fG���"��    ��G�힂3;�(����ٽ�?��zO��mr���GX%���^�fG��wq<9�R�V�<kS�e�8���U=������o����C�����F�F�F4�ߩ=�\mw�lG����ߞ\zj㞂3;�(��0.8�Yp��gv4Q���+<i�v���l�<�.,h�Ajf�;z~��P��l-B�8�ie���͎&
�^�=�xP�{
��h�P��ۓ���T۝<��Fa�C��Ya���SpfG���˳ 1�V�qKV�����U�v���Cu��J�d���;����͎6
�r>J�M������̎&
��?}=�	���3;�(��R�y��(�L��gv�Q�q���%�Q�T~Wk�e�x����ӕ�������PX!��튒� Rz���͎6
U��/�!�����F���݅����=gv4Q���>�b�{P9��gv�Qhz&�Ev܉�����bщ�*�ݣ�ix�`���뵩��XK�k
��h���^�zj��=�l��=_v4Rx���LHI�a_t�F8�����ׄ�c0�~�#�(���������!i>�r?wJ���}��@յ��P��v¸?E[���$W���FA��+�B������D!�f]8��Ov�{
��h���z�(�:�i�(8���B������痞��2/=]�de��4�v���C����Cz	�p���늂7;�(}�t?D50�Z��)8�����J	e�ש�uG��M�֣z#vĵ͑�~_�)8�����Fj��;�>}D:!h��j$�y>+��
��:I���M�X�)x���B՛:��k�uO��mHWl�P��'��j�{
��h� �l-a����w���D��SͲP���s����������k����P��$a�˓�1��W���D�GM!@~j�D���SpfG�^rw�����m~G��m�P^ء9������Da$}�$I�H�x��^�I<�ny^����C��L����1�S��7;�(L�r�;v�e� �SpfG
z���*��s�SpfG��W��i$�s����3;�(,��kJnA��;��%~��u�ҟ�}�v�������jw�`P
y\S�fG�+�K*�s��
��h�0��#&`^����=gv4Q�s}�'�c��d�gv�Qx��ȉˬ�'^�B/�x�#��zΞ�����>a,m�Ɛ�9UzE��MV��)	{)�q'�����Fu��Ie�����3;�(���@a!b��ς3;�(���6,q������mNX� �|��g���^�;�q#�u�
��h���B~�ɷ^���SpfG	[�ڎ9 c�C*���̎6
US�4�O����7m�^������8+tH�BkX;��jͱ��C!Bѻ8�V�y��rM���PW�j ���[����̎F
��#͒z���/;�(��/��� �=_v4R�z�P8���'v�T���*�m��9��϶
k��T�)�9���-���7;�( �,��X&�5(�{
��h��S�0�NC8����(8����,z���zj�@?��(8���B�AŎJ��ry�>w�AOB4�	jc�����P�B��=K�rM��mX���3��1��=gv4Q�o���HRKjYb�����F��̔��V�|O��Mj�}� T�a���yj��3�2)��u����BיF��3��)x����S"�~$FI����D���h���L��{
��h��/�ǀ@����=gv4QhAgױb�3��Uw��l����=��W�����U.��F\S�fG��O������QpfG��OwYeP�k$���̎&
=�3tS�F3H�ó�̎6
S��8��P}v}J�:IÀ�$�^�뚄?���0��?e�~+��k
��h�P��#S�9VY�샾��̎6
C�;�<kZ=c���̎6
{T�.�ܠ�z��,w���D�Pǎy�9C��T��z๐pMy���?�~(��ZE+�4����ov4Q�A�;�E �����̎6
�-C���;ʐ��)8������ b�u��(�SpfGNY�SJ�	W�y����L~p������W���O�gH�a�q���W���F�z/���97���̎&
+��ˌ��= �����F��l�3=�ke���w���Fa.]Q�x-
���Z%�՝f§V����g;�j�����L<��v
��5ov�Q��.jԺ�[]���3;�(Lx�ׄ;~�e������@��t����A$�0�=gv�Qh:�	1�!-�g�r_�V�Wd�3q��x7��
���$�e�����ˎF
1�=Qb����zO���P?�b�3p�ό�%Wv�R�:v�J��k��{
��h��@ǎB���,��s�t:���'��]��W���/�w���1\S�fG�����g�_��ᒂ3;�(� ���#Zޯ�{
��h�P_Ve�ev��}j^RpfG�=xT
%��z"�f�/"]�!I�<�v9����
H�A�D�i���7;�(4�B��"w��L�5gv�Q`}2 c�g��*��~����D���nX��Z��)8������(�%A���/�Z^�7� &���=��~(,��N�}\�횂7;�(ԗCK"I�Yq�=gv�Qh�.*�������=gv�Q��LE�i���$���̎&
�u�D�q_��Q�8֓�	kp���w���wqL	���X�k
��h���Q��#?�BO����D�%��Hs�9�T����̎6
���
B��E)����D�����c�1(q�3�nS�~����H��c�_m?^j!�4�9��k
��h��u��g����㞂3;�(,�1�|���>�=gv4Q�eIWڐǪ����Fa�<nC:Y�?�#�$u�\���.����퇂�29?���N��h�@Y?0A����鞂3;�(t5=����d����̎6
+i;���=�5�gv4Q�ET���=���p����I�#�T �����
���""��9e�k
��h� ��sr +��SpfG��_\����B��j�x���F��^��O�8S�����DaŗU�F�^�D����
aPH]V��َ��~(��x5�4�P랂7;�(�*���_��)8���/�>CJ�͍�@��Mt�� R�Bi��=gv�Q }J$��ԩ����QZzY�B�TR����̯�?�3zV��נ>��N��h�P�Y�����Tf�β\QpfG��vbh*;��SpfG�5t:U"�M��)8���B�KONB���@��#��D�H뱹�w���C��e�qw��z�tM��mR�:��P�a�\a�S�eG#��O�in7DY�/;)y�ؚB��R��6���ˎ6
�t��q��LPr;^H�W�Vi�e�j�l�_m?P��i�xsz
.�5ov�Q��`~GB+Q螂3;�(�k���J�:�{
��h�P�޿��(S�o��SpfG���I��g�g�#�(�R�S�]ǎ����P��eّ��5Wߒ���͎6
U���ȹ�^B��)8����)��G�O�*��̎&
5��y��F�4�@��mPWrF�8zEL�k/I����k��z7�϶
s����0NZ횂7;�(`���P��c����F�j
�������3;�(�N8�?GL��a�SpfG�YW�ƊsMh�N��+�
;<E@�w��l���K�Q���?�1^S�fG��k��P^K��*sG��MzԳ,,X��4x�rO��m��e��f���¼��̎6
���؟��|�~�ԇ��yª�%�>�q]��m�PI�A��9#�L�d*���͎6
��n%��w�Q������Fa�C,�yAH|v}�QpfG���#`�3�!㞂3;�(��� \w����SR�Ǌָ�]��<g0���C����e ����Y���͎&
3A/��)�����3;�(�>1�4�JKjb���̎6
s���g�.$(�U���̎&
\�^�����P9�#G������1����P�rB���{HE����Fa�2m�wa>e[��_���̎&
�bf�J���7    Of�;
��h���jm�>F�1�{
��h� �t{�Fi���X�6���mn�V�v���C�d5I9`I��k
��h��uv���!#���̎6
K��&�+t���w�튂3;Z(� �%O|�iU��lw�lG�y�Y��T���gd�BӨ:�@5�޺�=?�����e	�2'�H��w���H��
��*�{��)����B�����	���=_v4RXEŎ����x|��F!U�S&@\!��,KJ�eI��G�<����%�5�J^eG�+�5ov4Q���;��V�QӺ��̎6
%�C;��=���̎6
C�i.�ꩇ��g��Mr\/�vԔǬ;���	��8D���\Wl���C��"�f����ɳm��p�i�%�SpfG���Oc!�=gv�Q(���I�`:Y.�(8����̆�YC`���y��av�\he�Dų��C�B|Y�ɋSN�?u��(x�����f�����=gv�Q���8��Y�۝<��D���Q�� Oe�{
��h�КGt�%5R�~����IO	'��������m�m���)x���B��R �C#�Կ��W���F�6=!%�0tޏC���̎6
��;v���1���)8���B�Yǎ��X��cP��Ɨk�c怞����Bcuѐì0B�����F�u��&3���=vG��MFթ����P3B���̎6
R��x�Z�F)8�)8����|90lA�Ϙ���9��F�D�:v�����{	ݑ��z+�L�W���F���B�F���=gv�Q`У)�"55�{
��h��IS`��!�{
��h�@�R�-�/9�u��ː�Y̅�=g0����m@�,�}�h�g���͎6
U׳����I����F�em*�%?/�\��̎&
���3��S���{O��mX�A#�{�o�$M��!iW�uN�kֿ��P�?oyɄ��BxO��mP_$��-ȫ�JKw���F��z#"�W�}e����D!]�$c�ա�*w���F��=z�w �>�,�N�Ԁ3��<��~ǟm?X�M�m�:Xv0�����F!�T�ƾ(�|V��(�����7B(1�S>��=_v4R`���Y�؁u(��e���ˎ6
Pt��a�Pb_�3� HY�	(��{�X=�w���Ca���Bjߣ�9�5ov�Q�'~���=�B�=gv4Q�Y����MJ��)8���BO/�okX3���SpfG����L��d�Ǝy�P�����;�k�?�~(�d<ݡ���#�(x���隄a?-�?��{
��h����C����SQ厂3;�(Ԣ���Ov�X랂3;�(�����X���K)υ�Ժ�rL�����
�?��hJh�*��rM��mP�/4)`�N���gv�Q�z/K���&��㞂3;�(���b�bǎ�/L�;y���B�kSC�g��_/���$F�.�{K�yU�g�A�0��V��f}E��Mz�U49u�ɓ�=gv�Q@=�J�'�X��xO��m^Vk����
��SpfG�Q��Yv��<�wz
�詘&\EF*�3��l��0@��ha�QS�����FAt��;�!힂3;�(P���(w7F>��(8���Bק��KRA����o�3;�(̨�;iq���Y� �I��2������
U�A��^�D��5�P�fG���AWⲇ���{
��h� zwׂ����wd}E��M�-�� Ic��$����̎6
S� �=�ܡBl���)�U��VJ������
+�y�JQ�J���ɳm��U:	g��9[�����Fa��f	>EkC�����FA�zA�3a�2�@��M���c$�1�\b�'^���.8�����l�_m?��N��Jol��g;Z(�uu�!�ܟS��,x����NO qU�Tl���̎6
���d�链'|c�+
��h���˂Xb-%�rv������N���Im?z�Oa���)�ԯ)8���/�c��2�U�;
��h����1�wO�=�qu�#���Ha���a`�TK�{
��h� CG� ꎭ���ϝ��"�F�"p��㯶(�Agņb��B�{
��h�P��&�ҋжd���̎6
�S[u�@+�J,����D�D���Ѫ�����̎6
C��Ȑ���<�s�ڳ8,���&�϶(���*C����T�)x���B�ge�8j������{
��h�0uv�J���9ɺ��̎&
�%9l]A`f���̎6
S�#�gP
{��gGƦ�S��ip�ux^������v����p�2�5ov�Qh�%G��YRϕ�)8������q�9;vd�{
��h��A�e	 �[���)8����9�=�,1�-�q������!8j���g�?Fҧ�I"�KG����F��Z"Hk�}��N%�;
��h� z��	��!`���̎&
��Na�}v���SpfG֧J�v���|�DC�~/*�Jϒ�g;�j������ b����R�fG��/�G*��S����3;�(,A�"9.��)8����s2H��	��x���Fa��e�y�"��Agz;�l��:6U���g�?VN��9u*H�����F����$��W��;�xE��m�*
 �b����SpfGٽ�^�yk��$۝<��Fa�zVϩ���D�2�1d����"� �v����B	 �T)��R�O.�+
��h�������&�1�c�+
��h�����ޱ�B��gv4Q�Y��OΚ6���g��m�ur2t�-~�Xb��N�jM#p�*��
�%O<I����|��]QpfG#��z4�a���;�Q�eG#���/�mU%%^�|��F@WZ
"���R۝��H�u�O���\+|�Y�����QJl�=����C!'=E+��J�gO�ov�Qh�Ri)&�V鼣�̎6
Kg�޽��Q�j�
��h����;����c(0䞂3;�(L�N9���C���ӖP�Vܱ���?���P��N@%��J�隂7;�(�PQ���1C�xO��m�.8�`|�;��qO��M��Z�J+B���̎6
s��Ɉ 2`��U��]ok�!�5�ب��W�?�Z�ʈ�V��䚂7;�(�^�n�e)H�3;�(L�M8� hk������fG����P�������N��h�0Ay�1�չ���k��DOMX�1�k;�j���b����D9�k
��h� ��y b�%��垂3;�(�u�Q��p�?<��h�������V�#�����3;�(̪W�#�> �1ס0��-����c�ʞ������a6H}�f�k
��h��Qg$YD+�����	w���F��KF��Xm�1�SpfG�zw�H=�ک�{G��m��`���ޱH�YX_RU��p�US�l�_m�P��Wk@h�"���qE��mJW�J&��{
��h�0Dg$A��P�x���FAD��{JL�2b���̎
54��-m+���Y���碬���m������g��t>h��%�N�+
��h���sX��]9�F�|��H����;��)P�)����BJ���x���S���ˎ6
��Sb�=�
|����u�����	"���v���C������:���َ&
y{PG�'Ʋ;J���̎6
U��K�Rf��J�gv�Q �! ĹFi-�SpfG�z�I��.�� 8v,!����9@׻���Ph:jj� �v'�v�QXE=ő2�0ʩ�xG��M*D}��al�=gv�Q@]�*�1e(���,8�������D��X[�#��X;ʆ��&�zd���
�uE���1Ƃk
��h��ҝ2�ַ0P�SpfG��z�Ep����N��h��r�4&�"3Ŕ�)8���B/zƍ0����M���B,�8��=?�~(P�geG\%�8�>�(x������7�if۝<��F!���'m��5�)8���Z��t� X�=gv4Q �s�L��h�s���R+���{�\��g���GS�$��©�pE��m�M�1s�s��3;�(̨3��3�T;R,����F�V/��YvXE�]����̎    6
��z���x�%�1�$�0��P����c;�j��g=���q�zM��m�Ζ��r�����=gv�Qx)t�G�5�@rO��MV�Z�k�8@���̎6
C����󚱌A�Ď{��:�'s�6k�gIױ��P��/��g.�v���͎&
��7�Ie?%m¸��̎6
C�/�Ĳ?0A�zO��m���[�PZ+�uO��-0Ԯz� 8���~V�0�^��_�$���5�m?�:%�9S	c�uM���D���0B��W�=_v�Q�#+��ZMq� 	�)����B׵�Pd?5�3�zG��md]��ɍ�*)�;ť/
�X8�ǆ=����Ph᥊���i��
�ov�Q�/S1��ˀ��*���̎&
���qLs������F��[Q�qn�v���7;�(,]�~IiE����W�{�b�V�x^������u����UfK��)x���B�5�ӎ��
������̎6
��&�7��C�rO��MJҹ�2�����6�)8����У��5�<�Jy|f_���E�n�p���g��3�����vM��Mj��i�${|]z���̎6
�em
	N�9���3;�(���옟1�*xO��M6�;�����5mѾ%�Ƅ�=g����Ca�Y�� �KM����D���.�2���=��{
��h�Pt�[hcbiP���3;�(t��kɈ��-��CwG��Mz���k�3$>3nm��OgH� ܳ��P@�SF
������7���F���k����;^QpfG�t]�B-���7m�NؐU�=��{
��h�0�˹�Wx�}��,�^u]�e����l�_m�P��7������d6���͎6
E��L�ÚSv�!����DaF}VfȊ�K�?<��h��:Ǡ�ԕ��g���̎6
�g_=sm1K��q΢7?A�����#�_m�P�'!�$��\���7;�(���dn��S3���3;�(,֯�s�r�5霹���̎&
�꓄"��Lȉ�)8����ҫ�v��Z�����C.ir�-�����
��p�v��q\S�fG����E�T��1�{
��h��'>C�)�������̎
�)��ϋ&����+�SpfG��Wk;H�%�B��R5���h�%�#x�����*�B���qM��mbZzd-"�O���S�eG#�5�+�m����g����>1��H� �:�w|��F!��#Hx�����S
:Qp��V������B�'�
�ha� <]S�fG~� kDX8�{
��h� ��~G�]��	Ͼ�;
��h��E�ǵ��������FAt�p�PEΝ`�TU*��� ��Im�PȰTG� �O�('��ov�QhzGQ,+�vO��mX�5��K������̎&
e�z~��J��*�SpfG����{�{@U֩�Ҷ,�S��;S#�l�_m?���S�e����}���͎&
���Hۏc�2��N��h���
5!�%5�NxO��m���S�o|�A�QpfG|�~;)�p�[��NYW7|���$N�zd����Y�}�1.�嚂7;�(�ԡKDیi���@��MZ��i�g��pPmrO��m�K�1X��!1�SpfG��V(�)��I��X�fik7t�<����C��0���e��]����͎6
C��5��C_�9�=gv�Q���	ˠ B���̎&
#�Aƒ�S����FA�`����4�pF�cf��D�ؖ�<��,?���@�t�*�
e7!^S�fG�Tw��/%��w���FaM5��$�Ye��mw�lG�	U=����s�����F��!�ڎ����\܍ic<=g����z/��1D�TW:��(x���Bѹ�ھhJ�y�tO��mF����<+�SK䎂3;�(,�y`"I�A�SpfG�U��_�0;�U�8���z�Io�V�'	��P }�z!Q������7;�(H�:/�<g���=gv�Q(z�r�&3?�]�)8���B_�ޔ�в�꼧�̎
=D�딂�#ה��8d��	r.u����Im?�������������͎6
���װ`~w}^QpfG�禀��@��\����D!���e�g#�܁��gv�Qx���Ѡ�i���\ԗ.�+T�J�<��������[�9��rM�����m�!��M�aD.�|��H����SNct��)�������c��9����㞂/;�( �~#�s~��s<�d}��m��\�D��������zk(Α�w�}�b_Q�fG��K�1Jne?'鞂3;�(TP���$p+���gv�QzmJ`@l�����3;�(��g�#岽@�g~�g�S1�;̎빖<��W��iԋ�
���SW抂7;�(�xY�\���R�)8���B:�m�"���)�(8���B��r����=gv�Q`�G�*`�4γP�����%ݒ���=����� @���7��n�����MQf��'<}�ܗ�I:����ո�����c�Q���#�+��S��_}C��m�%���A�A�)8���7]ڊk�5��e�SpfG
��g�<玬{�vO��mH)�ӷpH�gNIY�+	Cd�a�g;~��P��ך �%5���5ov4Qh{R�w�g�I�*�gv�Q��{��ǚ�6���̎6
LZ����F�{
��h��_:���P�
�w�����$���3�=�w�����Wi�T'Ռ��k
��h�0t�N��yp㞂3;�(p� ��y�ٳ���̎6
U/�-��j*�����(8�����:�^Jh;n�zz�4���ֵ�2R�Q<������ �_%�ا�|M��mPW��AI+-��=gv�Q��t�!,j��=gv4Q�1*/�̼Őb�{/x�����l"6���9�,z)fb�۪<g~��PXzWf1�,<O��ov4QXI�_Hښ=w8���(8�����;tnP�0h�{
��h���%l������{
��h����_�5�Rz ��a�^
��-�1J_���5�C�Q���X��H[_S�fG�=�������B�����F��3��魱�T0X�)8�����q�����ޟ�F����D!Ɨ#���{p�����a՗vL��L#�랄�c?�^}Ƙ��Ѯ)8���B׫�&��\�U����ˎF
�ҬNd�ީ��ó�ˎ6
	t5;�:1���ryG�����(3����	�;%�醓����+�9��z�.񒾊H=���(x���B����#�YA�QpfG��;',!���z�Fx�����>�eH�+��YpfG��r������K�g/E
SL9��yf�9�C�u�5H�af���͎&
%�g��9�OD8���(8���Bѯ�*��'����3;�(����c��H�gv4Q����'&�<ҹS](�0�\����5�C��211%�uM��mX�Y�p�5����=gv4Q���#O�s
�B�gv�Q�:�ZDZ��#�ɕ���̎6
S�G<[־���ֱiT�mp��y��s�?
��~�H'��8�cW���F���]���C�=�
E�)8�����]Z�;hh#�{
��h� :��9)Mϑ�LxO��M�˳�'�XsI��woY�$v���O�
��;~��PU�;"�	��=ov4Q�Q?S8�ٸ�B����F��.��M�P�D
鞂3;�(��R�{��z�SpfGN����N�Ў0w�Rt�����[���5�C�z#�<����ڏ���͎6
<�Z� +��Nf�gv4QA�_ ���W��Y�)8���B��e��C.L��SpfG��W_8�UBY��]]��hiH*�������f���i?-O�s�5ov�Q���]|��C����SpfG����Tj$�T������̎6
�t7�@�?��3;�(,�sЄ{�="�/��K��H�-�}��=_c?^��,��}a�tM��M�s�75��?��
��h�P�� c/m���=gv�Q��)�L"�X�)8�������"�c��7���%�*���(��c;~��P ݍo<�s�c�+
��h�0t�����    Ob������/;�(Ĩ{Wȥ/��
��h�P��� @ �=_v4RXE��Aȩ'�3k������h����g;~��G!���:�Ό�LtM��mP��tɳ�'w��@��m�^e�3����T[�����D�P^@��
c�SpfG�/t�C)���.����F���:v���0�~D�X�ܴ�^S�fG��2�&cr���SpfG���u��~wh.���̎6
/3�}�=�:��)8���By�YG��6���N�\^��;�Ha�L���?�~(�.���o�c��_�5ov�Q��Bb4q�垂3;�(�8�f&<���:9�w���F��,���h�ͨ�
�gv�QX:�s���u2���N%	8���x����t�ӌ�F�g�|M��mP������8�#�(8�����u��|{V���9�rG��M��4��b�y#���F��o3�������&*/�m�@kX�玭�c?�ޏxz��5Y����Da?�:^��7Z��;�QpfGқ�r]<���v'�v�Q��&�mO��~Y�=gv4Q�Y��O��yN<ySܣ���H�$��u�ϱ
�������qE��m���G��2�ov4Q`h��#G����S�掂3;�(��G4ܟ���������Da��I���j:U��_�R� �F�tmǯ�
Ew���K�1�3nW���F��g���9�Sw�=gv�Q��Ό;���S�ó�̎&
�8,s*@s5�?PpfG��'7��c��4<��R2VT�Ϯ����5��t�t��J�3w�k
��h�P�*Al!�{
��h�������H�tO��mD�c�S�
ȼ��7;�(곯1����kg6%�?1Rqk���uǯ�
�+�O�=�l��;|C��-F�:j
�'�SO��gv�Q(��	2i�#���F���]K�,��¿,�+
��h�_2�QR����9<�Z��C�X������̎�c?�ޡc�0&�Yw���̎F
�Ow5e��[��)����B
�Bz���-.j\�)����B�����vN��Q�eG#��^β��l��H����О���x>�9�H�L<ɠ=�H�_�+
��h��I�g�0{������F�u�
i��������̎&
9�~��-�-w^랂3;�(P�&T�{����7"祦߅�(+Q���y�ϱ
^!j��b����D�$�,.i��J9�{
��h�PY]�PjɿJErO��mX��5����ڼ��̎&
����<��B+�U�QDԇ�@�-ђ�<�Y��P���u���ia��)x����(*�.���k��xO��M0�.��4l��_���)8���Bջ2�������̎6
��&��V<��F���o͘��2�c�Q �/;�R��H�횂7;�(�>ŁO�un���{
��h�0�
�A��͎$N}�;
��h����������,����3;�(4}QC��m��s���Tπ�%��1z�lǯ�
+)/!��a+��)x���BO��P�P�3@���̎6
X��RF��y�{SW���F�u�� #�ٟ˓sG��Mt�ۀ�w���trPofJ�۬1q�\�s�V�]���̥����ov�Q�z%~IL�p��N��h�0��RRBM���)8����K�����<���7mD���1�z��ǀ�C�T��0��i�ϱ�(��R�G"���i'rM��mH�܋���p����W���Fa�ls�5��L�x�D�(8�����7Uv�:�=����7m���I���d��Uu�R�=sTױ����}�"$BL-�\�)x��������/J�_V�gv�Q �RP�֞�(����Fa�&d�Z�P�?PpfG�^2��, ��ۡ�!�s�M�{x���}e>�~(4�Ѡ�џ��S����3;),�1`��<�{�(����B|�0n��Xm,��S�eG#"}X�5����_v�QHA���<��~�,3Ψ۴	f�����=��k�B�5z"��è�]S�fG�t���Ķfo'{쎂3;�(,�%`%�%�q���QpfG�g�^GMe@�O��?<��h� �r���sj|��'��)�3-O��
���5����γ޿V�_y_xM��mH���Ҏ�E�3;�(L/4�'�zM�tO��MJ�/U���$��{
��h��t���u{a���7�lG���,sO:��x�����-x�.D�;r�#�(x���B�U�6�rcG���3;�(4]��s��(�5z�(8����ԫ,�-�	�@��M�TmGX-N�-�cGL��$#b�i��\��s�B��ʪ=��<�5ov�QX�R�%��F��=gv4Q �ꢎ��&�O�#���F��Y`xj����gv4QhAg0co(�y(��^
�A;Ў=��|��P�����)�5�D���͎6
�倬�*IR���gv�Q��{o�F}�Sᎂ3;�(��w��0"�g����F��>t����f�~��?��Y�vhE��t=���� :�� �zƇX�)x���g�O�!����zO��m�*v�2
�X��ov�Q�:j�;n��栿PpfG�Q�^���O�t�u-�Ϋa�?�]�������m�R6A�A횂7;�(��>�JFځ��=gv4Q���ٿZ�z��b���̎6
�w�3�~�S���̎&
+T]!�x��ɡ���y��̩��3��َ_c?�K�wH%B�-�xM��m�>� Ȣ.aT۝<��Faŗ�-�9؁��|�Fx����$�u+K�"�@:�i�(8����ʆv�<��ֿ;	���T�(������
+]
 *^e�xM��m�ޏ`�+��B=ySw���F᥇q�ʍ��r	�SpfG���=#s�a��'����3;�(Ī�������7bL�ˁș*4��c�ϱ
]w�̸
	H��v'�v4R��4�?>+����ˎ6
)�̀�uO���^�{
��h����lJ��2�9�)����8�,ؠP����ִ�|+mUJ��h,�=	?�~(�tZ"�O��9֩�uE��m�^�'�Ը�<Ҹ��̎6
KW6d��C���SpfG��jU�H��3e۝<��F��zz�r+)��,d�^~�̂�se>���P�ҹ2XCK��⺦�͎6
�����}��a���3;�(��H{a�h�ԲN��gv�QXK��2�
=�s�+
��h��gL/�c�S��QA�B�<��� J���9�C�u���=,fH#�k
��h��!��&�	3c�{
��h�PtVi~�����N��;
��h��Xͬ'w�=����;
��h�@Q��K�u�5���/ch��/�$#D�������5�C��L��H�s�|ξ^Q�fG�>Ԝ�CZ1���G۝<��FAPQ(�����yO��MZ/yS-���CrO��m�ޕI(��DS9Y�����q�̋�Ӛ˱����У�l�$�B="A���͎6
U�G�Olme��fSW���F�ue��5�<�e�SpfGѧ>#��Q¾T�)8�����RF�5��Og��Y����<G�ŵ��~(]
�qM��sX���7;�(�w_wfܑT���cc��g;�(Ԭ�2)�@������3;�(��� K��_��;
��h�0Aw�bءT@���G�!�e♧ Đ��\�ϱ
/��' qIaҩ�|E��m�>�dT4�{
��h��^jw=g����o��SpfG|�؊��3�Sy���3;�(�έM�#����kЋ��ff��L�;'|��GA@����V
-�>�)x���鼩#��<p>�o�(8�����ySO�14��)8�������=���;A�{
��h��t�H�(�A��V�%TЅ�0�S��ȱ?�~(,}�i@��������̎6
�Y�9�g�L垂/;)�>˒��&Hø��ˎF
�)y���˨cO��)����BʺKg��r�?�YHQo�6�k}Z�z>��9�C�tժ���D�gNyE��m�έE�*7�����DaϬt'g^s���J�w���F��G��x�-�=gv�Q�U��4J
8�C'W�Pd��d�v���B.���ns��FvM��m��T$2F�i��v    O��mD� ��c�k.����fG����Y��j\�N��;
��h�0u�y�g�V��ִB���5�h<w����B�:�q
O���N��ov�Q���a��S
9���vG��mX�SXq�=�ˡ���̎&
�~D��
�����͎6
$�Y����F8_J,/�<1Gj	��\�ϱ
SW��}�AN�7;�(P�]�"4�cL����F����*s����Fa�7��fy�|O��MZ��ȸ���x����Ԣ���7h�fn�z޳����tWoa
�������͎6
Sǎ�#��b�����D��4)��Ɩ꺧�̎6
�)d齶=��s�㎂3;�(�N��8W�5�ʆ҇N+(�S�/�g;~��GaO�^N}�*�)�\S�fG��NK}Ǎc�����gv�Q�/]����e�SX�)8����fְ/�R���7m�>�k��5�ǎ�fT�mߵ&B�=	?�~(�Ώ`��V(�rM��MfN�Z��^���F�=gv�Q �g_%��S�
rO��m��H��h!����{
��h��JTSl��N ˊz{_`طY<��|��Ph�Kq��(!�L����Fa��*��V���=gv4Q�4u��o�\�c�gv�Q����s$��蹣�̎
-�t`�׎3��:c�`Hi䎅]��|��P�z:���Z�L|M��m�^��4�z�����Fa�Fn C�����D!&��"�%�|O��mz�5���+A¯�־�.}pq�A$㎯���{쇂�9e�Z�Llw�kG#������?��G��qO���H'�&����2�(������U.������{
��h� /�����VV��ۭ��D���n��wN�����iI�좂,j��)x����[�%�)��,z���̎&
�N1��*!�*!_RpfGҫ,B 4*���3;�(��Ͼ���F��N��S�S�6�6)��Y����c?�.��қ�[հ�5ov�Q���Kd�2�����̎6
�ך&$@�s�����D���*�=��a�SpfG����a�j�#�ߝ*��V��p4���w���F�7U�a���=ov�Q(C��ᯗs�{
��h���ۜ�)��{
��h��t7��F�$�{
��h�@M�I?�G�L���DU7�ؓ�Dse�̾�~(,]�DP�#����;
��h��@�/4.�{�:��Y�fGҽD@��l3�|O��m�^_(�i�V�H���̎&
��B> }s�s�yD�o�@j��p|��{�B�9t�k(��+�7���Fa���� ~
3���)8���'��d�2W��=gv�Q@]�dGϭe�UG���̎&
#�C�aO�F�8ϝx�6�5���v��������4��@���͎6
��������=gv�QXI]�v⁘���͎&
3�~�d��GQr���̎6
]�0�;f�z:��D}p�p��R���w��� �`G��s��rM��M��I?���!s?힂3;�(4}�cI�� T���̎6
S��t���]_�=gv4Q�R��d�&9�ǎ��Q�T+�{r}��k�Bק�*��4˳�k
��h���z`��a�z��螂3;Z(� �%ø�T!��mw�lG�{�CƳ,�����D!���'(���M�0�KÑ�@u��c;~��Px٭�j�Z-�3;)t}�m�&��u���=_v4RXz��aF���uO��m�C�i��h��@���^��~ʲH 9tL���`�T��v�����Ό��
�HpM��mJxٕ�бg�_m�K
��h���K�3�6���{
��h���I�!�$pp�D�(8���B����d�򔺜'?"��vr��2��<��k�Bו��5q)c^S�fG]�sO!r*3w�gv4Q(YS@X�)���{
��h��tw�� ?�S��SpfG��E�?���=��/��vL;��!ꓻg;~��P(��c�T�9�5ov�Q�Q���:�O>�gv�QXCŎ�a��{
��h��Pt��;�FB)x#���F�u���a5y�kwBԉv !o�R�3	?���@��0��SɹI�����F!��q�$3bO�mw�lG��Oq̧>A�}+�{
��h��teÎ�r���{
��h�Њ�m�yVx��:�-���a�Ɇ 4�{֟c?��˲!m�t���͎6
���:��.�mw�lG����B��CrG��3;�(4�s?S.��l�^�fG��m�[� <��u�}�FD��ϒfr�g�5�C����:q�'�r]S�fG��{H�7iy�yO��m$�o��Vc��ڈ����Da����~%z�O��zO��m�^}ma!�m�s�Az{?J)�T$�ޕ����r&�C �Z�)x���B}�у����9�)8����7��(u��#�{
��h� zY.s��p����3;�(,z;�� 1�1��/��t֍���-��v���0�y�k�Sy3���͎&
���
�ID�i$�{
��h�PY]Tq������uO��mXg��S����q���̎
���%[����r�]e0��������l/�8���*G���͎6
#��kjWZ��SpfG��˹&�X��14�SpfG��;'DL��6G��3;�(L�0%#L��7�H�kT�k�{rl�ϱ�(���/d����	��)8����.K������ׁ풂/;)�^e��$�*���)����5�g���5�s���/;)�.Uј�)K��O����G����������P$)q��������D!��m�U1�7(��W���Fu�������ϩ�;
��h�0���]B�&��QpfG��u'g.�✝~��T�.[��=��ix޳������*̖<q����ov�Q��\S&Lk� �=gv4Q�IW$AH ���=gv�Q���)�s江��
��h��Q��}+q�7�����b͹f��َ_c?*�g�K��㊫�5ov�Q��YKie��
�?��h� �h�k���jxO��M(�yD�=-b�rO��mFx��W�?�؍Ϝ�h�$څ��6H��َ_c�QhQW�gI���8�)�(x���>�x��Ԇ�{
��h���R��u��=gv�Q������c,�)8����SEŎ�g�5SZ�w�/���1�Pc�k�>�9�Ca�~�K�v�0�5ov4Q��>�3M���̎6
e��Ai�=gv�Q�z��`mu�1���̎&
#u�F0���)�˳N,UH$�
�U(>�~( �o���x��7;�(�^��׶�xO��Mf�E��W��V�ς3;�(d��9cF����~O��m&�/e��R�{�����"[8���L��n}��Ga%��/;^��4����7;�(ԥ���!Rɘ
�{
��h���L��6�æ��@��M$�d���6�Y��͎6
�s'ƄU��FH��+����}C�5z>�~(L/T�a�Yf�yM��- $�I������ɳm��SL�8А{
��h�0�n,�'qގ�{
��h�A��IKd��{ �J�q�� �]�؎�c?H���hԸ_�k
��h�0t�����k�{
��h��"��#`�D؏��N��h�PugƁ�� ��	�;
��h�����d�r	�/$Nz�b?,�)� �lǯ��(�^�DV�g�垂7;�( ���Nu����Fa���[��xJ�{
��h����[��bJu��;
��h��2��Ìc�z��@.��U�O���s������O /�=�99���W���D����)a����N��;
��h��2�n��*S�۝<��F�ef�$�.!��HrG��M���9�T��DM�%
E(�լ����k�����O����]S�fG��Ͼ鱍9�:'��(8���Ʈ��ne�x��gv�Q ]������⺧�̎&
^:3"�^R���SN]�l�Ef���P|��P(�%��I�C�q�k
��h��t&a�sJ����=gv�QXz�e����>Z���̎&
-錡�!J��)�=gv�Q�:jʂ� ��    Չ��/�	��a�R{��9�CAX}H
��9��mw�lG��U����C����ς7;�(���\H��I3���)8�����4��51eF���̎&
O�2�/kŉ�ғU
��a�,u&�aGۮ���~(t��y��J��;����͎6
KW*"a���4d�SpfG�:����Q�B��)8������z��=�N�q�t�QpfG�Ǖ:^��DF��i��?IO���������ꢆ3�%��o�ov�Q��]d��"����̎&
+���%5P���=gv�Q�ڎB^m��y�SpfG��3	w\]D0�1N���ޯ���3��Fy�$���� ����y�I�<��W���F��z#����ٓ�����Fat� ����߈'3���3;Z(�u3�.�9(�ڸ��̎6
-���1��_�C���2V�S�O���P����ƀ0k�5�5gv�Q�)�tѨ�=�	�ɧ���ˎF
��S�g�
�L*rO����.�'�+>t��A�Q�eG��u��&41�ƹ��;�u-�	��QV���9�C�{�3�*��R�)x�����gܦ@�HӉ��(8���$]�`M�Tځ��gv�Q@����k�F3�ʆw���Da��/��sNP)�fSF�=��*}O�g�lǯ�
Y�YO\���S��7;�(4PvO�.�I��{
��h�0u;&ƹ�8����3;�(�T�l*�t���ә�3;�(��(L��� N��\�. �9���8=�w����X�#�L����}���͎&
t&��C�P�?��h�@zW��Yu�ө�h�SpfG���+��2Kiu�=gv4Q�,:^�:k�{ΝΗ�k��P2�G"���5�C��t�S]}�L����Fa�L�}�I�)���3;�(P���]\�v�XNm�;
��h����x����j���(8���Bz�5@�r�2ϗ��^�����"��sO�ϱ
����\A $� ����F��JEi��kc���̎6
SW*l#�5(�rO��M�����B�5���{
��h��u�šǚ���u9�� �e�mw���5�Ca��������*���͎&
�u�0yk�)����F�鵦�Tŝk;�d�QpfG��u�-�9�\˒?PpfG�Qt�u�	��\��� �8)�
r"��?�~(4��P�a�_ȧv�ov�QX�3��!�({�qO��M&DuQ���`������3;�(��6g��#N��7MV�]���#�O1��F̗_�!��\Ϭ��~(������74�[k���͎6
M�/L��p����gv�QX������TF���̎&
���)�J:���(8����>��#tNc@=的ti�(;��_���9��B	Q�ق����?/�P�fG�u� �G��Zmw�lG��se��	���I�@��mD��%�;l���w���D!bЧ��9��g��ėd�#��(�َ�c?Xe�#��V�rM��m�������霉���ˎF
E���\9pyދ?<��h�Г���<fK�_���(����ĥW_E֠=�.�<i�rF�'�+���D������"�\�ĵ߉|M��m8�z�Rc��¿�w���FA�~���C<���(8���BκK'C̣ĐǨ����Fa,]���)�oŭdҭ<�q����h�؎_c�Q(q�~�+�^ƄuM��m*�~{R�!�W�gv�Q`Pt�Z�L��p�Fx����L}���G�l��g;�(ԗNK	�����[w,5�B%0�P�DϹ2�c?��Rf)+I����*W���D�~`���i�m��g��m�ޡ�"&�����F᥄MxZ���y�j�w���D���F$�sd9Q�. � ���`45�v����U?ܷHƿ��W���F�u�HgL[I螂3;�(��WYd�C���͎6
E׃��-=�,1e���̎6
S��
Big����K#���Wޟ�v���BOzWFpՐw�O-�+
��h��z?��4����)8���ϗ:n4�@M��;y������
�F�q�zθ�QpfGҙ	r�e�|(p��	W)o�V�lǯ�
c(/8j�;xl����DaDM�e��V$��g��mjW���q	��=gv�Q��R���R����3;�(L�'�"�Rr�p"�!�[�I�;���<��k����^eI��x���͎6
��T�f�s�VY�(8����
z}�1$ �58�SpfG���;&��Hkv���̎6
K�GT,��V��y#V��~����ڎ_c�Q��Q	��$��5�5ov�Q@]!}��%t��)8����x;�X�ڿItO��-jCE�U*�g��)8����5�.�bk�߉�ZS�ѡ�j56�<<��|��P�A��fz2��9�uE��mbҫ,u�:��~�,8���B�R �2�H��=_v4R��*��)�ly�vO��m���N�<=U~wJ/ħ�X�Jex����������p������7;�(�?BX(�Y�qO��M �*�u��B.������̎6
5�4ȍ�@�{��m�.U!B<�j�|(@9�5T�5�*��k�?
9����6��2�~SW���F��#��K�����ɳm���Y��1*H���̎&
%�.�3�=�\��QpfG��=k�5C�I+��jy��Yf��<�w���0t�X��c	��S�fG��~G�$\�i�;
��h����_,	:1�?PpfG��B�3)�_�����̎&
:ݰ2��Bj��7���Q�T�����~(��k�=ҞE ���َ6
Cg<yֲf��T����̎&
uf q�$%-�~O��m�K��'�0<5ں��̎6
k*;��
���g�t4��	��d��s�g;~��G�A{�S��3Z�v'�v�Q��.�5��H�
��h�0���}��ڞ[�{
��h��c~��W$>ݞ�u����F���;��q�Q�7���R���=��َ_c?^:9����5���͎&
��!��+J���z�QpfG��~S;`��a|G��m�^q�=��-���7;�(�k�S�Ta�~�F��r��p>��g;~��P Q4
��C��5ov�Q�z�x�����)�SpfG���˞����8��w���Fu�&�@�٘A�{
��h� EQ���g���=V�굉2s�/�\��s�?
��Y��Xyd��o?ↂ7;�(�L-��Ӑ螂3;�(L]�'5n�pA���̎&
Y�Yâ����=gv�Qhz�5B}V�2���E�.�<M,��C���5�Ca��w�Xs�y�k
��h��t׭&O�x!j'����3;�(�������
ϓ+sG��m��&�Q�����o�3;�(Dԋ�SF
�S����Ęu����W�k	{Ε���0�>%@ߏB�3�|M��mR���Kp�7��|O���P�G�탚f'8�w|��Ha���]3D*u��rO��m ���,���J��/ ])2⚁1�we>�~(��ޯ�f�X�7;�(��)��Xxq�{
��h��_�"ϴ�]+�{
��h��Z�g`��x�pO��MJ�	58VB��<v̬�	�j��	k����~(�+Ӑ{�-��;y���Bן���6Eԑ�=gv�Q��fu#�`��:]��(8���B���Q�ր�p:�D�(8������ǡp%�s�JEo��-7\�se>�����+/d荟���)x���BAuQ��t�u���;
��h��u�LG�����;
��h��tG����;�0�n�gv4Q��Oq�Aqa���7�U���r	}ξ<�������iib|���S8���7;�(�^w,G��N��;
��h������8����+�{
��h��[� K�������DaO�	�'V��'^h���@�¥5�[?�~(TPR���¿5�
��h����Bⱸ���=gv�Q]�#1�_�:�)8����6�^w�H1��&�=gv�Q`=�l�kl7�y�ǐ�`�J�������~��GaD�_J\� e��K�ov�Q(Sǎ�-�?��=gv�Q�*�6&A/�{
��h� ��y��� :5��(8����~�_��#/�q��g��%Y�_(e5�    }e>�~(�^� ��I�,|M��m���'��#�5�=gv4QXY^z�(+-I��SpfG��+�tH��S-�SpfG��r�T����uⅵXwƆD�7(@Ȟ��5�C��,�9Gؿ��ov�Q`]��
&����=gv�P�tUl���
��{
��h�PtE��ܱI-i�=gv�QXQ���2����SRh�؞��G.�=W0���B��gAK���I�k
��h��z�n��V����Q�eG#��V-_ƈ�ω���/;�(���N�?4�IF���ˎF
�c��JyǙ�N�h�>	ڱ	I�'z>�~(L/�1ղ���߳pC��M ����5K� ����Fuf�n�mܿ��h�0�K�&�}���F8���B}�#A�D�2�=��nVטCm5�<W����@�������N/�+
��h�0u�1�1��S	���3;�(�ؔZ��,���̎6
5�y��<5z��,8���������NXD�5h��
�����e������*芧���Л���͎6
�_*!K8����{
��h�0tM�ȽÈA�=gv4Q�XUԴߒ���P{���̎6
M��?�j�0�C�Eof$R��=��|��P�]��qؿ?`@+����D��>��~	��b�ó�͎6
�V'^�L��|Nw�QpfG����;dJ��Q��,8���B˺�Y¼b��T<�BC/�B���
y����jꢀ=�W/8�)x����Ե���]B��zO��MzԵ�����s��)8���B��,��@O���F8����Ea�3���T��<�s�&�Kji�3믱�(0�E��t��37���͎6
�^j��:[�A�H����B�Qa�C��D��fD��%���.�����E��HMʈ��u���p��������������O��a���\�8C��7,��o@����i�"��]3�����?���.jU&��Nk�^��"�K
pU�>��{b���Y�v¢�'!�C�~��2��Pap���c��q�wf�<sa$�O��Џ�d���C^������,b2}F$PTI;b*A�����EL6
-�����s��,�u)#̍*���{����~(,�35a�K�V��:�o���M�1���-�vO�Y�d�@z�e�{���5gv�Qx�kN2���������̎&
���s/�Yu�}�ɷ�AM��1�Zs�lǯ�
�s��+aϦ�ZMW���FaO�7;�4�`�gv4Q���s�I#T
���3;�(�.�:E��,O��yO��mD��	���>�ZϗR�Ki���$�1�g;~����B֕o3��|=av���͎6
�r���uQគ3;�(L]�&p���X�qO��M�?��^Y Ɯd۝<��F��})��W�����K�Xu��=٘suF�{�c?��P���=I3�5gv�QH�������<�Z�_v4R }��C�������ˎF
C�|�2V��vXy�gv�Q�<�N-6�g�>�o��A�G~�����<g�|��Ph�22�(CV>�sW���Fa���O~u�6�?��h�����@�pQ��ɳm���=�<�%�)8�����\�°
�~��-�D��#mZG���9���u.e�c�h�/����͎�~�����o/���r;r����}����U��=��4R���B~�@~!Hȥ��EEvLōr��@�������3��P9��F��� ~��1�8���J����;�����I�AHE�qb3=G;J��)m(ꝁ	��8�����,��5_C?8���R:��z�����`� A�8"��9�:��C����!��c�F��=_N0A�Aw- ���b��HT�Đ
��V���	_C?*��`����:�!�r��ȕ��ce�t��L�3G���2�  #u��|9��w儵���pO��o%�UuQc�=����c'|�������9�co��!�r��~.�����p@�!�r�B��IH�3�����_N0A���
B�e0ŧL�}������
�<�����[���k���m��/g6W_:b�{
���Mj�݊�$B\��r���l��F�-uQ��6`�%��C]_�7w�T���w%��~�]�b�d�vNt/G_��O9>��N3���cY�!��L� �=_ұS*��/V��/�&� ���ލ�:�@�C-<D�ľ�L�|�
6c��Vb^Ҥ����	&=N�:�-^༞=�{��`�е�S��`m��йW��',�B|҇�:�k��4�:�������`��;$R�u�x���|9��k�z�w���/'� ���ܑ�;8-#�;��%��� 4�H�?T����k�����S���!�r����䞸�Z� �r�	/8���b�!�r�Bg%��{^5��g���N�3�L����	_C?������H4S��ɱLV�rPz��|9��i}���Q�M�� �r�	��o�r�Ȑ��8a-}��������#;_C?0�����'��|��lx�8i�xJ���C���B�O*�Q���=_N�A��.�9�E���߾���,k�ڞk���u��������4e�X����	F1�z��{Yfm�<9�
�wt�ԙR�+�=ON0B����-��w�}����*�ޗ�!��������V�g���,�C����o�����f��ɱL �ކ��b΅'�{��`���E�}�~$܄~wL�;���$��Ҋ�:�k��h�'P-%�j��|9������KX�����)oy��S)䦏�#�<����G��L�C��CF��86:!c^:�"�%/, �8������ߧ��q��l�_r��~o �|�W�`�PC�KK��z���/'� �>����[�e~�J��!�ꌳqݱ��~ ��U�s�5qGR�|9��~\��!���s�Ó��	6/��H{.�}�C���Y�Q��}A��K�Sgr���cmx^d���T��$�h�d�t��l(�'A0渿��Y�|9�a4�$D�2c	<S����	&�G��f��K:+�-,]xW�0�����k��z?��4W@����	6S��w�)O�{޾�!�r�	BOC=	(!	>fp�C�����إ�1���	u1�=>�2G����5�A��@�-�)X�M�� �r�	g~9�X�
���t��l�� �V�1�D��/'� ��+I��F���p���zg�6��s�����k��$���g�b�_N�A�/����;O��1��/'� L/ؤ���&F����	6S�;�L��3&>q��UW_�,e�g귦����p���R�1��z�߇sV?���^j���e��W|��Q�%��G�a�ҔA�<�e�[U���K
&�	�㜩�Q�(g3R ՚� ����M�~����~ ����R�N[�t�W�`���c��[;0��a�?@������2c�s�����%_N�A��^�����h��CC|mP�W�et��9��X���3���?����	F�/꼒�2jC����	6)�D����[��,7�Ap�#�_�H�(bͶa��RD���猇ϡ/�����{϶;9v�	�lA-a\g��!�r�B�̈�� <�!�r�	��O�(�{Z�U �|�(u �P�Z������|ˑ�[���C����!0�H���V�|9���L�D��F��/'� t�%�~݁���Jm�.��9���p���9�A�����<��C�y��L��-O�]�bǕ�!�r�B����;����/'� ��'���j��n˿;��՝*W�aQ�'|�@@a͈����J_A����ث�k���s_�Cy��L(V�:R-����/'� t�	>�9�8b��:naB��<P��� ��xn%�!�C����5��� MJ��|9��)�2���j�����`�У�E.,���V�#ƶtS��Ax�<=�1~�@�z�q��s�)�{��`��zCvB����j�{��`�    �A��S��^a���!�r�B�j=A �Zq�g*�Ԯ&J�uI%���_C?���R1��4�Mc�C���ze	�<3����=�C����>U�(l?�{��`� �ne�9��o�e�5��D�E�s��JK�C�A�U_��Ƶ���|9��u��qBH���C�����J�?@A�~#�=_N�A:YG��I�YYZ-�$䕸�bs섯�� Hԇ4"İ?� s�=_N�A(��;K�9H�;r����	6�x�`Y���/'X ��uO�&�KΙg��)����{M8���x/�s�BC}fI��͙���\9�a����X��?m5�=WN�A��!L=��z����	F<u�%�[�+��:Dzyg ��bd�������>� �%���\����	6���Df��͜��_N�A���"
�q�q��A�����c�5��i�;A��6X"��e��81�s����"�<bO/=����	&9ij{qS8g�� �r�]T��*��d�C���u!�Ŝ��O���$�k\l�����c'|�@�z��aZ#!��� �r���S͌2fi8F�_N0A���8a=EZw���\�|9����C!c�
�Od�o���g@<���~ �l���i�N�8�=_N0Ax�1님ڞj����/'� tT��ȽLj}���|9���DIoí��	�r&P��yy0ԁR -�?�~ PQ5�{n9h��!�r��$]�W`���=_N0AhI��N�F���?���`�0t�@�T�BI�+�;5�v)X(�''<�������[V9�=C�p��l�.0���[�:lwr�����1ӈy�=_N0A��r���E���i��/�/e�ya(��&��"��~ ���6c���DE����	&#���a�ƀ3�C�����	���qu۝;�a�CDZ�����:�`�5֑C�ձ����0A�������!�r��\���b}��A�����2�oY��:�&����D@� {�$��&6�#+s�����m��enS��LHB{:tৄq���!��	G���j�ЙBٻCW�a+9X�Bq��/�S�A�C	�g�Kڳ�� ��	G4�n�.8K��!��	gު�pΥ!�1�=_6��h�?�o��v���j�P��O-'۱M�}C��R�q����=���/�p�e�n���(���ɱM8���O�==�ͽ�{�l���R���2�|��_���e\�
(�6�S����0�U�j��!��	��B ��O���z��M8� 9+n�m�A�4�!��	��m��J)�l�v	0l�(dZ�b�ڄ/�rN/#�rY>�P� �/�p�ۆ�YƔ���� ��	gԮ0gn%��Q�w|ل#� Z�*fйc�v�H�g�=:�w�}Cx�ۼ~Z9.���	W|ل#5�I�7�s!�6�!��	g��,wZ��z��_6�&y'�G^ӊ1~�VX�5�v���Ȏm�Z�i�My�K�%��/�pAl�΄>pH����/�p��]�J؟��'�:�!��	gf��+������Mh/ÝY�������ΗO��r��M+r(�ƞ�~��M8��,��Cň3@����&�A���A��!��	GF6�
��ص�ք����˲-���<�O�7��I��$^_C�;"� ��	G(XeY�
H�Mw|ل3���'
CQ0N��|ل#����G+�g�mhXu�u����z��D ��H[���V�yg�3
�sT+p��A��%���4A1�[i����H�8�g��7Xr
J�yJ�)�����F,m�	��?���0�@�!��Ϊu��{������������=�>�P�2�D�[�D�(��,}���P��ܑ���S��h�Ϯc=�WősS��k��o�^�����)��ɯa<� ��mS�=PC�=W��B�v�^�+xB�창��'?!c~s+�2o�����vr���]�� ;���)�����3��j�>�{MpuD�iBG��&`n�����)'z&M;��}C ~i��ǜ%+�C�u:A)������&����&�A��Կ`Z�-�3�{�l��i�ȡiyӕ:�J�<�fc;�P�w����O�l�4"��F�����A�e� �hۄ�:�<z��M8� ֭�:�h��@�e� piF>�Y��ɒZ�&�����?E��؊O|2�)�ߑ{�l��l��b�5h��7�-��ק��
=����oA����T�R
����C�E�@ A�&< %�g��/Q'`��M�=Ɩs��`�ڿ�S���Ɖ�e�Tht�ս���캓!#N-�{GG�/MxV����3�w�����5ܑ���A8��K����,���v���=g�i��K�����[��K�}D@%dT΍&�����s W��Lv�P/\�C���>�#�@b��	b��$�;�ptD�[�pd@��h�8�<���]�/?��.2{5����n�q�w��>����8l�y`-4
bp���p!XM蚸��2�Cp�1�A�j�4&�,�+¼��:��i�����a�9�����{g���p�,;�(�1"q�x�,��s8�'$[�Db���5��a<҄$oÝ3�8��x�H�����v�
"�Z�Ah����H�����0�aw�"�A��=��a���EAI�����_��>����?���O���/�0*�@���x����|�iPK��/M?a�B2�����}�������?�	����ZJ�S�&,��ð�8�)֙5��������UC�Q)E�^	vw������A�ZF�ĝF���������m�欺f}����2!/[Cl�#��r�K���K�5]vc��r��&|B�Y�I�?h
S$
�zo��eLɳe}i���1eн*��#��l.�I�4��48{�cw��{X~����Y���2��N����?Zg�r�d`���+~�wO!���{��}S�9�0
����M�_����_�z�e�
�����BuM��P:��R�=g���g��<�9����^SpvNQ@�?�Z��
��{�h\��Tq@ā��:~ɾ)�ly�tM��u<��bNJ�Tj�Yz�{
ά�Z!�>�*��5�qO��u<�P�y(j �Spf�(�nt�����`��;.���g���j�eE�g��%��C6�@j��B�)x��gP�M�5�g��=g��w�51��̒&�{
ά��ɸVC����_����3�xF��P�I���R�4E�\��:~ɾ)�4^�]��=�5o���(,e�K����:�Q@y��c'nU��=g���9#&��B�Q�)8��G4�3Bh��*,��/��?a�O�J1\'�g��%��������|��[n(x��g4�3�P�ʨ%�{
ά�	��=)#r��=g����+,c�y�������:Q�]Ld�`y8��ta�bR��<�8����o
�Z7�j��z,��Y�3
	������~����k
���!/���4����|Y�C
�wlPC�<V�]�)���g�&M�:(K��e�	�.3�Ã�,<[�/�7
�����T*_S�f�(�9h��Z�.T�)8��G��|+�j#����Spf�(46_>�6A(Q�)8��GJ桡�<�� ��5e���N�¨q�����d�j2E��(J�k
ެ��E�g%�:%�4����:�Q�i(� *�r�Kn�3�xD��f
�gO��W�wG��u<��Ü�H��e��w+3*k<��g¾����K���P( ��O)��k
ެ��noe&�[XaH��o��´_D$�)s�go�l�(4h&�D̩&�D�)8��gȖ�,x��,�7�֒	��ei'wϷ2���(�`�#T��Z}^S�f�(�_@}�a���g��B�=���r,-�{
ά���������)��@��u<� b�#֯�����,c�K�D��V��Mri�d�Q���C�'�B��5o��    ������8VTI	�)8��g�f܀�>Ӽzh�_�7�xD���}]A5��O�{
ά�)b|Ǌ+��y��w�E�M�#�rCQ�l�d�^<�D�j�HtM��u<�0���$��,�H���ɳu<�P���Tj��T����:�Q`4�0PRԹ~nW��Qpf�(h���Ki�z��W�8Լ�B�)@hH�﬿d��-���@Y?U4��[�
ެ�	
P�.��bB��=g��������8���3�xFA�v�@�M!-�	�)8��G�W7'bк���5-���R�BɎ��웂N�AHi��go�-g��Bz&[�g��F^~D����;
���!�A6�FCc�Pg��|Y�3
��χ�>k��s�R����:R�ޱ#�,���/�DPm�<S쉒����?
94;���0�6�5o����x�L4#��go�l�(p4���h{Vx�]pf�(�h���WC�MG����:�Q�b�˵$=�{*/��s�9������?
5�N�q�Ԋ��Y�3
/]"��AY���)8��g�oJ�Ĥ�{
ά�|��$�0����g��G���Ph��}�lټ��HW-�����K��m?%@��;�+
ެ��I:6�c��(8��gMdݗ=Wh�%�]pf�(t�ƃ�B������Y�3
�~��y��4�\So6!�!��s��y���?
#�L���L�c����:�Q�h|GY�gmDs�e_�(8��g�ֲ�S�6J���V�Qpf�(PJ椄e7���Y�=g���J���<c:��Κ�1+�~�pk��:~������A�A������+
ެ��_�
Q�����(8��g�e
*�j��(8��G$ڝ���%P�vO��u<�0��@��9s�;-�6]N
K�кv�y�/�7���XKh�wOyC��u<��\���L�t��Y�3
��w�4N���t�;
ά���$,�  �	គ3�xF��)��VLۜ�+�H�m=e�q,�ʨ��u��}S��8�,�Ρ�k
ެ�	���XD)�v�&������B1�̣�Spf�(,����gLmٌI��Y�3
��ǳ�Ifߓ8۱��I�#��^�O���@��ղ
]�}�g��B�/s_S%���_��ښxĬ<�Ls�����:�Q�l����9J���)�������cr.	�]��/����V�W�S���l�Sմ\�Q"�k
ެ��f+�����#U�^�;
ά����6�N�J\�!�ެ�������l"���M����&���� �wo-�f� �0�M��'�}���P#�)��r�A��sY�(x��g�;F�c���{
ά����*Y{.((�{
ά��/s_1�	"{��g��E;
�&�hj��6�b�]�p���S��mz1(Y˲�!]S�f�(��� `��s)���Y�3
�v�+���Z�?���:Q���:�,!*xO��u<�0��W@HmTLy�}�^�6]bS!`)ax��_��(�`�@�0X�5o��B/���B�iE��3�xF���q�<�̜�3�xD�^j�)�YSf��Y�3
�؛{l�lMHY�II�γ�eg%" ׷2_�o
j'�&b��&Ϳ\�o��g�Eju9օ��=g����vv�9��=g�񌂲�)5O����wCwE��u<� ��[�33��sMRl�=)6ut�����´��+ՒfQҽ�7�xDaB�{�uD�)�rO��u<�����ҙD��"tO��u<��6�����=�g�񈂢����`h�˗ؑ���]!��R����֭O�7!�mN
��2�S�fO(H �eAR���B{^�g��B�u�Hc�5��
ά��_f��Z��㞂3�xD!�������E*��}�D��|����Z��{e>e�$����PC�sY�(8��gRj&��*5a
��S�e)�
q�1DA��.�����e�qe�Ҿ�����:�Q���d�$�so����"!t���?���K�M���̳��<���7�xD!�a{贆��P����:�Q�vN��>�lU����:�Q`�k,�gE�0�)8��GJ���=J`}�nk�ݸV5��F��y
ŧ�°�WV�i�T����Y�#
5�����$�$e�.x��g��5u�J���W�rG��u<� 6���SƢ��Y�#
���*�L!�2p�3��6d�=�Z�����	f��ϴ�!�{
ެ�����qQ�Rne������:�Q@��.i��8O�@�Y�3
bo�� ؟�|O��u<�����v�D3�ɿ�Z�`��D��M�����?e�^:�&j��e�5o���� MA��93�Spf�(�}hQ�P�1�{
ά�.� Z�[+!F����:Qx����CCk��Zq[��Ǹ�đ��rtYɾ)�C����6��k
ެ�᥺k�9�_����3�xF���F5����������:�QX��=R�xO��u<� ��5���H�W�&�/#��	R����)��o
�nN �TG�{��o�񌂂m�QEb����3�xDa��2�/!�^��vO��u<��m-K�Z8I�)�{
ά���2ȧ�R:�(��c�-~*1�җ@�+z�d��ݨ�c
Ac��g}E��u<� ��:Bñ�ڠ�����3�xBa��D*T� 1�=��3�xF��_@O/~���g��BL�V&c�c}���:�0m�iє24
�#�O�7����
ЧPO�㚂3�xHA�F��Q���=_��B�l����J2�W����:R�6˒���l��K䎂/�xF��"�{//3�y��	�ͥ�
3,#��l�d��~�ٿ�&��{
ެ���2S�s1�)�Spf�(�d�#�B�3In��Y�3
h7�#`�Xe��qO��u��P�������Р��+�����y]7��C�z�)P��vck����?�����o��?A�YS����.噟t �������7�.�?ʐb9�$|��8������χ��i-}��Mmr�χh����rq�	_�om��|�j������k�4��@�@҇Χ�����`�h��9�tO���D�r0�%�V�q��i���p4�\�H�ocRE� 9ք/�7}.���&`O[m#�5g�p��9�(��2��{�dtJ!�4������M_�oC�C�wr.�{�8�!8ӄ#���%�LK�u�I�y��������v2Ͽ
�C��X��À:'��wD�@�	G8����IYr��=�q�#D(Q*Omz��D��z�5��h��=g�pA~]s����yR���$i�x������k�B�l�%��Y�2�k�4���,�Q�b��7Ixq+p�+�|:|���0�M��Hc�����7M8��lN��<�2p��N�7�N��Lf�	k���!�&�/�4d��TEb(�[���i��jCͪ�`���>"��Op2�B�70�&�/�7���C���	^Cp�	g���gX�S�mP�/��>���ͳ&|��@� �|3J˦~��5o�paEK�O��:Ֆ��j}��1����{�O�7~q���0�p�m� �҄31�MX?�!��?:�N!���AٱM�}C���i�J,I{z��&A`�rG�+�ِ~�%�_�Ѷ���L��߄�%����|3@�$&���k�4�B*`�Ti}�J?�c�Ĳ�L��ǚ�%���l�~x.� <�!8ӄ3�%�χ��e���(�����z�1�u�ֿ
�C�H6�d�*��{���i��f�T)0@+� ��rbVʣ?�k�ٻ�H#rL�&�k�4�B^���ֱ��������lN[.{K9xք�7���-KoD��k�4����D]�A���Z5�@-��zKȿ	�K�a�yhJ�4�T���L� �l�$�֗A��~o*����g_�.�q�	_�o-�� 8²�+�k�4�B���m��BA�oM�f<�������y�c�}C�6vHK��C�)���M� ��
@!tH%�n����    R�|M�M���c�}C��hB��a��(��i��`��4���e���9Bb��z���	�K���(��Hʕ�\Cp�	g��"e��e����V��i���qE��?-�ͬπ�r�Ck��i��G����5eڱC+��q`�K�֪z�6��!���x��f���L� �d���9�96��?�^J�F�a=��s��K���f����,��m���M� ��,!p[V���N��Ի�L\H�:z����oB�}CP��O� �&��/�z��&A�lY�R"Nc�~��YsM5`y��	��	_�o=���2��q����i���k@Gj5vܟ��b��c��A3a��O��������t���y��&Ah�^]S�0�;�J�^X6��!�:G=ۄ/�7�E�jBL����_}�g�p��^X�>c�:R�����x����9ք/�7�1�]�3e��9B<{�cM8� a�t͇և��^cQ[΢:'�R�y���}C��ƌm�&i���i��a�ʧ�k�C������=3GF���sf�K�Al(�yy�#�*��i����k���`�<��4�KW�&(1��<��B�T[~$iˑ��3M8������@�7n�c\��M?�
�'p+乶�K����F�x���k�4�B�7PH�p�sW�]����
�3{�	_�o_&i��+���k�4����!�-��c��N2��f4�ų��%����9��O���
�n xӄ#�l��fP����i�V���>��[M�}C��Pa9�A�n1���K� �¶>A��R��;8B2o*I8q���BO�z��?ZT��t��&�APk"t�HE�~�9B9u��Ǖ*��� ���D*�!�ARw�o�p��Q�R4�%D�R�U��[��Ϛ�%���v��\Qx�J�ڼ��L� �h���AB��4A�0&��G�OR�q�ʧ��oY��4DZ�����
�7M8�@�Y��0q���J�6_��c��䤯�����D��4���c�!8ӄ#9����q�J�!�v�r��&ĈRr��k�>E����QhC*�O��3M8�0�]$��!��y�����M�Tϱ×�?%ڻHI#%JB��7M8���2v��g��
!vY��˚T���"��R�S�a��3:��u��!8ӄ#5��&��9*�$o��X��[�'=g��D�2Ø5����3�!xӄ#��m���O����m�oC�=.�CٳM�}C;�� �)ſ�*W�i�̶y�<�sT�ng	#�#dcC,�<�c�}C����<Ƨ<�1^Cp�	g�Ɓ8��7sho���*������"?E�Aho��R�5��r��&A@{!;tpe���,�l{h��t�3hz��D����h���Dmw�\Ap�	Gz�+��F�눈��~��˜��s�<��S�l1g�Z(58|�gM8���eRK\������{���3���Hݳ��%�� 6�J�U�gҽ��
�3M8�0��u'�y�C�����Ֆ�=�&����ǚ�%��P��,T�?>��ܮ!8ӄ3l�T�T��	�ۊ�!�)�T�xք�(�M�I�2
+����M� T{D�b�������e�smT��@}��!��`B�Z���+�4���#R3����W������L�uB,�{�	_�o`C�H=��J�!xӄ#��Y'?��J���b���X�0�{���}C`�Y���f]B\Cp�	G$ٖ����9��t�`���Y7\��g�_M�}C�v�u��rz�r��&�A�l5���&W ���,���	3�������K��e�F�	u9T)�{�4��,��3@{�!q��f�5/Y3��z_�cM�}C�zT2-VE�^Cp�	G�%��@��Z٧��;mϙ�Xc�:���)���O���,��i���R!N�H#�#R��B��ժٳ��%�a�v�E���zJ�5o�p��oв<I�ռ�b��Y@x@s|��)��@v#�S�ˊ%�k�4�B���!Ҥ�T� L��rj��O�}C�o�u$�V
®O���M� �V��\��s[��|��l���9���{�O�7�iG$����1vR�
�3M8��r})�Y�����E�Ӷ���U�9�c�}C@��]��Hy�r��&�A��U�ZC�Vl�?�D�ev�zKx&gǕ*��� @���y��c��\���M� ��aD�ԗI)�9T ����+ڎ0r���S�aԗl�2�`��0~��&A���Ta�V��.�fI@^fr<}u	s���&|��!�u��*���r��&A�6�4k�-�	ޒ�� Ϯݚrn�������^2/����q���i��R���☚��R���ԟ�̬Ew���!�h�6����^mp��&A���PS���Ϩ�����ɎI�,,}t����o`��&F���#_C�	G:u!
%e�4��y���tmK�p!���O�7	�sX��R�- _Cp�	G�ȥ6��a{�޶��8��6<O��}C��R�c_�1�8�!8ӄ3��������M��á���]1���O�7�C$�{�	
��+�4�B+�F��WRoA���&R�P��㚥O�7�^�� �iN9�k�4���bGȂ�V�3Z����I�����A=�E~����_6} �0�ќ��7M8�0���F��;&�Loc�Laz�	_�o3y�O�)�������L� �l�������s�^�4�i����]��֗�#��
�b��� 8ӄ3bg�M�e�Ŀl�j�ִ<�)-d�|�%���i�4��Z�v��&A��m^q��&�/���&z���KJ!�7P_�o��^#�u@"��5g�p��K͒jKs6��Oz�PGy��y>�D����&��AJS�!xӄ#/��2�S�W��a�5/��h�<�\g��D�^֝����k�4���,��JRR[Ne۟�j�C�@�xZ��Bŗ������L� �,�D�A+����H�os�R��G��������d��*l��ل�4��,v���B4B�h��=�������;|��!J<�k)mw�_Ap�	g�&m�4�?�0��`,��eB�=�m��A_��3B�������Y� t{5Ϥ��ƴ�ȧQ�R��T���O�7���:)�c���i�	� ��2�1Bk{��|z$��dj,J=8���)��Pm��m\w����/M8��v�|}:F��={m�ng��Ãz�� ;>>E�A���6Gh4=h��7M8��v~�$	�H�e�|�1ۤC^Rn�Y�W�D����0��pa���^Ap�	GR�E�!��mS��R�������O�7��9�T{5�_��
�3M8� ��E��~����D�pt�1�9T��[�O� ڼ|����T��7M8���p0�aʀ��1N(v�[�>�8gD�~��*�i.��*�~��&A��^���\DJm~L��{@�0��Jw�Y�}Cȶ�1)��|��&A6۬��(���_�q���ⶼɄ15h�s�%�� 6�<V��)��5�k�4�B[�\�� 
u�M����4S��H�c�/�7��"��O�7��c\Cp�	g�!�ܥ�8��P��)�V���}���� ����Ҿ��XC�)�+�4�B��Oø����~S�(H�!Ǖ*��o���!в���n���3M8��6�����g�Ծ����5����p\��)���'lR������M� 4�O���a\ˉ��	k���W�9��q}§��K�Ơ҆t�aw�^Ap�	GZJ6��E��'��Se�Na��gM�}C�/S�(�28=���!xӄ#l�z3@_�4W�_�lݾI�h]�/��l�D����dFXD-9^Cp�	G����M}p��١tO����D�ƭz���)����e"U�.#�79ք3Z_֢�r�
���7��y��KЎ�q�ʧ�?#�����X�V�5o�p���R��E��ϴc�Q���ؗ�    �ų&|��!�ݓ��*�F-�ٮ!8ӄ#���#j3qK�Y��Me
�RC�|�%��P��%Ʃ�@jt��&�A`�c::�3���V��u+��:�w���!��1�h���,��i�	.v�<�`p(��W�l�J4Z^U���ԗ�Bc;�AA����3M8�0����9F�q�=qk2�-zD� ��_�� H�3G�+�)#i�r��&Ahv�C�"�sd�JK���zϳJ�<o�}CX��>=��ٛk��_�\���s^�N��d�Y���W�����S�!ۼ��Tfl��6_A�	G��� '���=�x�f�� Ψ�r���c�}C���cj�2k�T��3M8��C�9A��A��F������	_�oh{�H#Dm���i�����Ԕ�_	�{a�@D)aU��u>E h��+�BOTK��n xӄ#ծ+�H�R��19�ʰ���D��	��oú�H�a��k�4�B/͡�F��2���&����9��(4]k��1���<��{��o�p��r�3�2G�6!6�a��z�{+�3K��o��3"�;.\��i����رb�(�@��jM9�o�.D)���s�ڧ��n�	�9i��ק^Ap�	G �ˉ���R��&�i��{@�����q�1~��!�j7} 㬨=G���M� P�9F+x��'�>����B��������O�7��R��%w���gor�	Gֿ��#4΋�n	�mgH"�%u�<I�S��ٵhM�u8���+�4�B�v1LQ�Xk)�� h��6�QJjгM�}C(6󲾙�`��?\C�	G_�	rY��\�m��@�����㚥O�7�)�
;�R����!8ӄ#5[�A���Ρ�M5e�h�C��g��_M�}Ch�Կ#aṒ�k�4��D�T��@���^���lJ����k���L�O�p���N���3�k�4��1BX�f�#���u���ӊCS�a�!�5�K��^*9�ǉI�j���L� �h5abD�dC��&�3L����%��?E���,)�Ԟ����i���B�s��}ۄ��:�
�Y�'96��"?E���o-ṇ��W�i���m�J�L��Ѽ���f&�M��j��1~��!4;��`4��-�W�i��i�H���<)ع�N/[���/}q��)�vQ�g�}z\�r��&A@;]G�[���������T:��g�<S�S���%���N����3M8�@�n���|}�(pcڲWR�0�
H=o�}C�������C�!xӄ#�^X*�n�`�MJ�^6a�9��]�x�'|��!��R�%�d�r���L� p�Gd��UrBi�*w��vbf.5�R�g��K��e<)=�U�I��i���
Ty��R��6�K%G[iY�LY�gM��A���В@F�[wr��&A�/S�p&��̥�=Tm�_�Q2C/�<�E~��!�o�!$���s��&A�`�Jw�5��ֲ�Dm��ҕ��Y$�:��%����B6c�+��%�%Un xӄ#b�r�� BK�b��氽ā/=�mz�1~�������u�R�T寘��3M8�P�v�i�m��2�7=[��C->cnG�;|��!�b=F��v�D�^Cp�	r/�j�==��aT�M�3Z��s;��}Cx�wP�)ᨔ8^C�	G��T�4��1t�����lcMZf	�V���!��f�0Z��ߦ�;�4�B�d/,�ؒ)��K������]'�h��;��[����	�E����p��&�A`;�Z��#5e���)u1R�Y=��}C����ӔuD���7M8���M?L=bl��m�ˎ� e�%B_�cM�}Cv<i%���n����w�i���|H��.�(Gd���%Q
"��~{��E��=�s�?�r/��i���r: �?Z���{ӊ7��O����ǚ�%�� jH�9fn�f���L� �P�1�L4C�!Ǘu ˙�9���	_�oh�h�3�Z�!8ӄ3�ra��c��A�{��gp��O-��J�o�J��I=PY��6���M� T{Ҍ8�}:�lCM�RbZ���o�7��s(�Y����4�B6�jP'i�a���M�fcT�Mt9�~��E�ry��*�Q;�_��o�pa�����ˉ*=��'T�up˷�#W��:��}C�� ����P��r���L�  ��z �T!�}:`|��Ep@u���җ�BU;���<%�<R���L� ������qB��w��ɕ������9��%����MT�H2��k�4�°Øh���_ �\G[�F�ypL*���/�7�74��T�m��!8ӄ#=ۆq� E�p�m{��T˝�XG��v�	_�oh��FAC���k�4����Y���uNm�;�ag�f�u���R�[��-��vw�3���Nz��&A�6Ѻ��P����4`�,��J�˵��	_�o�F��jE,�%�k�4��d�H�Z�Ri;KC���BTt�Z�>�K�l�K����]C�	G�����#�yk՗�	��>ep��	_�o�6ކm�Y��e�n 8ӄ#��B Ipӡmg����.�s:<�_�o���YCnA����!8ӄ3lW	�q�Fd��r�n'M��p9؞�J��!��M���M%���MN H���:NZTdvr�
/0�9[t;|��!�����3.[f��i���@�A�]��5�fJ(#���E�A���Ǩ����-���7M8��l}a��MV��f��ۤ}�����|+�%��@�>!�P��]��@p�	G4��a<�1-qu�S��v�6��r!�~���c�Q[]�p�&ϚpAl�ah��O�����y�����0�f�\��%�!�(os�`�W�կ!8ӄ3�/���M���b��}�3���.�w�ַ�?K�:Ց��)�ٛ�j�!�lC5i�urC����v��sS�.y�c��)��������Hk>C7o!8ӄ#�5/�k41��@��&���L�̒p��z�S�� ���Fm;KW�i��^�F0ʺ0̺��)U���ˣ
u6m�R�S�A�&sj{�\K�x��&A x[��#�s��'<{��9�
'�g�cM�}C�v�⤧5D�!8ӄ3��m�O�pN�����D/�	Ji��V8�w�Ʒ�?�e��Бk�K�k�4�B[
�D�+�~S.��A�1������o�7�~`-�Z��;�4�B��OX�G�sn����G�K���;�6��!�A:ׯ0��!xӄ#���g��SO�m.�n̊�	S]�ñ&|��!L�UN4G}�1�k�4�B��s���<7v�P#u�P��Èi����-���v#=�M��"���i�����$s,�m�7�M:0,#Q&���/�0�"�C\�=o�p�N�h��Fwf	�u&p1�T��Ryք/�7��!m=�4D���!8ӄ#�%���W �+�;��b�	��{I˗��c�/�7�u~	�g-U���A�	G�������wTlh������F6����K��_&n!U�Y�\Cp�	G:�굪���e�J�c��>�ʘX�s��%���/�k&���S�5g�p��N��+�l�p�}ԗ�M���h�ϱ×�?#ԗ�벘Z^C�	G��'�n��-4ڥ�q�dHXNgGYǌ�l��°��AoM��+�4�Az[|��r=�O�`��-�
$�(u�6�K��چq�a���!8ӄ3l�����'������ǣV�q7ܧ�?�5���������7M8�Pm�c`P��l7�=v�蠟2.ǲ���-����&��U)˷�k�4��vc�:ZJi���up��ul!j��'|��� ���Cy�!�w	�o�p����=��E��ڄ�)�/upu��:�u��%�����%kѲ���(�5g�pa&4鵎s�s.�b��v;N�^���ք�7�bg�gH}�����v��&A ;�v�#M	��0���	0A*���U�_�oj��h�ZU�&�@p�	    G�|�W�I��`g�5ɋ[����=ۄ/�7�f�d
5,����~��&�A�vcVm�=�����_�,�=L.��$�O����o�%��5o�pa�K�X���}�����:���a|�a�j§��K�F��a�4L��/M8�_6�6�TZ,y�%�7�h����
GiFǽҟ�oh���x�-w��3M8� v�B\nR�ן�~Ӱs	��g����ҧ�?�pxYw��K"�;d� xӄ#ն��<e$���JJ`{��Ƥ����X�D����h<zl[���L� ��P�F=�2u��:϶c8d���	��	��o`'xWʽ���J���i��no�� ���c�h{��iY�R�8v�}C�[',�I'��� 8ӄ#�e�J2s������b�φ�O1�����ohǉ u�2K����i�yi���|'3�rO�쭦 㓘��6���P�Ks��)<���5o�pmm�Њ0z�ÆP���T���Sk��M�}C6�Fʥ�w����X� �`��TJ�ӳi����i+"'��Cn���V�S�!ۊց�QXA6U���M� ���*f|,B�w�+Ҵ���J[�eQt�	_�ob�;<���a�	�W�i�[��G������;a�74S1.�%�6�K���[�D�b�/�z��&�A�h�Og�+~�͡	��z?�L�^s�m�?-��Q�M{*��7M8�P�Kz-MZc;�؀^2�omZ=�O�}C��|MU ���5g�p����-�'���MX¨�`��P-eq�c�}C �Y�C�6���R�7�i��n�H�uDBX�%�_ms��n�c%��=<�	_�o��]���k��+�4��x���t�ti�G�GdW�E/A���:F�m�}C�ِZ���ǧQp����M� �l�@JOO�"�)|i���T��P�=k��VC��
��B���i�*�L�)g�%��0�(��dX�G-�s��K���o0�p[U�Wu��&�A��H���C���&��i�d]4U(�k�?E�A�h;CpyJq��ٛ<k���?M����c��?.ٺ�XXJ���6�O�7���h	k��?W�i��v@[����PZ��,I,��^�=�����S���x�jx�e�n 8ӄ#3�r���L^���n��hԥv�<��S�!۽�]g�������7M8�0l�V���JO|霠gR�����/�7!�� ��^_Cp�	G4�l�a`��0j�����b��1~��!���3�^ UK�k�4���R�d@Ě�MЗJ�����wz�1~��@����~Rp��\�!xӄ#uڮy���� ��B./�v˥���L�O�7�a�O�$^q$�k�4�B�%�jk1�ߪ;�
᭒C�/�m��-���o��J-PJC�k�4�B������V�>a��e*|yZH�:I�>E�$�I �p��9�5g�p!%��	�� ��_�R��@u�������B�{����X��5g�p�m>�=�EaYǊ��G��~�Q����K�A�v�Hf깧X�!xӄ�߷1�YuRr��җ�!=h��8�^�}Chv�LX�"�"�Ҹ��L� h��DT�Nq�}D۾��D��v̞+Z?E�A��e�%ϟ�k�4�B�G��#h�mry�WZo&�ք/�7��+4�Z�u���i��6�(��
�1�a,a���Eb��	_�oն	G��U"�5g�p�ߊx�F.��4�u-��"��;|���P�-�|j�'���z� xӄ#ho�*ՙېe~�P��:,!S$�x����x���I->��!8ӄ#�lx~'b"�c̡�`����i#]_�gM�}C k=3�B�π�v��&A�j�J�V*O�O
����5T�V��o�?E��R�@W ^�h���L� 4�5K�>m=�;vh�mb)�D�O�}Cx�������y^Cp�	g�:K���XGDI��M/;QX����y��?=�of�No�y��!xӄ#/M+ �}vn�B��0P.��9�S�����tY�Q1�t��&�AP[�޴E鱦�i��m�u��y��?��6���0�e�8&ڞ�x��&AX^���Mp�¨֙h�����z���}C`�1�NA&�ل�4��4}����*Aڎ��^[R��%Oך�!��Plsh �*)���+�4��ɜ�ʣCE�%|@+���L��\Q���җ��T�[�kk/C���3M8���Z?AgM9f��0r�S��i�zFs�\��%��Ъ���k�1�5g�pa�F�'��y(��&����	G��z�	_�� H��t���<8�^mp��&A@;D������5�-� ����r�2
��k�S��^��+v��#��k�4�v
AR�˗5K2�7�ux̠��&|��!d{5�@��1ǘz��&A/�E+�xV��4��ւ��N�bs<g�S�A�ţ� �%����4����|h�F ɲG���i����kǚ�%����m�P�N�k�4�O;����I��E���ky�ƥ0�o��D ��|�@׮���7M8��m ���w�OƯd�֜����<�O�7��V���K�a�
�/M8���� ��N�s�)>�0�!f�g"���O�7�j����)��5g�p�m�k E3��_�YTۤ��f�l�D�AH/�I%f�}:\A�	G�5��#��X�^m��K9K}�+�8�y�T�}C�/��ؙ�ƪ ��i����@�ܴ`�Gdb���:J,�vǱç�?��mY�%��	=�5o�p�e��|<� 1�^��W ��<�д��qf�S��e���Z{���L� <!�1�L�?�1G�"hyT	ó+�=�	_�o/;d3�E�ʬ{��g�pA��:;��gL�0�����h:�����,��%�̉V �Ԯ!xӄ#�f����)�Ź��ȊDSk3;�c�}C�bw�k�8�l��5g�p�Ɨ�+0�$s�E�e��+C1R�<�c�5�C�!۾����ٟ�<�!xӄ#î@���$�8�/�k�}u�5�L�����җ��OT���K���L�  Ljj]_IE��;,��r��g�:�m�}C@��Q��P���+�4���xRA-�hE�O� �e�+z�,}���Т��\֠�ǝ���i��j��Vhj�4w�в��T�e��Uǚ�%��0l�Z��W��5�!8ӄ#=ؑ�b#ɱ�ء�0XW��ArǷҟ�oَ��sh��,t��&A/����d��:?oꈶ�u� ��f�S�aN;�[`m�➽v��&A�PD�~�:�My��k�G��.�����_�o��&K����7ݓ4� 8ӄ#lY`�L��r�I��Ύ��#������K�!��L̕0p��&A/Ŝ�"�q���<����J-�*hs�	_�o�a�%@T��+�4�g�R9bM�t����vb�:@�´Г��O�7��M�U"!t����7\֤E�v�w(��>Q9�C��㚈o��H�t��3]������EX��y����B;�;P�p
�Ǘ�1�� ��=�'|���0cЩ4.̥�Z����LH/���@	��
ggi�3��|��,�����o��}Ln ��y�	�
�=i��Q�9�zZJ���g�^@����e����e��X5�X���y�	Bӟp�9�ig^dZENTl#���t}*�e��0�7��'�d�b�K�n 8�A��t�(W8{�����ađ�y�m�2�@(z�?�~j��'�5g�`�0�� B;qx:��#�҆n�A�˨#��o������O��{j��y�BY�,U������r�u��-&
sl�xu�4�@h:l�g��\a��/O0BX�RD����b>o/=>)��D�����?t}���V�x��'� T�����$F>b	J8v�9;N��W�}�~ ��	T��폢_Cp�	&�²�H�ɉr] �    ">�Dķ'|�~ d�Db,c����7O0A��Kϖ�Z�.��1��Cuu��XvzR={��"%�;���P틮!8�,�z-��qr~�UN��	�E),3��6:��/�~�h��ՠ�ܧ�M�=�!�\��	��8���&���O�-��4�l���O���� "π�����h����L�>�E�ɅĂ�\͉�nl�Ys�9�v�	_�S^&}�=��s����L2���-��<�	9&]�Ǵ�s���,�����z���`�k�<�a����o#���,2w]İcϴט��>K��� ��IK���k�<��֗�ȧ�1���?��tX��$0�`����/�	�=����z��'� ��~�0!��0�ߛ^��I��UwΝ�gO�0�@x�O�@5��F����L^�b����/w��|��<}8�`�:|�~ ,}Mx��3�!T{����LjҟC~��F�z���\���Y9`XO�[�:|�~ ���N$�U���!8��)z�]�s�������l:�.�-A���e��άu����G�>+^C��	&��&�0�a���xn��o�.�#��;P��/�42f.�`¸���L���'��mM�#MhK�b�g�r�:[q\��i������)0������7O0A��T���\qO��M��t���/���{��2"�����g�`��I�;�UGڢ�{G]�r��  �]�>M?��u^ �;&����l�>��;���Z��"�M	G��ԝ�����/�F���!����fc����L^n�TI�w��X�<���Z) 7���{������:� O��Q��3O0A�/7_�&D��k��9����=#IB��;|�~ ��|�S��*��7O0Ax���Ӓ�t�ʓt�����l0]�6�~ L�տa�����5g�`��P��1�0g�wM8��f�FI=�6=�_��_�������v��'� L�b�v��S�@��/T��,�����?^f�	�W+�����L�.�8�X�F�fIp�NX�S�b�1~�~ ���ҿIq'���3O�@x���>K����Ɩ�?O��"%pV��y�����}y� +Ρ����L�>|Y�y�Z�����{��A�=�*�e��	��C��N��us�y��\A��	6�>��w
U'�ySQ��N�<w��4�@Ȣ<!�f�m̯ 8���>��dm�ϛ�j��D��tp���i�� o�g�+� ��y��3�s���,���: ����,��|;F��k��U�b����z��'� �C��[X�*�~�4�A[,����y���� ����H#!��1�u��'� ԗk�;�̩쏂�	��#���L�6��͗O��G��ג����\Ap�	&�R�"���H��MK�����Zc����I����0���o�`����Q�a�7%��^�l�	F�\��i���^d�U�k����y�	B~�T����L��s��V��#��3-�q���̭NCZ���y�	��O ĕv�1�y�d�.�b�Tr���i����܁%��9[�v��'� ��*�!������M�,�`0�fJ,���}�~ ��Yj yd�����<��H'P�'���rPR}�@��߱'|�~ }j[(��l�7�k�<���җ"$Aܑ$�x�f�	'�=qډ�gO�0�@(�e�.�k@����LFy)��#��rQ��6���A�Q1�P�c���"?M?����g���3%�
�3O0AhYK����K�����d�BX09��i��В�fH�i���k�<�A�N�#�m�-i"����͞;n}���С�oh�*�)���y�	B}�<)OȼɅ'��y�:LsG��J����e��0tD���N�q��'� 쿪�5/c�2�tƬ�.��X���R���!�N�R��mҸ���L�m��0�����y�o�1?��wT:<�'|�~ ,=c9��ƅ�}�+�<�a��҂'�b�)O�C�=�g&��×�B��L%\�"Y�Cp�	6K7����)���u�[���y�%{���&蚞�����UY|��'� T]��,���u��u ~����6�~ ��R�0Tn{�M!^Cp�	&+�*��"��bι�����K{����e����7�e=�du��ɳ'� �̐�2Vi;�<�/��c*��Xr�=yք/���w��ˣ�������L$��C�*���:	�D=��<`y��L?H��$�����!8���g�<�Ew���s�#G��@������g�_�?(}��#�V����7O0A(�pZĽ:���($�Z�"5)D�qO�O����@�J-<��k�<�!��0̐�l��MS�ք%��#aw���i����c�-��b��J�o�`�������5����y�U
0��� 9���e��0���ŝ\N�}�5g�`� ��\L�����8g�Q� �y�Z�{�Y�4�@xiOZ�����)�����l�ƌ��ϡS�r��uEd��
-�٢�N��� `�5K@����#�k�<������vU`�9{��/�aWhH�����O���ҭ���j`�8�C� 8��@��1e}�1����j9��sn�W�/�Է� i�[��lo��	&M�	�xB�s��K�{�qH$�ܷ���a�i<-�{|n�]Ap�	&���DL��'��A��;��8г'|�~ ]����ؽ<��W�y��(�W�����������v�'�,��Y����{�u�Yg��,����,J��h�`ꑁOĸ_��m�bIϐUǞ�e����n�6*�S����y���9P"��J��+Me��:I������<{�?z�<�p�I��y�	B�/YdTh�J�4�)RW�ܻ�.|��SO۝�z�Eq�Cp�	&uC^�3���P��H�����'|�~ �K�-�!�nԿ��<�a*��RZ��J:�C/�5���}���q����?t��6�c/���y�	B�	ϐ�:���~��Ԋ��@H�̝l��9N�2�@���BJ��ė�>��<����51�q:��D��ܨ��ߓgO�0�@�/q(=a*�7�y�	�з�V(u�HKd���1�1L���:��/���l;��V��� �+�<������5��`��he��6
��À���=����N6�:��je�k�<�a�-�,��^F��O��|Tdg�y>i���O���!q��;�����L���!�g���o/7'��#Sl��/���� 4�{�<�"� 8��	��Z��\�L��M���ڠ�s��B�/���3����o x��3_2��W���\i�U��S�}�9��8���a��:CVikB�:�!8�������%�2�����KǦ9�S⑋��/���{�L5��m���y��z�&����E�l�,��v�@YrC�<W�����Ԓ��m����7O0A��+����M��^�4tXI� �ӭ���O�֥��7�� �/7�y�B�S�n����Ä�	���HF^Ot��{�}�~ $6陑1�̆����L��F�τ�8��ۿϡz+v�s�qt��	��SO��᥯~ڎ]A��	6����vn��kK��)�,�j��cO�2�@(zڮ`��$a�5g�`�0��Pe�\��>�7���<$x�O�⸓Ƨ�?����?��S�F��y�	B�Ŏ(#H���/l���eRD���	��~���MO�M8!��kb����l^*U=����	/���{q�\��i�"�L�Yi�g�|��'� 4���I��'�=��+�B'���s�=���a�ٝk�^�� ��y�	B��R�1eb��M�����W�o���]���!�c���|ql�a^C��	&S�6W�y?2F�GR�꒞4l[�t|�i�B��ܡ�3h]��gr�g�`��R���5X����    J��_n��e���sw�O���ێ	1��E����<��@xiT[�H ���Y�B�����̝\{�B�K$0�*���|��'� �����(H��J`-��|{ɐ�퉘=G�_�KO�j4��y�Y]Cp�	&��]�ȅ�<��O��J�:�>�3Y2{�Y�4�@�oͦ�X�?õ� 8���?������_��J�O0*��I����O�*�	[Pa���ƙ�!x�����3a�x�Ƚ�*w�\I-��q}§���*�*��K��n 8���r�e"�r'	�0Vч�`ry�z�+�i����I�c��,�z��'� L�w��
���gJ`m/������{��q��?=��mF�ܘ8�k�<���݋L�z���D���$�g�Ϧ�_O�2�@x)҈�t�_s��{��'� p�Ŝ���ա��rsb22��m��	�/EB;��1�%]C��	_V+��=�)Z�$J�?�C�?�J����`���'@~���?(�o�rz� ���,-�?$XØ��?^a1���ǹ����T���"]C0x�?<�>8(�������������>�}*�����}��By��<C�����cM;T`�)�Ch� <C��C�8�����������5�5۱0~���PSS��9Ͻ�4(��!8F�V��i��¼��KmV�!J]<�����/a4Ah�ju��
����C�%�63)M�LXc��L���ƢHe�q��������?=.�	ԟ���%�5g�h�PDyB�XK��%<�!�F���t ��)�{������.{�K8��`qnB�|	��oS�?��d���M�XI,�?������F��?#h	�3L�k΄�!u%�O�	ځla���KmZR�QN+>�p�C�%�6s)a��A�,�^�	�	�,SiB�%�fL��ߛfn�!���
4�x��L?X�'D|z���_�p��0� �JDf+)�l{�ca�AhEm�.��d�4��=_�h��P	b�/J;����	���AHo��Q����ф����{H�JҡE�-��oB�2�@z{-qݟɬO��k΄�Ata��/ ���_�h�@Zy��e����/a�AAy��� �����LMb�*N�8S�:���� �?������kZ��*�E��<��!>�����Km hMxf�9�r��;���!��f�����!�F#�.z�ܑ∩���=W�h������(���ߛ�3�Tۿ�Z������×��j_ ��3a�AU�'���w:��+���KMR��z-�x�j)<�!�F��/�1��t���/a�AXI=��H��tOg�L=�o&I��Q��N��oB�2�!cV�R�96�
��s���LmH�	�}���C�%�6c����S���p�Y�!�F��W���D n+��!�F��s@������EJ�����e������M_�� [ϧ1�H;;��LmjUul'v5�C�%�6�C�2���0�ɱ0� ԨO���ܲ0��{Mp&�6=�c�gj����m�Zބ#��[@�v{�	���a��ZD�p�4K���LM&�!o_H��<z��0� T}�e<�*Cn�|	�¬*�.�������|	�	B�7�e�¨��^�P��Hm�)�s��e���u�T�0+��?W�	���`��x�c���v��0� 0N%�;l�P�I���Km*�T��1�j��/a4AA?4��U�~�oS���<Y��T����S�/�����$�r���	�Bg��u�Rc��ɱ0� ���YY9�d����LM�KE�9\�4��|	����4>c��%��-��_�Q��2�B��?M�AX��J�8<�alor,�6�CL��ILϥ�;����/�	ic\����C�%�6�!t�����/a4A�%|Oӱ4���΁���w^(>x�ca�2�@:Xb��TK���Lf��%2r�1�r�	΄��D�	Ba��낙�!�F��O�'c��K��|	�	B��R��+!^O�0���/a��uD��1~�~ Ԣ{�Q���N&S���J�fP	�����{�����/ ��>�@��{���
�4�'%"�K��<	���:�g^\
��"��&��Ө�������V�R�%�~��0� T]ǘ$��JK���/a�AxiO*�]�q�_�h��@_�yf��Ư�%_�h���Yd�z���8c*�+>���!�=G�_�k����zV
��|��0� <#uL=2��B�=_�h�@K�����ڭ{����_!��f��V�?|������w���i��NYb9�LC�L���̗�&�/��F�@��!! �k΄�a�t��:Q�Db��|	�	!�����VR���=_�h�@��o���=3T��/a�A�:ʊ +�_EC���H^�e�!���|���P�.׉�g�k?���t��0� 4ziT;v�G�e�C�%�6K�w�U��s�|	�	BK:�j�����!�F���DU�,�G:qBk:)�\{Ϲ_ρ�oB�2��G�����n��5g�h���zh?R��oY��g�h��I}3�<�\��P�|	�����v�9K�O�%�&;6�Wi����Ӽz?��ZB�Hϑ2F�����aėc��F�,1�~��0� ��u'.=����+���!�9I��氳H�]����Km�.��G��J�p��0� ̨+Ux�@���c�7���d��sͧ��ca�2�@؟�Z���jm�5g�h���r�N��S��=_�h� ��V��E!�=_�h����8�e��X���Lm��"I�փ\��oZ-��(����4���e��D�˽��;�"���΄�!�HU�V�U�߹�_�h���l�D��>��0^A�%�6�'�,;��!��T�
�/a�@��t��B'�A���~�n� 0B��~�~�~ �.��h<`�y��0� lW��p�CZ[���J��>�+����đ�!�F#��g�Ė2֙J���Jm �h�O9'���a���(����ի8N�?M?���BNa���	�gA��T�lor,�&߂�œ`fL���3a�A(�fH�\�\M�����Km�>|i;}L=�����O�&B��+6ܱ�_a�2�!��'��/�y�E^Ap&�6��u�x.����t��0� ����v��25Z���/a4A��06�E��:��s�%�6��Pɭ���l'w�Y��t;ÊT*�mT�m��0�bk*ؤ!�\Cp&�&��� ���
�h��/a�A =�И�H$��������g,Z)����/a4A��k�(�tN0N�@/m�vr�u�F��o��o���[wl�D��~}�� 8F��օ/���Z��/a4A��;xa˂4F���KmJ�5K\v�аJ��|	��*ju ���ٗ���2�i��	lQ!�ð�M�Ah �!��<�M�=g�h��rM���QB�x��0� ��o����c�[�!�F��Z"��τ�i{�ca�Ah/-xd�*!�H�s�Y�D��s,X��R�X�L?^R���,��n�k΄��AC`,!�f��/a�A �=L�Qđk���Km�.܊��Y�9�=_�h�0�n0@� ق�{������Sډ9:�/���Y�����3��2W�	�B�Dv�]HK�!�F��7Z3�:�3f��/a�A��:��H��H���KM]�(��pi��O����
�2C/ͳ0~�~ ]�6��N4���n 8F	��^G�0q�ә��/a�A�E�͑C�D��{�����m�v����>_�h� �Q��Oh[#����,}�|0�?�3��Y�L?�ލ��0�ѥ��J�@p&�6/qB�m��W��/a4A�A���p���mor,�6I^R�b��vF}��0� ݴy��t���	b{ْƐW�Y�p\��i��~Jߕ�k������K��ޒ�O����J�:�|    [CY�N�;���A�˦
�I�ń��+a�A���^���3�Q�|�1t��;#ϱJX��1~�~ ��.|���~�� 8F���Jl#=�dC��g�h���D0 N��f�C�%�6]�{���Z�߼�K���!��Ԉ+V���ߛ����K.��w��4�@xI�wl�)s�6�5g�h��zTz
܉�=_�h�P^J��
+/l�|	�B֛*�����賯{���a��Mz��B�6��P���H�CM�|�4��@�6gTZjY��3a�A �b( HZ���*�C�%�6<�0�$�a�fSw|	�	BU�O�J�oU(��C�%�6u*���֖�v�@�M��
(�q������-}�(�����!8F��$)O ����7��/a�A�1��&�fͧu�_�h��Y�Y�2�!%��ɱ0� t*b|�M�Y�܆�&S�*GN�8C��h�O�j/KHz��.l{�ca�AB�	F��x����KM8�Z*�
3����C�%�6Y�|Y;��)U��o�_�h�0Y��<f��c�����*wY\�>F���?tKߧ�P/�����3a�A(:�;��cc��g�h��Yi��B`��	W|	�	�3TY��O�5�R�!�F��z&�}�,1�����m�D�C	2�pܨ���a�y�QҨ���O��+΄�aE]������{�������ɿɚ�v����a�s���*�;��������pN;l<����ʌ���������B��vB�?���y��0� L�	�V�KŖ��_�h��^j���{�1�=_�h�@:l�x��P��g�h� :b�L��> �[���� �)G]踎�����:b|�!i�d�s���K�*�F��:ϝU�ә��+a4Bx�&�)�8
I��+a�A��!�����+a4Bh��𥄺�6�/XB(��c�ֽs�-��?M?�K�'aI}�����3a4A@�[�Yʘ�S��y��0� ���70�r�� ��0� ���nQ�YEX��/a4AHI��,���.����)�r�̥�@�;��i�������(�G���	����	�+<���O�;���!��/"=�T��9����KmHå�`���H|��0� �>�a�=����?a�C��j[<c����q����?%����u���i���Lm��O �{
꺇�Km��0dĔ��|:s�A�%�&��\�+�:��w|	�B[�,��q���c��QI2[(�E���e������J<���w&]�!8F��z?!3�O���F�_�h�@��T�)#om�|	���7C�b�z�k�{Mp&�&-�b�)��T
�3f��1N���sř�1~�~ ��J�X���t�79F����A�s�+�y�	΄��C��i��̧f��/a�A ��R��3i��C�%�6K�^[X�(#f��M�u3&@~�!wJ�ϕ�4����IP�(��	��˩tBi�g[��,�
�/a�AX�V�D�L<�1��'\A�%�&���b�RJ��;\A�%�6\^v�,#R8K��R�;��ҡ:��i�� Kk�PKG��\Cp&�&3�
��YB�9�x��0� 4}C��R�:Oۛ��ԗC�k~�S9�� �F��uX�X���3�갠���;����zϩ���Bם+3�"k���!8Fї>ڎvR��=_�h� 8u1��9-��;���Xm��YZ�#mu�9T���K-R�!����	�<�(3)���8� 8�s��B����^S���W�	�B�� �*U��>�
�/a�AXz���jo�{�W|	�	B�AO�A���6��s�%�6S7�|�E�4B_��	)6=@�tR�x>��4��?z��}�'�x��0!��2�|�Rc�#�{����/}�B;�SB���+a�A���u��>��O��;������aP�"���l¤����c�@�����atM�A�N�k΄�!��'T�5v:]��/a�AȺ�9ш,��q
�� �F���3���f���?@�%�&y�,�Y	�.����.���?`gZ��������R�Rg��@�X�!8F��Z� �6�S��/a4A(�����K���0�;����H�	��Q��3���/a�AT5�1�Oc*/s�w�c�*�#�/��nc.��j$�k΄��f�: 1/���v��0� 1��s����XM*%�L0�����<��0� l����Ev���g)���ٱC��!9��i���t)|��$�6��� 8F���[��
�0F/t��0� �|��1j���?@�%�6#��;��D��r��0� ��kz���y��ݧ�K�͒�S[���e���u�H�ư(��Lm����)�J�?�{Op&�&�t�`����1�!�F���f���@�����/a4AQ�@M�+���P�#5��6*9��������!����SH^���3a�A�z�0U�6��wu��0� ̠������*�)�w|	�B���~�<�?x�/a�A��T�=�6Ϳ�?i6=^� ��J�Ş��L�AXQ7���c��.�v��0� �RB[i�X��/a�A`�IcI�5���/a�Aݙ�x������KM�&��2��յ�8�(I�X�4Hf�������Co�.���]���~�g�h��C�c�26��>t���/a�A(���`�O+�B� �F��ۉ �9�����/a4A�����}δj;w��ӎ�?�2(�0v���J�����¦��h�5_�h� Q7���g��9v���J���2��<]���+a4B�/õ�B�P���!�F��>���[����{���]0L�gdǇ/����SV,p�'\Ap&�6�Ҕ�w��r�\�=_�h����#=m|{�v��0� =�`#���B��/a�AXz�Ӭ+�x*Zs��r��)��{���� <����G-a��i]Cp&�6UG�k�	�x��� �F��T��X)�����+����ė^��S�F�{�����Օ�t����̥�V}Lk��rw܏���a���Z���4�k΄��P�kҤ���]�;������,}e�Xf��ɱ0� }�8q���|	�	B͠<!r����5�^G)u"n؆ga�2�@h���p�#n_����	���	p��=Vq�C�%�&5���q�f|�ca�A �I���!v��g�h� zu(R�3�c�3 /�AJ8*g�k{�v,�_�� ��k������d���Lm�n;&X
��%��Xm&�4^�{u��۹��KMP	�ļ�b �9�!�F���2O�%���@`�a%�<;���
���e����nsÕ*���3a4A�tC{"�y��ý'8F��!�~�Łi�ɡw|	��|�厌S��H� �F�����ibN�̚�t�����{+{N��L?��OhX�`i]Cp&�6KC�g��ԋ���KMꦔ	��/��ɱ0� �.�M<$p�4���+���A��h�v&NU��h]C�ZTW���u,�_�� HҭÀt�߂k΄���l����Id���/a�Ax�-6egؐ�'��|	�B�oQa3�B���|�^�	�B׍e&W(RK'w(�H�)�~����W?M?u�$,I��\�5_�h��zM��9B++�Cp%�F/�t!�NO��;���a�ވπ�0��!�FH��F��<�t��;\ƄS�t}��i���t��#�c9m̯ 8F��Si�ɹ��C�u��0�  �`�#� ����_�h�@:�JR��4���z��0� ��}�;��J�|�_�q
��9Ͱ����e�BJ�u@���\J���	�B�͘��փY�ұ�!�F��+92ƕ�3O��/a4AȨ�4p�e�=.9�� �F�qB��@8���	�F]�� c'�,ϩ������戣�R�?�pW�	�	�����#�L��&��h��t�F�U�y�����/a�A�7    C8b�4��z��0� %�l
NXR�sn5�ZbRγn��,�_�C�w���K����	�	B��5w�n�{���!�`)��^3T�� ��0� t�jv*Vڱs��|	�	B���d�<F�߁l���֓�:�j���u>M?��
8T�9���q��0� �>�����e��{����=ߡq�L���<��0� �Y�I2Qo�|	�	ݏ��R ���	�{ק�"��#,q,�_�Y_�L��T�gȼ��Lm�v��)��0�|	�	zHBn�?q�|	�Bn��<���Q���!�F��2\�F)9!��k'RF�-x� ͆�ku\��i��=�`�h�v��]Cp&�6U�l8k�-��x��0� L]� µ'D��I��/a4AXQߕ.��� ��/a�Ahz`Uf��/XZ�*�ݙz�,T�^�~����a�@�s�2J���!8FA} *��Z�;����Km�K�H[�3M��/a�Aة��(�i��/��K-(��r�@�!k��(�4w&[9�Ȑ�W?M?�&�!R!�gh�_�h���0�Fk�Y�b����!��r'�8 Ji�\	���yFL9ֳ�r��0� ��Xiɪ\��_�@q�[���5&�Ku,�_�I�փ(պ���g�
�3a�Ah�>@�y����=_�h���m�H;x��
�q��0� �R�Yǜ0�:mor,�6=��^�[I���~��C�/J����17��4�@���@�p��j��3a4AH�^J��p0����/a�Ah��@�a3r̳�?x�/a4Aȡ*��x�RJ��|	�B�3_PB-����߅q��z�W�҉�1~�~ ̨'��5�V��]Cp&�&��T���Ϳ�pw|	�Ba'H��m5���_�h������xn�s�����0� �K�b�����ܫ>�C=o0cn;�j��T�����O
5���]Cp&�6��A��F"�n�=_�h�P#���%��78u�w|	��N���)����/a�A����| 2泳T��7��ӖPj�������;WR��r�
��3a�A��W� "�X�!�F�/�R��n�|��0� t`}C� �Tcg��_�h���~B��3��w;�ᨓ���D�5��ޟ��#Ƹc����q*Z� 8FN��u�b���R�!�F��/��@)Ime�{���a�yE��`�s��O���KMF�=U"��S��;�֣q��?5Ў������F��J��e�z��0� ���wz"�,� �F��t�
OX4�q��0� T]Ǹ��Jµ����KMV����y/��siw��z��t,�_���ڍ� ��Z�a{�ca�A������z��0� ��H%�Ts�K�0^A�%�&�ֲ�
��8�=_�h���%w�Z�Y�9w��2.��W��Y�L ��l8�<��W�q��0� d]�����a�3C��/a�AhK�@���_I�|	���m�"�Lk�V�"� �F�X�^��4h��0ֈ:�D�}��Q������0s�L��g�
�/a4B}9��XW����!�FHz������\	�B���P�\�=W�h��Qg�������N1o��Ϸ�C�4g\�q��B�[��j�3]Cp&�6=�"�6r�gS��/a�AXK�1�XRJ}ʺ�!�F����2?|!ș�p��0� pRaeǶrnq�B"��4��p#e��9b�2�!!H�ǘ�_�p��0� $]�"{�0�%ۛ�B��I+�ޟ��P�=_�h��t>�P�@a���/a4A(]�Oe���(q�)���e:�3�}1`�฻Χ��ˁ��l��5g�h�@I7�I�k\c���/a�AhU�	k.�;Ψ�|	��ҭ��~��죟��w|	�	B-z,��H�[���'T���H��^��8�/���ImP�p�4N�+΄�a��@V�0���4����KMZ�z,��p���r���Km�˹3��m&�~��0� ��o�4����#��9��I����X}
:���i����͗�L�(<�q��0� t}�e!&l!�tw|	���ӄagO�νF�x��0� �tYw��?g���!�F�ƅ;�܉�s*��m��\+�NA<G�_�� ��'�'�$��$P�!8F��r(s��s�L���Lm�n"p��{�K�� �F��2��b��2�������0� Tݼ���hcb>f�W�%a�c/%��~�~ Q�R��V������XMV�������4��/a�A(:ln�0EIk���KmXC�L#��4t�{���A@�"ܱBN��ۼDw�\��Ԙ<��|�~ �K+B.�?�!�k΄�a���%��5�v��0Z �����P��ȼ��Km�r��SKv�<�!�F��[T���V�,I�u�7��4�!�s�ʹ���0^A�%�F��@v�s	��=W�h��z�n����M`�Cp%�6�0�N09��U� �F#��kz
cZ#̧�X��A�IfM�9Vύj?M?�.Ҙ�Sa+E�!8F��rj�+�yn��A�%�6E_��Òc���|	��d�W�RRY�|	�	BB=+"� +n'bLA_�;�������B-�T�D���u��0� =)�8���\#��g�h���nh_(���O��_�h�@��X�g[e��C�%�6�R��´���O��YoD
���9b�2��$,U
Tӳ!qz�_Ap&�6UKE
`�=_�h�0�K��,9���=_�h�@�z�23�&}@��|	�BӗCEFi�E�;KT��8��B@�}?�X�L?�n�1d!�Tb��h���LM�����&�z�1�mor,�6U���F�c��y��0� ]�D�Wn����׮ �F��t���I�\C8�Z�Iw��-�K��q��O����"����!8F���1N�ʉ�C��_�h��A�c,\c�6jl��/a�A��"ƌy�ʥϑ�!�Fѳ�k����{Sg��9�"m&)�S�/�8�F����"�5g�h�P�Ɓ��CH�!�F��o���C�=����LMD,e��h��{������"V����TE�D��	{χ/_�+��A�*-�\�N�o 8F�	��/S�C�9�?@�%�6$J��GƘK���Km�.� \U�ȩ��[w|	�	�zI�WIIB����u/�,u�z�/����I��`9�k΄�a���8���T�
�/a4Aз�;�����M������kQ�3I����L-zz�,r`��G�@=5>�!I�p'��q۱O���/}$�����k΄���h��4¬5KW|	���m��>qa���|	�	BD݅�p�XK��Y� �Fn�c)��3R�ǚu_cB
+�g?ү0~����_�6s���*��/a4B��R�;�>L��3��+a4B�/���w.�V���J����θ!�*ɽ&�F��e����a�_��u���o�$���0~����PϕFyW���!{��0� ���"��A��!�F��^��6�@RK�|	�	B=�p�skp��0� �nO����s��w �3�ؓ�1}�T�bp,�_�� ��7Z��9Kx.��5g�h�P��08?E�m¹�r��0� pUa3�Ow���\�|	�	�$P����~�	΄���=�N�轧�qk�z��Tđ35�M$>M?�>��p�XkJ���LM�?�܅b൞<2�C�%�6E̓��)03V���Km����m�����
�/a4A؋��C��	�ق�7Dq��TBt<W��������a�9��΄�A@�6S��I�Jm�C�%�&Y_�Pa��?g�h�P���a�K�iEx��0� ����T��T�pB<�QE��%�\��B���|
�W���LmZӚ�=G(ag�x��0� ,}%p	�(�:W� �F���H�P@��t��0� p|    9|ia��6��Eҕ���7Gn�g�|����_��)nF c
�y��0� dx���%���Km���!�?%yjr���Kmv4�����E�\��M���a��l`҂�����9�N�q������e��kNDR�L����LM��J5֘QH�!�F���$	'Z#J�!�F��#�N�q��lor,����R�E}�N�|��vYz�t� 	�#vϩ���B��sC�JN��+΄��uc�'z��r��|	�	Bz_^�Z��I`�|��0� d},R�-�����Xm�n6ՙg��R��	Ǧ��V�&}	�帻Χ�?u'�Υ�F��/a4B(���N0�
t�Y�!�F#��;i$a)�}:5Kw\	�Ƥ>�E;^���:�Ap%�FM�@%�%��jh��5Ƣ+9�3P���|�~ ��o���
u�v�]Ap&�&	��Z|�`ŭ��|	��V}�c�)��!�C�%�6C��#����*�̚���KMr��H��ք�$��ySS7m���8�$���e��P�z��i�VV�?a���Lm��1�I�(��w|	�	Bݪ�鸓zI�O��;����,�}�FM��|	�����HīI�q��
kR��j�9Eq|��i����#��{Xu �k΄����H�[�-W�{���aL]��c�.��=_�h�P��&�e��W���'�F��[����Ӝ��T�ݴQPJ�֔Y��|�~ ,��Pw��N����3a4AhHJ-N1��O{�;�����Y�e�T��L��/a�AS�M|�̧�Q�C�%�&���9�X��)>c��rᐁ���ؖ�����G��0�3;���3a�AX�6Us�l]��/a4A`��OS�e����/a�A }/r�mrj���`w|	�	�Hzu蘧P,[XO�8bS�:ƘZN�������"�ť�0���!8F�^�;�Z)T�y�_�h�0Q�,MS��	�=_�h�@�eq���!U��T���KmDO[[Fc��;̗h��!P��S�/�V*/qB��v���_Cp&�6U��$�����/l���Kmv��7UF˽�<(�C�%�&�2�(v�1B�39��/a�A`Vv��ǒC<�X^
���n�8��ޟ�?�J��M/�m6|z��Bp&�6��[/��⢹C�{��������<r_Oؼ�!�F�����(��F����!]�<�
�DO����=��e��=�X�:.��4�@`ԝ4(4B�KNY�_�h� A�Y��Ӳ3��\	�BZ����8�J������c��j������+a�A����D�i���A�۪���0�O����N�_B	�Z���LmzW�C��)/�q:x�A�%�6��� �<FoK�_�h��P��4k�\P��C�%�6,J=�'��r�m��T�Fd��;��<�r,�_�� �;x��mor,�6/3_"�����!�F���/CV�c���KMJ`!�ȫ��*�C�%�6u� ���"{ɿV��d�/�ӫ�~}������6H���F��k΄��@�:Z�j��"��/a�A���p�ޠ���/a�A�N1+$\��_�h�P����4ߡ�ϡF]���r��������Η�f�؀�!8F�Y^Z�Af���/a4AhQ���if���	�����,rKKr]-�	�w|	����:�\�a�u���a�yJ��X�L�Aؿ�r��䵸��W�	�B�}�ƸS
����Lm�.qk�p��qJ�� �F�/C.p�S�B��/a�A�K�ࡁi2���g���<l��Dѱ0~�~ ,Mj��!�h����3a4A�҅3�[��|	��K��@,<v����sp&�6�e�	�6K� �F�'M��a�T�p>��K;
�� +Ǎj?M?jWqI���Q>C3� 8F��IH]r�����{���a�� TN�
��R�=_�h�@��8��A!�`��!�F��ǧ.�c=ç���z��,��f�Q�ca�2�aGD/�-O��9�k΄����kL��lk5���Km�n@�s�0C-�?x�/a�@�o�-���$J3�3��/a�AxI�3�a$�S�9�K�)F�0�￭/a�4�@��@6ra�f��|	��&�[�s�p��0!�n�4j����W�h��du� ���W���&��h� I�6?���	�nM�� ��%��̝A��(�@ǽ@�`9H��/���נK>�"F�����p����kB�ɱ��~ t}�e�����rj����aJ��4�\�[���/1� @ҥ�v|5��/��x|���Zs�U��/1� ����02���i�~K_��_�Av,Ư�� �\t����i	��5gb�Ah�K me�	c���K�6���xʎ�{��h�P����?"��,�v'�b�A��B�PZc�*�I(U����ӞY�A��?�~ ��D>�pb��:�5gb4A�Y�T����b���C�%F�&zCƎ�q�2��/1� ̮�u�E(�^_b4A��+s�s��v�} `�*�L�e�[�k�_C?����(�gY�!8��KS�D�S̳����
�/1� 4��H$�t.�|����
�3P"x�9� ��	B��x� ��C����^�;78r���5����[SJ��~��m(�o☟�h� ��m�^^�:3��*�v��MF��"��{J��=_b�A��A���X��lK��	
��g����5������4��	꯰�gb�A�I_�OK`Zk�C�%F����=[M`���!����t`��c��p�_b4A`��:�)�iG��u`x;K��G��qk�ϡ��; �X%�ʧ��gb4A�A�J��_�)O9�~��m�.��Tk���),�|����V�AZ�s��{��h���N�Ȱz��S��\zZYp�Rю���k�B�/)|�C2�T��L�6�!0��-����=_b4A��}D�9%�9�|��m^�Wr��CZ�o��
�/1Z ��R�9K��V�+�'AX7�0e���k�Bijڼ'�1qMA2^Cp&F��K4#�0K���/1� ,R��������!��	B��_�n3�!�Np&F�/�cVI+sb�E�+�|0����ԯ?������c�RQp�S?�
�/1!d}�	����_3�;��h��_��%΀kt8}�� ���ҙ*�p�J���r��m��t��+`���҂��.J��đ�1~�@�;�X���xʉ\Ap&F����D��\��|���K�&95�`*3�@kq������p��o?���x|��������e��4f��Yy�ÓD,a�k�ֱ��~ ���C���B���L�6#ꦒs)[
tV�� ���z���1�Vb���K�&t�	(�CH�+"q��mH	�@�6̍OU�U��V�=���R̡z������/�t��e!��p��m^B�Թp���=_b�A��T(�Q|V�� ���K(�Xk!s:	�w|���}�B��R� �IhI� �<�T]��_C?^B�$[=(��31� ���kʥ����_b4A��;�`�Z�s���K�6]�m��2Ʊ�M۝��aĦ��,c��B;����K��~P�
�{n��9��F5cD̉b߳�خ!8����L�9����j�_b�A��R ��Cr���!��	�tD	�H-�C�%F���ײ��f��	D:�����=�����t%�.�	S�|��mP��g�i�0��E�W|��aSP� Ը�Q�_b4A�Q's&$^)�X��C�%F���� u�,W\�������RsOL� -d����5�af%�8�c@�;9�	�JB�P�B�d��A�%F��ˉ��2V�Q�!����hE�q?�����A��ԼdȫI��PZBы�����yw��k�B��k�i�T�w�k��h������Vg��|��AB��I��p�    �'T�!��B�/	�#=�̀��!��	BL/ͧ��*����� zZ���5EGq�W�s���@��>b��|���%�����$Z��+1� ��(�PiQ
���J�FE�c\[L���Wb4BXQ����X���ϝ�����Z4�E��~��Ps��z�WЩ�r��mP��s���G�T뽃�K�6�w�Dz� ����|��!���	r��4����/1� �D����{���I.zsbb���T������S�E&�1�J���}��MJ�ɜh����Y���K�6�����29��=_b�A�� ������I�%F�
��4`Z�!���	E�Q�����Y�_C?��,�tr���!8��K'��E@è��/1� `�E$�a��W���/1� T]DaJ,�ڬ� ��mV��up�dI}��ƈ�u�i��c���������@'n��Ay����5gb�A@]�) �*�*|w|����iZ!
�|��Mz���H�����!��Bc��ٍȋc�'��E/:����<��b���0u-wD��r��5gb4AI/�$�I�R[r��m��+[�s���/1� �ޕ&Y0BZ]N2�_b4A ��;e
T8��K(���@I5,�g�_C?^v�'d̹d������u��N�����{��h��A������+�C�%F��S����B�=�-�_A�%F��P�#�(��ZO�yaҋ�*#���su�ϡ� L�zN@*̚�)Ex��mP��>�Q�Av��ɱm��i�}�h����K�&��9F���:b��|��a�ՃF�3H:󄅺'J� �E��ޕ��� ���'��:g&�k��h� EW�Ϧ.����/1� ]:�`ڳ	J�����L�6�+\/�+�Q[��1^A�%F���
���2��/��5$hWF�G��~ �.�K3w)�w���J�F1��iHu�Q��X�!x�B�5ZV����<��'1Z!� �HNY���?<	��h��"�T�_�32�t�����b.m��[gb���Pu��9V�p�k��h�@:qk!�Uc]e�{��h� ���i3���y��M���A�I���_b�Ax�m�D+�
s�2Z�sDm$h�[Gq,Ư�� �!4�k����5gb�A��d1Qj-�Ҝ�|���t����9B�q�=_b4A(��P˰�@��C�%F��bS[�D��ס��r��aͰ�[D�{��>��� 8�WI��31� ԷbS�F���"���K�6������I3��3mwr,FJ/3����߀��/1� `�{�QB�\�/8�C���=��C�L���5�5)Ɓ��X��5gb�A�w�d�\s�=_b4A�7��"q�0v,=��{��h�Pt���+�{��h���%�{���a�3Yj]��U����N �X�_C�A�/�t�Ԝ:�m�{��h��S}:��$k�W|���_:kJ�c��7Y���K�&#V=YBICd�r��mzRe����@�/�E��!�ʳ�=����{��:��������31� P�u�J*��ȶ;9��CK�Z�o��
�/1� �ށJX`Ϧ����!��	]�qPo�ʄ2��N��V��a�4ȳ��~ ��@��bÒk��h� I�'P�O�Jݟ�{��h�0A��m�ro+���/1� 4}B6S������/1� ��A]O��p�k���9u�[�T{
�왆c1~�@(/�f���{���31� t�݅�C:��0r\�|��a�ĭ!u��B^��C�%Fy��EP$DI��?<	��h�@�t@��f�Udڿ;Iʞ$	�g�����=�At�N!�3��@��'�@p&F�JSOB�
>���!���H�"�F�溇�K�&1���b��B�c�C�%F�1p�<W����}�Z��!���J��͗ϡ�CiAe�Sw,]C�%F��u(�$6�}��O�/1!t����BKs�X�����J�F��bIcHǶ_�{��h��'D���<�(���Hz{`�K��������0t�ak5�2�$x_Ap&F�]��9 �6�!��	B�%�z������L�6�����)*g����I�%F��js}m��8�<u-p�R
D������P��Þ,���&`���L�6}�W@ʑ�Q�=_b�AXzQ�D�f�����M*��O�u,e>¸��K�6�t�V�Q�@��[T��YT��th�oٱ���o;�l\�k��h��Yw	l m���T���K�6��o���R�g�v'�b�AXQg��J�ı�v��MZ�E;2e|�i���Gli�.fh[���|�@zѡQ[�JNr6_� 8��K(�$���,�;��h��_B� ��lC0�{��h�Ъ�DH����?@�%F��rB���������'���D14����������'���������a���f�{�<Z��Ip&F�5Z'̴���C�%F]}w��0-�A�|����EM��5�h�8��K�o�ޔ\K��X�_C�A��;���y&���L�6E���4����+��h�0^���j[H#�C�%F���4�4aQ�vj��A�%F�Y��A0�����y�'5���;�}�@=���~ P~�!K��
�gb�A��r��Z5�q�'�A�%F��u��DP���/O�/1� t�%�c�O��I#�C�%F�:{m?	��\s��1��E�1!����X�_C?^��,ja��y��N��h�0�qY5�Q���_b�A]��)"���%L��/1Z ��J�	�� ��!���S�]��>.�0~wJ����Bx���6��+�ϡ/u�%J�p�R�!��B�� �u ȳ�g���+1!t}��Yv�����x���������1$���=Wb�AH/-��6��)��'���zF�q#J�\��s���m�'�K�p>�W���At ��F��b9�� ��	@W!a���I����K�6C7�&��;l5��f^B�%F��t~Cc1���|y뱊i��''�b����:����-��B���L�6�˓�p#��_�u��MJ��Vj���_ ��By�h���H���}��Mj��S��9����7\*S7� �$ZDp���9�a������9�*�Tܺ��L�6C�@*HmR�u�C�%F�5t�ھ����_�K��h������� ���'��m�u���9�x��}钾 L�����a}����Ef\�rFI�����w��(i�=k�q��m�,��@zɔ"��/1� zQEx�1�7f���K�&�y����\U���1�>(%��Tk��49���������*;�(�����^^E��$�|���K�&u�� �������L�6U_D��RF<��w|��a颔Ij�%D:_/�0�8
C����|�a&}V:Sʲ�z�k_Ap&F��[L����e�z��mX��4d6ɋ��C�%F������9������K�6]/D2Pb����'�\5�ǅ��|Z�U���5�a��{�8k��R�k��h� I�^4������!��V]S�y"�0�6d� �������d�u��|��B��&>��C���hϟ�j�sp2
�3�ϡm���F����N~�h�0u�S��?-d�=Wb�A���S���8��Nk�;��h�Pu��2R�ݘ�!�����V��=k<b��ꝡe� 0�;���9��:���ω�x��m�>0>�B�U�8m�� ���K(0 ��Ef���K�&�Yi�2��\��=_b�A�]�,Q����+P�y�	���(����C?�>5�o>���v��M�~*���Oޖ�r��mP'i �N�H� ��k�(`�B���h�P�K�����qB�E��"$��*��P�k�B��� ))p���31� ̩O�A~6���{��h�P��5��S�>NK�;��h����8His۱�y|��a�c��    �O����h�J/��7�V�4�y��C�A���\3N�q^Cp&F�ƺ�:��ã�p�9� �����:�љ�X'���/1� ��[ mi���f�W|�����
�=�,9�CкN�	��)���k�?=��	y�����gb�A(:�`ɝB�Mb���K�6���=m� Ŀ��+��h� �eei���ǔ{��h�0���i��q�"������S�Ta=����k��� =�R�9v��M(�T���	�%���_b�A���l��pf9�w|���W%�*R���G��!��	G]�o��I��4�7YڿPwZ("�kJ��������Uʎ S��:�!8����p�&����9�e� ���ԗ�[S�1�;�C�%F�	�Y�".U&<U��!�����'
(;�lr��g�g��<�E�g1~�a]�Wdf������h��u㠘K��� ��m��4@�0�.e�C�%F��?*����1ƿL�+��h����ꢎ-�L��_
ߎ!���_y��i����~ R�Hب8!Q(|��m��H��e�Ί�;9�BYo�Tj�q�)��!��B���SL��/1� Ĩ�m�Q�J��_�����DlRq���9���O��b�kl1�JW|��a�^� �s�R��?	��h� C�6�=���穤q��mR��O9���H|���H֎����q���X/I�(�1dǻҟC�A���9��k��!8�B�������J�A�%F��7d:H�[|��m�4�d	�C��!��	B�/��(���!���2#�ֹ;n��9��t�'>'�i����k��h� �J] �,O��;��h�P����$�Bs�~�z� ��B�=dIF����j���X�&�eWzQ��~�Bk.�6���%cp\]�s�B���d��y��mH��o��ۚXΡ�;��h��J3��Fk-�|��M�%��0z�QK���:���K(��;�k��5|�{.���h=�;���k�?-tub����`�����hCpX�i�z��m^B�H}@�a��'��m�>:	��3�1r���K�&�%��aTڟ�J���%#���O�Yv|V�s���Y�(�IrJ_Ap&F�t�I���	t��m�� 	딧��=_b�A ��
%�� �z��M�_d��@5�q�3��R�|���t�ϡ-��
A{J��vZ%^Ap&F��W�2���9�C�%F~����\�L��/1� T��ƐB�5�{��h��t�?�s�:2C9bdz9<���P�(�C鯡� L�ڒTYe��+_Cp&F��t��츊��E^A�%F�QV"2�!�!��	]�J/�H\Gp�gb�A�E�PKB�NG��^��'@��k�ayޕ���0E/:��"��*�;9�	����o =����/1� �ކc��O��;��h���B�}&㺇�K�%�>5�`�Q��:��1Z��p��az���9���2�C抣��a^C�%F#��O�d곖�q �!��B���=m���=Wb4B���P��[�8�Ó�J�FKP���A�oW�ġgTq��rhų�����@CH����dP���L�6���F�bF�?n�C�%F~�h��x�y���/1� @�3*����a�{��h����|%I5>]V�P��U���-no8�+�9�a6����4����L�&9���c�gD'���/1� �~Ҏ�z�D�{��h�����?����|������V�Z'���P�>u=$C	�GD<���~ ��f)��\@������x5�(���|��Mj�i��JJС߿��h�P�Y�@��)[��|��a霥��
4��O��T)�ǥHzZ	J��x��s�?z�^���#B���31� �����A��Ԉ$�|���usm���c��'��MZ�%��S����!���zkq�9B�ifiEϨp��i	F&�b�����"�e��8�Lg�
�31� ���K��L-?��ι�;��h��t����
��/q��/1� �^^�-��c���K�&#/�M���4$�q��YT]���{B�X�_C?�P�*k�%5��!8��m8ꁃ�4�!��	%���%mY<1ԟ� ��V�/e�
!����+��h���%�BN3i���SZC����T�-�c����M9�C���t
�^Ap&F��;�Km���=_b4A�Q����J�"!�v��m��IM�`�hs����h���K�6K�?H���S]�L�+/��2
��S?�����.�!�֘k��E�7������\,�����/1� L��G��P��t)�{��h� I/�t�R駌�_b�A����9P���� ����B9tl\8������E�J(�SK�����H����`����{��h������`�6p���K�6<Փ�y�(᜚���K�&1�j�I��r� c�A�1����)�2fq��s�B��k�R���d^C�%F#���j3�T�(!¸��J�6�cL��� ��u�%F#��d@Oa,�3�{��h� ��J�Ԟ9eo�@H�k�Ez�9f������ k A�G�;9�B�[�M����d;3�;��h�0APS|*�v>�"� ��	BNQ�'P-P����/1� t}Ѡ�Ubq��w�\�j��؟*�Ԗ����ѫ͙B�ua������\�i
ҸVN�|��a��	;|�%l4��/1� ��6w�A$�9Α�;��h�P�^TA)���4�(rO�t:� t��E�J�@ }�#H�6��CW���A���N��)��{��h��Y�1�4��{�{��h��uY�Jy6*9��'�A�%F��c�5���'L����G��Ǿ��Cu|$�s�Bmjy-#�\k�x6_� 8�ŗ:Kk���L���_b�A@�Ԗ;�b�_b4A�Y'n�Zry�z��m8*'L�
����Bo��\�ēB�=�1~�a=��p�!��pW������WHuQI��Ip&F��!tH+cn� ���b}pH�#�'V��/1� <'�ծ4Ě���|���g�9��cG�3Ư��K& IiI	����h��J�Y�W���|������0���<�_o�;��h���d�
E��f[��!��	�U"��B��WN���./)���\�{�|�@(���|d"^Cp&F��R��Ä�?���/1� HTQd\�H���K�&���F�伧J�T漃�K�6��Jw �t|b���K&G)���������$�Y|�aa������eW:Q�O]��F���K�6]��n�����C�|��A�zSJ������r��-pk�F묡����+,�{��Rّ�*1�=��+�ϡSo�0V&��)�k��h�Sӧ�!��Z_�=Wb4Bx9&��	�6C>�u� ���'aP*�)��=Wb�AH�('t�u�
�O�7���@ޟ��¤���������7
OvB��;9��$]�n��0�@:�C� ��	$�����>%��|�����\yz$6I%���;��h��P��%�,�N#�k��6���et,Ư�� d��u"�lq��Ͼ�gb�Ah��Hϴ�uʘ�A�%F�eǂp�QS���C�%F���TAs���@���K�6��$n�@Ir:K�X��>�&��k�@o�|�@X�F+�)Ԏ��N��h�PSכ/�����O�31� �n��{2�g�m����/1� �>0���&#C���_b4A��*v����Eq�@�������9DJ59���9���/	fM55�v'�b�A�:]g�~$Ų��{��h�ВN�y����|�:8��t�N�*�ڱ伇�K�6����{j��Q׵�$���Z�^c��B���CZ�oy��31� ����`�##?u��gb�A`��[!��VC��|��aD��,R�m%p��mz�b��X[�    ㄱgNz�~G�+�I�9����0���,�}A�0q]Cp&FJU=	�	0����6�A�%F��]i�F)�����_b�A`�����D��'�C�%F~)^�8��������L�g������=#R�pB��R>U�� 8���e�h��!m7�{��h�0S�y�PR
�3H���K�6�+i�0�=��#�C�%F��<)�2�d:w����5{.�9�����z�����_Z�gb�Ah�q���.��/1� ̷E��%���_gb4A���H4�Șs�C�%F����}8�Z!��A���&�!��8�����˘3�2s�����gb�@ht�~V�8���E^A�%F��!L�,sϙ�t���K�6�W���^��Wq��/1� Ĭ��P�Αg��'�Q�,?!�0��ۯ?�~ ���@A�k���k��h����ʀVki{_�\��!%VN�������J�F]�J$�)��k���:��ė�`����U���Ȗ�&�2���d�b�����/3Ɩ��P��N��h�0tFk�_s*᜕���K�6�T�t��I%���/1� d��k@5�
��r���K�6�uk\֊��^d˭*{>'H�(��i��1~��=Y��eŚs�{��h�P���@�׍:����K�6CoX��Vj��!���"j�J5�1�l��A�%F�Zu9���)�:c-�	P)v�+c��*���ϡ�k�%��ed�����xuŅX�H�	���K�&�R�z;q`�a�{��h���\��������L�&-���GiTz��y��=�8��g1~�@(�O�P����2]Cp&F��K$��!&�{��h� :�w�`O�
�x��M:�[���D*�=_b�A��2ZK\���r�z?eT�Q<�|������Yv:�W�����s��"�#�=_b�A��K���0����L�6��	ӎ�BYc���!��	��AJ�������n{@�-�8W�y�P�b�����F�`�3u�~��M8�E�������w|����E��Y���v'�b�A�6_��"m�{��h�0�.�i�e�(>�/]��j��:�|���P�y�A;z�3���$�@p&F��u���N@+�C�%Fы*9՚z�t�:8�	��ME�@X
֙��/1� ��j�D�<!�͗�uY�}ʚXAw,Ư�� <���}`���5gb�A�]� �%#�C�%FJzk^��8#�=_b�A��21�.�F	|��-z ]��J��9�N�(���Q���}��}���!�u������`���K�6;�x���[�k�s��+1!t��B;��V���J�F/��{���\۽|��!��K��H��QΓ�R�sO\DaF���s��бBMi����31� �^hm���
P�{��h� �Նl��z�3��|�����R��B�q�S���/1� �k�.��v���<�e��g��[���5�!�� *����mwr,F����XR��fk���_b�AX:{-C�OӲ�!��	B�:��������$���KZ��:�v��V/]7����dZaϱ��k�?��ĭ�%�T��5gb�Az�D��lz_ǣ�C�%Fy��.D-�X{���h���mym����;��M�R��fH,�O�����=w�J��/��k�B}�� k�8�#���X�6;VRO�ȹP��y��Mz�/�:�S����v��m_�	�!8�=_b�ARb�P{�������;kRI �;^_��?���0�^OW�PAN��+��h���z�4.�k�S���/1� ̗B���
�a�_b4A���f*��z�{��h�0t	��ð���XΝu��%��Yq��Y�_C?D��4x�gh�7�gb4A`X/�:�G�?-��/w|����n�I� Q�e�Ó�K�63����:�i��v��Mf����L��I���,��z\�X�B!x�|�����KbS�������gb�AX���J�Յ�v'�b4AX���2�U��$�|���ŷ�=HPI�|���i��W�(�	�"�륤o ��f���a}�@Ⱥ-Z��9qj���31� ���)��ڷ���/1� ��RN����ӄx�:8��i�P5sa0����K�6Co�
�4I0��#�.�6P*�_�����m�2��C��R���K�61g��h����� ���˺�"�o��m1�Cp%F#��������Wb�AH��ie�\ǜ1�u�;N��8��-{���9���K�u(O�ڒO��gb�AR���L�g죞yw|���YXV�̲b�(�|���kMV���8�!��	B���n�%%(���.�Td��x���9���S�O��P��y�� 8��x;��?eG�imp��m�.;��Ab����_b4A(Y	|jܳ���;��h�@o�Ik����+'v(M�? j��6lH��?���PC)@�C��k[�\Cp&F���T�}�&�C�%F�����ԹI��=_b�AXze�K�
5�R��/1� `��N�&�!��R�[�K�jL�z꽊�ҟC?HhC����¶;9���}������N��h�в>�����r�|�������9%ƕ�=_b4A�u�NIT�~��RA�����\����C?PWҀ_�D�5�t��m�<!�yR�3�<��� ��	:qkc'�L���_b�A�:vؑe�i�3�|��m���8��I��di_����*�ю3�c1~���('���@�ү!8�����c�@�0�!���4צ�rZm�n�C�%F��v�&����/I�
�/1� ��?(�\����3Y⪛J"Ąsh�������+Wv�#V�-�r��Mf�/��- E���gb�AQ����\��/1� ��O����V-�C�%F���	����9���$uE*����<�1~�@ 턅�ŕ��_2�gb4A���t����"�w��m�n9��)?����/1� tyف����x
�\C�%F
/=_�_p�$��ً��+\��<�"�,Ư�/=_p!��Su#]Cp&Fҥ�9Jɔ��z� ���L��TDV���4���K�&1�
�OV�B������mx��c���t�fR캕`��E
���_1~�!E�9t���uK��|����� c�%�6�!���ЇC�R;P�m�Cp%F#�I	S�U�-��Ap%F��^�'��u���V�	^��<����B��C?^ڧf��ì����!��O�Vq����E�A�%F�������i�he�C�%F�����R	N(}��MJ�@LЧ�q^���ڰ,�v�5��s�ϡ;P���G�p�6_Ap&F��s��ò?�+49g�� �����Y�y�)�{��h�P�.�h	�O�9�p��mX/�6�!P��)�(�v��!����H|�#��PJ��r��m�.EX��p�@X�=_b�A ��Pe4rq�x��mD�'��a���|����N�ّt��ZH����r<��sL38N�����ۼHv5�{��ɱMz��	Kʠ�{J��/1� ���C�{|���C�%F��+\7 *���O=�;��h�0��(a�e@_�c_�M�(u4�yz�|������ANi���5gb�A`]��i�X8w�q��M(�&,�c��#�{��h���"�Tkɫ�1�C�%F/Ɏ;v�$���:��r<>����������
}V��k�k��h�����*������gb�A�:]g
B	�ڨx��Mf�Ԅ^[9C�|��a�t�����:K�	5)�8�'�[I�7_��~ H�G���C(`�����a�>�du��8��|�����+-}�I�{� �|��a�i3s�a���/1� HI/%�03��Ά�Dݐq,at�k�_C?:�t�%���=gb�A��^��    ;��a�C�%F���Dl�O�w��_b�AhEg���'��!��	Bo�C�K���H�ߏ���l�`�"�C�_1~�@ȚT�}�}vI�|�����!�*���{��h����.�����h�\��!��R�:�N�e<�t� ����M3R��Y~+K�P�*8i�U7*�k��C?��yt(�VZ��31� <�$�0�=_b�Ah��w�:�(��	�|��a�K3,i%'I���/1� ���
�Ը0�Y^㜂N���f.�KȎ��5���`A�"�$�k��h� ��Ȓ�G�瓟p��M
��bH)�/$�_b�AhI}���@����|�����c��R���C\_����6s��G�e�>�~ ��>!M������r��mXM���q���p��M06@�d�\����_b�A�:��q���	��h���6���K���;�JB*%)i�v;.T�9��/��00�FR�k��h��@}X��Ѷ-Nu�;��h�����("}HD���K�&=V�:D�z�aG��|���닲�w��V��v��]�h?*!u�5���k������gQ�D�!8�	� �$�<UG2�!p��mPW�B����x��/1� �>K\[�=��lwr,Fz���$!"���(&u���c�ұ��5Ư�=�6��g��ef���L�6S�;AZ��+�{��h��/�"�>��j�q��m0�$s��
<�t��L�6z�QR�5���v��K�>!#��f�2<��k�?�K��2pO%e�=gb�AhU}"���I�J�o�
�/1� ̗uy��[o�Ƽ��K�&�N���l3�h��/1� ��1Έ����M�WӤ�J$������5��=A~i����qP���w��m��1
�UӞ)U��|��᥆)��m���_ �����D¬��Mt��-f(z�e�\3̿m�^�$�eBx���H�������#�=K���S��
�/1!��A0�Ҙ%��`w\��!f=c�i�V9�S� ��B�/�[92�q����J�6)�V��)�;x��I�S��RrUjm��~�@(M������v8}��m^�M�
ρ@�q��m$���)B�}U�{��h� 0t�V!`/��C�%F��k�������EN�Y��b�� 09���rZ����#�1^Cp&F����p����8'd� ����?O1���\���{��h�P�>��a�
D�g���/1� 4���20@^��@�Ru�6���걐�P�k���%}Q��A(S�_Cp&F���J�g���{��h���i�,��ܹ�x|���t%��Tw ��{'8�	B��k+�=Qȧ}�Ġ�mL�`�ʴ��k�Bө�hY�%<�� 8�뢔���j����_b4AhQ�,PW�)���K�6u('؟�5e���~��mV})h�߄EY����tw��j�Cs�W�s�?�A����9=a�������lǆ��s �C�%F��	+Шq��|��a�v����h��c1� ���K�iĳ�4*�4I���q�渵���u~B�I�a��7�����I�,am��(��/1� p��	�t�&<��/1� T]N�K�_ȧ/Z�{��h��g�zZ	mO����Ry��-�M�OqA�k�_C�A��k�˞*�M`�k��h��t�@� ����/1� L}("A�8QV���K�&+]DB �̝��/1� t}np!��ߓ��.���Y�Jh%����~ HV�Pΐ����gb4A��Nv(�Rm��/1� 4]�>S������I�%F��۬7쩵�'
���_b�@X��� 2 ��~�/+$mO�NO���=��s��K��3������/1!�Ksm��n��Cp%F���n�Eq`�K��+1!]��%�B�X�;��Bʺ�w�޺0��s�(/�'r\�u�W�_C?�#�̩����k��h�0��w �ҳ\=�!��	����]b���C�%F|Y�ۓ%IM8��C�%F�^�@I���}�ߌ8�<�ë
�5;>��9���*CHZ�J����a��7�s���|*n�A�%F��P��PF<�C�%F���'�R*S¬s�;��MjЙ*U��Au��0�ʄ����[J��+�9���n��c��p ��N��h��u(]a��+4��O�31� <������D�|ʓ�A�%F���4�p�!��@�{��h���H�V,�I�?�H�z�ey����B��C�Ah�Oȶ�:p�}2�k��h������,�gL���_b�Ax��*C�V?ɜw|���G]}�q{����/1� ��.�J�9��9�zէʗ�8S�+��X�_C?�>�������W���a�ދ\��,�ji��/1� 4=�X�i�r۝��a�t~���Ts2�!��	m�=w�P"�!�ׁ�~g&5�1��qϗϡCW��R(��V�X����A��,A�#�{��h��Y�,���D��up&F��v' R[���!{��Mf�����2P��1���Dh��'2���?�~ V_��g�4�5gb�AUE�J�D��s��/1� ��16�#�7���{��h���>+�h�*�?@�%F�Y��ir�'�PΝ�ɧ���/���s���$�dN��r���)'r��m�[�,\GL1�{��h�0�T�\3�����|��A�פ�j��O�/1Z H@�u`����J��6K�:�-C X�Z��?�~ L�K2H���p��mbj�	 �c����'�Ap%F#�u�*��b�!�1�!���}���,u7��Wb�AH���q�J=wJA�S(��/�8'x�@h��w�.k�5�k��h�0��<p��\��!��	��ۧ?Y<SZ�{��h�Pu~B�	#� ��$����Ͱ�H��^�Yh��gT��+dϭ>�����%}"T\�t���L�6-�l��������{��h��Rbh��X�L�;9�	B��r�Ƞ*i��;��h�@�I 	�z��~{�RP���[��­:n��9��@o���Bݿݯ!8�B�M%���Ë�;9�B�K���R�{��h����d	"��;�,�|��a���/�j�k8Ǆ_N�&�o�d�5ѱ��~ Q_�����Z���L�6�^�,ՖFi=a���K�&-�#�U2�Rj�� ��Bׅ\� �$���/1� ��{�M,�#�t ���(�j�s�������)8C�Q�߾�gb�A�qٯ�l���ȶ;9�����@�������K�&{���!�+�~b���K�6��*| �<���'���YsO1�H����Y�ϡ� 쟥 Jb)1��/W����k�V�܈:�{��h�0u�ʞK�����C�%FNz׶H��x�>�!���ԍa2B]�29w�����r��8���&���=��jl����u~a(�	��=_b�A`� o�2�;΢D��/1� �X��0h��y���6_A�%F��vVZfkF��$�Y��{� !���5Ư�S��OHY��#���7���A�>�� �<1���?@�%FԵ���5Ǚ��"� ����f�����!���� �-Z��"C͘�ĭ}Q��"(c�4�m�b������҂^�9O~�� ��땥L1����<��!ƪO�I逡?�m�<��
��]ی�$̙�/���'1Z!,}Q���^�&�;š��=��zɱ��������Dd�a��k�u��mPPE*a�9R�|���ue΄�Hb~z��C�%Fz�If#����/1� 4��Ѩ�^`t��u��gTB�gN��1~�@�:�]��ر�t��Mr
:gI������+6u	��mP���E��)g��=_b�A`� Be�;���'��M�K��O�ߝʞ8�uy�4bh����M�������f���L�6S�3�y��'��Mj��	r���&�|���%�yR���±�    {��h����,�'{-��-�'��>#T�3��8�����t-��cϫ�6C+����ueΎ�6��*�=_b�A`�� �S/\c��|���%}�IJ��J��/1� ]�6㢔�¢�a}I����D�*ͱ��~ �����Jl���"�����g`D,{0c���K�6�%��z,���ߝ{��h�0�T��pȎ�����K�&���P:G��fg=�)E����-���;������Ww��i�y�k��h��t�kA�-�L��/1� Pu� �ơ��/1� �n|�`��k�h��c1� i��U�O~1���}E�}Q���5��:{m���g\��!8�B��I@�f���{��h�0��|���<�R���h�0Sz�|Ya�a¼��K�6]�����tZg�5G*L� "z^c����t�0i+�i_R��31� ��� �^��7����K�6�^V�r��_����s	��mf֡&�)�B�� ��	�}.ҨR��� osOIsA�������C?Fzi��r���Jr��m�.;6e�I��!��B�OȲ�X;��!��B���@K��q��Mb��P-`�� ���6�������H��������usm����0��I��6���s9' g6���p�����"ػ"+
��U�Z���c)İ�Y�	�]��K�'s�Z���~�p�a���ɜ2P�=�wW�� ���bJs(�7 \e����]�dui�O���K�o��1)�[��,� �O�[\Bu��!\f�� ��dYC���s����w�M �DCɿ1�2��A�����i`�� �wwƯ �,����f�Q�-��s&R,��޾�g����/�Ǯ���~�p�a����;�2F̖�����WJ�ji�����o�2��A���2�9��w���!�e�� >�̰b N�"�3w��g�g��0��?j�-����b=R��3���wH|oL!0�8��.��������{�٘~�p�a�
����l��oA��7 �e����Dl�N�ae���J��5"����ņ�$� ���3�]����p�a�
��m&֟����ww�� ��k8�����,��.���	n&�AM?�?A��0~�e�ۜ4|�8�zKfZ�Ɏ]*4髵~q�Q�Ah>�9��@X!��~�p�a�����) �<���2�_A��G�U�.�[��1�2��Ah�l���� ��C��0~���C0���]���O��1��J����/G��,gY�q]!��	�~�p�a�B�w�1�Jn�C��0~a��� ��
�J��C��0~!��0��P�F!���2��A���r�P�y3Q���ѦO礿��$��<ƣ��Թ���S\-��!\f��P}�JG�	q��2��A����s"L	K��]��+&�PE�g^P�ō��wП1���3R���]�֟�`�;��7�1����O�vhE���~�p�a�
�D���t�x�%��C��0~�xu�$��'��7w�� ppu�w�T��]��)��A�>%u!fE���Z�Ɠ�/6�'��_�!���)�O��/.3��Ao�>:�&Y	*��.���|�o����M��	�]��;���NiV��Y�	�]��;��2�~'��s��b�pt�2G�����u��)�������Z`��!�e�������rClY���2�_B�׼`�u���wW�� @��;��}"�P~�p�a��ݡI���l�x���5f�	r��Q�AP��o!�~����'�Ư �n�S˫�X��.����gB�H�X���;���w�|yR�(�)����.�����7�,a��b�NR	��-�l4��o�O���'B�D�p�a��`_NJ��p�ĿC��0~����⾦�&u��.����!�y��7��]��;��h�;���"�ڧ����hvC��I�_B���W���.3��A@�;���VcꟷҿA��0~�-��]�Sʘ�7 �e��@�7Ú\���:L��]��;-� *sf^k�0��Lld�8cA�9��(� ,a��(3-Y�g�Ư ��K�8���9���]��;�k��AUF��ͿA��0~a��`
����2�_A��S����yIYV?!�0���0��B�]�$�(� �?O�\�)��O.3��A���l�#�o�� �e����wf���|b�� �e��P=���t�S����.����S�:ƅ���>M̾���\���\��}��@���9���hy�?A��0~_j�����L��� �e��0�{�΁C��X���2�_A�j:�5�Thq��ҿA��0~���Y�kͥ{�&��ʕURƠ���y�G���L %��tڝ�~�p�a�����$�I�o@��0~a����a<��b������$���d	޿A��0~����Q���B���I�Kcn3� 8�ͷ�'�a�CD^�����3���7 ��CP��ns���p�a�NE2��ɻ(K��]��;�%��S�:8��p�a�
B$+Eb'�aX� �ٿ 5��	��'�G�a��6؇kS�%�#�p�a�B��Bv ��EFk�U��K��6�D���[��U��K�������\~�p�a��Rp���EV+�q� �/�I�0B-ċo����k8�;z����g��� ��fB�=g����]��+9�����gM�/���w�O�V7+鮱
�߀p�a��K�0s�c�d�͐�w+�6������%���6��O.3��A@�/r	ǖfh~�	��� �/OJ�f�"��;���W���.�����<�o�2��A r�!��0
A������Uf��b�x�n�'�������.3�_A���v��t��!�e��P�y�ءk =-��7w�� �O��8J�]����L��0~��w����yf1�ŷ��)Ia^lO��F���I��Ǿ�g��� ,�^p@H�O%���2�_Ahi�P:a[��Q����2��A@_g)A�Փ�b�C��0~A���� �?3��!�i����.�G���}q ��~�p�a����5��d��p�a����R�YJ��*x��.��N��1����^���2��Ah�O���^��_�;n&�\/6�'�a��2���� k�����WF�e�W���jO�C��0~_�,ɂTsL�;��.����/_:��4��s�n.3�_A��g�UNC�&D���������'��w�^�x�n�/h�DZA^�g��� L�a��U��\�wwƯ ��;/���Ɉh�e~�p�a�FEvA��2c�n���w�?	�@1�2cb;^[��t��)��7Ɠ����>*�H�y�����w8?A����u&��;���w^�M�TI�WX���.6��@�!�/'�%$� rK�ww�� ���g&�c�>rhɯ(��}�a<J ��+i$D�("��������/�F �0��wW�/!�\�.�q�����o�2��AH�����[�R��տA��0~	�|Q��Y��~r�T�'՘t����������M
e.�R�?C��0~�+ML�Fn5N��]��;ş16,���4���7w�� ta`@�#��m�e��+9��k���~�l&����$�:��eǎ���c���2z�?C��0~a��Frc&֭c��.����K��% ����o�2��A(��%������2��A��if�w7���	�C{����SmƓ�BM�/$���3���w����$�}��;���wݚ	�ꂜ[�� �e������D�ۣ��$�7w�� ��(I�DK����!c���΄۱np��I�A�w���t�BVN�'�Ư P|9r�ږz���L��0~����ռ_G���]��;�7�_�)�z��]��+    -�GYt{X��Г��I�/Ƅ��0p _���(� 4����&I���!\f���|1��)Z��黑.6�_A�P�3ZIK(�}B� �e��@>?ar�k�	"�wwƯ �˅섑��UڽC��s\�G^��|9J7�mw�ZKE��2����6~��sN�W�7w�� Hzy�3f��a��wwƯ �qx���J�����.��ܡ
���C���,ʾ6ȌFD��0��?�K�4v�-��?I�@��0~�|'`.����.6��Ax�"Ջ\+���0��.��������hĈc&�e�����&LX�<��,�|�0�}{]�Z7Ɠt�0|(d�@���e��+|$��X&��g�e��;/�WD�4bK�ww�� �<�<i��j��ww�o ��OҀ���'{M��f�k&�j/~�r�n*�������3���w�w�
����j��]��;��Lh����<�p�a�
B�/Ŧ��q���C��0~a��	¸݄c>'K%j4�G*q��̋��?R�� �yE�,~�p�a�Bo���'T��U��K��A��!�`���p�a�������`YF��U��K��'������{����g|b
��/����*/�ZOu�Y�p�a�
BN>�1qO3S�'��A��0~_j���B����.����BT��o,���W
�� �u��z��P�_Nt�B�������{��XJ]!�f��p�a�
B>�9j�X�h�H�C��0~���f��=
?5c~�p�a����d	8����X_�� �e������@��I"@�ݡ��R}��*3p�'x�����`Kk�S~�p�a�B��#�>J�Sq�7wƯ P��!���1%����.6��A(�p돉��*�;���w��c�V�)�a-�5��0�ȑr7{�'����� 2{甹��.3��A�/�Ӥ��e$N�;���w�Ch��U	Y�ō��Wz�I�W�h�2�˗� �e���>{��Cf���Z{nCU�q�v��Q�A�ȝ0�
�{��g�Ư p_�F�[��C��0~��3��y&�	5�C�� �e����ˣ���r�;��.�����A����0�x��YAQp�rs(}�n0��aH���)ܾ�b���L����JU�wwƯ �0|�;��O�~�p�a�B�� �@�9�h��]��;3;�aȬ��4��L�@�@+S�L�Ɠ�����!�֟!\f���J/�tLm��.���m�Xs�,�����W$���Y��Ok���2��A��?R?��[(��J�-�!}���I�A�!X��5��#3��2������01�D��;���w���$�ji�jȿC��0~��������O����Wb��B#��r�Y�����2���s��0�G��0�{��3����G��9p*�����*����K�NLk7x��p�a�BIn&D�9g�j	޿A��0~	a�.��cMJ��rH�_N�]�/�g��b�x��@��W�΄N)��g��� _�q�,�{	�]��;}�ʜL�����;���w}�tڕ�Xy�� �e����Pa�N�^ôJ5����s��]�_lO���	�C��V��g�Ư ��=����3��.�����YӬT���;���w�g� w�0�-�Z�A��0!�0��^���l�hc�	�W���q+��?*�0JdJ ���`��=���_����e�_������3��(��
/�����B�CaF;s�Ϗ��#e(i>#��H��B�����(���F�#�r�������~$ʲ���W�*����������?Zta�5WI6Ҙ��\[+��Wב���v�@v��u�`�ɳ>#��n�4�RgT:�f
'��8��QEu�B]y[zF�t���G�ڀ�5�)�GAM�u�l�"${��.����W���-
'�Fa4�J8��u-�/6R�n��D�9\�"N�7���8!q�#A�3�H�UjsATb_�I�kڍ6�G4L{���/�P����N�2b���̿D��(�W�(H���~��F��v�UYpP�n
��]������I'I��U��K��5��q�nh�Q8��ųcF�%��2CU�BMw��)���/�Q�gR�ARl$�~$�R��W���5
���-��[i�M4|����_6#��w[�-
'�F�^��1[W��gg��CM�/qo�p�n�tM�.��ڲ�>����ՔG-=Λ}ǣ����{��G��va��b���ǔ���8�+��oQ8i7
�� s�&�3R�n#Qob���z.����܄��t�X����h~��c�9�<j(d�tVTˌL��B�1�	���1G����)Oڍ§j�~��gZ���H՛Ш[q����Wυ�v���?��R���f+BC���K����p�Ny��P(@���
��NYr�ބ2`�Ќa���G�F���ĭ��,;����D��	��1~��_�p�n�|���n6�?��w�;K��*��k�
��Ԕ�����VDUp�x�A3�7�=%��(��Z�¾�\i���C�S���2y��U�¿F��(��VD�H-�2�F���\Ȍ��r�u<i( x��`J��E6��,��1z���gM'�F���N�)�(3e��X�C��:��������@��A\�F*��kB�<'��4Q"_�G���%��i�թ ;}��ӎ������'�'�����G��RJ�������Y��)�/���-
'�F�y��$�z+vC���e&�RV��w<i7
�{�"��N_��^(C��� wS8h(t�tđg�-W����?(,R'l7����I�Q qv���q$�h^S��G��gHU##w�Н���t�p_M"�e+B����V5���^M�����B�H%N!�Y�G���o'Z�#]M��(�����`E�*��M7V�'�(�U?�j
�FA��n�yrF�y��r��w{�'�����i�!���#5gB+�R�t���I�Q��-�=;BC�m$���4f�"��է,'�FA�-�]4�\ 6�Ln�,�}�5h]N���0sw�O�M�q�v[;Sq����穴���;i7
=���1۠��FB�22��r�x��PX�_�e���
��,��+�	�˪�]`��p�nJ�pP������\�W<��5������NڍB�#��z��G��rQ��O��B�r�=�I�Q��t�ZL]���|�؆��
0���I�CA��Hԧ�%�P�_��O�#R�T H�zE����7���ƒ�ͬ��/�ߩ��ͼ����(��H��o��ES2ѹVj˻�P]wυ��MA�j��(��4�xN_w�^���H+LJn���
1�Ⱥ�0�5x<#�Oǀ�^�6{	�n���(����5�َ��H��ꆳ�e�To~=v�n$��\�,t�m�ᝊ�T�<n��G�����0m�E�}I��"R
>"�P�n����W�I�QX�م��wor{%R����<��Rz�y�8j( �w�ȭ��hA{�#
��vv�MC�Po>w<j7
ͧ�7���Ǆ 6R���U=��4��n
���-�_l�1����-���l��&�
r�q�n��Yq_��K�g�\���.��2�(��p�n�r֑D�7�C��#�nmi�Z!�|�x��P��Td�!)�g��|v�ҝF?���o�<p�n�K: o�2"�`;e!�����˟�)�?j�E��>f�3�R�ˁ��p��s��(�G�g2����4��O�$��`�W�;����&�w�N�GT�G���w�S�j
�FA���!�D��hZ4U5�G1+���j�������{�K�l{=#aZ/�w�!��
_�S�������VS�%t���v�9BT-���'�
/�����X����-�]�*�ZkO7W�:j7
Ż� i�awS���ltH1��ݦ�f
'�F��[�P��    �9�N_���v�Q xu^�Q�C�+#�7�Nd�2��/��V�^��7��8j7
�|5;�m�5��8���� �*����)���O�����V��k
�S@�����������[vWDA�<���K�3�Jt7��v�P�F� +�3~�B_.#ơ��
t󋡣v���$>aB�9}��G$d7��%���������ԭ���g{D)a9��sN����Q�Q��cJ;���C�az��e��\����(��� �$B��Z|��m��\���4G���R�$ɪ�����H���-��3F��^M��(�?����##���e����k���S��v�0ſ�@
5cʳ�\��YCW-5�ϚN�
^ʢ¾ٞB��r���l*'ഠ]mOڍ�KL� 5�k�nsa��xVI�R�%����I�Ca��4��5��)�\���H�̬������(v�4u�KR�v+�� ^�ndp�5��s��(pzyI�JIi4�iyT(�����z��P��R 3���	/[������>��'�FaxT�m%��U0SW˟f��}��#_M�}S���O_�,4�`z�B��1h 0�ΩH7�A���]x�}����˃����W"G�Fay�
��<�h6���P��*}�[q5����B,>�&�cm��cjL��aĀ+�ğ�)����'�d�3R�:l��R����um��(���*�0����3�Dg< �\�*ps}ǣ��B*o�D4��V��]M�;T��:�$W�����ώ�"M�u��D��� Y#�\G����K����Y���0}����BO��7���? �Ⱥ��9M���5U��ݲ	��ǒڎ|�m�Q�Qx��{����~(��N箨-�]?^�G��?r��)��몖�Za�dNr�iEK5]�"NڍB��`�eH�笩f��xR$���L��(t������J�h�u͔�!���
%Bo�������B���<�<����2�[!�Vb����{ʣv�P��̮T��S ���%�����Yql���+��(����۰=���� �4��n
��0��1�e0-��3��_Ⱥ��l)�n΃>j7
�W�ɨ��d'�V��q��	U�>e9i7
��К ��.�����\k�����I�C�����vGo��C������Z]S7S8i7
͟�LQ�Qm�Z�i�"z3`Ѹ4놓��)Oڍ��,C'�l�)qx�p���B���A�C��on����R#h���D�W��M�t�9p\mOڍ{T��n$[����qUC�\9��WS8h(��wJ��R�j�VI����5㸺.�Q�Q��v8�b����(��K��G���c��W�I�Q��b3�ݖ��yк��|�
w�L��)�?�K�:
kN*�A�H�_j���;j�r�=�I�Qh�|����8�d��X;�}��,��@w�'��}$0 c��4�m��b��ƫ�����OYtA�RG���1x/4�����1�����v���X����V��U��IE3��{����Oڍ��=�:�)�� YU��}^�(Iޅ���^�I�Cad_'�sG�9���dw��r�G,�t˭��L��(��>Z�-*&,��z��H)�bX}^mNڍ���l��k����>Yz��Y�Ð��N�
3�4�}�}$��z&����:`�[�p�f
'�F���&Y�w�%�|�	i�,x���I�Qx�r�xM�^��9�S�<qp��Q���
�� �ZBi��\X�7�AI�s���q�I�Q�RA�5�vڸ�5-���SZQ����P�in���J��FN��&�T�W�����W��'��]��{�+â�Σ��|���A�]����G�F��4��c�\�Z��*�/�5�Z�WG�'���}GL���|A�JR!.�Y����q�I�Q�>�Owɜ�c���Sb���s�iT�ڃ>j7
�����t���e�펖�2Sm�D����S����B�}�Ĥ��r��H�?7��s�T�^7�G�F���;B�Xt�{U�^r��C��|ǣv����!aeF�~S���H�Ն��������B
/=dJ�����4}C� ywW�]����A�Q ��T5ؐ6f��VD��,�Vn������\���FW h�a���?+�<v�S�tu������y}d���|�=�,���&.=ǜC�:���(�t�8���_�G��6Cv���^�]��(,_L~WU�������v�qR+��wSG����̈́��TǪ؉��r��5�5ziWWH?j7
��d�#�,`+"�uI�	�-�]D�j
�Fa���d���.�g���ۓ%XG�x��x��P(�ϠY(�⽤l�(ſ�-8�G³��W�I�Q×9�����i���_RC�īW�I�C�F�nJ���3!K�8bWy�#5I���y��Q�Q@�_�E����j/�3�>�M��S��v�0|�l��ԱC`�H��lʲJ��^��p��P��{LNy�c�������$g��Qn��;j7
��F���<��/��$n���VYa7����I�Q�>��B�jFs��o
��sܥ�)�4�7�;�?(�W"#�1����Rk}��Is鄻����(�?wԠz��1A�>��/Z�J>����U.�ڍ���4���I@����Xu׍Um��YG��/��8�
�R��5����F)�S�Zۛ)����JE�����H/�~�촵Z��;�v� ~�0琹�
l+�M?a��lC7����L���Ћ/�N�e�
;k��'�˭�\u�^�G����R�	�Ϙ�>�����6Qc��v���;3����z̕!h�e#M��4�Du<�g�:�>i(�k�c�����u��[�.	3�����)����ҍ;%n9����>���k�4#\�"Nڍ�K���/)ڂ2�H�gBt�D�(��w�'���>A6`ӽtpf��F�XYԆ2/�G��Oڍ�����]�%��픣��]�`3�Z^������0��0��`�5k�ͬ�/�5�Z�������(h8�<h)}iX����H���wg�ZPTW{M'�F�幡�U.�l0�I���e�.9���pud}��PX���}-,j�sǕ^�s���rg�����(t_!��
��z;� ��� �Ց�I�Q���m j��V�q�� �����Օ��
���_Z���	������_l�*���o�OڍB{PSJ"��+�!/qYǞ{�x^�G�����2���z��_���� �ʽ�yu����M�B��,�ιҬ�9���}x��B]�귵G�F�};�!m��b���G���A
��*�ꞄG���m$p�T�uѠ >)R��4Eo��?j7
�̶���O�+ŗ�L��n����oe�ڍ��這s�E÷[a#u�y V]L��Ĺ�:�?R��즅s�n#�?����3��;����wl�J(�y1D)��~��Q�Ap�]8i7
�/��n)3��Ժ���x�d�AW��<j(@�'c��W[i�k�}D������'�F�|+O��ÐBK�b� ���y�3�g6W�'�FA��ҲK��lAY�Fb_�d�\���q��.��?r���O~��Z�1'���0h��;2��A����ok��]���Oj��AI-Z�曳��ڍ�x���:��v�H/d�ճ��F�Q�Ca����I��9Yc�g���CU1�К����h��(t���#g*3�4?#�{���e����Ϛ��
5���)H/��Ԅg$�z�������gMh�m���A�����h��5s��w<i7
˗?�c[�oj���}� �Q�yuﱣ����;-	M�I��	�Ϝ$N1�L5��W�I�Q�Z��%F���w���4u+K�:����@�|L��qN�b����S/���s���P���)����#2v��m��F�#�BW�'�F��k1m7{�^"D�ֳ���uϹ�:��?Z�W7$�����;��)2i@��suq�nȿ+v�����V|:��Vw^iMWW�:j7
3��MQ�B۰l�h�X!��;o
W[Ǔ��BO/�ǀ��,��z�t�$�i����    �(��Hb�i���F�������̶�^Y����7�$��YX5��H��B�]Cjk7:���A�C��?C&u&Z�3>Y����ouMs����_}}�n�ms*P�XosR1���@�;�]M���0B��#IĪkǬ#O�bdWW��HW{M'�F�冎1���6��m����@��A_}�v�nx�|T1���f�\/�\A��6]uq]}�r��P��/�}m�`%����X�x�"��i��W���v��|c��K�� �,�3Ҭ>0I���ǻoeNڍ��^ӮL�E���vs?��<(s`�rwLy��PX��/Dh�rK�/����n�y�~��@7��:j7
���*�4�w5�:����,u���b䫽��v����!f�*Q�ĶS���!��5fU��:nG���R-���P��3�D_�m�=pT�s�ˀ�v����~ƕ1�ڱ8BM��3��Z����v� �V&�FS0�~�m#y)�-,!]cwυ��M����SĶԫXT�����O��Xcś3z�ڍB��I�kW�G	}�� y��^�Q�QX�.K��G�?U�W�����6���3���B�>�-�P:I����}��M�J:\}s�n���b�YC���G�X}�̂X(ԯ�'�Fa��'��f�b[�n���#`(�Ej�]mN�
����,%��w���>�%�{��r/����_��,��dk\D:�뱖^��N\k��W�Y�y�[;ӎ����4}@gH�ե�9�>j(�G��#�;��Q�g���k��D]]@;����I�Q��Q8p��T�)����(m�z�I�Q�Qx���d��]=b�6�K�˝D�l�|uW���B.�3c¢>�݀�)�t�l��h+ŌW�'�F���P�J�\�ͅL���@+U狤�_�?J�O�"�4h�'(���r�k����s��(�Ĭ ��v�o��
���u:�5�̛��ڍ�K	��\3,(�G���\�R֪W�'�F�Kg�����X��By�t�%������3���BE��������s��j��"�̋c��>��(�-�+"�!Lfk�͆�-N�v���?j(`��~�k襪U �wc"�窢�+t�����v��|���^g	}L{C���FR�d��澵G�Fay�
!���V�P���q��d�	�j�p��P ��,��
�����4xCU:�կ�=v�n�\�NEB�C6R����K���r���Q�QX�� ��>��3�6� �@���{�I�CA#ϗ"���F�q<=�Ev'��v�8'��V��(���0�g�؊h��w���"�h�u5����B>���6п��s+ӖnH�nL�x�=ڍ�r��BX�P,��u��r��9��j�x�n��6��B�U��|�����v3T�=JW�/��?8�CI�����#�"�>�K�%*������I�Q(�8�:�Tg��ne���i�Mh��WG�'�Fa�D�	s��3��{�1��:e������0�'?��]:V�1^�2��S]P��OYNڍ��5^�Pv�؃Y�Q�5�:#S�n��_}7u�n^��2p��r��cm�K;&Y]}����2G���r��=��k���g�CB�0"m^mNڍ�KYԊS���YțP�IPb_W粜����������ջ�ξ�tڥM꺺��Q�Caw0�Qk��N��^^fd�ru���v�@/�<9a(5F��X���I ֬��+��(Lx�.��Y��`va�Kn��5��.��?$y�b���2��$^����=��� W�Y����|]�"5Rj����R��1#K�#�v��|3�B�A�d�i��?��co�K��չ�'�BࣩEڈ���؅��+g�S$��[��v�м	�8(��S��^��yH�q\݁���(�t����Y�hH�l���HYGIV��+�?"��C�F��л���Q��u�M�Wm���G�FaT,�i�J����3?a��q]�u����bs-�<3��?v!�_[%��Q���|�x�n��4$���E�9q�)�b�K��<�曽��v�0��	v�g�Fjo�rk������;j( �ʆf�9F���/-&��Z�|7��v���K^S����6�.�K��Z)W[Ǔv� oqD�pj|��0|��ꁎ�#Wo~%r��P�ٿ$\0t���^>#��c#��cϻ�n����,iSR�J��B&�[��n�Z^mN�
%�T��2fˉi��A�/��;J�.��~SG�F�K4ōt��T��׮�ǿ=�4��w{�'�Fa��K�m{��^���%a����=	��
5��2Uv3��Zp/�O*�js1�v��x�nзc"c��A�=��8��\�^'�Fa���ƶ����ݦK�]��pw4u��P�苷�,���c����c#.N��~u���v����m7�!���1��� ��.}ի+�������f��&��^�2�6$J��r
�J��VxP�^�4�)Q��%P�n��8^�A������b#;w���i��V�n��YG�Fa��Ym���*��s\����̐��=���Т����nS^������`B�¹e���A�Q���S�1VZ5�޲?�U/��@|u6�Q�Q/�����b�,��u�jPb�0��|s��P�џ;6�ĝ�h#-P��`Y��}}�n^"�&�D��4(5
���SÒ�1�r���I�QX>���Fi5�`v��[�KN�N��z�Ny��P`�U���>�(�h7t|�(	��,��t�\8i7
/��TI;�Κ����n��#��j
�Fa��b)j���};�]]{d�p]�S��?F�ED* �q�N9���X ��7���/����V����e~vʁoEF�
�k�:�:i(��ӾK��I-X��>�V��sA]^w��������'���}�_�a�F����ޏڍ���#��ق���y�j�P�5�p��I�CA�����K����s1�/�6����[)�j�x�n�[;�N��f�
/J���ͼ{�<i7
]��ɭ�����g$��S��!`���p��P���D	5�\�/��^�_�(���rW�/����/��(0c�sG�&��4I#�؛)���i��߀�G����� ��4�d^ݫ��}S���2z��S\�bJ�>�E7ے�L1���)�ڍ��w�$Cj���p(>�c�m��e��;�����Fq6Zr|(����B#��o~%r��P��NV�1�Әs�H��Gp������G����l�u�;F}bJ�I�x肓X�Z7�G���Oe� 0X^�g��)�Iƺz.��?t�pf��+G�����_��IQu�|s4u�n^z���\�0b����^�}��3ں����(,?a g�&~Fbx
蚉2!��;�I�C�Ͻ�6V�B���'�&	s�����M�*��;�
i2����Dn��H��~[{�n&�dq캈f��Fұ��A���������_^�f�s�NE�Sr�i��G%�Qn��>j7
��5���]+������D���YB�u]�u��(������R9��\��X��$R��|}��P(����,m6�Sz�;rI�Iz��P�j
'�F���0����|1��B�)�y�]8i7
����;2�a#��.�"���Bu>��p��P�Y^��d�E�W��nJ�Ƌ��md��V�z�<i7
�#�)#�:3�H�� �3�R���[{��PЈ�W�Щ��$$�T�=ϡ?@}�\p^S�����e���N�*itI/&T���Q���Nڍ���5e'���H��W�F��̼��A�C����̀u7(#;w$�ϐ+sUTs�FDS8i7
콦��jNst��ej~��QF�T��1�I�C���#��m�eyлޗ�.���1��u܎ڍ�	�va�l���u%�<+��w��'�Fa������M�M���}��y�HK#ԫ��I�C�G_4zaZ�t��d1e�pdA�Qy����'�F����$�!�R��&��7fDu� _]���(oBYvE�=�픽�5�$(Dv]M����ѷ]A��b��l��� �>�1[8n    ��8j7
�'9�ʆ�@`[����1�X���}Oy�n��wT��Q	y�)��З�GG��\��y��P���/�s�D��}��t��R'T��lG�F��E�E%�,��5���q��^�����G�Fa$7%)� �Ph�h4؇�4��e9i(��v$ �1��m��SC1��m*�;-��:|���f���3���{���3_�����(�/	�r�6�v�:�/[R��^��%Ѯ�p��PX/G
����~��$��aa�Yc����j
�F����TL���ܯ:���PDb���8��(,_:;�Li��ճ�����vo�U ��)O�
�R:{%��1���D��84�C���>_8i7
�oyЈ%�0��v�ܬj�q,��|�u<i7
��!�#L�bJaߏC=*��f��y�]8i�F �Aw肴͇e��|?��u�����G�F��s��C�<`2�H�?h�ܞ���)�?b�/2�s�t�a��](QY����ڍB������Z׭�ՆP�g�S��)�����f�����Xl��s�A:S#�WXWS8h�����q�5�+�?�fUMk�j3�g���taI�:v=�?C���P�o�����UW�����y�?O�nY2f��!���P��S������Z�d>�=���nZ���*១p�n�r�k�4��F��F�KQ���Y�C�
��	� [��!�<#��W/t�`�1��������v�����?ҟ_�2&�����_	�����F�0�3ի)�?j���Yǝ0>(V�g����&��WU��韡p�nfps���]-Ԭ��^�#�e4Q	��?D����Ԝ]X:J�1�����蜅�t+�������(��&L�q������P��ژ�������������i;e�}��F2
�n�
�D*��p�nZq%F�Kgv�)��s*���Kz�������A�QXބ�+���`��_�������Ro���?D���Ъ�#&/Ls尀��L��J�����g�m�?C��(��&���ai��;�MF�Bj�C/	�!
��ѭ�	iU�T�3$:/��:h�������p�n�t+��:�9���s�Iθv��?U�⟡p�n�e���4Dx>j�xv��~U(���p��P�܊� G�_�"����h��$]�"Nڍ�󚚺�m�9��5q^�����B�Wǔ'�Faȋ���\���A���x6�O�'�n�WS8h(�Tݲ��v�J�e+�ś��������O�Nڍ�SGC���	�w%�e��~��+�j��(��>2[���/��~m	��*��+���0���2�1�ZI���;��_��&��N�?D��( ��pR�T�;q�y:�+u��Qռ������I�Q���0�s�l^����Y+��S/��!
��/�C�w�yb��6y��~�Xc(�埡p�n�/�*�@a�٫�T�۲�#�N�>�>i7
Ӈ�K���v?m$F�3j�2C�k�?��Q8h(TP-�Cӟժ�$�B(��5�w�Н�j/������!��S�C����E�OU*��(�o
9$#�	�YuU���Q�n٠쑊Ι?U���p�n��'��N��5k^�l��tEBO�����G�F��G�mm�)@%�����r���So��!
�����p4����2sf�J�����)����#�"$q#�K��j|9�o�nU�y^M��(���lA���
�g$���8�.�������A�C!��>jw���V�9q�)�?�D�Dl�y5��v�@�S��C��2��re䲘�H������(��6�$�
�)N��?��Pv���x5�����7�,u�^�gE@��A	u1u�����G�F��yЍ1��*��T}D�Za�R���G�Fa%g<�d�K�6���	��o��:j(d���>�C� �)�VG�m���쮣v��|�[䖱�W���T}���0�cәu�}�Q�QXބ�8�d���0���
�R�X��SU�!
���V1��9��fJ�Cg�ĝ0Y��#NڍB�&4�S)���/yA���gMG�Fau��J́b�;M��h7�v��E-D�{E��?*��m�u�D}' [5��U	Q��;��9nG�F��[�&C�j4C��Z}�h�Uc���n
�FaU�/�+�t�Sm��#
	�(�Q��q��P@XΩP����z���/Y� L8ꘓn��?j7
���x ���o����p���}�<�z.���΄f�Xw��]��hx/t��W�q��8i(P���v��n9Ug|n�2���l�<ZKq\}g}�n����s�l����@(�B��I�ƫ���ڍ��x�"�
+��4��0A�n�Nf�������в��'�� fѬcK�_���2����>�?i7
�? (�!�H�Q�H+����S��v� �Q��Ԋ��F��@�aW/���|�]8i(��=�11�Jm��S�^(�@a��L�f
'�FaNg< ̵v�J����c�)�R�(�Wυ����14$� B�(O�k��Hjj���W����"g<4�(K��ҭ����B �Ԓ�$Wǔ'�������g5M����>�i�Lk��:��CڍBi/�'#/��|nP��Hqg�]�"Nڍ���K��YV��;��j�a�ّij���n
�����}E�44�N�H⟒�ى�گ��9i7
�^W��L)���şTD��r(�������v�0�7��h?Ώ`'n���b��JK�Ȯ�p��PX�%K��$	`{��ZM�RHwԀWGS'�F�|���z�iY�� ���~�,W�����﬛�����#��Fg��z�p�}��P�gM�V��u:=#I�&4�P#K51\mNڍ�S"K��R�y͒�����Bq�n�/�5vՁ��)67��.UD����G�B�m��E�g�gE�_�~֖.�����v�@�Κ�Ζ���T�c�P��:��{ʣv�0��u�\uXKc*�ߒ�VFZ���������B[;!�h�5t����ԽV,�3�f
'�F��KRd�+W�F�٭���0$�u��t��PH���9$������_lD�C-p�}�n�Q@7�B�`�q��v���
���ܷ�`w�X^Wޥ[��~��������j:񖘋D�TR����,�χ��,ܰ�7W�eu��U�ж�>��.*eӚO˅��|��Q
�a=�]��m+����������S"vR�����OY�DP�s��R	�������0}	X��AʚԢ��~�aܙ�5�2�Y�`?,d�#�:p�1�s�����po�z�v���,ܰ��O��%���N���`�E����ko�?�������eA�� ��Nb��&n2�����}��쇅���2�2{��P3�[��6��3,ܰyJUL0T��I�� �=������W쇅?���Wb�=�Hv�����"�j�o߅vc��jB�ꉵ�YM5�ڠ;v9*y9�v�n,�a�"�(��+�{Ӫ�Ԡ�43>m5ݰ0��#D�:�4;I�����db|z:����~�xǺ�hZ����<���R������X�K�՗(�m;����S��������@��EP�����(�E(���M�C,\��G�	�I1���T��I�R����a7������h�V���`�w�=������]�a?,��	3I�#���gM�{P�t�B�a�i.؍�)�bY��Xh%��pXZ�A
<�Ix�n,�%9OTӺD��_Z���)���>�m~�~X��'-XV�G�_�	�uL�2��x:�x�n,�/�	�0&�V�IǞ}L�r.�w�銞+vca�΀��V��6��t�U�X-��Czz��a�!|�Mq*���+���T���^M�27��B���G+s�u�I�B}S�y�<}�a?,�P|��/��br���C� %�2���֭+vc��H|��f�w���4�EFQ��>y:q�n,p�3z�EȠ���D��,�Ki�^b?    ,� .���c˥��m3����K�-�姻Ǯ؍��#n�N(�a���?��!�3�>�K��X���`���-���#�$�J�~��y�5m/�p�~XX���Ρ5B�-�XX^��3��:��q�n,|��2�^�ȪO�jZ
�	n�'W¿k��?�����>\�b!R��W���/��2ZC���q�~X����`�=��w���g�:�a����vc�|4]J!D���Y��嚘G��i�x�n,�p/�B[D(3e��J�0e؋6��/�}�PxQ���V�`3zj�~��T[��$���	fW��B�C�:O�2��vz3��^K�z,OO6�b?,��]"�{W�$�k���F��8���b7�{E�g��������K�,=��l^f��XX�������`'�!I������i.�	��e�<n%3L:���ȡ*S�fx9�x�n,4�֛���M����hv���Z_��rg�������U�V�j'���#�I���b?,@�Q�$���S�f}���W�2B[�=�m~�n,4o`vH{VŢ��N�X�9��J��@/�_�b7��k��	��k���c�]o�\1�����+��B���&���H�9����06T��47��B�i<Q�9T��XL:f��z�)صy��vcA��lf^#��4~�c�p~J�ar����W쇅R� ���3�����̌b��b:�z�n,t�zx�*u,L����0�[U�(c�}�b7�E�9I	�Ʌ2�"�U%�O�7쇅Z|B��H8�w�5��{���<bz�j�a7z��״�tX��>�$�;��Wl9,��7-]�0��-�B�Y���ca��1�&S�����P���Ơϩ��W�)1�@�`У��t���0�G���]]�Š+6r�d���6��5��a��o�k�g-��f'-�[�z��Nzۛ�a7���B��Ry��P)�g�7�PZ��Ix�n,��~;��V�	����Fh����ԧ#n7쇅��n�E���H�w��>j���3��t5���P�Q�"#g��������UȎ�u����1�&B�=tu9�4�
J�'Ĺ�5��Mݰz�uЉ1�D�7�Y�M��Q�r�-��t'���P���"۶LX3�J?�|/�J�2��_���b7�G�'��b_��D�ڛ�f̌u���4��)]����N;i�df���Ŭ �i�p�n,T_��`�]S�?���WN*��4��kY�؍�>�
{���4q�I��� ���Y��q�~X�}�=g*q�c~/b����^��Cħ��\���$�����4� ?_��"��w�f��X?�1�z����E����%�+������+�����}�aՅ5I;i&?ԩ�z[;D�t���X�>\�eN��X�P���(juG�OoѸb7ě��>Q�����z��qU��z���aae��X+e��_朤��i������a7��;���&hj��>2�ao���g|;�~XP���Q*�R���յ��*q�]5�O�n؍�a�3�bǪ��YK�޴R�F�#\���q�n,�H���B�ݢ,�AR�ŝ����}��!��`
�w	[�V$4]��ݐ���=�W���!�����*9�u>�����0�$�n��l���0�b��r��-;�%�ӒF��r������V�+��6�
v���w{HC�	Ϸ��+vc���Ɣ;�=I�DY0?�Pm�TU���,ܰ�+��X�>@�����~/�2f��i�p�~XH��:�������;�굷�p����b7�w�	N�	zJ6�� Dz�-�����t�n,LoA�~5jgs�-��� �IIe���\�a?,@�Y�=6�O�����5U׬�7U�p�n,|��(�T�jg;	�G+	��W�2�q�b7D���	���v� L�l�?S?�/ǚ��j�iv@}���N�5�-RY���7��BGo/�\I�JA���L�٘�JR������a�į	齭��;�l�T�Q�f�@P��b7�ȍ0e��ђ���^x�ʭ� ��f��X��L(XJ��t�#���h%����*Ogk����|�bz�6aZ�558������z�j�a7��*8K�5���k���a���CTz�}�b7������A�P�����
*B)����b?,���^D�-k�X�'��V�����˕~W��������̔f��V?N��I+�ӹ�+vcaz3���+�lƪW�P�ɣ�q9&��m����ﳞ;�Z��I�H�� @���9nW���>�=mJ�/�ǦK�8Fk��<}n�-D�OɐZ�@�>jUT���{m���q�n,�dBu$�҈����ڪ]fly�>}�.ܰ]�\B���R�A7*~T��[
,$��p�~XP��C�&"
�LX��Mߍ7�S��O[M7��B�V�~T��C1����.7Ĭ4�ٞ��ݰ]�,�1-�҉�|sU�X{�9	���ܰ8��=s)QPB	f/�鷞V5�-��z:�p�n,�+<$
�Z����}��J���=tW���������`�N"_38E"�ق<]�x�~X�{��3�z���p�Q��@ہZ.ܰՋP�����Yz�w� (����)W������(�K���c�������0Zn��l��aa~t�"��+�h��X�@�t�5��?m;ް]���6Q�j{ep�m�� Eº������0|�0�D`�$Ӭ���\���/I���t$�����bv��2�0hV�s-?�L��	�iMy�n,T�[�pA�!�@_X9����$�:��-�vcA��0��!P���^��	P�h�E��7��_sY&-,�b���љ�x��k<��a7�ZxϺ�T�IŨ�$��|�j��+?�����X��C�L�9�~J�b�{�2�|���}�@!��({��"�����S�H�H
����b7�k"	a�ȳJ���G� �^ʊ5��/��X���^s�c��N���w�׎�N|9�v�~X��7�%����e���G�W��VE/�p�n,te�g.)����p��JfIJ��-�+vcA�>�4��>�%Bq~�V�i�����a?,���l��Ò�K=���2a5ɤ�Uw]��,ܰ웫TS��j٬&J����w�c����p�~X��%�B*c��{䙣*�ʘ#�#�W��B��~��r���E x�L��֒ԧ�����]�^h��;���;-�q*�mt~������?v���n#�^���Ǿ�&� ��U^�Hr�n,?:[P��f��3�Q��)�2�{���,ܰ읍9�
��D�6hb!����>��a�D_�8�x&uJ���[��n��PfOO˅vc�zZx��RU�8�R[�k��3��������>O�$�����G���j��h��Gܰj�TK�=���NZ�W9aQ)��c����vc��@�H\ke�7|jܨ��ީ�ϵ�羜��b7�הZ�eϺ\_��Wm�{	�R�5<q�a?, �Z���W+���G?.9HܥA����vc����ڍa�ɼ)�^�XMLM��ӱ�vca�^�.�V��2��/�TotO��F�i{������ؒESTӤ#�3[����wN�en؍��� C�GZm������UD�i�x�n,,/<&�ZC*��َ4���=�"T����5��a������2R��#Z�M���Z�����7�����"L�2�D�XS���:�PK�i.�=���[���.�YMM|�4q�$˂�u������!�%�\zm�3�z�p#lo��I��Oy�n,_�0DHMJekt;ImI�N[D�\0�\�x�~X���5�M��|�.�{���^G��_����~�q��eI���8��9��#��]"W����1h�Z�\Kߎ��>���!�ў��v�~X��&�B��o�q����r�jh�\~�n,?�oB�8�L���F�T�%!cJoײܰf��c�a��f�U��X�{�a�%�=��i.؍���r붙(��E�D�;]�@-����7��w���ci8A�����b^���t��aaEoZen��.��
`��    ��y�PS�EOK�vc��Q�f�x��YM�c�ϐB��Ru��}�n,�o�X<�����*�Vk3� #�).��p�~X��<e�hOrj�w��f���n����q�n,|�);�X�r�
`����P^�J��t���X`_�Q0��B� ��J�_����ꦯ�u��f���#�Nq�,���#s��v���{�؍��#�Q��48��S� >��
��,�.�˞����>ִ�n���J��,-4oT�ݫ\ShB/߅+��B���3H�Uƴ���|�&�|�28��g}�n,ԯY�{[_J\�3����)1��/R{:7u�n,�W�j^��Pǜl�m��7W��)IP���|��a!E�H�`�,M.�8>�>��x>�M]��+��O!g�lKgK�V	�(��	/��؍�-f*8ԫn�E�Nj�d��ژ��l��a�G�Rr�f�f'��D�p�����a7��ФW:�v�$ ��!ܻ��������a7��� ��g������X{A*Oﳾb?,�ૻv�X�֌&UY��H�KF�ї�W��B����4�="�x�-g�o{���I���}�n,�ߴİ
�Q�݅�|�T����߶n��ó&I+�(���.,ߍG@�J��?�)o؍��8Tt�,�uf/���{yay�Eܰ�1\�G�Л,;�}U�`ɐq ��,\�vr�'�p��#c;�>���1_[q�������X�V��	yR
f;��7Q,�5U9���+��F߀;02�$��$~`G��jk)�]�x�n,4_�eH�e�O��կ��ob�%{4��,ܰ���2Jl �I�mf�[%�jS���w���@9}l`+0i��iJ���6���z}:�v�n,t?2K	��������C%���OW�\��,q�QV6�H�7W܃�T����a?,��Ga�n�I8�߰�В��XPrn�4����+vc�_�Ēe/��̓n��y��9�Qҟ�7�Ƃxӊ��vߐM6lm���\�Je�m>e�a?,��Gg7�������s��Z5u��:+�47������cC;���~CPB��==�����*}V��.��4��$�MFV�*���,\���� uO)���4�~vjS�������a7�g#{%���l/��B `$µ�9O�p�~X��@F�@ +���]�"����z�OGYn؍��nM	�6�TlrSR|#V�تʙ�Y�a7X�NB	;O��z�vR�� q$)����aaF�t��@Ǚsi��aZ�T���4����Ga�!-�`qǙ�(�{�|�Y�ӑ�vca}�0.�$BR��,��}�Tˣ�]7����o��c��
+�G���NZ�_��qt�)����vc���HK���㗡[���S!� E��o؍������n�U���/,��|"���W�?q�a?,����t!�T��e٫$>�F���������]��ь-#�V�"�0n��~��s��kYn؍�u����r��e|4�J�v�����W웅����?��!՜���_��h�Ӧ��eMy�n,4?4:�N�Rhhy��cq!�AUѪ��4���������q�v��G,U�L���\�b?,D��w̃�X�t*�U����aAq�𲎸b7>� �f��S�X?��a=��Y�`7��W�k
���B��@X�sT93���b?,��|J�jk��t��r�ER'���뚮؍��5eR�Jj�d'u�m*
8�|^f��� ѷ J�=����c�>7���f�i.؍��L�V�:\mL{�}�<	�,0>�Y_��Kǀc�x���;t?4�K�iɂ�#�W쇅�|-��9T�腈��d�#����r|9}�n,���-�XV�,O�s���½N�s&����b7�_����n�I}D;�����Xħ�/\�J�uM�i�2����;V멂�s�J���p�n,��N3�P��A'7�K�}h�n�/�<w�b7�oC����P[����}��E�SE������a�&�H
���:�&���& K]�Uc��m�vc}�T�cytl?Ϻ��r�Oo`�b7f�S�$�մvX��r�VR�*!�����n��|��0.�{�s�\���3�i���Z�b7ȧ�V%
���^��A�(	0�^&|��vca��VM s�%��֑�di�@+����;ްH�K�XC��IG���D8޳�:��t�����4t��E&�ً��{����d>=���X�����UO�����7�-�UZz_���n�m�=t*W�M�i���Y}Sy!K������a�'���\X�r�-+�d|L~baE�k|�v�a7�w 5� ��5ƽ�c�
��H���0�Qq%F}O8LG��m�,1q���������|>bw��!qZܑ?Vy���J=ЗY�a7�笫ʍ��[V��W���"v�>��\�x�n,��.L��V�=���p���=J��N�+���uL�FQ�So��#��"�o�6pz�Eܰ�[�0��֋�َ�O��pU�H)��l�+vc�cxA(T�H�����)q�'�-n�j@|�ٳ/C�}E�?R��g�ŐZ��vc�����)QЪ�*UY��5Cը��Pz���aa�W$�TK,��(�
>��1S��B}:Cw�n,�/�R�j�l��Q9���Ү�}ZSް˯])��!}�7�F��zI+�m��5��aA�}�Ƣ�e���,�.��2a�}IQk<>���a7���������|J�^�(U��m|<�a|�n,,�GT�rN�1);���N�1�k�1���ްo8d�~3�	�>Dd����/�1�j�0��f�r-����?�J+kT�h'��Ze��e�[O�p�~XPD��V�R07՘���O`���5�A��y�+vc��>k�L{�l5񼇄{+T���ZXO߅vc���4'u%��iJ����V��jbgn/�+vcA|�#0@iV���vaҘ�����a!��q[���M0SUᓙ��C�U��ˑ�+vca��T���@
\�{���c�hSp�lA_� ����Rj8;�X��m�H�������@~� 	6�!y��Y3T�T��Ag;����x�n,|,� Kǡv�iJ`?�o�3��F��w�����{�"A��h�Xܑs��if���_���@޳��s���tD��;ͨv���4��Ns�n,����/��7A���}�v�&M�.tx����B�YO̴g5�F:Eߙ�7c�ӹ��i?��X ofg�1Q�G�a'UߓX ���tws?������	�Ʋ�$h�)� ߽��h��0�޺u�~X�0��ĳ�`Sۺ��c�����<��O[�7���"�*���2d�Iկ�jufVǫħ��vc�cFO�2Ս�\a�I�3�z�����'�^��#O��EYML2��g<��&��XO{S7��B����7��Y�X}�Ѧ*͚{|;�t�n,,_�wF��B{槝4��u����X��y�+����N�����g5Q���Ġ������?(���4��X���)�T�:�_���k��G{!�6����M�,�����_I��R��\�[m��yaZ#�W�����%�y�xW���:�r���C��3�OensL�m�sҚ'���J	�I%(>L����N�۟>8��'����ꘂ���W)=L��&C<��!�7HS(?Fw�M�2�=_&��Hh�}4�&�K:����Q^�aE`58��]��	1��
ƴF����I|�0��pX-���D�$��H�^z&�����J<'E�_���vs����?�/�p�n$0;�ؙd��n�NjՉ؂XR���$\��m^�����hQBB;i�c*cX�F��>}.Ѝ�Z?T�k{\���0(�1@m�h<L���0�v Ʃv����#��c*@k���vm=I��!bu#s)��*v���\��Y^6��Ѝ���,�@p,#�w�E%������p�n$�宋�������ԳS��Mz���4	臄�����V�9'��I2���jq,��~�z��t#��.]F�)0%u��GY��
j[��VB~��t#��� ������r����kV�   �h�a�
��P���*jD�؇=�,�N�=ip�_�nЍ�>� �̾@2��~��8�D���*��ye/�p�n$��>�{�L��k�IS�S���i����CBM�e��ݤK�i;I��<B�B�G��Ѝ�)T��bm=�i�Z�Ǜi1��g/�nЍ�1���@Б!�NvRG�T�Pm��������}M�BNAp��l��S5G�M���I�@7�:����K�LƟ�%8�2�=F}-��I�A?$P�$LԿ.�mO���噂�R�%��y��t#�#չH�����&P��Ք�"v�ٞ�7�F�������o�%vRO��(1���L��!�EqLUH�����f��l�c�Q���M�@7���47}%*Z4�>rY�3�=L��4�En�	�d9�y酩;9��$�'5=%�)����t#�IغԐ��Ʉ����&s�k���|��t#ax�y5���z[���ݝ���i�p�~H�}HgɽB��dB�g������	�Fz/�ˌ���5��Y��Y#t�a���t#�Áj <�܍S���^ppMU�Ǆ^&���08��L{�+����1Ġg%|�9ܠ	X�L��a������I��v/���>L���0���f�ԥ,+��ѓc�p���/{�7臄�S!FNaO6�"�d_�#{�����T�I.Ѝ��zF;�"m�n�Z���aWJs�(�e;��HX���3A�qK�����p�)��ӂ�����ON(Ozh�������Z�C�������0|#઱����"o[3C- Y�����C���CcR�ɃUM��$��خ/	�̒��2��H_ش���͋���);��b������&�����p�z��;���u��K��^��v���0|��Zk�2�GB����=�M0�\�y�~H��K�����4�N�w���@�o���z؁�B7|}Y��́ҋ3�uA.��vh�e.Ѝ��>*����ڟ��|���J�9'�,n�	)���=��
|NJq�h,c�<��؇3PW�FB�Le H%d��Їgd�_�T6��Ѝ���u5dw
T{ize\Y2V��p�~H�⫻�ġ7��TN�Qe���^V�Bw�\�	ݫ�$q�X�q��y���A���4	�F�x� ��5~7a�7�P�%�/w�]��G�1G�e�lŜ��W!idl���p�n$0�\U��$��?e'����!5��#/�p�~H(�~T�n�;U�vҊN�$^YO\ꋽL��������؉�b      �   �  x�͜On�8��y��}�I$E��2RN����Uy�ݓ2l$� VJ�g�����s	�8ߠ����fh|�,Q��ޒ���jy*#�B����ӛ7�n��c�Yכp�XzJ�C�� o�}��P#�X����R��t����Q��`��Wo��\J�7_t_>FnJ�7C%S���A_��;-I�t*`������КN4���r9:yCG�E-d������B�$jW�3�tŠ���txM�Z H)i��|]�N���ąN��r%�x3FE˩D��X��L/t�CMR" I>����7�{)I�8:�yt{_Ӊ��;�⮧ϧ���HsY���,W�-��etH2ނYp
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