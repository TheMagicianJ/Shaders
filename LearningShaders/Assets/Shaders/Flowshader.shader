Shader "Unlit/Flowshader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FlowTexture("Flow Texture", 2D) = "white" {}
        _UVTexture("UV Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _FlowTexture;
            float4 _FlowTexture_ST;
            sampler2D _UVTexture;
            float4 _UVTexture_ST;

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _FlowTexture);
                o.uv.zw = TRANSFORM_TEX(v.uv, _UVTexture);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 col = tex2D(_MainTex, i.uv);

                fixed4 UV = tex2D(_UVTexture,i.uv.zw);
                return col;
            }
            ENDCG
        }
    }
}
