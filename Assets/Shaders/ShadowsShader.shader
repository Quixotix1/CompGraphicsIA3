Shader "Custom/ShadowsShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                half3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 shadowPos : TEXCOORD3;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.worldNormal = normalize(TransformObjectToWorldNormal(IN.normalOS));
                float3 worldPos = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.worldPos = worldPos;
                OUT.shadowPos = TransformWorldToShadowCoord(worldPos);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;

                Light mainLight = GetMainLight();
                half3 lightDirWS = normalize(mainLight.direction);

                half lightNormal = max(0.0, dot(IN.worldNormal, lightDirWS));
                half3 diffuseLight = lightNormal * mainLight.color;

                half shadowAttenuation = MainLightRealtimeShadow(IN.shadowPos);

                color.rgb *= diffuseLight * shadowAttenuation;

                return color;
            }
            ENDHLSL
        }
    }
}
