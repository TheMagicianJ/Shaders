Shader "Intro/First Shader"
{
    Properties
    {
        _Color("Test Color", color) = (0,1,1,0)
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

            #include "UnityCG.cginc"

            fixed4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;

            };

            struct v2f // Vertext to Fragment
            {
                float4 vertex : SV_POSITION;

            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 col = _Color;
                return col;
            }
            ENDCG
        }
    }
}
