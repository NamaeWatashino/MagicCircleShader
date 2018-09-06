Shader "Custom/MagicCircleShader" {
	Properties {
	    _StencilNo ("Stencil No", int) = 1
	    [Enum(OFF,0,FRONT,1,BACK,2)] _CullMode("Cull Mode", int) = 2
		_MainTex ("Texture", 2D) = "white" {}
	    _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		_Color("Color", Color) = (1,1,1,1)
		_RedSpeed ("Rotation speed Red", float) = -0.3
		_GreenSpeed ("Rotation speed green", float) = 1.0
		_BlueSpeed ("Rotation speed Blue", float) = -0.1
	}
	SubShader {
	    Tags {
			"Queue"="AlphaTest-1"
			"IgnoreProjector"="True"
			"RenderType"="TransparentCutout"
		}
	    LOD 100
	
	    Lighting Off

		Cull[_CullMode]
		
		Stencil {
	        Ref[_StencilNo]
			Comp Always
	        Pass Replace
	        Fail Replace
	    }

	    Pass {
			
	        CGPROGRAM
	            #pragma vertex vert
	            #pragma fragment frag
	            #pragma target 2.0
	            
	            #include "UnityCG.cginc"

				struct appdata_t
				{
					float4 vertex   : POSITION;
				    float3 normal   : NORMAL;
				    float4 uv		: TEXCOORD0;
					float4 color	: COLOR;
				};

	            struct v2f {
	                float4 vertex	: SV_POSITION;
	                float2 uv		: TEXCOORD0;
					float4 color	: COLOR;
	                UNITY_VERTEX_OUTPUT_STEREO
	            };
	
	            sampler2D _MainTex;
				fixed4 _Color;
	            float4 _MainTex_ST;
	            fixed _Cutoff;

				float _RedSpeed;
				float _GreenSpeed;
				float _BlueSpeed;
	
	            v2f vert (appdata_t v)
	            {
					v2f o;
	                UNITY_SETUP_INSTANCE_ID(v);
	                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
	                o.vertex = UnityObjectToClipPos(v.vertex);
	                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	                return o;
	            }
	            
	            fixed4 frag (v2f i) : SV_Target
	            {
					float sinX;
					float cosX;
					float sinY;
					float2x2 rotationMatrix;

					float4 rotationColor = tex2D(_MainTex, i.uv);
					
					if (rotationColor.r >= 0.5) {
						float _RotationSpeedRed = rotationColor.r * _RedSpeed;
						
						sinX = sin ( _RotationSpeedRed * _Time.z );
						cosX = cos ( _RotationSpeedRed * _Time.z );
						sinY = sin ( _RotationSpeedRed * _Time.z );
						rotationMatrix = float2x2( cosX, -sinX, sinY, cosX);
						i.uv.xy -= 0.5;
						i.uv.xy = mul ( i.uv.xy, rotationMatrix );
						i.uv.xy += 0.5;
					}
					
					else if (rotationColor.g >= 0.5) {
						float _RotationSpeedGreen = rotationColor.g * _GreenSpeed;

						sinX = sin ( _RotationSpeedGreen * _Time.z );
						cosX = cos ( _RotationSpeedGreen * _Time.z );
						sinY = sin ( _RotationSpeedGreen * _Time.z );
						rotationMatrix = float2x2( cosX, -sinX, sinY, cosX);
						i.uv.xy -= 0.5;
						i.uv.xy = mul ( i.uv.xy, rotationMatrix );
						i.uv.xy += 0.5;
					}

					else if (rotationColor.b >= 0.5) {
						float _RotationSpeedBlue = rotationColor.b * _BlueSpeed;

						sinX = sin ( _RotationSpeedBlue * _Time.z );
						cosX = cos ( _RotationSpeedBlue * _Time.z );
						sinY = sin ( _RotationSpeedBlue * _Time.z );
						rotationMatrix = float2x2( cosX, -sinX, sinY, cosX);
						i.uv.xy -= 0.5;
						i.uv.xy = mul ( i.uv.xy, rotationMatrix );
						i.uv.xy += 0.5;
					}

	                half4 col = tex2D(_MainTex, i.uv);
					col.rgb = _Color.rgb;
	                clip(col.a - _Cutoff);

					if(i.uv.x < 0.0) clip(-1.0);
					if(i.uv.x > 1.0) clip(-1.0);
					if(i.uv.y < 0.0) clip(-1.0);
					if(i.uv.y > 1.0) clip(-1.0);
	                return col;
	            }
	        ENDCG
	    }
	}	
}