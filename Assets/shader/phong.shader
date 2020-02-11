Shader "Unlit/phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		//アンビエント光反射量
		_Ambient("Ambient", Range(0,1)) = 0
		//スペキュラ色
		_SpecColor("Specular Color", Color) = (1,1,1,1)

    }
    SubShader
    {

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            //ライトカラー
            float4 _LightColor0;
            //アンビエント光反射量
            float _Ambient;
            //スペキュラ色
            float4 _SpecColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                //ワールド空間の法線ベクトル
                float3 worldNormal : TEXCOORD1;
                //ワールド空間の頂点座標
                float3 worldPos : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                
                //法線ベクトルをワールド空間座標に変換
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldNormal = worldNormal;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //法線ベクトル
                float3 normal = normalize(i.worldNormal);
                //光源方向ベクトル
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float NdotL = dot(normal, lightDir);
                
                //視点方向ベクトル
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                //法線 - 視点の角度量
                float NdotV = dot(normal, viewDir);

                //テクスチャマップからカラー値をサンプリング
                float4 tex = tex2D(_MainTex, i.uv);

                //拡散色の決定
                float diffusePower = max(0, NdotL);
                float4 diffuse = diffusePower * tex * _LightColor0;

                //フォンによるスペキュラ近似式①
                float3 R = -1 * lightDir + 2.0 * NdotL * normal;

                //フォンによるスペキュラ近似式②
                float LdotR = dot(viewDir, R);
                float3 specularPower = pow(max(0, LdotR), 10.0);

                //反射色の決定
                float4 specular = float4(specularPower, 1.0) * _SpecColor * _LightColor0;

                //拡散色と反射色を合算
                fixed4 color = diffuse + specular;

                return color;
            }
            ENDCG
        }
    }
}
