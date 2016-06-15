package com.malalaoshi.android.adapter;

import android.content.Context;
import android.net.Uri;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;
import com.facebook.drawee.view.SimpleDraweeView;
import com.malalaoshi.android.R;
import com.malalaoshi.android.core.base.MalaBaseAdapter;
import com.malalaoshi.android.core.utils.EmptyUtils;
import com.malalaoshi.android.entity.School;
import com.malalaoshi.android.util.LocationUtil;

import java.util.List;

/**
 * Created by kang on 16/1/5.
 */
public class SchoolAdapter extends MalaBaseAdapter<School> {

    public SchoolAdapter(Context context) {
        super(context);
    }

    @Override
    protected View createView(int position, ViewGroup parent) {
        View convertView = View.inflate(context, R.layout.school_list_item, null);
        ViewHolder viewHolder = new ViewHolder();
        viewHolder.ivSchoolPic = (SimpleDraweeView)convertView.findViewById(R.id.iv_school_pic);
        viewHolder.tvSchoolName = (TextView)convertView.findViewById(R.id.tv_school_name);
        viewHolder.tvSchoolAddress = (TextView)convertView.findViewById(R.id.tv_school_address);
        viewHolder.tvSchoolDistance = (TextView)convertView.findViewById(R.id.tv_school_distance);
        convertView.setTag(viewHolder);
        return convertView;
    }

    @Override
    protected void fillView(int position, View convertView, School data) {
        ViewHolder viewHolder = (ViewHolder) convertView.getTag();
        String imgUrl = data.getThumbnail();
        if (!EmptyUtils.isEmpty(imgUrl)){
            viewHolder.ivSchoolPic.setImageURI(Uri.parse(imgUrl));
        }
        viewHolder.tvSchoolName.setText(data.getName());
        viewHolder.tvSchoolAddress.setText(data.getAddress());
        Double distance = data.getDistance();
        if (distance!=null&&distance>=0.0D){
            String dis = LocationUtil.formatDistance(distance);
            viewHolder.tvSchoolDistance.setText(dis);
        }
    }

    class ViewHolder {
        public SimpleDraweeView ivSchoolPic;
        public TextView tvSchoolName;
        public TextView tvSchoolAddress;
        public TextView tvSchoolDistance;
    }
}
